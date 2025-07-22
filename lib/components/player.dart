import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idle, run }

class Player extends SpriteAnimationGroupComponent with HasGameReference<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  Player({super.position, required this.character}) {debugMode = true; add(RectangleHitbox());}
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
  final double _gravity = 9.8;
  final double _jumpForce = 450;
  final double _terminalVelocity = 300;
  bool canMoveRight = true;
  bool canMoveLeft = true;
  bool isGrounded = false;
  bool hitHead = false;
  bool hasJumped = false;

  // List of collision from levels
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _flipPlayerSprite();
    _updatePlayerMovement(dt);
    if ((!isGrounded && !hasJumped) || hitHead) {
      _applyGravity(dt);
    }
    return super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    bool isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA);
    bool isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD);
    bool isJumpKeyPressed = keysPressed.contains(LogicalKeyboardKey.space);

    if (isLeftKeyPressed || isRightKeyPressed) {
      current = PlayerState.run;

      if (isRightKeyPressed) {
        horizontalMovement += 1;
      }
      if (isLeftKeyPressed) {
        horizontalMovement += -1;
      }
    } else {
      current = PlayerState.idle;
      horizontalMovement = 0;
    }

    if (isJumpKeyPressed) {hasJumped = true;}

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is CollisionBlock) {
      if (!other.isPlatform) {
        if (velocity.x < 0) {
          velocity.x = 0;
          position.x = other.toRect().right + toRect().width;
        }
        if (velocity.x > 0) {
          velocity.x = 0;
          position.x = other.toRect().left - toRect().width;
        }
        if (velocity.y < 0) {
          velocity.y = 0;
          position.y = other.toRect().bottom + toRect().height;
        }
        if (velocity.y > 0) {
          velocity.y = 0;
          position.y = other.toRect().top - toRect().height;
        }
      }
    }
    return super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is CollisionBlock) {
      if (other.isCollidedHorizontally) {
        canMoveLeft = true;
        canMoveRight = true;
        other.isCollidedHorizontally = false;
      }
      if (other.isCollidedVertically) {
        hitHead = false;
        isGrounded = false;
        other.isCollidedVertically = false;
      }
    }
    return super.onCollisionEnd(other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("Idle", idleConfig);
    runAnimation = _spriteAnimation("Run", runConfig);

    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, _PlayerAnimationConfig config) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/$character/$state (32x32).png'),
        SpriteAnimationData.sequenced(amount: config.amount, stepTime: config.stepTime, textureSize: Vector2.all(config.textureSize))
    );
  }

  void _flipPlayerSprite() {
    if (horizontalMovement < 0 && !isFlippedHorizontally) {
      flipHorizontallyAroundCenter();
    } else if (horizontalMovement > 0 && isFlippedHorizontally) {
      flipHorizontallyAroundCenter();
    }
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isGrounded) _playerJump(dt);

    if (horizontalMovement != 0) {
      velocity.x = horizontalMovement * moveSpeed;
    } else {
      velocity.x *= friction; // Friction movement when stopped
    }

    if ((velocity.x > 0 && !canMoveRight) || (velocity.x < 0 && !canMoveLeft) || velocity.x.abs() < 1) {
      velocity.x = 0;
    }

    position.x += velocity.x * dt;
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isGrounded = false;
    hasJumped = false;
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
