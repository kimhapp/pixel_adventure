import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player.dart';

import 'animation_config.dart';

enum CheckpointState { close, open, idle }

class Checkpoint extends SpriteAnimationGroupComponent with HasGameReference, CollisionCallbacks {
  Checkpoint({super.position, super.size});
  final RectangleHitbox hitbox = RectangleHitbox(
    position: Vector2(18, 56),
    size: Vector2(12, 8)
  );

  late final SpriteAnimation closeAnimation;
  late final SpriteAnimation openAnimation;
  late final SpriteAnimation idleAnimation;

  final closeConfig = AnimationConfig(stepTime: 1, amount: 1, textureSize: 64, hasTextureName: false);
  final openConfig = AnimationConfig(stepTime: 0.05, amount: 26, textureSize: 64, loop: false);
  final idleConfig = AnimationConfig(stepTime: 0.05, amount: 10, textureSize: 64);

  @override
  FutureOr<void> onLoad() {
    add(hitbox);
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      _reachCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachCheckpoint() {
    remove(hitbox);
    current = CheckpointState.open;

    animationTickers![CheckpointState.open]!.onComplete = () {
      current = CheckpointState.idle;
    };
  }

  SpriteAnimation _spriteAnimation(String name, AnimationConfig config) {
    // Use for filename only
    final int textureSize = config.textureSize.toInt();
    final String size = config.hasTextureName ? " (${textureSize}x$textureSize)" : "";
    return SpriteAnimation.fromFrameData(
        game.images.fromCache("Items/Checkpoints/Checkpoint/Checkpoint ($name)$size.png"),
        SpriteAnimationData.sequenced(
            amount: config.amount,
            stepTime: config.stepTime,
            textureSize: Vector2.all(config.textureSize),
            loop: config.loop
        )
    );
  }

  void _loadAllAnimations() {
    closeAnimation = _spriteAnimation("No Flag", closeConfig);
    openAnimation = _spriteAnimation("Flag Out", openConfig);
    idleAnimation = _spriteAnimation("Flag Idle", idleConfig);

    // List of all animations
    animations = {
      CheckpointState.close: closeAnimation,
      CheckpointState.open: openAnimation,
      CheckpointState.idle: idleAnimation,
    };

    current = CheckpointState.close;
  }
}