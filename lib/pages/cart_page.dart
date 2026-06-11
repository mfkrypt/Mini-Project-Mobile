import 'package:flutter/material.dart';

import '../application_form_page.dart';
import '../data/admin_database.dart';
import '../models/booth.dart';
import '../widgets/phone_frame.dart';

class CartPage extends StatefulWidget {
  const CartPage({
    super.key,
    required this.cart,
    required this.exhibitorId,
    required this.onSubmitted,
  });

  final List<Booth> cart;
  final int exhibitorId;
  final VoidCallback onSubmitted;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final db = AdminDatabase.instance;

  int? _eventIdFromCart() {
    if (widget.cart.isEmpty) {
      return null;
    }
    return widget.cart.first.eventId;
  }

  bool _hasMixedEvents() {
    final eventId = _eventIdFromCart();
    return eventId != null &&
        widget.cart.any((item) => item.eventId != eventId);
  }

  void _removeFromCart(int index) {
    setState(() => widget.cart.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.cart.fold(0.0, (sum, item) => sum + item.price);
    final eventId = _eventIdFromCart();
    final mixedEvents = _hasMixedEvents();

    return Scaffold(
      body: PhoneFrame(
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
                  if (widget.cart.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: Text('Cart is empty.')),
                    ),
                  if (widget.cart.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Event: ${widget.cart.first.eventName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (mixedEvents)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Cart contains booths from multiple events. Please submit one event at a time.',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  for (var index = 0; index < widget.cart.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${index + 1}. Booth ${widget.cart[index].id} (${widget.cart[index].typeName})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            'RM ${widget.cart[index].price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Remove from cart',
                            onPressed: () => _removeFromCart(index),
                            icon: const Icon(Icons.close, size: 18),
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
                      onPressed:
                          widget.cart.isEmpty || eventId == null || mixedEvents
                          ? null
                          : () async {
                              final event = await db.fetchEventById(eventId);
                              if (event == null || !context.mounted) {
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ApplicationFormPage(
                                    exhibitorId: widget.exhibitorId,
                                    event: event,
                                    cart: widget.cart,
                                    onSubmitted: widget.onSubmitted,
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
      ),
    );
  }
}
