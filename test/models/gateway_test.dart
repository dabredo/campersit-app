import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/models/gateway.dart';

void main() {
  group('Gateway Sensors Tests', () {
    test('parses gateway with sensors map successfully', () {
      final map = {
        'state': 'c',
        'userId': 'user-123',
        'alerts': {},
        'sensors': {
          'sensor_air': {
            'type': 3,
            'state': 'e',
            'name': 'Indoor Air Quality',
            'value': 21.4,
            'unit': 'ppm',
          },
          'sensor_motion': {
            'type': 2,
            'state': 't',
            'name': 'Entry Motion',
            'value': true,
          },
        },
      };

      final gateway = Gateway.fromMap('gw-001', map);

      expect(gateway.id, equals('gw-001'));
      expect(gateway.sensors.length, equals(2));
      final airSensor = gateway.sensors.firstWhere((s) => s.id == 'sensor_air');
      expect(airSensor.type, equals(SensorType.air));
      expect(airSensor.state, equals(SensorState.enabled));

      final motionSensor = gateway.sensors.firstWhere((s) => s.id == 'sensor_motion');
      expect(motionSensor.type, equals(SensorType.motion));
      expect(motionSensor.state, equals(SensorState.triggered));
    });

    test('excludes sensors with unpaired state', () {
      final map = {
        'state': 'c',
        'userId': 'user-123',
        'alerts': {},
        'sensors': {
          'sensor_paired': {
            'type': 3,
            'state': 'e',
          },
          'sensor_unpaired': {
            'type': 2,
            'state': 'u',
          },
        },
      };

      final gateway = Gateway.fromMap('gw-001', map);

      expect(gateway.sensors.length, equals(1));
      expect(gateway.sensors.first.id, equals('sensor_paired'));
    });

    test('defaults to empty list if sensors array is missing', () {
      final map = {
        'state': 'i',
        'userId': 'user-456',
        'alerts': {},
      };

      final gateway = Gateway.fromMap('gw-002', map);

      expect(gateway.sensors, isEmpty);
      expect(gateway.seenAt, isNull);
    });

    test('parses seenAt as int and serializes it in toMap', () {
      const timestamp = 1760790600000;
      final map = {
        'state': 'c',
        'userId': 'user-123',
        'alerts': {},
        'seenAt': timestamp,
      };

      final gateway = Gateway.fromMap('gw-003', map);

      expect(gateway.seenAt, equals(timestamp));

      final serialized = gateway.toMap();
      expect(serialized['seenAt'], equals(timestamp));
    });

    test('maps state codes to readable labels and state getters', () {
      expect(GatewayStates.connected, equals('c'));
      expect(GatewayStates.inactive, equals('i'));
      expect(GatewayStates.localizing, equals('l'));

      expect(gatewayStateLabel(GatewayStates.connected), equals('Connected'));
      expect(gatewayStateLabel(GatewayStates.inactive), equals('Inactive'));
      expect(gatewayStateLabel(GatewayStates.localizing), equals('Localizing...'));
      expect(gatewayStateLabel('unknown'), equals('Unknown'));

      final connectedGateway = Gateway(
        id: 'gw-c',
        state: 'c',
        userId: 'u1',
        alerts: {},
      );
      expect(connectedGateway.stateLabel, equals('Connected'));
      expect(connectedGateway.isConnected, isTrue);
      expect(connectedGateway.isLocalizing, isFalse);

      final localizingGateway = Gateway(
        id: 'gw-l',
        state: 'l',
        userId: 'u1',
        alerts: {},
      );
      expect(localizingGateway.stateLabel, equals('Localizing...'));
      expect(localizingGateway.isConnected, isFalse);
      expect(localizingGateway.isLocalizing, isTrue);
    });

    test('formats coordinates correctly in GatewayLocationPoint', () {
      const point = GatewayLocationPoint(
        datetime: 12345,
        latitude: 40.5,
        longitude: -3.7,
      );
      expect(point.formattedCoordinates, equals('40.5, -3.7'));
    });

    test('supports const constructors for Gateway, GatewayLocation, and GatewayLocationPoint', () {
      const point = GatewayLocationPoint(
        datetime: 12345,
        latitude: 40.5,
        longitude: -3.7,
      );
      const location = GatewayLocation(
        approx: point,
        exact: point,
        startedAt: 12345,
      );
      const gateway = Gateway(
        id: 'gw-const',
        state: GatewayStates.connected,
        userId: 'u-1',
        location: location,
      );

      expect(gateway.id, equals('gw-const'));
      expect(gateway.alerts, isEmpty);
      expect(gateway.sensors, isEmpty);
      expect(gateway.location?.exact?.latitude, equals(40.5));
    });
  });
}
