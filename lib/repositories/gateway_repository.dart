import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/gateway.dart';

class GatewayRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  GatewayRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;

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
    return _firestore.collection('devices').doc(gatewayId).snapshots().map((
      snapshot,
    ) {
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

  Future<void> armGateway(String gatewayId) async {
    final callable = _functions.httpsCallable('armDevice');
    await callable.call({'deviceId': gatewayId});
  }

  Future<void> disarmGateway(String gatewayId) async {
    final callable = _functions.httpsCallable('disarmDevice');
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

  Future<void> addSensor({
    required String gatewayId,
    required String sensorId,
  }) async {
    final callable = _functions.httpsCallable('addSensor');
    await callable.call({'deviceId': gatewayId, 'sensorId': sensorId});
  }

  Future<void> sendRequestState({
    required String gatewayId,
    required String sensorId,
    required SensorState state,
  }) async {
    final callable = _functions.httpsCallable('sendRequestState');
    await callable.call({
      'deviceId': gatewayId,
      'sensorId': sensorId,
      'state': state.code,
    });
  }

  Future<void> deleteSensor({
    required String gatewayId,
    required String sensorId,
  }) => sendRequestState(
    gatewayId: gatewayId,
    sensorId: sensorId,
    state: SensorState.unpaired,
  );

  Future<void> updateSensorTag({
    required String gatewayId,
    required String sensorId,
    required String tag,
  }) async {
    await _firestore.collection('devices').doc(gatewayId).update({
      'sensors.$sensorId.tag': tag,
    });
  }

  Future<void> updateSensorAction({
    required String gatewayId,
    required String sensorId,
    required String actuatorId,
    required bool enabled,
  }) async {
    await _firestore.collection('devices').doc(gatewayId).update({
      'sensors.$sensorId.actions': enabled
          ? FieldValue.arrayUnion([actuatorId])
          : FieldValue.arrayRemove([actuatorId]),
    });
  }
}
