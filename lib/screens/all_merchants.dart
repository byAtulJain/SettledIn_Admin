import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllMerchantsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Same black background
      appBar: AppBar(
        backgroundColor: Colors.black, // AppBar with black background
        title: Text(
          'All Merchants',
          style: TextStyle(color: Colors.white), // White text in AppBar
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('merchants').snapshots(),
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

          // Get total merchant count
          int merchantCount = snapshot.data!.docs.length;

          return Column(
            children: [
              // Display total merchant count at the top
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total Merchants: $merchantCount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text for the count
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: merchantCount,
                  itemBuilder: (context, index) {
                    var merchant = snapshot.data!.docs[index];
                    var verificationStatus =
                        merchant['verificationStatus'] ?? 'pending';

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
                              'Merchant Name: ${merchant['name']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // White text
                              ),
                            ),
                            Text(
                              'Email: ${merchant['email']}',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Verification Status: ${verificationStatus[0].toUpperCase()}${verificationStatus.substring(1)}',
                              style: TextStyle(
                                color: verificationStatus == 'approved'
                                    ? Colors.green
                                    : verificationStatus == 'disapproved'
                                        ? Colors.red
                                        : Colors
                                            .orange, // Color based on status
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
