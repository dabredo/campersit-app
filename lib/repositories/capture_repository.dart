import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/capture.dart';

class CaptureRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CaptureRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  Future<void> deleteCapture(String captureId) async {
    final callable = _functions.httpsCallable('deleteCapture');
    await callable.call({'captureId': captureId});
  }

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
