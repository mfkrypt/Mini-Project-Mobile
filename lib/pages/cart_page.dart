import 'package:flutter/material.dart';

import '../application_form_page.dart';
import '../data/admin_database.dart';
import '../models/booth.dart';
import '../widgets/phone_frame.dart';

class CartPage extends StatelessWidget {
  CartPage({
    super.key,
    required this.cart,
    required this.exhibitorId,
    required this.onSubmitted,
  });

  final List<Booth> cart;
  final int exhibitorId;
  final VoidCallback onSubmitted;
  final db = AdminDatabase.instance;

  int? _eventIdFromCart() {
    if (cart.isEmpty) {
      return null;
    }
    return cart.first.eventId;
  }

  @override
  Widget build(BuildContext context) {
    final total = cart.fold(0.0, (sum, item) => sum + item.price);

    final eventId = _eventIdFromCart();
    return PhoneFrame(
      child: Column(
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            color: const Color(0xffd9d9d9),
            child: const Text(
              'Cart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              children: [
                if (cart.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: Text('Cart is empty.')),
                  ),
                for (int index = 0; index < cart.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${index + 1}. Booth ${cart[index].id}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'RM ${cart[index].price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 80),
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
                const SizedBox(height: 22),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: cart.isEmpty || eventId == null
                        ? null
                        : () async {
                            final event = await db.fetchEventById(eventId);
                            if (event == null) {
                              return;
                            }
                            if (!context.mounted) {
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ApplicationFormPage(
                                  exhibitorId: exhibitorId,
                                  event: event,
                                  cart: cart,
                                  onSubmitted: onSubmitted,
                                ),
                              ),
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
        ],
      ),
    );
  }
}