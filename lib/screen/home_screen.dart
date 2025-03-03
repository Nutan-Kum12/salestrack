import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:salestrack/bloc/auth/auth_bloc.dart';
import 'package:salestrack/bloc/auth/auth_event.dart';
import 'package:salestrack/bloc/shop/shop_bloc.dart';
import 'package:salestrack/bloc/shop/shop_event.dart';
import 'package:salestrack/bloc/shop/shop_state.dart';
import 'package:salestrack/screen/shop_detailscreen.dart';
import '../widgets/shop_card.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCity = 'Indirapuram';
  final List<String> _cities = ['All', 'Kaushambi', 'Vaishali', 'Gangapuram', 'Govindpuram', 'Vijay Nagar', 'Raj Nagar' ,'Indirapuram'];

  @override
  void initState() {
    super.initState();
    context.read<ShopBloc>().add(LoadShops());
  }

 Future<void> _fetchShopsByCity(String city) async {
  if (city == 'All') {
    context.read<ShopBloc>().add(LoadShops());
    return;
  }

  try {
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    context.read<ShopBloc>().add(LoadShopsByCity(city));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error fetching location: ${e.toString()}")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.place_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new_outlined),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCity,
              hint: const Text('Filter by City'),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCity = newValue;
                  });
                  _fetchShopsByCity(newValue);
                }
              },
              items: _cities.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: BlocBuilder<ShopBloc, ShopState>(
              builder: (context, state) {
                if (state is ShopLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ShopsLoaded) {
                  final shops = state.shops;
                  if (shops.isEmpty) {
                    return const Center(child: Text('No shops found'));
                  }
                  return ListView.builder(
                    padding:  EdgeInsets.all(8.0),
                    itemCount: shops.length,
                    itemBuilder: (context, index) {
                      return ShopCard(
                        shop: shops[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShopDetailScreen(shop: shops[index]),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else if (state is ShopError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else {
                  return const Center(child: Text('No shops available'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
