import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/gateway.dart';

class GatewayRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Stream<List<Gateway>> watchUserGateways(String userId) {
    return _firestore
        .collection('devices')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Gateway.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  Stream<Gateway?> watchGateway(String gatewayId) {
    return _firestore
        .collection('devices')
        .doc(gatewayId)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          if (!snapshot.exists || data == null) {
            return null;
          }
          return Gateway.fromMap(snapshot.id, data);
        });
  }

  Future<void> addGateway(String gatewayId) async {
    final callable = _functions.httpsCallable('addDevice');
    await callable.call({'deviceId': gatewayId});
  }

  Future<void> deleteGateway(String gatewayId) async {
    final callable = _functions.httpsCallable('deleteDevice');
    await callable.call({'deviceId': gatewayId});
  }

  Future<void> requestLocation(String gatewayId) async {
    final callable = _functions.httpsCallable('localize');
    await callable.call({'deviceId': gatewayId});
  }

  Future<void> stopLocation(String gatewayId) async {
    final callable = _functions.httpsCallable('stopLocalize');
    await callable.call({'deviceId': gatewayId});
  }
}
