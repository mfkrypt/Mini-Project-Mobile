import 'package:flutter/material.dart';

import '../widgets/app_name.dart';
import '../widgets/logo_mark.dart';
import '../widgets/phone_frame.dart';
import '../widgets/primary_button.dart';
import '../widgets/role_field.dart';
import '../data/admin_database.dart';
import '../models/admin_user.dart';
import '../utils/route_names.dart';
import 'admin/admin_shell_page.dart';
import 'exhibitor/exhibitor_shell_page.dart';
import 'organizer/organizer_shell_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String role = 'Role (Dropdown)';
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhoneFrame(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 28),
          children: [
            const SizedBox(height: 36),
            const Center(child: LogoMark(size: 66)),
            const SizedBox(height: 14),
            const Center(child: AppName()),
            const SizedBox(height: 30),
            const Text(
              'Register',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Container(
              height: 52,
              color: const Color(0xffd9d9d9),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'Username',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              height: 52,
              color: const Color(0xffd9d9d9),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.mail_outline),
                  hintText: 'Email',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              height: 52,
              color: const Color(0xffd9d9d9),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  hintText: 'Password',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              height: 52,
              color: const Color(0xffd9d9d9),
              child: TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  hintText: 'Confirm Password',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 18),
            RoleField(
              value: role,
              onChanged: (value) => setState(() => role = value),
              includeAdmin: false,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 72),
              child: PrimaryButton(
                label: 'Sign Up',
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();
                  final confirm = confirmController.text.trim();
                  if (name.isEmpty || email.isEmpty || password.isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Fill in all fields.')),
                    );
                    return;
                  }
                  if (password != confirm) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Passwords do not match.')),
                    );
                    return;
                  }
                  if (role == 'Role (Dropdown)' || role == 'Administrator') {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Select Organizer or Exhibitor.'),
                      ),
                    );
                    return;
                  }

                  final db = AdminDatabase.instance;
                  final exists = await db.userExists(email: email, name: name);
                  if (exists) {
                    if (!mounted) {
                      return;
                    }
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Account already exists.')),
                    );
                    return;
                  }
                  final normalizedRole = role == 'Administrator'
                      ? 'Admin'
                      : role;
                  await db.upsertUser(
                    AdminUser(name: name, email: email, role: normalizedRole),
                    passwordHash: db.hashPassword(password),
                  );
                  final user = await db.authenticateUser(
                    identifier: email,
                    password: password,
                    role: normalizedRole,
                  );
                  if (!mounted || user == null) {
                    return;
                  }
                  final isExhibitor = role == 'Exhibitor';
                  final destination = role == 'Administrator'
                      ? const AdminShellPage()
                      : role == 'Organizer'
                      ? OrganizerShellPage(user: user)
                      : ExhibitorShellPage(user: user);
                  navigator.pushReplacement(
                    MaterialPageRoute(
                      settings: RouteSettings(
                        name: isExhibitor ? exhibitorShellRouteName : null,
                      ),
                      builder: (_) => destination,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
