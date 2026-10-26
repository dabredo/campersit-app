// ignore_for_file: subtype_of_sealed_class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/repositories/capture_repository.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult<T> extends Mock
    implements HttpsCallableResult<T> {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseFunctions mockFunctions;
  late MockHttpsCallable mockCallable;
  late MockCollectionReference mockCollection;
  late MockQuery mockQuery1;
  late MockQuery mockQuery2;
  late MockQuery mockQuery3;
  late MockQuerySnapshot mockSnapshot;
  late MockQueryDocumentSnapshot mockDoc1;
  late MockQueryDocumentSnapshot mockDoc2;
  late CaptureRepository repository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockFunctions = MockFirebaseFunctions();
    mockCallable = MockHttpsCallable();
    mockCollection = MockCollectionReference();
    mockQuery1 = MockQuery();
    mockQuery2 = MockQuery();
    mockQuery3 = MockQuery();
    mockSnapshot = MockQuerySnapshot();
    mockDoc1 = MockQueryDocumentSnapshot();
    mockDoc2 = MockQueryDocumentSnapshot();

    repository = CaptureRepository(
      firestore: mockFirestore,
      functions: mockFunctions,
    );
  });

  group('CaptureRepository', () {
    test('deleteCapture invokes deleteCapture Cloud Function with captureId', () async {
      when(() => mockFunctions.httpsCallable('deleteCapture'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call({'captureId': 'cap-123'}))
          .thenAnswer((_) async => MockHttpsCallableResult<dynamic>());

      await repository.deleteCapture('cap-123');

      verify(() => mockFunctions.httpsCallable('deleteCapture')).called(1);
      verify(() => mockCallable.call({'captureId': 'cap-123'})).called(1);
    });

    test('watchCameraCaptures streams and sorts captures descending', () async {
      when(() => mockFirestore.collection('captures')).thenReturn(mockCollection);
      when(
        () => mockCollection.where('userId', isEqualTo: 'user-1'),
      ).thenReturn(mockQuery1);
      when(
        () => mockQuery1.where('deviceId', isEqualTo: 'gw-1'),
      ).thenReturn(mockQuery2);
      when(
        () => mockQuery2.where('sensorId', isEqualTo: 'cam-1'),
      ).thenReturn(mockQuery3);
      when(() => mockQuery3.snapshots()).thenAnswer(
        (_) => Stream.value(mockSnapshot),
      );

      when(() => mockDoc1.id).thenReturn('cap-older');
      when(() => mockDoc1.data()).thenReturn({
        'userId': 'user-1',
        'deviceId': 'gw-1',
        'sensorId': 'cam-1',
        'url': 'https://storage/video1.mp4',
        'createdAt': 1000,
      });

      when(() => mockDoc2.id).thenReturn('cap-newer');
      when(() => mockDoc2.data()).thenReturn({
        'userId': 'user-1',
        'deviceId': 'gw-1',
        'sensorId': 'cam-1',
        'url': 'https://storage/video2.mp4',
        'createdAt': 2000,
      });

      when(() => mockSnapshot.docs).thenReturn([mockDoc1, mockDoc2]);

      final stream = repository.watchCameraCaptures(
        userId: 'user-1',
        deviceId: 'gw-1',
        sensorId: 'cam-1',
      );

      final list = await stream.first;

      expect(list.length, equals(2));
      expect(list.first.id, equals('cap-newer'));
      expect(list.last.id, equals('cap-older'));
    });
  });
}
