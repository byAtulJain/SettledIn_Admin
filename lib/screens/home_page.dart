import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_detail_page.dart'; // Import the detail page
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Keep this for map usage in detail page

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  String searchQuery = '';
  String _sortOrder =
      'recently_added'; // Default sorting order is recently added
  int selectedIndex = 0;

  // Add this field to cache services
  List<Map<String, dynamic>>? _cachedServices;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  final List<String> categories = [
    'All',
    'Hostels',
    'Flats',
    'Tiffins',
    'Laundries',
    'PGs',
    'Libraries',
    'Tuitions',
    'Cooks',
  ];

  Stream<List<Map<String, dynamic>>> fetchServices() {
    Query query = FirebaseFirestore.instance.collection('services');

    if (selectedIndex != 0) {
      String selectedCategory = categories[selectedIndex];
      query = query.where('tags', isEqualTo: selectedCategory);
    }

    return query.snapshots().asyncMap((snapshot) async {
      // Fetch services data
      List<Map<String, dynamic>> services = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'images': List<String>.from(doc['images']), // Fetch multiple images
          'name': doc['name'],
          'price': doc['price'], // Fetch price as int
          'tags': doc['tags'],
          'description': doc['description'],
          'address': doc['address'],
          'openingTime': doc['openingTime'],
          'closingTime': doc['closingTime'],
          'location': doc['location'],
          'phoneNumber': doc['phoneNumber'],
          'whatsappNumber': doc['whatsappNumber'],
          'timestamp': doc['timestamp'],
          'userId': doc['userId'], // Add userId field
        };
      }).toList();

      // Fetch each user's email based on userId
      for (var service in services) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('merchants')
            .doc(service['userId'])
            .get();
        if (userDoc.exists) {
          service['email'] = userDoc['email']; // Add email to service data
        }
      }

      // Update cache
      _cachedServices = services;

      // Filter, search, and sort services
      services = services.where((service) {
        final query = searchQuery.toLowerCase();
        return service['name'].toLowerCase().contains(query) ||
            service['price'].toString().contains(query) ||
            service['description'].toLowerCase().contains(query) ||
            service['address'].toLowerCase().contains(query) ||
            service['tags'].toLowerCase().contains(query);
      }).toList();

      if (_sortOrder == 'low_to_high') {
        services.sort((a, b) => a['price'].compareTo(b['price']));
      } else if (_sortOrder == 'high_to_low') {
        services.sort((a, b) => b['price'].compareTo(a['price']));
      } else if (_sortOrder == 'recently_added') {
        services.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      }

      return services;
    });
  }

  // Method to handle transition to ServiceDetailPage
  void _navigateToServiceDetail(Map<String, dynamic> service) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ServiceDetailPage(
        serviceId: service['id'],
        images: service['images'],
        name: service['name'],
        price: service['price'],
        tags: service['tags'],
        description: service['description'],
        address: service['address'],
        openingTime: service['openingTime'],
        closingTime: service['closingTime'],
        location:
            LatLng(service['location'].latitude, service['location'].longitude),
        phoneNumber: service['phoneNumber'],
        whatsappNumber: service['whatsappNumber'],
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ));
  }

  // Function to show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Recently Added'),
                onTap: () {
                  setState(() {
                    _sortOrder = 'recently_added';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Price: Low to High'),
                onTap: () {
                  setState(() {
                    _sortOrder = 'low_to_high';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Price: High to Low'),
                onTap: () {
                  setState(() {
                    _sortOrder = 'high_to_low';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Maintain black background
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar with filter icon
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Find your needs',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.grey),
                    onPressed: _showFilterDialog,
                    tooltip: 'Filter', // Call the filter dialog
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Categories filter
            Container(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 10),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            selectedIndex == index ? Colors.red : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedIndex == index
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Services List
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: fetchServices(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _cachedServices == null) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Use cached data if available
                  final services = snapshot.data ?? _cachedServices;

                  if (services == null || services.isEmpty) {
                    return Center(
                      child: Text(
                        'No services found.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      var service = services[index];
                      return GestureDetector(
                        onTap: () => _navigateToServiceDetail(service),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(service['images']
                                        [0]), // Display first image
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Rs. ${service['price']}${service['tags'].toLowerCase() == 'laundries' ? '/load' : '/month'}',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      service['address'],
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      service['email'] ?? 'Email not available',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
