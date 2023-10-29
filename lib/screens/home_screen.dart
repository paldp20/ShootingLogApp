import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shooting_log_flutter/screens/create_session_screen.dart';
import 'package:shooting_log_flutter/screens/signin_screen.dart';
import 'package:shooting_log_flutter/screens/view_session_screen.dart';
import 'package:shooting_log_flutter/screens/delete_session_screen.dart'; // Import the DeleteSessionScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<FlSpot> sampleData = [];
  String recentSessionDetails = '';
  bool showSessionDetails = false;
  bool dataLoaded = false;
  String username = '';

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchUsername(); // Fetch the username when the home screen initializes.
  }

  Future<void> fetchData() async {
    await fetchLastSessions();
    await fetchRecentSessionDetails();
    setState(() {
      dataLoaded = true;
    });
  }

  Future<void> fetchLastSessions() async {
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
          .limit(10)
          .get();

      final sessions = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      sampleData.clear();

      for (int i = 0; i < sessions.length; i++) {
        double dateAsDouble;

        final sessionDate = sessions[i]['sessionDate'];

        if (sessionDate is Timestamp) {
          DateTime date = sessionDate.toDate();
          String formattedDate = DateFormat('dd.MM').format(date);
          dateAsDouble = double.parse(formattedDate);
        } else {
          dateAsDouble = 0.0;
        }

        final score = sessions[i]['score'] as int? ?? 0;
        final shots = sessions[i]['numShots'] as int? ?? 1;

        if (shots > 0 && score >= 0) {
          final value = (score.toDouble() / shots.toDouble());
          if (!value.isNaN && !value.isInfinite) {
            sampleData.add(FlSpot(dateAsDouble, value));
          } else {
            sampleData.add(FlSpot(dateAsDouble, 0.0));
          }
        } else {
          sampleData.add(FlSpot(dateAsDouble, 0.0));
        }
      }
    } catch (e) {
      print('Error fetching sessions: $e');
    }
  }

  Future<void> fetchRecentSessionDetails() async {
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
          .limit(1)
          .get();

      final recentSession = snapshot.docs.isNotEmpty
          ? snapshot.docs.first.data() as Map<String, dynamic>?
          : null;

      if (recentSession != null) {
        final sessionDate = recentSession['sessionDate'] as Timestamp?;
        final sessionName = recentSession['sessionName'] as String? ?? '';
        final shots = recentSession['numShots'] as int? ?? 0;
        final score = recentSession['score'] as int? ?? 0;
        final notes = recentSession['notes'] as String? ?? '';

        if (sessionDate != null) {
          final date = sessionDate.toDate();
          final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
          recentSessionDetails =
          'Session Date: $formattedDate\nSession Name: $sessionName\nShots: $shots\nScore: $score\nNotes: $notes';
        } else {
          recentSessionDetails = 'Session Date is not available';
        }
      }
    } catch (e) {
      print('Error fetching recent session details: $e');
    }
  }

  Future<void> fetchUsername() async {
    final user = _auth.currentUser;

    if (user != null) {
      final userUid = user.uid;

      try {
        final userData = await _firestore.collection('users').doc(userUid).get();
        if (userData.exists) {
          final username = userData.get('username');
          setState(() {
            this.username = username;
          });
        }
      } catch (e) {
        print('Error fetching username: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome $username'), // Display the username in the app bar
        actions: [
          PopupMenuButton<String>(
            onSelected: (choice) {
              if (choice == 'create_a_session') {
                // Navigate to CreateSessionScreen and wait for result
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateSessionScreen())).then((value) {
                  // Refresh session data when returning from CreateSessionScreen
                  fetchData();
                });
              } else if (choice == 'view_session_details') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ViewSessionDetailsScreen()));
              } else if (choice == 'delete_a_session') {
                // Navigate to the DeleteSessionScreen
                Navigator.push(context, MaterialPageRoute(builder: (context) => DeleteSessionScreen()));
              } else if (choice == 'logout') {
                _auth.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
              }
            },
            itemBuilder: (BuildContext context) {
              return ['Create a session', 'View session details', 'Delete a session', 'Logout'] // Include 'Delete a session' in the menu
                  .map((choice) {
                return PopupMenuItem<String>(
                  value: choice.toLowerCase().replaceAll(' ', '_'),
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Check out the graph of your progress here!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              color: Color(0xFFA0D2EB),
              height: 300,
              child: dataLoaded
                  ? BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(showTitles: true),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) {
                        if (value >= 0 && value < sampleData.length) {
                          final date = sampleData[value.toInt()].x.toStringAsFixed(0);
                          return date;
                        }
                        return '';
                      },
                    ),
                  ),
                  barGroups: sampleData
                      .asMap()
                      .entries
                      .map(
                        (entry) => BarChartGroupData(x: entry.key, barRods: [
                      BarChartRodData(
                        y: entry.value.y,
                        width: 20,
                        colors: [Colors.blue],
                      ),
                    ]),
                  )
                      .toList(),
                ),
              )
                  : Center(
                child: CircularProgressIndicator(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showSessionDetails = !showSessionDetails;
                });
              },
              child: Text(
                'View Last Session Details',
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFF8458B3)),
              ),
            ),
            Visibility(
              visible: showSessionDetails,
              child: Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(recentSessionDetails),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.add, color: Color(0xFF8458B3)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateSessionScreen())).then((value) {
                  // Refresh session data when returning from CreateSessionScreen
                  fetchData();
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.list, color: Color(0xFF8458B3)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ViewSessionDetailsScreen()));
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_outlined, color: Color(0xFF8458B3)),
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => DeleteSessionScreen()));

                // Check if a session has been deleted (result is true).
                if (result == true) {
                  // Refresh session data when returning from DeleteSessionScreen
                  fetchData();
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Color(0xFF8458B3)),
              onPressed: () {
                _auth.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
