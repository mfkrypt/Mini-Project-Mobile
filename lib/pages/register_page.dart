import 'package:flutter/material.dart';

import '../widgets/app_name.dart';
import '../widgets/form_field_box.dart';
import '../widgets/logo_mark.dart';
import '../widgets/phone_frame.dart';
import '../widgets/primary_button.dart';
import '../widgets/role_field.dart';
import 'huge_x_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String role = 'Role (Dropdown)';

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
            const FormFieldBox(icon: Icons.person_outline, label: 'Username'),
            const SizedBox(height: 18),
            const FormFieldBox(icon: Icons.mail_outline, label: 'Email'),
            const SizedBox(height: 18),
            const FormFieldBox(icon: Icons.lock_outline, label: 'Password'),
            const SizedBox(height: 18),
            const FormFieldBox(
              icon: Icons.lock_outline,
              label: 'Confirm Password',
            ),
            const SizedBox(height: 18),
            RoleField(
              value: role,
              onChanged: (value) => setState(() => role = value),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 72),
              child: PrimaryButton(
                label: 'Sign Up',
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HugeXPage()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
