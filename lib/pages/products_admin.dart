import 'package:flutter/material.dart';
import 'package:flutter_app/pages/product_edit.dart';
import 'package:flutter_app/pages/product_list_.dart';
import 'package:flutter_app/scoped-models/main.dart';
import 'package:flutter_app/widgets/ui_elements/logout_list_tile.dart';

class ProductAdminPage extends StatelessWidget {
  final MainModel model;

  const ProductAdminPage(this.model);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          drawer: _buildDrawer(context),
          appBar: AppBar(
            title: Text("Products Management"),
            elevation: Theme
                .of(context)
                .platform == TargetPlatform.iOS ? 0.0 : 4.0,
            bottom: TabBar(tabs: <Widget>[
              Tab(
                icon: Icon(Icons.create),
                text: 'Create Product',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'My Products',
              ),
            ]),
          ),
          body: Center(
            child: TabBarView(children: [
              ProductEditPage(),
              ProductListPage(model),
            ]),
          ),
        ));
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Choosen'),
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text("All Products"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          Divider(),
          LogoutListTile()
        ],
      ),
    );
  }
}
