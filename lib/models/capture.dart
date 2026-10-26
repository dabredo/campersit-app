class Capture {
  final String id;
  final String userId;
  final String deviceId;
  final String sensorId;
  final String url;
  final int createdAt;

  const Capture({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.sensorId,
    required this.url,
    required this.createdAt,
  });

  factory Capture.fromMap(String id, Map<String, Object?> map) {
    return Capture(
      id: id,
      userId: map['userId'] as String,
      deviceId: map['deviceId'] as String,
      sensorId: map['sensorId'] as String,
      url: map['url'] as String,
      createdAt: map['createdAt'] as int,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'userId': userId,
      'deviceId': deviceId,
      'sensorId': sensorId,
      'url': url,
      'createdAt': createdAt,
    };
  }
}
