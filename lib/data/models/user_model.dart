class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profileImageUrl;
  final int points;
  final double totalCo2Saved;
  final double totalDistance;
  final int totalTrips;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl = '',
    this.points = 0,
    this.totalCo2Saved = 0.0,
    this.totalDistance = 0.0,
    this.totalTrips = 0,
  });

  // Factory constructor for creating a new UserModel instance from a map
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      points: data['points'] ?? 0,
      totalCo2Saved: (data['totalCo2Saved'] ?? 0.0).toDouble(),
      totalDistance: (data['totalDistance'] ?? 0.0).toDouble(),
      totalTrips: data['totalTrips'] ?? 0,
    );
  }

  // Method to convert a UserModel instance to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'points': points,
      'totalCo2Saved': totalCo2Saved,
      'totalDistance': totalDistance,
      'totalTrips': totalTrips,
    };
  }

  factory UserModel.fromSupabase(
    Map<String, dynamic> data, {
    String? fallbackEmail,
  }) {
    return UserModel(
      uid: (data['id'] ?? '').toString(),
      name: (data['full_name'] ?? data['name'] ?? '').toString(),
      email: (data['email'] ?? fallbackEmail ?? '').toString(),
      profileImageUrl: (data['avatar_url'] ?? data['profile_image_url'] ?? '').toString(),
      points: _toInt(data['points']),
      totalCo2Saved: _toDouble(data['total_co2_saved'] ?? data['totalCo2Saved']),
      totalDistance: _toDouble(data['total_distance'] ?? data['totalDistance']),
      totalTrips: _toInt(data['total_trips'] ?? data['totalTrips']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}

