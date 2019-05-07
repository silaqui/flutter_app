import 'package:flutter/material.dart';
import 'package:flutter_app/models/product.dart';
import 'package:map_view/map_view.dart';
import '../helpers/ensure_visible.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/location_data.dart';

class LocationInput extends StatefulWidget {
  final Function setLocation;
  final Product product;

  const LocationInput(this.setLocation, this.product);

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  final FocusNode _addressInputFocusNode = FocusNode();
  final TextEditingController _addressInputController =
      new TextEditingController();
  LocationData _locationData;
  Uri _staticManUri;

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    if (widget.product != null) {
      getStaticMap(widget.product.location.address, false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void getStaticMap(String address, [geocode = true]) async {
    if (address == null || address.isEmpty) {
      _staticManUri = null;
      return;
    }
    if (geocode) {
      final Uri uri = Uri.https(
          'maps.googleapis.com', '/maps/api/geocode/json', {
        'address': address,
        'key': 'AIzaSyA4YHhJUn3UNsoQ6ml4g_WK59sGms5DZ7A'
      });
      final http.Response response = await http.get(uri);
      final decodedResponse = json.decode(response.body);
      final String formattedAddress =
          decodedResponse['results'][0]['formatted_address'];
      final double lat =
          decodedResponse['results'][0]['geometry']['location']['lat'];
      final double lng =
          decodedResponse['results'][0]['geometry']['location']['lng'];
      _locationData = LocationData(lat, lng, formattedAddress);
    } else {
      _locationData = widget.product.location;
    }

    final StaticMapProvider staticMapProvider =
        StaticMapProvider('AIzaSyA4YHhJUn3UNsoQ6ml4g_WK59sGms5DZ7A');
    final Uri mapUrl = staticMapProvider.getStaticUriWithMarkers([
      Marker('Position', 'Position', _locationData.latitude,
          _locationData.longitude)
    ],
        width: 500,
        height: 300,
        center: Location(_locationData.latitude, _locationData.longitude),
        maptype: StaticMapViewType.roadmap);
    widget.setLocation(_locationData);
    if (this.mounted) {
      setState(() {
        _addressInputController.text = _locationData.address;
        _staticManUri = mapUrl;
      });
    }
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      getStaticMap(_addressInputController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          focusNode: _addressInputFocusNode,
          child: TextFormField(
            focusNode: _addressInputFocusNode,
            controller: _addressInputController,
            validator: (String value) {
              if (_locationData == null || value.isEmpty) {
                return 'No valid location found';
              }
            },
            decoration: InputDecoration(labelText: 'Address'),
          ),
        ),
        SizedBox(height: 10.0),
        _staticManUri != null
            ? Image.network(_staticManUri.toString())
            : Container()
      ],
    );
  }
}
