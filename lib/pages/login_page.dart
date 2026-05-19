import 'package:flutter/material.dart';

import '../widgets/app_name.dart';
import '../widgets/logo_mark.dart';
import '../widgets/phone_frame.dart';
import '../widgets/primary_button.dart';
import '../widgets/role_field.dart';
import '../data/admin_database.dart';
import '../models/admin_user.dart';
import 'admin/admin_shell_page.dart';
import 'exhibitor/exhibitor_shell_page.dart';
import 'organizer/organizer_shell_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String role = 'Role (Dropdown)';
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhoneFrame(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 28),
          children: [
            const SizedBox(height: 36),
            const Center(child: LogoMark(size: 66)),
            const SizedBox(height: 14),
            const Center(child: AppName()),
            const SizedBox(height: 28),
            const Text(
              'Login',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            Container(
              height: 52,
              color: const Color(0xffd9d9d9),
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'Username or Email',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 52,
              color: const Color(0xffd9d9d9),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  hintText: 'Password',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: RoleField(
                value: role,
                onChanged: (value) => setState(() => role = value),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: PrimaryButton(
                label: 'Sign In',
                onPressed: () async {
                  final identifier = usernameController.text.trim();
                  final password = passwordController.text.trim();
                  if (identifier.isEmpty || password.isEmpty) {
                    if (!mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter credentials.')),
                    );
                    return;
                  }
                  if (role == 'Role (Dropdown)') {
                    if (!mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Select a role.')),
                    );
                    return;
                  }

                  final normalizedRole =
                      role == 'Administrator' ? 'Admin' : role;
                  AdminUser? user =
                      await AdminDatabase.instance.authenticateUser(
                    identifier: identifier,
                    password: password,
                    role: normalizedRole,
                  );
                  if (!mounted) {
                    return;
                  }
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid credentials.')),
                    );
                    return;
                  }
                  final destination = role == 'Administrator'
                      ? const AdminShellPage()
                      : role == 'Organizer'
                          ? OrganizerShellPage(user: user)
                          : ExhibitorShellPage(user: user);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => destination),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Don\'t Have an account? ',
                    style: TextStyle(fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 14, color: Color(0xff6c6df6)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
