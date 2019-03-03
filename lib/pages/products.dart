import 'package:flutter/material.dart';
import 'package:flutter_app/products_manager.dart';

class ProductsPage extends StatelessWidget {

  final List<Map<String,dynamic>> products;

  ProductsPage(this.products);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            AppBar(
              automaticallyImplyLeading: false,
              title: Text("Choosen"),
            ),
            ListTile(
              title: Text("Manage Products"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/admin');
              },
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: ProductManager(products),
    );
  }
}
