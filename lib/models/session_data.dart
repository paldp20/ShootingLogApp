import 'package:cloud_firestore/cloud_firestore.dart';

class SessionData {
  Timestamp? sessionDate;
  String? sessionName;
  int? numberOfShots;
  int? score;
  String? notes;

  SessionData({
    this.sessionDate,
    this.sessionName,
    this.numberOfShots,
    this.score,
    this.notes,
  });
}
