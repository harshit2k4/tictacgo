import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tictacgo/features/game/domain/player.dart';

class CoinTossView extends StatefulWidget {
  final Function(Player) onCompleted;

  const CoinTossView({super.key, required this.onCompleted});

  @override
  State<CoinTossView> createState() => _CoinTossViewState();
}

class _CoinTossViewState extends State<CoinTossView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Player _result;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 2500,
      ), // Slightly longer for suspense
      vsync: this,
    );

    // Use Secure Random for true 50/50 unpredictability
    final random = Random.secure();
    _result = random.nextBool() ? Player.x : Player.o;

    // Randomize the Starting Face
    // If random bool is true, start at 0 (X). If false, start at pi (O).
    // This removes the bias of "It always starts as X".
    double beginPos = random.nextBool() ? 0 : pi;

    // Calculate Target Rotation
    // Spin 5 to 9 full times
    int spins = 5 + random.nextInt(5);
    double spinRotation = spins * 2 * pi;

    double targetPos;

    // Logic:
    // Even multiples of pi (0, 2pi...) = Face X
    // Odd multiples of pi (pi, 3pi...) = Face O
    if (_result == Player.x) {
      // Target must be an Even multiple.
      targetPos = beginPos + spinRotation;
      // If we started at pi (O), adding even rotation keeps us at O (Odd).
      // So we add an extra pi to land on X (Even).
      if (beginPos > 0.1) targetPos += pi;
    } else {
      // Target must be an Odd multiple.
      targetPos = beginPos + spinRotation;
      // If we started at 0 (X), adding even rotation keeps us at X (Even).
      // So we add an extra pi to land on O (Odd).
      if (beginPos < 0.1) targetPos += pi;
    }

    // Use easeOutCirc instead of easeOutBack
    // easeOutBack overshoots large values, causing the coin to
    // visually flip to the wrong side for a split second before settling.
    _animation =
        Tween<double>(begin: beginPos, end: targetPos).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCirc, // Smooth landing, no flip-flop glitch
          ),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            Future.delayed(const Duration(milliseconds: 700), () {
              if (mounted) widget.onCompleted(_result);
            });
          }
        });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.value;

              // Normalize angle to 0...2pi range
              final normalizedAngle = angle % (2 * pi);

              // Check if we are showing the "Back" face
              // Front is 0 +/- pi/2 (X)
              // Back is pi +/- pi/2 (O)
              final isBack =
                  normalizedAngle > pi / 2 && normalizedAngle < 1.5 * pi;

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015) // Perspective
                  ..rotateY(angle),
                alignment: Alignment.center,
                // If back, show O. If front, show X.
                child: isBack
                    ? _buildCoinFace(Player.o)
                    : _buildCoinFace(Player.x),
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            "Tossing for first move...",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinFace(Player player) {
    final color = player == Player.x ? Colors.blue : Colors.red;
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 4),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          player == Player.x ? "X" : "O",
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
