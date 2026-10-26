// ignore_for_file: subtype_of_sealed_class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/repositories/gateway_repository.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseFunctions mockFunctions;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;
  late GatewayRepository repository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockFunctions = MockFirebaseFunctions();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();

    when(() => mockFirestore.collection('devices')).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocument);

    repository = GatewayRepository(
      firestore: mockFirestore,
      functions: mockFunctions,
    );
  });

  group('GatewayRepository', () {
    test('updateSensorAction adds actuator ID using arrayUnion when enabled is true', () async {
      when(() => mockDocument.update(any())).thenAnswer((_) async {});

      await repository.updateSensorAction(
        gatewayId: 'gw-1',
        sensorId: 'motion-1',
        actuatorId: 'cam-1',
        enabled: true,
      );

      verify(() => mockCollection.doc('gw-1')).called(1);
      final captured = verify(() => mockDocument.update(captureAny())).captured;
      final updateData = (captured.first as Map).cast<String, Object?>();

      expect(updateData.containsKey('sensors.motion-1.actions'), isTrue);
      expect(
        updateData['sensors.motion-1.actions'],
        equals(FieldValue.arrayUnion(['cam-1'])),
      );
    });

    test('updateSensorAction removes actuator ID using arrayRemove when enabled is false', () async {
      when(() => mockDocument.update(any())).thenAnswer((_) async {});

      await repository.updateSensorAction(
        gatewayId: 'gw-1',
        sensorId: 'motion-1',
        actuatorId: 'cam-1',
        enabled: false,
      );

      verify(() => mockCollection.doc('gw-1')).called(1);
      final captured = verify(() => mockDocument.update(captureAny())).captured;
      final updateData = (captured.first as Map).cast<String, Object?>();

      expect(updateData.containsKey('sensors.motion-1.actions'), isTrue);
      expect(
        updateData['sensors.motion-1.actions'],
        equals(FieldValue.arrayRemove(['cam-1'])),
      );
    });

    test('updateSensorTag updates tag field in Firestore', () async {
      when(() => mockDocument.update(any())).thenAnswer((_) async {});

      await repository.updateSensorTag(
        gatewayId: 'gw-1',
        sensorId: 'motion-1',
        tag: 'Hallway Motion',
      );

      verify(() => mockDocument.update({
        'sensors.motion-1.tag': 'Hallway Motion',
      })).called(1);
    });
  });
}
