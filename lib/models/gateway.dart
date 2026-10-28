import 'sensor.dart';
export 'sensor.dart';

class GatewayLocationPoint {
  final int datetime;
  final double latitude;
  final double longitude;

  const GatewayLocationPoint({
    required this.datetime,
    required this.latitude,
    required this.longitude,
  });

  String get formattedCoordinates => '$latitude, $longitude';

  factory GatewayLocationPoint.fromMap(Map<String, Object?> map) {
    return GatewayLocationPoint(
      datetime: map['datetime'] as int? ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, Object?> toMap() {
    return {'datetime': datetime, 'latitude': latitude, 'longitude': longitude};
  }
}

class GatewayLocation {
  final GatewayLocationPoint? approx;
  final GatewayLocationPoint? exact;
  final int? startedAt;

  const GatewayLocation({this.approx, this.exact, this.startedAt});

  factory GatewayLocation.fromMap(Map<String, Object?> map) {
    final approx = (map['approx'] as Map?)?.cast<String, Object?>();
    final exact = (map['exact'] as Map?)?.cast<String, Object?>();
    return GatewayLocation(
      approx: approx != null ? GatewayLocationPoint.fromMap(approx) : null,
      exact: exact != null ? GatewayLocationPoint.fromMap(exact) : null,
      startedAt: map['startedAt'] as int?,
    );
  }

  Map<String, Object?> toMap() {
    final approxPoint = approx;
    final exactPoint = exact;
    return {
      if (approxPoint != null) 'approx': approxPoint.toMap(),
      if (exactPoint != null) 'exact': exactPoint.toMap(),
      if (startedAt != null) 'startedAt': startedAt,
    };
  }
}

abstract final class GatewayStates {
  static const connected = 'c';
  static const inactive = 'i';
  static const localizing = 'l';
}

String gatewayStateLabel(String state) => switch (state) {
  GatewayStates.connected => 'Connected',
  GatewayStates.inactive => 'Inactive',
  GatewayStates.localizing => 'Localizing...',
  _ => 'Unknown',
};

class Gateway {
  final String id;
  final String state;
  final int? seenAt;
  final String userId;
  final Map<String, Object?> alerts;
  final GatewayLocation? location;
  final List<Sensor> sensors;

  const Gateway({
    required this.id,
    required this.state,
    this.seenAt,
    required this.userId,
    this.alerts = const {},
    this.location,
    this.sensors = const [],
  });

  String get stateLabel => gatewayStateLabel(state);
  bool get isLocalizing => state == GatewayStates.localizing;
  bool get isConnected => state == GatewayStates.connected;

  factory Gateway.fromMap(String id, Map<String, Object?> map) {
    final rawSensors = (map['sensors'] as Map?)?.cast<String, Object?>();
    final sensors = rawSensors != null
        ? rawSensors.entries
              .map(
                (entry) => Sensor.fromMap(
                  entry.key,
                  (entry.value as Map).cast<String, Object?>(),
                ),
              )
              .where((sensor) => sensor.state != SensorState.unpaired)
              .toList()
        : const <Sensor>[];

    final rawLocation = (map['location'] as Map?)?.cast<String, Object?>();

    return Gateway(
      id: id,
      state: map['state'] as String? ?? GatewayStates.inactive,
      seenAt: map['seenAt'] as int?,
      userId: map['userId'] as String? ?? '',
      alerts: (map['alerts'] as Map?)?.cast<String, Object?>() ?? const {},
      location: rawLocation != null
          ? GatewayLocation.fromMap(rawLocation)
          : null,
      sensors: sensors,
    );
  }

  Map<String, Object?> toMap() {
    final sensorsMap = <String, Object?>{};
    for (final sensor in sensors) {
      sensorsMap[sensor.id] = sensor.toMap();
    }
    final locationData = location;

    return {
      'state': state,
      'seenAt': seenAt,
      'userId': userId,
      'alerts': alerts,
      if (locationData != null) 'location': locationData.toMap(),
      'sensors': sensorsMap,
    };
  }
}
