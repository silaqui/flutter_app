import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/shared/globel_config.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as geoloc;
import 'package:map_view/map_view.dart';

import '../../models/location_data.dart';
import '../helpers/ensure_visible.dart';

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
      _getStaticMap(widget.product.location.address, geocode: false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _getStaticMap(String address,
      {geocode = true, double lat, double lng}) async {
    if (address == null || address.isEmpty) {
      _staticManUri = null;
      return;
    }
    if (geocode) {
      final Uri uri = Uri.https(
          'maps.googleapis.com', '/maps/api/geocode/json', {
        'address': address,
        'key': apiKey
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
    } else if (lat == null && lng == null) {
      _locationData = widget.product.location;
    } else {
      _locationData = LocationData(lat, lng, address);
    }

    final StaticMapProvider staticMapProvider =
    StaticMapProvider(apiKey);
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
      _getStaticMap(_addressInputController.text);
    }
  }

  Future<String> _getAddress(double lat, double lng) async {
    final Uri uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${lat.toString()},${lng.toString()}',
      'key': apiKey
    });
    final http.Response response = await http.get(uri);
    final decodedResponse = json.decode(response.body);
    final formattedAddress = decodedResponse['results'][0]['formatted_address'];
    return formattedAddress;
  }

  void _getUserLocation() async {
    final location = geoloc.Location();
    try {
      final currentLocation = await location.getLocation();
      final address =
      await _getAddress(currentLocation.latitude, currentLocation.longitude);
      _getStaticMap(address,
          geocode: false,
          lat: currentLocation.latitude,
          lng: currentLocation.longitude);
    } catch (error) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Location failed"),
              content: Text(" Could not get user location"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Okay"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
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
        FlatButton(
          child: Text('Local user'),
          onPressed: _getUserLocation,
        ),
        SizedBox(height: 10.0),
        _staticManUri != null
            ? Image.network(_staticManUri.toString())
            : Container()
      ],
    );
  }
}
