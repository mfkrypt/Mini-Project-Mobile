import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_booth_map.dart';
import '../../models/admin_booth_type.dart';
import '../../models/admin_event.dart';
import '../../models/admin_floor_plan.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final boothIdController = TextEditingController();
  final db = AdminDatabase.instance;
  AdminFloorPlan? floorPlan;
  List<AdminEvent> events = [];
  List<AdminBoothType> boothTypes = [];
  List<AdminBoothMap> boothMaps = [];
  int? selectedBoothTypeId;
  int? selectedEventId;
  int selectedSizeIndex = 0;
  double? pendingX;
  double? pendingY;

  static const _boothSizes = [
    _BoothSize(label: 'Standard 10x10', width: 0.12, height: 0.12),
    _BoothSize(label: 'Corner 10x15', width: 0.12, height: 0.18),
    _BoothSize(label: 'Premium 20x20', width: 0.2, height: 0.2),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    boothIdController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final loadedEvents = await db.fetchEvents();
    final eventId = selectedEventId ??
        (loadedEvents.isNotEmpty ? loadedEvents.first.id : null);
    AdminFloorPlan? plan;
    List<AdminBoothType> types = [];
    List<AdminBoothMap> maps = [];
    if (eventId != null) {
      plan = await db.fetchFloorPlanForEvent(eventId);
      types = await db.fetchBoothTypesForEvent(eventId);
      if (plan != null) {
        maps = await db.fetchBoothMaps(plan.id!);
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      events = loadedEvents;
      selectedEventId = eventId;
      floorPlan = plan;
      boothTypes = types;
      boothMaps = maps;
      selectedBoothTypeId = types.isNotEmpty ? types.first.id : null;
    });
  }

  Future<void> _showUploadDialog() async {
    final titleController = TextEditingController(text: 'Floor Plan');
    final pathController = TextEditingController(text: 'lib/image/Easy_book_logo.png');

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Upload Map'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: pathController,
                decoration: const InputDecoration(labelText: 'Image Path'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (shouldSave == true) {
      if (selectedEventId == null) {
        return;
      }
      final plan = AdminFloorPlan(
        eventId: selectedEventId!,
        title: titleController.text.trim().isEmpty
            ? 'Floor Plan'
            : titleController.text.trim(),
        imagePath: pathController.text.trim().isEmpty
            ? 'lib/image/Easy_book_logo.png'
            : pathController.text.trim(),
      );
      await db.insertFloorPlan(plan);
      await _loadData();
    }
  }

  Future<void> _saveBoothAssignment() async {
    if (floorPlan == null || selectedBoothTypeId == null) {
      return;
    }
    final boothId = boothIdController.text.trim();
    if (boothId.isEmpty) {
      return;
    }
    if (pendingX == null || pendingY == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tap the map to place the booth.')),
      );
      return;
    }
    final size = _boothSizes[selectedSizeIndex];
    await db.insertBoothMap(
      AdminBoothMap(
        boothId: boothId,
        boothTypeId: selectedBoothTypeId!,
        floorPlanId: floorPlan!.id!,
        x: pendingX!,
        y: pendingY!,
        width: size.width,
        height: size.height,
        status: 'available',
        attributes: 'manual',
      ),
    );
    boothIdController.clear();
    pendingX = null;
    pendingY = null;
    await _loadData();
  }

  void _handleMapTap(Offset localPosition, Size size) {
    final selectedSize = _boothSizes[selectedSizeIndex];
    final relativeX = localPosition.dx / size.width;
    final relativeY = localPosition.dy / size.height;
    final left = (relativeX - selectedSize.width / 2)
        .clamp(0.0, 1.0 - selectedSize.width);
    final top = (relativeY - selectedSize.height / 2)
        .clamp(0.0, 1.0 - selectedSize.height);
    setState(() {
      pendingX = left;
      pendingY = top;
    });
  }

  Future<void> _resetDatabase() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Database'),
          content: const Text(
            'This will remove all data except built-in users. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      await db.resetAllExceptUsers();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database reset.')),
      );
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          color: const Color(0xffd9d9d9),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            children: [
              const Text(
                'Admin Panel',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                onPressed: _resetDatabase,
                icon: const Icon(Icons.restart_alt),
                tooltip: 'Reset database',
              ),
              if (events.isNotEmpty)
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedEventId,
                    items: events
                        .map(
                          (event) => DropdownMenuItem(
                            value: event.id,
                            child: Text(event.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedEventId = value);
                        _loadData();
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 240,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: _buildFloorPlanPreview(),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: const Color(0xffd9d9d9),
                      child: const Text(
                        'Floor Plan',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: _ActionChip(
                        label: 'Upload Map',
                        icon: Icons.upload,
                        onTap: _showUploadDialog,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Booth Size',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xffd9d9d9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedSizeIndex,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: List.generate(
                            _boothSizes.length,
                            (index) => DropdownMenuItem(
                              value: index,
                              child: Text(_boothSizes[index].label),
                            ),
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedSizeIndex = value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tap on the map to place the booth location.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Assign Booth ID',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xffd9d9d9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: boothIdController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'C-1',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Booth Type',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xffd9d9d9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedBoothTypeId,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: boothTypes
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type.id,
                                  child: Text(type.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedBoothTypeId = value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _ActionChip(
                        label: 'Save Map',
                        icon: Icons.save,
                        onTap: _saveBoothAssignment,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Text(
            'Booth Assignment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
          child: boothMaps.isEmpty
              ? const Text('No booths assigned yet.')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: boothMaps
                      .map(
                        (map) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffe8e8e8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            map.boothId,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildFloorPlanPreview() {
    if (floorPlan == null) {
      return const Center(child: Text('No map uploaded'));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onTapDown: (details) => _handleMapTap(details.localPosition, size),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  floorPlan!.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) {
                    return const Center(child: Text('Map image not found'));
                  },
                ),
              ),
              for (final booth in boothMaps)
                Positioned(
                  left: booth.x * size.width,
                  top: booth.y * size.height,
                  width: booth.width * size.width,
                  height: booth.height * size.height,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xffa7c7e7).withValues(alpha: 0.7),
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      booth.boothId,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (pendingX != null && pendingY != null)
                Positioned(
                  left: pendingX! * size.width,
                  top: pendingY! * size.height,
                  width: _boothSizes[selectedSizeIndex].width * size.width,
                  height: _boothSizes[selectedSizeIndex].height * size.height,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff55bd69).withValues(alpha: 0.5),
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BoothSize {
  const _BoothSize({required this.label, required this.width, required this.height});

  final String label;
  final double width;
  final double height;
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xffd9d9d9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 18),
          ],
        ),
      ),
    );
  }
}
