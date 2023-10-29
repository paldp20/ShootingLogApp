import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DeleteSessionScreen extends StatefulWidget {
  const DeleteSessionScreen({Key? key}) : super(key: key);

  @override
  _DeleteSessionScreenState createState() => _DeleteSessionScreenState();
}

class _DeleteSessionScreenState extends State<DeleteSessionScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> sessions = [];

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final userUid = user.uid;

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userUid)
          .collection('sessions')
          .orderBy('sessionDate', descending: true)
          .get();

      setState(() {
        sessions = snapshot.docs;
      });
    } catch (e) {
      print('Error fetching sessions: $e');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final userUid = user.uid;

    try {
      await _firestore
          .collection('users')
          .doc(userUid)
          .collection('sessions')
          .doc(sessionId)
          .delete();

      // Notify the user that the session has been successfully deleted.
      final sessionName =
      sessions.firstWhere((session) => session.id == sessionId)['sessionName'];
      _showDeleteToast(sessionName);

      // Remove the deleted session from the local list.
      setState(() {
        sessions.removeWhere((session) => session.id == sessionId);
      });

      // Notify the HomeScreen that a session has been deleted.
      Navigator.of(context).pop(true);
    } catch (e) {
      print('Error deleting session: $e');
    }
  }

  void _showDeleteToast(String sessionName) {
    Fluttertoast.showToast(
      msg: 'Session "$sessionName" deleted',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Sessions'),
      ),
      body: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.event),
              title: Text('Session: ${session['sessionName']}'),
              subtitle: Text('Date: ${_formatTimestamp(session['sessionDate'])}'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showDeleteDialog(context, session.id, session['sessionName']);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  Future<void> _showDeleteDialog(BuildContext context, String sessionId, String sessionName) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete Session'),
          content: Text('Are you sure you want to delete the session: "$sessionName"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                deleteSession(sessionId);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
