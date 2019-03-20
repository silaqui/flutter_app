import 'package:flutter/material.dart';

class PriceTag extends StatelessWidget {

  final String price;

  const PriceTag(this.price);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
        decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: BorderRadius.circular(5.0)),
        child: Text('\$$price',
            style: TextStyle(fontSize: 18.0, color: Colors.white)));
  }
}
