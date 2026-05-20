import 'package:flutter/material.dart';

class BoothInformation extends StatelessWidget {
  const BoothInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xffdddddd),
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booth Information:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(left: 17),
            child: Text(
              'Booth A-xx: Premium, 20sqm, \$1500\n'
              'Booth B-xx: Standard, 10sqm, \$800\n'
              'Booth C-xx: Corner, 15sqm, \$1100',
              style: TextStyle(fontSize: 16, height: 1.42),
            ),
          ),
        ],
      ),
    );
  }
}
