class PlayerModel {
  final String id;
  final String name;
  final int cardCount;
  final bool hasStagingCard;

  PlayerModel({
    required this.id,
    required this.name,
    required this.cardCount,
    this.hasStagingCard = false,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    // Handle cardCount - server might send 'hand' array or 'cardCount' number
    int cardCount;
    if (json.containsKey('cardCount') && json['cardCount'] != null) {
      cardCount = json['cardCount'] as int;
    } else if (json.containsKey('hand') && json['hand'] != null) {
      cardCount = (json['hand'] as List).length;
    } else {
      cardCount = 0;
    }

    return PlayerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      cardCount: cardCount,
      hasStagingCard: json['hasStagingCard'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cardCount': cardCount,
      'hasStagingCard': hasStagingCard,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
