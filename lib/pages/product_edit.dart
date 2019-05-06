import 'package:flutter/material.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/scoped-models/main.dart';
import 'package:flutter_app/widgets/form_inputs/location.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_app/models/location_data.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPage();
  }
}

class _ProductEditPage extends State<ProductEditPage> {
  final Map<String, dynamic> _formDate = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'assets/bee.jpg',
    'location': null
  };

  final GlobalKey<FormState> editForm = GlobalKey<FormState>();
  final _titleTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      final Widget pageContent =
          _buildPageContent(context, model.selectedProduct);
      return model.selectedProductIndex == -1
          ? pageContent
          : Scaffold(
              appBar: AppBar(
                title: Text('Edit product'),
              ),
              body: pageContent,
            );
    });
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = (deviceWidth - targetWidth) / 2;

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: targetPadding),
            child: Form(
                key: editForm,
                child: ListView(children: <Widget>[
                  _buildTitleTextFormField(product),
                  _buildDescriptionTextFormField(product),
                  _buildPriceTextFormField(product),
                  SizedBox(height: 10.0),
                  LocationInput(_setLocation, product),
                  SizedBox(height: 10.0),
                  _buildSubmitButton()
                ]))));
  }

  void _setLocation(LocationData location) {
    _formDate['location'] = location;
  }

  void _submitForm(
      Function addProduct, Function updateProduct, Function setSelectedProduct,
      [int selectedProductIndex]) {
    if (!editForm.currentState.validate()) {
      return;
    }
    editForm.currentState.save();

    if (selectedProductIndex == -1) {
      addProduct(_titleTextController.text, _formDate['description'],
              _formDate['price'], _formDate['image'], _formDate['location'])
          .then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/')
              .then(setSelectedProduct(null));
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text('Something is No Yes'),
                  content: Text('Try again later'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("OK"),
                    )
                  ]);
            },
          );
        }
      });
    } else {
      updateProduct(_titleTextController.text, _formDate['description'],
              _formDate['price'], _formDate['image'], _formDate['location'])
          .then((_) => Navigator.pushReplacementNamed(context, '/')
              .then(setSelectedProduct(null)));
    }
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                child: Text("Save"),
                onPressed: () => _submitForm(
                    model.addProduct,
                    model.updateProduct,
                    model.selectProduct,
                    model.selectedProductIndex));
      },
    );
  }

  TextFormField _buildPriceTextFormField(Product product) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Price',
      ),
      initialValue: product == null ? '' : product.price.toString(),
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value))
          return 'Price is required';
      },
      onSaved: (String value) {
        _formDate['price'] = double.parse(value);
      },
    );
  }

  TextFormField _buildDescriptionTextFormField(Product product) {
    return TextFormField(
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description',
      ),
      initialValue: product == null ? '' : product.description,
      validator: (String value) {
        if (value.isEmpty) return 'Description is required';
      },
      onSaved: (String value) {
        _formDate['description'] = value;
      },
    );
  }

  TextFormField _buildTitleTextFormField(Product product) {
    if (product == null && _titleTextController.text.trim() == '') {
      _titleTextController.text = '';
    } else if (product != null && _titleTextController.text.trim() == '') {
      _titleTextController.text = product.title;
    } else if (product != null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else if (product == null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else{
      _titleTextController.text = '';
    }
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Title',
      ),
      controller: _titleTextController,
//      initialValue: product == null ? '' : product.title,
      validator: (String value) {
        if (value.isEmpty || value.length < 5)
          return 'Title is required and should have at least 5 characters';
      },
      onSaved: (String value) {
        _formDate['title'] = value;
      },
    );
  }
}
