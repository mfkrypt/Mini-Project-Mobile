import 'package:flutter/material.dart';
import '../models/booth.dart';
import '../application_form_page.dart';

class CartPage extends StatelessWidget {
  final List<Booth> cart;

  CartPage({required this.cart});

  @override
  Widget build(BuildContext context) {
    double total = cart.fold(0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(title: Text("Cart")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("Booth ${cart[index].id}"),
                  trailing: Text("\$${cart[index].price}"),
                );
              },
            ),
          ),
          Text("Total: \$$total"),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ApplicationFormPage(),
                ),
              );
            },
            child: Text("Proceed Application"),
          )
        ],
      ),
    );
  }
}