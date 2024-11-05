import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBusinessVerificationPage extends StatefulWidget {
  @override
  _AdminBusinessVerificationPageState createState() =>
      _AdminBusinessVerificationPageState();
}

class _AdminBusinessVerificationPageState
    extends State<AdminBusinessVerificationPage> {
  String _selectedStatus = 'pending'; // Default to show 'pending' merchants

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      appBar: AppBar(
        backgroundColor: Colors.black, // AppBar with black background
        title: Text(
          'Business Verification Admin',
          style: TextStyle(color: Colors.white), // White text in AppBar
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Filter by status',
                labelStyle: TextStyle(color: Colors.white), // White label
                filled: true,
                fillColor: Colors.white24, // Subtle white overlay for input
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              dropdownColor: Colors.black, // Dropdown background color black
              style: TextStyle(color: Colors.white), // White text for dropdown
              items: ['approved', 'disapproved', 'pending'].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.capitalizeFirst(),
                      style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('merchants')
                  .where('verificationStatus', isEqualTo: _selectedStatus)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No merchants found.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var merchant = snapshot.data!.docs[index];
                    var businessCardUrls =
                        List<String>.from(merchant['businessCardUrls'] ?? []);

                    return Card(
                      color: Colors.white10, // Dark card background
                      margin: EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Business Name: ${merchant['businessName']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // White text
                              ),
                            ),
                            Text('Owner Name: ${merchant['realName']}',
                                style: TextStyle(color: Colors.white70)),
                            Text('Email: ${merchant['email']}',
                                style: TextStyle(
                                    color: Colors.white70)), // Gmail Field
                            Text('Age: ${merchant['age']}',
                                style: TextStyle(color: Colors.white70)),
                            Text('Gender: ${merchant['gender']}',
                                style: TextStyle(color: Colors.white70)),
                            Text('Phone: ${merchant['phone']}',
                                style: TextStyle(color: Colors.white70)),
                            Text('About: ${merchant['aboutBusiness']}',
                                style: TextStyle(color: Colors.white70)),
                            SizedBox(height: 10),
                            Text('Status: ${merchant['verificationStatus']}',
                                style: TextStyle(color: Colors.redAccent)),
                            SizedBox(height: 10),

                            // Display business card/poster images
                            businessCardUrls.isNotEmpty
                                ? Container(
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: businessCardUrls.length,
                                      itemBuilder: (context, i) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              businessCardUrls[i],
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Text(
                                    'No business cards uploaded.',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontStyle: FontStyle.italic),
                                  ),
                            SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _updateVerificationStatus(
                                      merchant.id, 'approved'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red, // Red button color
                                    minimumSize: Size(100, 40),
                                  ),
                                  child: Text('Approve',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                ElevatedButton(
                                  onPressed: () => _updateVerificationStatus(
                                      merchant.id, 'disapproved'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.white12, // Dark button
                                    minimumSize: Size(100, 40),
                                  ),
                                  child: Text('Disapprove',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
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
    );
  }

  // Function to update verification status in Firestore
  Future<void> _updateVerificationStatus(
      String merchantId, String status) async {
    await FirebaseFirestore.instance
        .collection('merchants')
        .doc(merchantId)
        .update({
      'verificationStatus': status,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Merchant $status successfully!')),
    );
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    if (this.isEmpty) return '';
    return this[0].toUpperCase() + this.substring(1);
  }
}
