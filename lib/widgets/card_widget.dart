import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/card_model.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;
  final bool isShowcase;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.card,
    this.isShowcase = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRed = card.suit == '♥' || card.suit == '♦';
    final isKing = card.isKing;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade100,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: isKing ? Colors.amber.withOpacity(0.6) : Colors.black.withOpacity(0.3),
              blurRadius: isKing ? 20 : 10,
              spreadRadius: isKing ? 2 : 0,
            ),
          ],
          border: Border.all(
            color: isKing ? Colors.amber : Colors.grey.shade300,
            width: isKing ? 3 : 2,
          ),
        ),
        child: Stack(
          children: [
            // Top-left corner
            Positioned(
              top: 8,
              left: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.rank,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isRed ? Colors.red : Colors.black,
                    ),
                  ),
                  Text(
                    card.suit,
                    style: TextStyle(
                      fontSize: 20,
                      color: isRed ? Colors.red : Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Center suit
            Center(
              child: Text(
                card.suit,
                style: TextStyle(
                  fontSize: isKing ? 80 : 60,
                  color: (isRed ? Colors.red : Colors.black).withOpacity(0.2),
                ),
              ),
            ),

            // Bottom-right corner (rotated)
            Positioned(
              bottom: 8,
              right: 8,
              child: Transform.rotate(
                angle: 3.14159, // 180 degrees
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.rank,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isRed ? Colors.red : Colors.black,
                      ),
                    ),
                    Text(
                      card.suit,
                      style: TextStyle(
                        fontSize: 20,
                        color: isRed ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // King crown overlay
            if (isKing)
              Center(
                child: Icon(
                  Icons.star,
                  size: 40,
                  color: Colors.amber.withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CardBack extends StatelessWidget {
  final VoidCallback? onTap;

  const CardBack({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade700,
              Colors.blue.shade700,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: Stack(
          children: [
            // Pattern
            Center(
              child: Icon(
                Icons.auto_awesome,
                size: 40,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
