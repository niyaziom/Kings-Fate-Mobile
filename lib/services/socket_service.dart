import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  void connect() {
    if (_socket != null && _isConnected) {
      print('✅ Already connected to server');
      return;
    }

    print('🔌 Connecting to server: ${AppConfig.serverUrl}');

    _socket = IO.io(
      AppConfig.serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) // Force WebSocket only to prevent transport upgrade disconnection
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setTimeout(20000)
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ Connected to server: ${_socket!.id}');
      _isConnected = true;
    });

    _socket!.onDisconnect((reason) {
      print('❌ Disconnected from server. Reason: $reason');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      print('🔴 Connection error: $error');
      _isConnected = false;
    });

    _socket!.onError((error) {
      print('🔴 Socket error: $error');
    });
    
    _socket!.onReconnect((attempt) {
      print('🔄 Reconnected to server (attempt $attempt)');
    });
    
    _socket!.onReconnectAttempt((attempt) {
      print('🔄 Attempting to reconnect (attempt $attempt)');
    });
  }

  void disconnect() {
    if (_socket != null) {
      print('🔌 Disconnecting from server');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
  }

  // Event emitters
  void createRoom(String playerName) {
    if (_socket == null) {
      print('❌ Cannot create room: Socket is null');
      return;
    }
    if (!_isConnected) {
      print('⚠️ Warning: Socket not connected yet, attempting to emit anyway');
    }
    print('📤 Emitting createRoom: $playerName (Connected: $_isConnected, Socket ID: ${_socket?.id})');
    _socket?.emit('createRoom', {'playerName': playerName});
  }

  void joinRoom(String roomCode, String playerName) {
    if (_socket == null) {
      print('❌ Cannot join room: Socket is null');
      return;
    }
    if (!_isConnected) {
      print('❌ Cannot join room: Not connected to server');
      return;
    }
    print('📤 Emitting joinRoom: $roomCode, $playerName (Socket ID: ${_socket?.id})');
    _socket?.emit('joinRoom', {
      'roomCode': roomCode,
      'playerName': playerName,
    });
  }

  void startGame(String roomCode) {
    if (!_isConnected) {
      print('❌ Cannot start game: Not connected to server');
      return;
    }
    print('📤 Emitting startGame: $roomCode');
    _socket?.emit('startGame', {'roomCode': roomCode});
  }

  void drawCardToStaging(String roomCode, int fromPlayerIndex, int cardIndex) {
    print('📤 Emitting drawCardToStaging: player $fromPlayerIndex, card $cardIndex');
    _socket?.emit('drawCardToStaging', {
      'roomCode': roomCode,
      'fromPlayerIndex': fromPlayerIndex,
      'cardIndex': cardIndex,
    });
  }

  void matchCards(String roomCode, int handCardIndex) {
    print('📤 Emitting matchCards: hand card $handCardIndex');
    _socket?.emit('matchCards', {
      'roomCode': roomCode,
      'handCardIndex': handCardIndex,
    });
  }

  void keepCard(String roomCode) {
    print('📤 Emitting keepCard');
    _socket?.emit('keepCard', {'roomCode': roomCode});
  }

  // Event listeners
  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }
}
