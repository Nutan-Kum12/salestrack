import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salestrack/bloc/shop/shop_bloc.dart';
import 'package:salestrack/bloc/shop/shop_event.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/shop.dart';

class ShopDetailScreen extends StatefulWidget {
  final Shop shop;

  const ShopDetailScreen({Key? key, required this.shop}) : super(key: key);

  @override
  _ShopDetailScreenState createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  late GoogleMapController _mapController;
  late Set<Marker> _markers;
  double? _distance;
  String _verificationId = '';

  @override
  void initState() {
    super.initState();
    _markers = {
      Marker(
        markerId: MarkerId(widget.shop.id),
        position: LatLng(widget.shop.latitude, widget.shop.longitude),
        infoWindow: InfoWindow(title: widget.shop.title),
      ),
    };
    _getCurrentLocationAndCalculateDistance();
  }

  Future<void> _getCurrentLocationAndCalculateDistance() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.shop.latitude,
        widget.shop.longitude,
      );
      setState(() {
        _distance = distance / 1000;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

void _callNumber(String number) async {
  String formattedNumber = number.startsWith('+') ? number : '+$number';

  final Uri uri = Uri.parse('tel:$formattedNumber');

  print('Attempting to launch: $uri');

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    print('Trying Google Dialer');

    // Fallback to Google Phone
    final Uri googlePhoneUri = Uri.parse('intent:$formattedNumber#Intent;scheme=tel;package=com.google.android.dialer;end');
    if (await canLaunchUrl(googlePhoneUri)) {
      await launchUrl(googlePhoneUri, mode: LaunchMode.externalApplication);
      print('Google Dialer launched');
    } else {
      print('Could not launch Google Dialer either');
    }
  }
}


  Future<void> _sendOTP() async {
    String formattedNumber = _formatPhoneNumber(widget.shop.number.toString());

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: formattedNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        _updateDeliveryStatus();
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        _showOTPDialog();
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
String _formatPhoneNumber(String number) {
  number = number.trim();

  if (number.startsWith("+")) {
    return number; // Already in E.164 format
  }
  if (number.startsWith("0")) {
    return "+91${number.substring(1)}";
  }
  if (number.length == 10) {
    return "+91$number";
  }
  if (number.length == 12) {
    return "+$number";
  }
  throw Exception("Invalid phone number format: $number");
}


  void _showOTPDialog() {
    TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter OTP'),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'OTP'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: _verificationId,
                smsCode: otpController.text,
              );
              await FirebaseAuth.instance.signInWithCredential(credential);
              _updateDeliveryStatus();
              Navigator.pop(context);
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _updateDeliveryStatus() {
    context.read<ShopBloc>().add(UpdateDeliveryStatus(widget.shop.id, !widget.shop.delivered));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.shop.delivered ? 'Marked as not delivered' : 'Marked as delivered',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shop.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.shop.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.error, size: 50),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.shop.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.shop.address,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.green),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _callNumber(widget.shop.number.toString()),
                        child: Text(
                          widget.shop.number.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_city, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'City: ${widget.shop.city}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.directions_walk, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        _distance != null
                            ? 'Distance: ${_distance!.toStringAsFixed(2)} km'
                            : 'Calculating distance...',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                Row(
                   children: [
                     Icon(
                       widget.shop.delivered ? Icons.check_circle : Icons.cancel,
                       color: widget.shop.delivered ? Colors.green : Colors.red,
                       size: 24,
                     ),
                     const SizedBox(width: 8),
                     Text(
                          widget.shop.delivered ? 'Delivered' : 'Not Delivered',
                       style: const TextStyle(fontSize: 16),
                     ),
                   ],
                 ),
                 const SizedBox(height: 8),
                 ElevatedButton(
                   onPressed: widget.shop.delivered ? null : _sendOTP,
                   style: ElevatedButton.styleFrom(
                     backgroundColor: widget.shop.delivered ? Colors.grey : Colors.blue,
                 ),
                child: Text(widget.shop.delivered ? 'Already Delivered' : 'Mark as Delivered'),
               ),
                  const SizedBox(height: 16),
                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 300,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(widget.shop.latitude, widget.shop.longitude),
                        zoom: 15,
                      ),
                      markers: _markers,
                      onMapCreated: (controller) => _mapController = controller,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

