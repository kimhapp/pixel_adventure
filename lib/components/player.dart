import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idle, run, jump, fall, hit, spawn }

class Player extends SpriteAnimationGroupComponent with HasGameReference<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  Player({super.position, required this.character});
  String character;
  late final Vector2 startPosition;
  final RectangleHitbox hitbox = RectangleHitbox(
      position: Vector2(10, 4),
      size: Vector2(14, 28)
  );

  // Animation related fields
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation spawnAnimation;

  final idleConfig = _PlayerAnimationConfig(stepTime: 0.05, amount: 11, textureSize: 32);
  final runConfig = _PlayerAnimationConfig(stepTime: 0.05, amount: 12, textureSize: 32);
  final jumpConfig = _PlayerAnimationConfig(stepTime: 0.05, amount: 1, textureSize: 32);
  final fallConfig = _PlayerAnimationConfig(stepTime: 0.05, amount: 1, textureSize: 32);
  final hitConfig = _PlayerAnimationConfig(
      stepTime: 0.05,
      amount: 7,
      textureSize: 32,
      loop: false,
  );
  final spawnConfig = _PlayerAnimationConfig(
      stepTime: 0.05,
      amount: 7,
      textureSize: 96,
      loop: false,
      isCharacter: false
  );

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
    add(hitbox);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (![PlayerState.hit, PlayerState.spawn].contains(current)) {
      _updatePlayerSprite();
      _updatePlayerMovement(dt);
      _checkHorizontalCollisions();
      _applyGravity(dt);
      _checkVerticalCollisions();
    }
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
      horizontalMovement = 0;
    }

    if (isJumpKeyPressed) {hasJumped = true;}

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit) {
      other.destroy();
    } else if (other is Saw) {
      gotHit();
    }
    super.onCollision(intersectionPoints, other);
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.position.x - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.position.x;
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
            position.y = block.y - hitbox.height - hitbox.position.y;
            isGrounded = true;
            hasJumped = false;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height + hitbox.position.y;
            break;
          }
        }
      }
      else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.position.y;
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
    hitAnimation = _spriteAnimation("Hit", hitConfig);
    spawnAnimation = _spriteAnimation("Appearing", spawnConfig);

    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.spawn: spawnAnimation
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, _PlayerAnimationConfig config) {
    // Use for filename only
    final int textureSize = config.textureSize.toInt();
    final String name = config.isCharacter ? "/$character" : "";
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Main Characters$name/$state (${textureSize}x$textureSize).png'),
        SpriteAnimationData.sequenced(
            amount: config.amount,
            stepTime: config.stepTime,
            textureSize: Vector2.all(config.textureSize),
            loop: config.loop
        )
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
    } else {
      playerState = PlayerState.idle;
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

  void gotHit() {
    if ([PlayerState.hit, PlayerState.spawn].contains(current)) return;
    remove(hitbox);
    velocity = Vector2.zero();
    current = PlayerState.hit;

    animationTickers![PlayerState.hit]!.onComplete = () {
      scale.x = -1;
      position = startPosition - Vector2(-32, 32);
      current = PlayerState.spawn;

      animationTickers![PlayerState.spawn]!.onComplete = () {
        position = startPosition;
        add(hitbox);
        current = PlayerState.idle;
      };
    };
  }
}

// Private class for player's animation config
class _PlayerAnimationConfig {
  final int amount;
  final double stepTime;
  final double textureSize;
  final bool loop;
  final bool isCharacter;

  const _PlayerAnimationConfig({
    required this.amount,
    required this.stepTime,
    required this.textureSize,
    this.loop = true,
    this.isCharacter = true
  });
}
