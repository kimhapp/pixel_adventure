import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idle, run, jump, fall }

class Player extends SpriteAnimationGroupComponent with HasGameReference<PixelAdventure>, KeyboardHandler {
  Player({super.position, required this.character});
  String character;
  final hitbox = _PlayerHitbox(offsetX: 10, offsetY: 4, width: 14, height: 28);

  // Animation related fields
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;

  final idleConfig = _PlayerAnimationConfig(stepTime: 0.05, amount: 11, textureSize: 32);
  final runConfig = _PlayerAnimationConfig(stepTime: 0.05, amount: 12, textureSize: 32);
  final jumpConfig = _PlayerAnimationConfig(stepTime: 0.05, amount: 1, textureSize: 32);
  final fallConfig = _PlayerAnimationConfig(stepTime: 0.05, amount: 1, textureSize: 32);

  // Movement related fields
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  double friction = 0.85;
  final double _gravity = 9.8;
  final double _jumpForce = 260;
  final double _terminalVelocity = 300;
  bool isGrounded = true;
  bool hitHead = false;
  bool hasJumped = false;

  // List of collision from levels
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height)
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerSprite();
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    return super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    bool isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA);
    bool isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD);
    bool isJumpKeyPressed = keysPressed.contains(LogicalKeyboardKey.space) && !hasJumped; // Prevent another jump if space is pressed during in air

    if (isRightKeyPressed) {
        horizontalMovement += 1;
    } else if (isLeftKeyPressed) {
        horizontalMovement += -1;
    } else {
      current = PlayerState.idle;
      horizontalMovement = 0;
    }

    if (isJumpKeyPressed) {hasJumped = true;}

    return super.onKeyEvent(event, keysPressed);
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isGrounded = true;
            hasJumped = false;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height + hitbox.offsetY;
            break;
          }
        }
      }
      else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isGrounded = true;
            hasJumped = false;
            break;
          }
        }
      }
    }
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("Idle", idleConfig);
    runAnimation = _spriteAnimation("Run", runConfig);
    jumpAnimation = _spriteAnimation("Jump", jumpConfig);
    fallAnimation = _spriteAnimation("Fall", fallConfig);

    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, _PlayerAnimationConfig config) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters/$character/$state (32x32).png'),
        SpriteAnimationData.sequenced(amount: config.amount, stepTime: config.stepTime, textureSize: Vector2.all(config.textureSize))
    );
  }

  void _updatePlayerSprite() {
    PlayerState playerState = PlayerState.idle;

    if (!isGrounded) {
      if (velocity.y < 0) {
        playerState = PlayerState.jump;
      } else {
        playerState = PlayerState.fall;
      }
    } else if (horizontalMovement != 0) {
      playerState = PlayerState.run;
    }

    if (horizontalMovement < 0 && !isFlippedHorizontally) {
      flipHorizontallyAroundCenter();
    } else if (horizontalMovement > 0 && isFlippedHorizontally) {
      flipHorizontallyAroundCenter();
    }

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isGrounded) _playerJump(dt);

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

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _playerJump(double dt) {
    current = PlayerState.jump;
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isGrounded = false;
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

// Private class for player's hitbox
class _PlayerHitbox {
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;
  
  const _PlayerHitbox({
    required this.offsetX, required this.offsetY, required this.width, required this.height
  });
}
