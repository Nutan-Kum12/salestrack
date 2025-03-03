import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salestrack/bloc/shop/shop_bloc.dart';
import 'package:salestrack/bloc/shop/shop_state.dart';
import 'package:salestrack/screen/shop_detailscreen.dart';
import '../models/shop.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Locations'),
      ),
      body: BlocBuilder<ShopBloc, ShopState>(
        builder: (context, state) {
          if (state is ShopLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ShopsLoaded) {
            final shops = state.shops;
            _updateMarkers(shops);
            
            return GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(28.6139, 77.2090), // Delhi coordinates as default
                zoom: 10,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _fitBounds(shops);
              },
            );
          } else if (state is ShopError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No shops available'));
          }
        },
      ),
    );
  }

  void _updateMarkers(List<Shop> shops) {
    _markers = shops.map((shop) {
      return Marker(
        markerId: MarkerId(shop.id),
        position: LatLng(shop.latitude, shop.longitude),
        infoWindow: InfoWindow(
          title: shop.title,
          snippet: shop.address,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShopDetailScreen(shop: shop),
              ),
            );
          },
        ),
      );
    }).toSet();
  }

  void _fitBounds(List<Shop> shops) {
    if (shops.isEmpty) return;
    
    double minLat = shops.first.latitude;
    double maxLat = shops.first.latitude;
    double minLng = shops.first.longitude;
    double maxLng = shops.first.longitude;
    
    for (var shop in shops) {
      if (shop.latitude < minLat) minLat = shop.latitude;
      if (shop.latitude > maxLat) maxLat = shop.latitude;
      if (shop.longitude < minLng) minLng = shop.longitude;
      if (shop.longitude > maxLng) maxLng = shop.longitude;
    }
    
    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.05, minLng - 0.05),
          northeast: LatLng(maxLat + 0.05, maxLng + 0.05),
        ),
        50,
      ),
    );
  }
}

