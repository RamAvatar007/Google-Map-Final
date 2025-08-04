import 'package:flutter/material.dart';
import 'package:google_map_final/ui/google_map_screen.dart';
import '../geolocator_funtion/geolocator_funtion.dart';
import 'package:geocoding/geocoding.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  // Search and move to typed location
  Future<void> _searchAndGo() async {
    if (searchController.text.trim().isEmpty) return;

    setState(() => isLoading = true);
    try {
      List<Location> locations = await locationFromAddress(searchController.text);
      if (locations.isNotEmpty) {
        final searchedLocation = locations.first;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoogleMapScreen(
              lat: searchedLocation.latitude,
              lng: searchedLocation.longitude,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search place or address",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _searchAndGo,
                  ),
                ),
                onSubmitted: (value) => _searchAndGo(),
              ),
            ),
            // Current Location Button
            ElevatedButton(
              onPressed: () {
                setState(() => isLoading = true);
                determinePosition()
                    .then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoogleMapScreen(
                        lat: value.latitude,
                        lng: value.longitude,
                      ),
                    ),
                  );
                  setState(() => isLoading = false);
                })
                    .onError((error, stackError) {
                  setState(() => isLoading = false);
                  debugPrint("Current Position Error :$error");
                  debugPrint("Current Position stackError :$stackError");
                });
              },
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Text("Get Current Location"),
            ),
          ],
        ),
      ),
    );
  }
}
