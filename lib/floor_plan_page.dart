import 'package:flutter/material.dart';
import 'package:flutter_project_event_page/models/booth.dart';
import 'package:flutter_project_event_page/pages/cart_page.dart';

class FloorPlanPage extends StatefulWidget {
  @override
  _FloorPlanPageState createState() => _FloorPlanPageState();
}

class _FloorPlanPageState extends State<FloorPlanPage> {
  List<Booth> booths = [
    Booth(id: "C-1", status: "available", price: 2500),
    Booth(id: "C-2", status: "booked", price: 2500),
    Booth(id: "C-3", status: "available", price: 2500),
  ];

  List<Booth> cart = [];

  Color getColor(String status) {
    switch (status) {
      case "available":
        return Colors.green;
      case "booked":
        return Colors.red;
      case "selected":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void selectBooth(Booth booth) {
    if (booth.status == 'available') {
      setState(() {
        booth.status = 'selected';
        cart.add(booth);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Floor Plan")),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: booths.map((booth) {
                return GestureDetector(
                  onTap: () => selectBooth(booth),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    color: getColor(booth.status),
                    child: Center(
                      child: Text(
                        booth.id,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartPage(cart: cart),
                ),
              );
            },
            child: Text("Go to Cart"),
          )
        ],
      ),
    );
  }
}