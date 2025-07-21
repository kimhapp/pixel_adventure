import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idle, run }

class Player extends SpriteAnimationGroupComponent with HasGameReference<PixelAdventure>, KeyboardHandler {
  Player({super.position, required this.character});
  String character;

  // Animation related fields
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;

  final idleConfig = _PlayerAnimationConfig(stepTime: 0.05, amount: 11, textureSize: 32);
  final runConfig = _PlayerAnimationConfig(stepTime: 0.05, amount: 12, textureSize: 32);

  // Movement related fields
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  double friction = 0.85;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    return super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    bool isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA);
    bool isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("Idle", idleConfig);
    runAnimation = _spriteAnimation("Run", runConfig);

    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
    };
  }
  
  SpriteAnimation _spriteAnimation(String state, _PlayerAnimationConfig config) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/$character/$state (32x32).png'),
        SpriteAnimationData.sequenced(amount: config.amount, stepTime: config.stepTime, textureSize: Vector2.all(config.textureSize))
    );
  }


  void _updatePlayerState() {
    if (horizontalMovement == 0) {
      current = PlayerState.idle;
    } else {
      if (velocity.x < 0 && !isFlippedHorizontally) {
        flipHorizontallyAroundCenter();
      } else if (velocity.x > 0 && isFlippedHorizontally) {
        flipHorizontallyAroundCenter();
      }

      current = PlayerState.run;
    }
  }

  void _updatePlayerMovement(double dt) {
    if (horizontalMovement != 0) {
      velocity.x = horizontalMovement * moveSpeed;
    } else {
      velocity.x *= friction; // Friction movement when stopped
    }

    if (velocity.x.abs() < 1) {
      velocity.x = 0;
    }

    position.x += velocity.x * dt;
  }
}

// Private class for player's animation config
class _PlayerAnimationConfig {
  final int amount;
  final double stepTime;
  final double textureSize;

  const _PlayerAnimationConfig({
    required this.amount, required this.stepTime, required this.textureSize
  });
}
