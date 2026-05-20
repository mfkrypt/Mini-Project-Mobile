import 'package:flutter/material.dart';

import '../../models/admin_user.dart';
import 'organizer_exhibitions_page.dart';

class OrganizerShellPage extends StatelessWidget {
  const OrganizerShellPage({super.key, required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrganizerExhibitionsPage(organizerId: user.id ?? 0),
    );
  }
}
