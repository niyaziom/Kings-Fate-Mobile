import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../models/player_model.dart';
import '../models/game_state.dart';
import '../services/socket_service.dart';

enum AppScreen { splash, lobby, game }

class GameProvider with ChangeNotifier {
  final SocketService _socketService = SocketService();
  
  AppScreen _currentScreen = AppScreen.splash;
  GameState _gameState = GameState();
  GameOverState? _gameOverState;
  String _playerName = '';
  bool _isLoading = false;
  String? _errorMessage;
  
  // Match splash state
  bool _showMatchSplash = false;
  List<CardModel>? _discardedPair;
  
  // Getters
  AppScreen get currentScreen => _currentScreen;
  GameState get gameState => _gameState;
  GameOverState? get gameOverState => _gameOverState;
  String get playerName => _playerName;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _socketService.isConnected;
  bool get showMatchSplash => _showMatchSplash;
  List<CardModel>? get discardedPair => _discardedPair;

  void initialize() {
    _socketService.connect();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    // Room created
    _socketService.on('roomCreated', (data) {
      print('📥 Received roomCreated: $data');
      final players = (data['players'] as List)
          .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
          .toList();
      
      _gameState = _gameState.copyWith(
        roomCode: data['roomCode'] as String,
        players: players,
        isHost: true,
      );
      _currentScreen = AppScreen.lobby;
      notifyListeners();
    });

    // Player joined
    _socketService.on('playerJoined', (data) {
      print('📥 Received playerJoined: $data');
      print('👥 Raw players data: ${data['players']}');
      
      try {
        final players = (data['players'] as List)
            .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
            .toList();
        
        print('✅ Parsed ${players.length} players after join');
        for (var player in players) {
          print('   - ${player.name} (ID: ${player.id})');
        }
        
        _gameState = _gameState.copyWith(players: players);
        
        // If we're not already in the lobby, switch to it (for joining player)
        if (_currentScreen != AppScreen.lobby && _gameState.roomCode != null) {
          print('🚪 Switching to lobby screen');
          _currentScreen = AppScreen.lobby;
        }
        
        notifyListeners();
      } catch (e, stackTrace) {
        print('❌ Error parsing playerJoined data: $e');
        print('Stack trace: $stackTrace');
      }
    });

    // Game started
    _socketService.on('gameStarted', (data) {
      print('📥 Received gameStarted: $data');
      print('🎴 Raw yourHand data: ${data['yourHand']}');
      print('👥 Raw players data: ${data['players']}');
      
      try {
        final hand = (data['yourHand'] as List)
            .map((c) {
              print('🃏 Parsing card: $c');
              return CardModel.fromJson(c as Map<String, dynamic>);
            })
            .toList();
        
        print('✅ Parsed ${hand.length} cards for your hand');
        for (var card in hand) {
          print('   - ${card.rank}${card.suit}');
        }
        
        final players = (data['players'] as List)
            .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
            .toList();
        
        print('✅ Parsed ${players.length} players');
        for (var player in players) {
          print('   - ${player.name}: ${player.cardCount} cards');
        }
        
        _gameState = _gameState.copyWith(
          yourHand: hand,
          players: players,
          currentTurn: data['currentTurn'] as int,
          discardedCount: data['discardedCount'] as int,
        );
        
        print('🎮 Switching to game screen');
        print('🎮 Game state: ${hand.length} cards in hand, turn: ${data['currentTurn']}');
        
        _currentScreen = AppScreen.game;
        notifyListeners();
      } catch (e, stackTrace) {
        print('❌ Error parsing gameStarted data: $e');
        print('Stack trace: $stackTrace');
        _errorMessage = 'Failed to start game: $e';
        notifyListeners();
      }
    });

    // Game update
    _socketService.on('gameUpdate', (data) {
      print('📥 Received gameUpdate: $data');
      final hand = (data['yourHand'] as List)
          .map((c) => CardModel.fromJson(c as Map<String, dynamic>))
          .toList();
      final players = (data['players'] as List)
          .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
          .toList();
      
      CardModel? stagingCard;
      if (data['yourStagingCard'] != null) {
        stagingCard = CardModel.fromJson(data['yourStagingCard'] as Map<String, dynamic>);
      }
      
      _gameState = _gameState.copyWith(
        yourHand: hand,
        yourStagingCard: stagingCard,
        clearStagingCard: data['yourStagingCard'] == null,
        players: players,
        currentTurn: data['currentTurn'] as int,
        discardedCount: data['discardedCount'] as int,
      );
      notifyListeners();
    });

    // Match success
    _socketService.on('matchSuccess', (data) {
      print('📥 Received matchSuccess: $data');
      print('✨ Match! Showing splash effect');
      
      // Parse discarded cards for splash display
      print('🔍 discardedCards in data: ${data['discardedCards']}');
      print('🔍 discardedCards is null: ${data['discardedCards'] == null}');
      
      if (data['discardedCards'] != null) {
        print('✅ discardedCards found, parsing...');
        _discardedPair = (data['discardedCards'] as List)
            .map((c) => CardModel.fromJson(c as Map<String, dynamic>))
            .toList();
        print('✅ Parsed ${_discardedPair?.length} cards for splash');
        _showMatchSplash = true;
        print('🎉 Showing splash overlay!');
        notifyListeners();
        
        // Hide splash after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          print('⏱️ Hiding splash overlay');
          _showMatchSplash = false;
          _discardedPair = null;
          notifyListeners();
        });
      } else {
        print('⚠️ No discardedCards in matchSuccess data!');
      }
      
      final hand = (data['yourHand'] as List)
          .map((c) => CardModel.fromJson(c as Map<String, dynamic>))
          .toList();
      final players = (data['players'] as List)
          .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
          .toList();
      
      _gameState = _gameState.copyWith(
        yourHand: hand,
        clearStagingCard: true,
        players: players,
        currentTurn: data['currentTurn'] as int,
        discardedCount: data['discardedCount'] as int,
      );
      notifyListeners();
    });

    // Match failed
    _socketService.on('matchFailed', (data) {
      print('📥 Received matchFailed: $data');
      _errorMessage = data['message'] as String;
      notifyListeners();
      
      // Clear error after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        _errorMessage = null;
        notifyListeners();
      });
    });

    // Game over
    _socketService.on('gameOver', (data) {
      print('📥 Received gameOver: $data');
      _gameOverState = GameOverState.fromJson(data as Map<String, dynamic>);
      notifyListeners();
    });

    // Error
    _socketService.on('error', (data) {
      print('📥 Received error: $data');
      _errorMessage = data['message'] as String;
      notifyListeners();
      
      // Clear error after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        _errorMessage = null;
        notifyListeners();
      });
    });

    // Player left
    _socketService.on('playerLeft', (data) {
      print('📥 Received playerLeft: $data');
      final players = (data['players'] as List)
          .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
          .toList();
      
      _gameState = _gameState.copyWith(players: players);
      notifyListeners();
    });
  }

  // Actions
  void setPlayerName(String name) {
    _playerName = name;
  }

  void createRoom(String name) {
    _playerName = name;
    _isLoading = true;
    notifyListeners();
    
    _socketService.createRoom(name);
    
    Future.delayed(const Duration(seconds: 2), () {
      _isLoading = false;
      notifyListeners();
    });
  }

  void joinRoom(String roomCode, String name) {
    print('🚪 Attempting to join room: $roomCode as $name');
    _playerName = name;
    _isLoading = true;
    
    // Store the roomCode before emitting - will be confirmed when playerJoined is received
    _gameState = _gameState.copyWith(
      roomCode: roomCode,
      isHost: false,
    );
    
    notifyListeners();
    
    print('📡 Emitting joinRoom event to server');
    _socketService.joinRoom(roomCode, name);
    
    Future.delayed(const Duration(seconds: 2), () {
      _isLoading = false;
      notifyListeners();
      print('⏱️ Join room timeout - checking if joined successfully');
    });
  }

  void startGame() {
    if (_gameState.roomCode != null) {
      _socketService.startGame(_gameState.roomCode!);
    }
  }

  void drawCardToStaging(int fromPlayerIndex, int cardIndex) {
    if (_gameState.roomCode != null) {
      _socketService.drawCardToStaging(
        _gameState.roomCode!,
        fromPlayerIndex,
        cardIndex,
      );
    }
  }

  void matchCards(int handCardIndex) {
    if (_gameState.roomCode != null) {
      _socketService.matchCards(_gameState.roomCode!, handCardIndex);
    }
  }

  void keepCard() {
    if (_gameState.roomCode != null) {
      _socketService.keepCard(_gameState.roomCode!);
    }
  }

  void goToLobby() {
    _currentScreen = AppScreen.lobby;
    notifyListeners();
  }

  void resetGame() {
    _gameState = GameState();
    _gameOverState = null;
    _currentScreen = AppScreen.lobby;
    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
