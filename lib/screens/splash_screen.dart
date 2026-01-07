import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../widgets/card_widget.dart';
import '../models/card_model.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade900,
              Colors.blue.shade900,
              Colors.pink.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  'King\'s',
                  style: GoogleFonts.cinzel(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.purple.withOpacity(0.8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
                
                Text(
                  'Fate',
                  style: GoogleFonts.cinzel(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                    shadows: [
                      Shadow(
                        color: Colors.amber.withOpacity(0.8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 20),

                Text(
                  'Don\'t be left with the King',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 60),

                // Card showcase
                SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildShowcaseCard(
                        CardModel(rank: 'K', suit: '♠', id: 'K♠'),
                        -30,
                        0.ms,
                      ),
                      _buildShowcaseCard(
                        CardModel(rank: 'A', suit: '♥', id: 'A♥'),
                        -10,
                        150.ms,
                      ),
                      _buildShowcaseCard(
                        CardModel(rank: 'Q', suit: '♦', id: 'Q♦'),
                        10,
                        300.ms,
                      ),
                      _buildShowcaseCard(
                        CardModel(rank: 'J', suit: '♣', id: 'J♣'),
                        30,
                        450.ms,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),

                // Start button
                ElevatedButton(
                  onPressed: () => gameProvider.goToLobby(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                  ),
                  child: Text(
                    'Tap to Start',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(delay: 1000.ms, duration: 2000.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShowcaseCard(CardModel card, double rotation, Duration delay) {
    return Transform.rotate(
      angle: rotation * 0.0174533, // Convert degrees to radians
      child: SizedBox(
        width: 100,
        height: 140,
        child: CardWidget(card: card, isShowcase: true),
      ),
    ).animate().fadeIn(delay: delay, duration: 400.ms).scale(begin: const Offset(0.5, 0.5));
  }
}
