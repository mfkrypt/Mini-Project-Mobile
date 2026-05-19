import 'package:flutter/material.dart';

import '../../data/admin_database.dart';
import '../../models/admin_user.dart';
import '../../widgets/admin_table.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final db = AdminDatabase.instance;
  late Future<List<AdminUser>> usersFuture;
  String query = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    usersFuture = db.fetchUsers();
  }

  Future<void> _showUserDialog({AdminUser? user}) async {
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final roleController = TextEditingController(text: user?.role ?? 'User');
    final passwordController = TextEditingController();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? 'Add User' : 'Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText:
                      user == null ? 'Password' : 'New Password (optional)',
                ),
                obscureText: true,
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
      final password = passwordController.text.trim();
      if (user == null && password.isEmpty) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password is required.')),
        );
        return;
      }
      final passwordHash =
          password.isEmpty ? null : db.hashPassword(password);
      await db.upsertUser(
        AdminUser(
          id: user?.id,
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          role: roleController.text.trim(),
        ),
        passwordHash: passwordHash,
      );
      setState(_reload);
    }
  }

  Future<void> _deleteUser(AdminUser user) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text('Remove ${user.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && user.id != null) {
      await db.deleteUser(user.id!);
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
      children: [
        const Text(
          'User Management',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xffd9d9d9),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Search by name, email, or role',
            ),
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<AdminUser>>(
          future: usersFuture,
          builder: (context, snapshot) {
            final users = snapshot.data ?? [];
            final filtered = users.where((user) {
              final target =
                  '${user.name} ${user.email} ${user.role}'.toLowerCase();
              return target.contains(query.toLowerCase());
            }).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminTable(
                  headers: const ['ID', 'Name', 'Role', 'Email', 'Actions'],
                  columnWidths: const {
                    0: FixedColumnWidth(34),
                    1: FixedColumnWidth(70),
                    2: FixedColumnWidth(70),
                    3: FlexColumnWidth(),
                    4: FixedColumnWidth(70),
                  },
                  rows: filtered
                      .map(
                        (user) => [
                          Text('${user.id ?? ''}'),
                          Text(user.name),
                          Text(user.role),
                          Text(user.email, overflow: TextOverflow.ellipsis),
                          Row(
                            children: [
                              AdminActionIcon(
                                icon: Icons.edit,
                                onPressed: () => _showUserDialog(user: user),
                              ),
                              const SizedBox(width: 8),
                              AdminActionIcon(
                                icon: Icons.delete_outline,
                                onPressed: () => _deleteUser(user),
                              ),
                            ],
                          ),
                        ],
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => _showUserDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add User'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xffd9d9d9),
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
