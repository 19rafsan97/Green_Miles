class RewardModel {
  final String id;
  final String title;
  final String description;
  final int points;
  final String imageUrl;

  RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.imageUrl,
  });

  factory RewardModel.fromSupabase(Map<String, dynamic> data) {
    return RewardModel(
      id: (data['id'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      points: _toInt(data['points']),
      imageUrl: (data['image_url'] ?? data['imageUrl'] ?? '').toString(),
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
}

