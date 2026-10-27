// ignore_for_file: subtype_of_sealed_class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:campersit_app/repositories/notification_repository.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {}

class FakeSetOptions extends Fake implements SetOptions {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockWriteBatch extends Mock implements WriteBatch {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDocumentReference());
    registerFallbackValue(FakeSetOptions());
  });

  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockNotificationsCollection;
  late MockCollectionReference mockUsersCollection;
  late MockCollectionReference mockTokensCollection;
  late MockDocumentReference mockUserDoc;
  late MockDocumentReference mockTokenDoc;
  late MockWriteBatch mockBatch;
  late NotificationRepository repository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockNotificationsCollection = MockCollectionReference();
    mockUsersCollection = MockCollectionReference();
    mockTokensCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockTokenDoc = MockDocumentReference();
    mockBatch = MockWriteBatch();

    when(() => mockFirestore.collection('notifications'))
        .thenReturn(mockNotificationsCollection);
    when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(() => mockFirestore.batch()).thenReturn(mockBatch);

    when(() => mockUsersCollection.doc(any())).thenReturn(mockUserDoc);
    when(() => mockUserDoc.collection('browsers')).thenReturn(mockTokensCollection);
    when(() => mockTokensCollection.doc(any())).thenReturn(mockTokenDoc);

    when(() => mockBatch.commit()).thenAnswer((_) async {});

    repository = NotificationRepository(firestore: mockFirestore);
  });

  group('NotificationRepository Tests', () {
    test('watchNotificationsForGateways returns empty stream if gatewayIds is empty', () async {
      final stream = repository.watchNotificationsForGateways([]);
      final result = await stream.first;
      expect(result, isEmpty);
      verifyNever(() => mockFirestore.collection('notifications'));
    });

    test('watchNotificationsForGateways queries notifications and sorts descending', () async {
      final mockQuery = MockQuery();
      final mockSnapshot = MockQuerySnapshot();
      final doc1 = MockQueryDocumentSnapshot();
      final doc2 = MockQueryDocumentSnapshot();

      when(() => mockNotificationsCollection.where('gatewayId', whereIn: any(named: 'whereIn')))
          .thenReturn(mockQuery);
      when(() => mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockSnapshot));

      when(() => doc1.id).thenReturn('notif_1');
      when(() => doc1.data()).thenReturn({
        'type': 'device-initializing',
        'gatewayId': 'gw_1',
        'createdAt': 1000,
      });

      when(() => doc2.id).thenReturn('notif_2');
      when(() => doc2.data()).thenReturn({
        'type': 'sensor-triggered',
        'gatewayId': 'gw_1',
        'sensorId': 'motion_1',
        'createdAt': 2000,
      });

      when(() => mockSnapshot.docs).thenReturn([doc1, doc2]);

      final stream = repository.watchNotificationsForGateways(['gw_1']);
      final results = await stream.first;

      expect(results.length, equals(2));
      expect(results[0].id, equals('notif_2'));
      expect(results[1].id, equals('notif_1'));
    });

    test('watchNotificationsForGateways respects limit parameter', () async {
      final mockQuery = MockQuery();
      final mockSnapshot = MockQuerySnapshot();
      final doc1 = MockQueryDocumentSnapshot();
      final doc2 = MockQueryDocumentSnapshot();

      when(() => mockNotificationsCollection.where('gatewayId', whereIn: any(named: 'whereIn')))
          .thenReturn(mockQuery);
      when(() => mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockSnapshot));

      when(() => doc1.id).thenReturn('notif_1');
      when(() => doc1.data()).thenReturn({
        'type': 'device-initializing',
        'gatewayId': 'gw_1',
        'createdAt': 1000,
      });

      when(() => doc2.id).thenReturn('notif_2');
      when(() => doc2.data()).thenReturn({
        'type': 'sensor-triggered',
        'gatewayId': 'gw_1',
        'sensorId': 'motion_1',
        'createdAt': 2000,
      });

      when(() => mockSnapshot.docs).thenReturn([doc1, doc2]);

      final stream = repository.watchNotificationsForGateways(['gw_1'], limit: 1);
      final results = await stream.first;

      expect(results.length, equals(1));
      expect(results[0].id, equals('notif_2'));
    });

    test('watchGatewayNotifications queries single gateway notifications', () async {
      final mockQuery = MockQuery();
      final mockSnapshot = MockQuerySnapshot();
      final doc1 = MockQueryDocumentSnapshot();

      when(() => mockNotificationsCollection.where('gatewayId', isEqualTo: any(named: 'isEqualTo')))
          .thenReturn(mockQuery);
      when(() => mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockSnapshot));

      when(() => doc1.id).thenReturn('notif_1');
      when(() => doc1.data()).thenReturn({
        'type': 'device-initializing',
        'gatewayId': 'gw_1',
        'createdAt': 1000,
      });

      when(() => mockSnapshot.docs).thenReturn([doc1]);

      final stream = repository.watchGatewayNotifications('gw_1');
      final results = await stream.first;

      expect(results.length, equals(1));
      expect(results.first.id, equals('notif_1'));
    });

    test('saveDeviceToken commits strictly fcmToken, lastUpdated, and userAgent to browsers', () async {
      when(() => mockBatch.set<Map<String, dynamic>>(any(), any(), any())).thenReturn(null);

      await repository.saveDeviceToken(
        userId: 'user_123',
        token: 'fcm_token_sample_12345678901234567890',
      );

      verify(() => mockBatch.set<Map<String, dynamic>>(
            mockTokenDoc,
            any(
              that: isA<Map<String, dynamic>>()
                  .having((m) => m['fcmToken'], 'fcmToken', equals('fcm_token_sample_12345678901234567890'))
                  .having((m) => m.containsKey('lastUpdated'), 'lastUpdated', isTrue)
                  .having((m) => m.containsKey('userAgent'), 'userAgent', isTrue),
            ),
            any(),
          )).called(1);
      verify(() => mockBatch.commit()).called(1);
    });

    test('removeDeviceToken deletes token from browsers subcollection', () async {
      when(() => mockTokenDoc.delete()).thenAnswer((_) async {});

      await repository.removeDeviceToken(
        userId: 'user_123',
        token: 'fcm_token_sample_12345678901234567890',
      );

      verify(() => mockTokenDoc.delete()).called(1);
    });
  });
}
