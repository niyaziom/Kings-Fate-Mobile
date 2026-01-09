import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../widgets/card_widget.dart';
import '../models/card_model.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final gameState = gameProvider.gameState;
        final gameOver = gameProvider.gameOverState;
        final myPlayerIndex = gameState.players.indexWhere(
          (p) => p.name == gameProvider.playerName,
        );
        final isMyTurn = gameState.currentTurn == myPlayerIndex;

        print('🎮 GameScreen building...');
        print('   - Your hand: ${gameState.yourHand.length} cards');
        print('   - Players: ${gameState.players.length}');
        print('   - Current turn: ${gameState.currentTurn}');
        print('   - My index: $myPlayerIndex');
        print('   - Is my turn: $isMyTurn');

        if (gameOver != null) {
          return _buildGameOver(context, gameProvider, gameOver, myPlayerIndex);
        }

        return Scaffold(
          body: Stack(
            children: [
              // Main game content
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade900,
                      Colors.blue.shade900,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(context, gameState, isMyTurn),
                      Expanded(
                        child: _buildGameBoard(context, gameProvider, gameState, myPlayerIndex, isMyTurn),
                      ),
                    ],
                  ),
                ),
              ),
              // Match splash overlay
              if (gameProvider.showMatchSplash && gameProvider.discardedPair != null)
                _buildMatchSplash(context, gameProvider.discardedPair!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, gameState, bool isMyTurn) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Turn:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Text(
                gameState.players[gameState.currentTurn]?.name ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          if (isMyTurn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'YOUR TURN',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Discarded:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Text(
                '${gameState.discardedCount}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(BuildContext context, GameProvider gameProvider,
      gameState, int myPlayerIndex, bool isMyTurn) {
    return Column(
      children: [
        // Opponents area
        Expanded(
          flex: 2,
          child: _buildOpponentsArea(context, gameProvider, gameState, myPlayerIndex, isMyTurn),
        ),
        // Your area
        Expanded(
          flex: 3,
          child: _buildYourArea(context, gameProvider, gameState, isMyTurn),
        ),
      ],
    );
  }

  Widget _buildOpponentsArea(BuildContext context, GameProvider gameProvider,
      gameState, int myPlayerIndex, bool isMyTurn) {
    final opponents = gameState.players
        .asMap()
        .entries
        .where((entry) => entry.key != myPlayerIndex)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: opponents.length,
      itemBuilder: (context, index) {
        final entry = opponents[index];
        final playerIndex = entry.key;
        final player = entry.value;
        final isCurrentTurn = playerIndex == gameState.currentTurn;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isCurrentTurn ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrentTurn ? Colors.amber : Colors.white.withOpacity(0.2),
              width: isCurrentTurn ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    player.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${player.cardCount} cards',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: Stack(
                  children: List.generate(
                    player.cardCount > 5 ? 5 : player.cardCount,
                    (cardIndex) => Positioned(
                      left: cardIndex * 30.0,
                      child: GestureDetector(
                        onTap: () {
                          print('👆 Tapped opponent card - playerIndex: $playerIndex, cardIndex: $cardIndex');
                          print('   isMyTurn: $isMyTurn, hasStagingCard: ${gameState.yourStagingCard != null}');
                          if (isMyTurn && gameState.yourStagingCard == null) {
                            print('✅ Drawing card to staging');
                            gameProvider.drawCardToStaging(playerIndex, cardIndex);
                          } else {
                            print('❌ Cannot draw: isMyTurn=$isMyTurn, hasStagingCard=${gameState.yourStagingCard != null}');
                          }
                        },
                        child: Container(
                          width: 60,
                          height: 80,
                          child: const CardBack(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildYourArea(BuildContext context, GameProvider gameProvider,
      gameState, bool isMyTurn) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Your Hand',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (gameState.yourStagingCard != null)
                Text(
                  'Staging Area',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.amber,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                // Hand cards
                Expanded(
                  flex: 2,
                  child: gameState.yourHand.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'No cards in hand',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'DEBUG: ${gameState.players.length} players',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: gameState.yourHand.asMap().entries.map<Widget>((entry) {
                              final index = entry.key;
                              final card = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: isMyTurn && gameState.yourStagingCard != null
                                      ? () => gameProvider.matchCards(index)
                                      : null,
                                  child: Container(
                                    width: 100,
                                    height: 140,
                                    child: CardWidget(card: card),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                ),
                // Staging area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: gameState.yourStagingCard != null
                            ? Colors.amber
                            : Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: gameState.yourStagingCard != null
                        ? Column(
                            children: [
                              Expanded(
                                child: CardWidget(card: gameState.yourStagingCard!),
                              ),
                              const SizedBox(height: 8),
                              if (isMyTurn)
                                ElevatedButton(
                                  onPressed: () => gameProvider.keepCard(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    'Keep',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Center(
                            child: Text(
                              isMyTurn ? 'Draw a card' : 'Waiting...',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver(BuildContext context, GameProvider gameProvider,
      gameOver, int myPlayerIndex) {
    final players = gameProvider.gameState.players;
    final isWinner = gameOver.loserId != players[myPlayerIndex].id;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isWinner ? Colors.green.shade900 : Colors.red.shade900,
              isWinner ? Colors.blue.shade900 : Colors.purple.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isWinner ? '🎉 You Win!' : '😢 You Lose!',
                  style: GoogleFonts.cinzel(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  '${gameOver.loserName} was left with the King!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: 120,
                  height: 168,
                  child: CardWidget(card: gameOver.finalCard, isShowcase: true),
                ),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () => gameProvider.resetGame(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Play Again',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchSplash(BuildContext context, List<CardModel> discardedPair) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🎉 MATCH! 🎉',
              style: GoogleFonts.cinzel(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (discardedPair.isNotEmpty)
                  Container(
                    width: 100,
                    height: 140,
                    child: CardWidget(card: discardedPair[0]),
                  ),
                const SizedBox(width: 16),
                if (discardedPair.length > 1)
                  Container(
                    width: 100,
                    height: 140,
                    child: CardWidget(card: discardedPair[1]),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Cards Discarded!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
