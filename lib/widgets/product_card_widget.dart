import 'package:flutter/material.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/scoped-models/main.dart';
import 'package:flutter_app/widgets/address_tag_widgt.dart';
import 'package:flutter_app/widgets/price_tag_widget.dart';
import 'package:flutter_app/widgets/ui_elements/title_default.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductCard extends StatelessWidget {
  final Product _product;
  final int productIndex;

  const ProductCard(this._product, this.productIndex);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(children: <Widget>[
      Column(children: <Widget>[
        FadeInImage(
          image: NetworkImage(
            _product.image,
          ),
          placeholder: AssetImage('assets/grass.jpg'),
          height: 200.0,
          fit: BoxFit.cover,
        ),
        _buildTitlePriceRow(),
        AddressTag(_product.location.address),
      ]),
      _buildActionButtons(context)
    ]));
  }

  Widget _buildActionButtons(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.info,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () => Navigator.pushNamed<bool>(
                    context, '/products/' + model.allProducts[productIndex].id),
              ),
              IconButton(
                color: Colors.red,
                icon: Icon(model.allProducts[productIndex].isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () {
                  model.selectProduct(model.allProducts[productIndex].id);
                  model.toggleProductFavoriteStatus();
                },
              ),
            ]);
      },
    );
  }

  Row _buildTitlePriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        TitleDefault(_product.title),
        PriceTag(_product.price.toString())
      ],
    );
  }
}
