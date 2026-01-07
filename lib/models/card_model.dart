class CardModel {
  final String rank;
  final String suit;
  final String id;

  CardModel({
    required this.rank,
    required this.suit,
    required this.id,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      rank: json['rank'] as String,
      suit: json['suit'] as String,
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'suit': suit,
      'id': id,
    };
  }

  bool get isKing => rank == 'K';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
