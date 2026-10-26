import 'package:flutter_test/flutter_test.dart';
import 'package:campersit_app/models/sensor.dart';

void main() {
  group('Sensor Model Tests', () {
    test('parses sensor correctly with seenAt, tag, battery, type, and state', () {
      final map = {
        'type': 1,
        'state': 'e',
        'tag': 'Front Door Camera',
        'battery': 85,
        'seenAt': 1760790600000,
      };

      final sensor = Sensor.fromMap('cam_01', map);

      expect(sensor.id, equals('cam_01'));
      expect(sensor.type, equals(SensorType.camera));
      expect(sensor.state, equals(SensorState.enabled));
      expect(sensor.tag, equals('Front Door Camera'));
      expect(sensor.battery, equals(85));
      expect(sensor.seenAt, equals(1760790600000));
    });

    test('maps all sensor types from 1 to 5 correctly', () {
      expect(SensorType.fromValue(1), equals(SensorType.camera));
      expect(SensorType.fromValue(2), equals(SensorType.motion));
      expect(SensorType.fromValue(3), equals(SensorType.air));
      expect(SensorType.fromValue(4), equals(SensorType.led));
      expect(SensorType.fromValue(5), equals(SensorType.buzzer));
      expect(SensorType.fromValue('camera'), equals(SensorType.camera));
      expect(SensorType.fromValue('motion'), equals(SensorType.motion));
      expect(SensorType.fromValue('air'), equals(SensorType.air));
      expect(SensorType.fromValue('led'), equals(SensorType.led));
      expect(SensorType.fromValue('buzzer'), equals(SensorType.buzzer));
      expect(SensorType.fromValue(999), equals(SensorType.unknown));
    });

    test('maps all sensor states u, d, p, e, t, s, x correctly', () {
      expect(SensorState.fromCode('u'), equals(SensorState.unpaired));
      expect(SensorState.fromCode('d'), equals(SensorState.disabled));
      expect(SensorState.fromCode('p'), equals(SensorState.paired));
      expect(SensorState.fromCode('e'), equals(SensorState.enabled));
      expect(SensorState.fromCode('t'), equals(SensorState.triggered));
      expect(SensorState.fromCode('s'), equals(SensorState.started));
      expect(SensorState.fromCode('x'), equals(SensorState.deleted));
      expect(SensorState.fromCode('unknown'), equals(SensorState.unknown));
    });

    test('handles fallback when fields are missing or null', () {
      final sensor = Sensor.fromMap('', const {});

      expect(sensor.id, isEmpty);
      expect(sensor.type, equals(SensorType.unknown));
      expect(sensor.state, equals(SensorState.unknown));
      expect(sensor.tag, isNull);
      expect(sensor.battery, isNull);
      expect(sensor.seenAt, isNull);
    });

    test('parses sensor correctly with int seenAt', () {
      const epochMilliseconds = 1760790600000;
      final sensor = Sensor.fromMap('air_01', const {
        'type': 3,
        'seenAt': epochMilliseconds,
      });

      expect(sensor.id, equals('air_01'));
      expect(sensor.seenAt, equals(epochMilliseconds));
    });

    test('serializes to map correctly without id', () {
      final timestamp = DateTime(2026, 10, 17, 10, 30).millisecondsSinceEpoch;
      final sensor = Sensor(
        id: 'air_01',
        type: SensorType.air,
        state: SensorState.triggered,
        tag: 'Cabin Air',
        battery: 92,
        seenAt: timestamp,
      );

      final map = sensor.toMap();

      expect(map.containsKey('id'), isFalse);
      expect(map['type'], equals(3));
      expect(map['state'], equals('t'));
      expect(map['tag'], equals('Cabin Air'));
      expect(map['battery'], equals(92));
      expect(map['seenAt'], equals(timestamp));
    });

    test('parses alerts map correctly and serializes when not empty', () {
      final map = {
        'type': 2,
        'state': 'e',
        'alerts': {
          'tamper': true,
          'motion': false,
          'battery': 'low',
        },
      };

      final sensor = Sensor.fromMap('motion_01', map);

      expect(
        sensor.alerts,
        equals({'tamper': true, 'motion': false, 'battery': 'low'}),
      );

      final serialized = sensor.toMap();
      expect(
        serialized['alerts'],
        equals({'tamper': true, 'motion': false, 'battery': 'low'}),
      );
    });

    test('defaults alerts to empty map when missing in map', () {
      final sensor = Sensor.fromMap('cam_02', const {'type': 1});

      expect(sensor.alerts, isEmpty);
      expect(sensor.toMap().containsKey('alerts'), isFalse);
    });

    test('parses values map correctly with temperature and humidity', () {
      final map = {
        'type': 3,
        'state': 'e',
        'values': {
          'temperature': 21.5,
          'humidity': 48,
        },
      };

      final sensor = Sensor.fromMap('air_01', map);

      expect(sensor.values, equals({'temperature': 21.5, 'humidity': 48}));
      expect(sensor.temperature, equals(22));
      expect(sensor.humidity, equals(48));

      final serialized = sensor.toMap();
      expect(serialized['values'], equals({'temperature': 21.5, 'humidity': 48}));
    });

    test('defaults values to empty map when missing and getters return null', () {
      final sensor = Sensor.fromMap('air_02', const {'type': 3});

      expect(sensor.values, isEmpty);
      expect(sensor.temperature, isNull);
      expect(sensor.humidity, isNull);
      expect(sensor.toMap().containsKey('values'), isFalse);
    });

    test('isActuator correctly identifies actuators vs non-actuators', () {
      expect(SensorType.camera.isActuator, isTrue);
      expect(SensorType.led.isActuator, isTrue);
      expect(SensorType.buzzer.isActuator, isTrue);
      expect(SensorType.motion.isActuator, isFalse);
      expect(SensorType.air.isActuator, isFalse);
      expect(SensorType.unknown.isActuator, isFalse);
    });

    test('availableTransitions returns expected transitions based on state and type', () {
      const pairedActuator = Sensor(
        id: 'cam-1',
        type: SensorType.camera,
        state: SensorState.paired,
      );
      expect(
        pairedActuator.availableTransitions,
        equals([SensorState.enabled, SensorState.started]),
      );

      const pairedMotion = Sensor(
        id: 'mot-1',
        type: SensorType.motion,
        state: SensorState.paired,
      );
      expect(
        pairedMotion.availableTransitions,
        equals([SensorState.enabled]),
      );

      const triggeredMotion = Sensor(
        id: 'mot-2',
        type: SensorType.motion,
        state: SensorState.triggered,
      );
      expect(
        triggeredMotion.availableTransitions,
        equals([SensorState.enabled, SensorState.paired]),
      );

      const enabledSensor = Sensor(
        id: 'air-1',
        type: SensorType.air,
        state: SensorState.enabled,
      );
      expect(
        enabledSensor.availableTransitions,
        equals([SensorState.paired]),
      );

      const startedActuator = Sensor(
        id: 'led-1',
        type: SensorType.led,
        state: SensorState.started,
      );
      expect(
        startedActuator.availableTransitions,
        equals([SensorState.enabled, SensorState.paired]),
      );

      const startedMotion = Sensor(
        id: 'mot-3',
        type: SensorType.motion,
        state: SensorState.started,
      );
      expect(startedMotion.availableTransitions, isEmpty);

      const unpairedSensor = Sensor(
        id: 'mot-4',
        type: SensorType.motion,
        state: SensorState.unpaired,
      );
      expect(unpairedSensor.availableTransitions, isEmpty);
    });

    test('parses actions list correctly and serializes when not empty', () {
      final map = {
        'type': 2,
        'state': 'e',
        'actions': ['cam_01', 'led_01'],
      };

      final sensor = Sensor.fromMap('motion_01', map);

      expect(sensor.actions, equals(['cam_01', 'led_01']));
      final serialized = sensor.toMap();
      expect(serialized['actions'], equals(['cam_01', 'led_01']));
    });

    test('defaults actions to empty list when absent in map', () {
      final sensor = Sensor.fromMap('motion_02', const {'type': 2});

      expect(sensor.actions, isEmpty);
      expect(sensor.toMap().containsKey('actions'), isFalse);
    });
  });
}
