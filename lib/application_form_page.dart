import 'package:flutter/material.dart';

import 'data/admin_database.dart';
import 'models/admin_booth_map.dart';
import 'models/admin_event.dart';
import 'models/booth.dart';
import 'models/exhibitor_application.dart';
import 'utils/route_names.dart';
import 'widgets/phone_frame.dart';

class ApplicationFormPage extends StatefulWidget {
  const ApplicationFormPage({
    super.key,
    required this.exhibitorId,
    required this.event,
    required this.cart,
    required this.onSubmitted,
  });

  final int exhibitorId;
  final AdminEvent event;
  final List<Booth> cart;
  final VoidCallback onSubmitted;

  @override
  State<ApplicationFormPage> createState() => _ApplicationFormPageState();
}

class _ApplicationFormPageState extends State<ApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final db = AdminDatabase.instance;

  final companyNameController = TextEditingController();
  final companyDescController = TextEditingController();
  final exhibitController = TextEditingController();

  bool chairs = false;
  bool wifi = false;
  bool carpet = false;

  @override
  void dispose() {
    companyNameController.dispose();
    companyDescController.dispose();
    exhibitController.dispose();
    super.dispose();
  }

  double _addOnTotal() {
    double total = 0;
    if (chairs) total += 100;
    if (wifi) total += 100;
    if (carpet) total += 100;
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final eventCart = widget.cart
        .where((item) => item.eventId == (widget.event.id ?? 0))
        .toList();
    final boothTotal = eventCart.fold(0.0, (sum, item) => sum + item.price);
    final total = boothTotal + _addOnTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Form'),
        backgroundColor: const Color(0xffd9d9d9),
        foregroundColor: Colors.black,
      ),
      body: PhoneFrame(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Company Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: companyNameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: companyDescController,
                  decoration: const InputDecoration(
                    labelText: 'Company Details',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: exhibitController,
                  decoration: const InputDecoration(
                    labelText: 'Exhibit Description',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Text(
                  'Event Dates: ${widget.event.startDate} - ${widget.event.endDate}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  'Adds On:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                CheckboxListTile(
                  title: const Text('Extra Chairs'),
                  secondary: const Text('RM 100'),
                  value: chairs,
                  onChanged: (val) => setState(() => chairs = val ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Premium Wifi'),
                  secondary: const Text('RM 100'),
                  value: wifi,
                  onChanged: (val) => setState(() => wifi = val ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Carpet'),
                  secondary: const Text('RM 100'),
                  value: carpet,
                  onChanged: (val) => setState(() => carpet = val ?? false),
                ),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'RM ${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: eventCart.isEmpty
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }
                            final applicationId = await db.insertApplication(
                              ExhibitorApplication(
                                eventId: widget.event.id ?? 0,
                                exhibitorId: widget.exhibitorId,
                                companyName: companyNameController.text.trim(),
                                companyDescription: companyDescController.text
                                    .trim(),
                                exhibitDescription: exhibitController.text
                                    .trim(),
                                eventStartDate: widget.event.startDate,
                                eventEndDate: widget.event.endDate,
                                status: 'Pending',
                                submittedAt: DateTime.now().toIso8601String(),
                                totalPrice: total,
                              ),
                            );
                            final boothMaps = await db.fetchBoothsForEvent(
                              widget.event.id ?? 0,
                            );
                            for (final booth in eventCart) {
                              final boothMap = boothMaps.firstWhere(
                                (map) => map.boothId == booth.id,
                                orElse: () => const AdminBoothMap(
                                  boothId: '',
                                  boothTypeId: 0,
                                  floorPlanId: 0,
                                  x: 0,
                                  y: 0,
                                  width: 0,
                                  height: 0,
                                  status: 'available',
                                  attributes: '',
                                ),
                              );
                              if (boothMap.id == null) {
                                continue;
                              }
                              await db.insertApplicationBooth(
                                applicationId,
                                boothMap.id!,
                              );
                              await db.updateBoothStatus(
                                boothMap.id!,
                                'pending',
                              );
                            }
                            if (chairs) {
                              await db.insertApplicationAddon(
                                applicationId,
                                'Extra Chairs',
                                100,
                              );
                            }
                            if (wifi) {
                              await db.insertApplicationAddon(
                                applicationId,
                                'Premium Wifi',
                                100,
                              );
                            }
                            if (carpet) {
                              await db.insertApplicationAddon(
                                applicationId,
                                'Carpet',
                                100,
                              );
                            }
                            widget.onSubmitted();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Application submitted for review.',
                                ),
                              ),
                            );
                            navigator.popUntil(
                              (route) =>
                                  route.settings.name ==
                                      exhibitorShellRouteName ||
                                  route.isFirst,
                            );
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff7a7a7a),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Proceed Application'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
