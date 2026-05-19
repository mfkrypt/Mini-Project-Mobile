import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_booth_map.dart';
import '../../models/admin_booth_type.dart';
import '../../models/admin_event.dart';
import '../../models/admin_floor_plan.dart';
import '../../utils/asset_path.dart';

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
    final hasSelectedEvent = loadedEvents.any(
      (event) => event.id == selectedEventId,
    );
    final eventId = hasSelectedEvent
        ? selectedEventId
        : (loadedEvents.isNotEmpty ? loadedEvents.first.id : null);
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
      selectedBoothTypeId = types.any((type) => type.id == selectedBoothTypeId)
          ? selectedBoothTypeId
          : (types.isNotEmpty ? types.first.id : null);
      pendingX = null;
      pendingY = null;
    });
  }

  Future<void> _showUploadDialog() async {
    final titleController = TextEditingController(text: 'Floor Plan');
    final pathController = TextEditingController(
      text: 'lib/image/Easy_book_logo.png',
    );

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
        imagePath: normalizeFloorPlanAssetPath(pathController.text),
      );
      await db.insertFloorPlan(plan);
      await _loadData();
    }
  }

  Future<void> _saveBoothAssignment() async {
    if (floorPlan == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload a floor plan first.')),
      );
      return;
    }
    if (selectedBoothTypeId == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a booth type first.')),
      );
      return;
    }
    final boothId = boothIdController.text.trim();
    if (boothId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a booth ID.')));
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

  Future<void> _showBoothTypeDialog() async {
    if (selectedEventId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Create an event first.')));
      return;
    }

    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final countController = TextEditingController();
    bool available = true;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Booth Type'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Booth Type'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: countController,
                    decoration: const InputDecoration(labelText: 'Count'),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      const Text('Available'),
                      const Spacer(),
                      Switch(
                        value: available,
                        onChanged: (value) {
                          setDialogState(() => available = value);
                        },
                      ),
                    ],
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
      },
    );

    if (shouldSave == true) {
      final name = nameController.text.trim();
      if (name.isEmpty) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booth type name is required.')),
        );
        return;
      }

      await db.upsertBoothType(
        AdminBoothType(
          eventId: selectedEventId!,
          name: name,
          price: double.tryParse(priceController.text.trim()) ?? 0,
          available: available,
          count: int.tryParse(countController.text.trim()) ?? 0,
        ),
      );
      await _loadData();
    }
  }

  void _handleMapTap(Offset localPosition, Size size) {
    final selectedSize = _boothSizes[selectedSizeIndex];
    final relativeX = localPosition.dx / size.width;
    final relativeY = localPosition.dy / size.height;
    final left = (relativeX - selectedSize.width / 2).clamp(
      0.0,
      1.0 - selectedSize.width,
    );
    final top = (relativeY - selectedSize.height / 2).clamp(
      0.0,
      1.0 - selectedSize.height,
    );
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
          title: const Text('Clear Events and Users'),
          content: const Text(
            'This will remove all events, booths, applications, reservations, and every user credential except the admin account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      await db.clearEventsAndUsersExceptAdmin();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Events and users cleared.')),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'Admin Panel',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _resetDatabase,
                  icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                  label: const Text('Clear Events and Users'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Booth Type',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showBoothTypeDialog,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add'),
                        ),
                      ],
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
                          hint: const Text('No booth types'),
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
                  normalizeFloorPlanAssetPath(floorPlan!.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
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
  const _BoothSize({
    required this.label,
    required this.width,
    required this.height,
  });

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
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Icon(icon, size: 18),
          ],
        ),
      ),
    );
  }
}
