import 'package:cloud_firestore/cloud_firestore.dart';

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
    return GatewayLocation(
      approx: map['approx'] != null
          ? GatewayLocationPoint.fromMap(map['approx'] as Map<String, dynamic>)
          : null,
      exact: map['exact'] != null
          ? GatewayLocationPoint.fromMap(map['exact'] as Map<String, dynamic>)
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

class Gateway {
  final String id;
  final String state;
  final DateTime? seenAt;
  final String userId;
  final Map<String, dynamic> alerts;
  final GatewayLocation? location;

  Gateway({
    required this.id,
    required this.state,
    this.seenAt,
    required this.userId,
    required this.alerts,
    this.location,
  });

  factory Gateway.fromMap(String id, Map<String, dynamic> map) {
    DateTime? parsedSeenAt;
    if (map['seenAt'] != null) {
      if (map['seenAt'] is Timestamp) {
        parsedSeenAt = (map['seenAt'] as Timestamp).toDate();
      } else if (map['seenAt'] is int) {
        parsedSeenAt = DateTime.fromMillisecondsSinceEpoch(
          map['seenAt'] as int,
        );
      }
    }

    return Gateway(
      id: id,
      state: map['state'] as String? ?? 'i',
      seenAt: parsedSeenAt,
      userId: map['userId'] as String? ?? '',
      alerts: map['alerts'] as Map<String, dynamic>? ?? {},
      location: map['location'] != null
          ? GatewayLocation.fromMap(map['location'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'state': state,
      'seenAt': seenAt != null ? Timestamp.fromDate(seenAt!) : null,
      'userId': userId,
      'alerts': alerts,
      if (location != null) 'location': location!.toMap(),
    };
  }
}
