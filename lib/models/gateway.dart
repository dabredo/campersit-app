import 'sensor.dart';
export 'sensor.dart';

class GatewayLocationPoint {
  final int datetime;
  final double latitude;
  final double longitude;

  GatewayLocationPoint({
    required this.datetime,
    required this.latitude,
    required this.longitude,
  });

  factory GatewayLocationPoint.fromMap(Map<String, dynamic> map) {
    return GatewayLocationPoint(
      datetime: map['datetime'] as int? ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'datetime': datetime, 'latitude': latitude, 'longitude': longitude};
  }
}

class GatewayLocation {
  final GatewayLocationPoint? approx;
  final GatewayLocationPoint? exact;
  final int? startedAt;

  GatewayLocation({this.approx, this.exact, this.startedAt});

  factory GatewayLocation.fromMap(Map<String, dynamic> map) {
    final rawApprox = map['approx'];
    final rawExact = map['exact'];
    return GatewayLocation(
      approx: rawApprox is Map
          ? GatewayLocationPoint.fromMap(Map<String, dynamic>.from(rawApprox))
          : null,
      exact: rawExact is Map
          ? GatewayLocationPoint.fromMap(Map<String, dynamic>.from(rawExact))
          : null,
      startedAt: map['startedAt'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (approx != null) 'approx': approx!.toMap(),
      if (exact != null) 'exact': exact!.toMap(),
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
  final Map<String, dynamic> alerts;
  final GatewayLocation? location;
  final List<Sensor> sensors;

  Gateway({
    required this.id,
    required this.state,
    this.seenAt,
    required this.userId,
    required this.alerts,
    this.location,
    this.sensors = const [],
  });

  String get stateLabel => gatewayStateLabel(state);
  bool get isLocalizing => state == GatewayStates.localizing;
  bool get isConnected => state == GatewayStates.connected;

  factory Gateway.fromMap(String id, Map<String, dynamic> map) {
    int? parsedSeenAt;
    final rawSeenAt = map['seenAt'];
    if (rawSeenAt is int) {
      parsedSeenAt = rawSeenAt;
    }

    final rawSensors = map['sensors'];
    final parsedSensors = <Sensor>[];
    if (rawSensors is Map) {
      rawSensors.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          parsedSensors.add(Sensor.fromMap(value, fallbackId: key.toString()));
        } else if (value is Map) {
          parsedSensors.add(
            Sensor.fromMap(
              Map<String, dynamic>.from(value),
              fallbackId: key.toString(),
            ),
          );
        }
      });
    }

    final rawAlerts = map['alerts'];
    final parsedAlerts = rawAlerts is Map
        ? Map<String, dynamic>.from(rawAlerts)
        : <String, dynamic>{};

    final rawLocation = map['location'];
    final parsedLocation = rawLocation is Map
        ? GatewayLocation.fromMap(Map<String, dynamic>.from(rawLocation))
        : null;

    return Gateway(
      id: id,
      state: map['state'] as String? ?? GatewayStates.inactive,
      seenAt: parsedSeenAt,
      userId: map['userId'] as String? ?? '',
      alerts: parsedAlerts,
      location: parsedLocation,
      sensors: parsedSensors,
    );
  }

  Map<String, dynamic> toMap() {
    final sensorsMap = <String, dynamic>{};
    for (final sensor in sensors) {
      sensorsMap[sensor.id] = sensor.toMap();
    }

    return {
      'state': state,
      'seenAt': seenAt,
      'userId': userId,
      'alerts': alerts,
      if (location != null) 'location': location!.toMap(),
      'sensors': sensorsMap,
    };
  }
}
