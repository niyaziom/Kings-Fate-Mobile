import 'card_model.dart';
import 'player_model.dart';

class GameState {
  final List<CardModel> yourHand;
  final CardModel? yourStagingCard;
  final List<PlayerModel> players;
  final int currentTurn;
  final int discardedCount;
  final String? roomCode;
  final bool isHost;

  GameState({
    this.yourHand = const [],
    this.yourStagingCard,
    this.players = const [],
    this.currentTurn = 0,
    this.discardedCount = 0,
    this.roomCode,
    this.isHost = false,
  });

  GameState copyWith({
    List<CardModel>? yourHand,
    CardModel? yourStagingCard,
    bool clearStagingCard = false,
    List<PlayerModel>? players,
    int? currentTurn,
    int? discardedCount,
    String? roomCode,
    bool? isHost,
  }) {
    return GameState(
      yourHand: yourHand ?? this.yourHand,
      yourStagingCard: clearStagingCard ? null : (yourStagingCard ?? this.yourStagingCard),
      players: players ?? this.players,
      currentTurn: currentTurn ?? this.currentTurn,
      discardedCount: discardedCount ?? this.discardedCount,
      roomCode: roomCode ?? this.roomCode,
      isHost: isHost ?? this.isHost,
    );
  }
}

class GameOverState {
  final String loserId;
  final String loserName;
  final CardModel finalCard;

  GameOverState({
    required this.loserId,
    required this.loserName,
    required this.finalCard,
  });

  factory GameOverState.fromJson(Map<String, dynamic> json) {
    return GameOverState(
      loserId: json['loserId'] as String,
      loserName: json['loserName'] as String,
      finalCard: CardModel.fromJson(json['finalCard'] as Map<String, dynamic>),
    );
  }
}
