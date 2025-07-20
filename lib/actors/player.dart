import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idle, run }
enum PlayerDirection { left, right, none }

class Player extends SpriteAnimationGroupComponent with HasGameReference<PixelAdventure>, KeyboardHandler {
  Player({super.position, required this.character});
  String character;

  // Animation related fields
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;

  final idleConfig = _PlayerAnimationConfig(stepTime: 0.05, amount: 11, textureSize: 32);
  final runConfig = _PlayerAnimationConfig(stepTime: 0.05, amount: 12, textureSize: 32);

  // Movement related fields
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  PlayerDirection playerDirection = PlayerDirection.none;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    return super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    bool isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA);
    bool isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD);

    if ((isRightKeyPressed && isLeftKeyPressed) ||
        (!isRightKeyPressed && !isLeftKeyPressed)) {
      playerDirection = PlayerDirection.none;
    } else if (isRightKeyPressed) {
      playerDirection = PlayerDirection.right;
    } else if (isLeftKeyPressed) {
      playerDirection = PlayerDirection.left;
    }

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

  void _updatePlayerMovement(double dt) {
    double dirX = 0.0;

    switch (playerDirection) {
      case PlayerDirection.left:
        dirX -= moveSpeed;
        if (!isFlippedHorizontally) {
          flipHorizontallyAroundCenter();
        }
        current = PlayerState.run;
        break;
      case PlayerDirection.right:
        dirX += moveSpeed;
        if (isFlippedHorizontally) {
          flipHorizontallyAroundCenter();
        }
        current = PlayerState.run;
        break;
      case PlayerDirection.none:
        dirX += velocity.x * 0.85; // For a friction landing
        current = PlayerState.idle;
        break;
    }

    velocity = Vector2(dirX, 0);
    position += velocity * dt;
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
