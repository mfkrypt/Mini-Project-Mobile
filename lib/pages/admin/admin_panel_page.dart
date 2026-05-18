import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_booth_map.dart';
import '../../models/admin_booth_type.dart';
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
  List<AdminBoothType> boothTypes = [];
  List<AdminBoothMap> boothMaps = [];
  int? selectedBoothTypeId;

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
    final plan = await db.fetchLatestFloorPlan();
    final types = await db.fetchBoothTypes();
    List<AdminBoothMap> maps = [];
    if (plan != null) {
      maps = await db.fetchBoothMaps(plan.id!);
    }
    if (!mounted) {
      return;
    }
    setState(() {
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
      final plan = AdminFloorPlan(
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
    await db.insertBoothMap(
      AdminBoothMap(
        boothId: boothId,
        boothTypeId: selectedBoothTypeId!,
        floorPlanId: floorPlan!.id!,
        x: 0,
        y: 0,
        attributes: 'manual',
      ),
    );
    boothIdController.clear();
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          color: const Color(0xffd9d9d9),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: const Text(
            'Admin Panel',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
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
    return Image.asset(
      floorPlan!.imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, _, __) {
        return const Center(child: Text('Map image not found'));
      },
    );
  }
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
