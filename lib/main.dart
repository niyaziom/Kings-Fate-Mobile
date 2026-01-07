import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider()..initialize(),
      child: MaterialApp(
        title: 'King\'s Fate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const GameRouter(),
      ),
    );
  }
}

class GameRouter extends StatelessWidget {
  const GameRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        switch (gameProvider.currentScreen) {
          case AppScreen.splash:
            return const SplashScreen();
          case AppScreen.lobby:
            return const LobbyScreen();
          case AppScreen.game:
            return const GameScreen();
        }
      },
    );
  }
}
