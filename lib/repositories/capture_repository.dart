import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/capture.dart';

class CaptureRepository {
  final FirebaseFirestore _firestore;

  CaptureRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Capture>> watchCameraCaptures({
    required String userId,
    required String deviceId,
    required String sensorId,
  }) {
    return _firestore
        .collection('captures')
        .where('userId', isEqualTo: userId)
        .where('deviceId', isEqualTo: deviceId)
        .where('sensorId', isEqualTo: sensorId)
        .snapshots()
        .map((snapshot) {
          final captures = snapshot.docs.map((doc) {
            return Capture.fromMap(doc.id, doc.data());
          }).toList();
          captures.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return captures;
        });
  }
}
