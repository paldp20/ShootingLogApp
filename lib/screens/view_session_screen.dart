import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shooting_log_flutter/reusable_widgets/reusable_widget.dart';

class ViewSessionDetailsScreen extends StatefulWidget {
  const ViewSessionDetailsScreen({Key? key}) : super(key: key);

  @override
  _ViewSessionDetailsScreenState createState() => _ViewSessionDetailsScreenState();
}

class _ViewSessionDetailsScreenState extends State<ViewSessionDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Session Details'),
      ),
      body: Container(
        color: Color(0xFF8458B3), // Background color
        child: SingleChildScrollView(
          child: StreamBuilder(
            stream: _getSessionData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text('No session data available.'));
              }

              final sessions = snapshot.data as List<DocumentSnapshot>;

              return Column(
                children: sessions
                    .map((session) {
                  final sessionData = session.data() as Map<String, dynamic>;

                  // Format the timestamp
                  final sessionDateTimestamp = sessionData['sessionDate'] as Timestamp;
                  final sessionDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(sessionDateTimestamp.toDate());

                  return Card(
                    margin: EdgeInsets.all(10),
                    color: Color(0xFFC9EAFA),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Session Date: $sessionDate'),
                          subtitle: Text('Session Name: ${sessionData['sessionName']}'),
                        ),
                        ListTile(
                          title: Text('Number of Shots: ${sessionData['numShots']}'),
                        ),
                        ListTile(
                          title: Text('Score: ${sessionData['score']}'),
                          subtitle: Text('Notes: ${sessionData['notes']}'),
                        ),
                      ],
                    ),
                  );
                })
                    .toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  Stream<List<DocumentSnapshot>> _getSessionData() {
    final User? user = FirebaseAuth.instance.currentUser;
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
    final String userId = user?.uid ?? '';

    return userCollection.doc(userId).collection('sessions').snapshots().map(
          (querySnapshot) => querySnapshot.docs,
    );
  }
}
