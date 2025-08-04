// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:google_map_final/geolocator_funtion/geolocator_funtion.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class GoogleMapScreen extends StatefulWidget {
//   final double lat, lng;
//   const GoogleMapScreen({super.key, required this.lat, required this.lng});
//
//   @override
//   State<GoogleMapScreen> createState() => _GoogleMapScreenState();
// }
//
// class _GoogleMapScreenState extends State<GoogleMapScreen> {
//   bool isLoading = false;
//   List<Placemark>? placemarks;
//   double lat = 0.0;
//   double lng = 0.0;
//   String fullAddress = 'loading';
//
//   @override
//   void initState() {
//     super.initState();
//     lat = widget.lat;
//     lng = widget.lng;
//     getFullAddress(widget.lat, widget.lng);
//   }
//
//   Future<void> getFullAddress(double laat, double long) async {
//     List<Placemark> placemarks = await placemarkFromCoordinates(laat, long);
//     Placemark place = placemarks.first;
//
//     fullAddress =
//         "${place.name}, ${place.street}, ${place.subLocality}, "
//         "${place.locality}, ${place.administrativeArea}, ${place.postalCode}, "
//         "${place.country}";
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: InkWell(
//         onTap: () {
//           setState(() => isLoading = true);
//           determinePosition()
//               .then((value) {
//                 setState(() {});
//                 getFullAddress(value.latitude, value.longitude);
//                 setState(() => isLoading = false);
//               })
//               .onError((error, stackError) {
//                 setState(() => isLoading = false);
//               });
//         },
//         child: Container(
//           height: 50,
//           width: 50,
//           margin: EdgeInsets.only(bottom: 80),
//           decoration: BoxDecoration(
//             color: Colors.greenAccent,
//             shape: BoxShape.circle,
//           ),
//           child: isLoading
//               ? CircularProgressIndicator(color: Colors.black)
//               : Icon(Icons.my_location),
//         ),
//       ),
//       appBar: AppBar(
//         title: const Text("Google Map"),
//         backgroundColor: Colors.greenAccent,
//         centerTitle: true,
//       ),
//       bottomSheet: Container(
//         width: double.infinity,
//         padding: EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 30),
//         color: Colors.greenAccent,
//         child: Text("Address :-  $fullAddress"),
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             mapType: MapType.normal,
//             onCameraIdle: () {
//               getFullAddress(lat, lng);
//             },
//
//             onCameraMove: (CameraPosition cameraPosition) {
//               setState(() {
//                 lat = cameraPosition.target.latitude;
//                 lng = cameraPosition.target.longitude;
//               });
//             },
//             initialCameraPosition: CameraPosition(
//               target: LatLng(lat, lng),
//               zoom: 14.4746,
//             ),
//           ),
//           const Center(
//             child: Icon(Icons.location_on, color: Colors.red, size: 41),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // For converting lat/lng to address
import 'package:google_map_final/geolocator_funtion/geolocator_funtion.dart'; // Your custom file to get current location
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Google Maps widget

class GoogleMapScreen extends StatefulWidget {
  final double lat, lng;

  const GoogleMapScreen({super.key, required this.lat, required this.lng});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  bool isLoading = false; // To control loading state
  double lat = 0.0;
  double lng = 0.0;
  String fullAddress = 'Loading...'; // Address to be shown

  GoogleMapController? _mapController; // Google Map controller to move camera

  @override
  void initState() {
    super.initState();
    // Set initial lat/lng from widget
    lat = widget.lat;
    lng = widget.lng;

    // Fetch address on load
    getFullAddress(lat, lng);
  }

  // Get full address using latitude and longitude
  Future<void> getFullAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      final place = placemarks.first;

      // Format full address using all available parts
      setState(() {
        fullAddress =
        "${place.name}, ${place.street}, ${place.subLocality}, "
            "${place.locality}, ${place.subAdministrativeArea}, "
            "${place.administrativeArea}, ${place.postalCode}, "
            "${place.country}";
      });
    } catch (e) {
      setState(() {
        fullAddress = "Error retrieving address";
      });
      debugPrint("Address error: $e");
    }
  }

  // Move camera to the user's current location
  Future<void> moveToCurrentLocation() async {
    setState(() => isLoading = true);
    try {
      // Get current location using your custom function
      final position = await determinePosition();

      lat = position.latitude;
      lng = position.longitude;

      // Animate the map camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 15),
        ),
      );

      // Get updated address
      await getFullAddress(lat, lng);
    } catch (e) {
      debugPrint("Location error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Floating action button to get current location
      floatingActionButton: InkWell(
        onTap: moveToCurrentLocation,
        child: Container(
          height: 50,
          width: 50,
          margin: const EdgeInsets.only(bottom: 80),
          decoration: const BoxDecoration(
            color: Colors.greenAccent,
            shape: BoxShape.circle,
          ),
          child: isLoading
              ? const Padding(
            padding: EdgeInsets.all(10),
            child: CircularProgressIndicator(color: Colors.black),
          )
              : const Icon(Icons.my_location),
        ),
      ),

      // App Bar
      appBar: AppBar(
        title: const Text("Google Map"),
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
      ),

      // Bottom sheet showing the address
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        color: Colors.greenAccent,
        child: Text(
          "Address:\n$fullAddress",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // Google Map widget
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,

            // Assign map controller when map is created
            onMapCreated: (controller) => _mapController = controller,

            // When camera stops moving, update address
            onCameraIdle: () => getFullAddress(lat, lng),

            // While moving the camera, update lat/lng variables
            onCameraMove: (position) {
              lat = position.target.latitude;
              lng = position.target.longitude;
            },

            // Initial map position
            initialCameraPosition: CameraPosition(
              target: LatLng(lat, lng),
              zoom: 14.5,
            ),
          ),

          // Center pin icon
          const Center(
            child: Icon(Icons.location_on, color: Colors.red, size: 41),
          ),
        ],
      ),
    );
  }
}
