import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Saw extends SpriteAnimationComponent with HasGameReference, CollisionCallbacks {
  Saw({
    super.position,
    super.size,
    this.isVertical = false,
    this.offNeg = 0,
    this.offPos = 0
  });
  final bool isVertical;
  final double offNeg;
  final double offPos;

  static const double stepTime = 0.03;
  int direction = 1;
  late final double rangeNeg;
  late final double rangePos;
  static const double speed = 50;
  static const tileSize = 16;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    add(CircleHitbox());

    if (isVertical) {
      rangeNeg = position.y - offNeg * tileSize;
      rangePos = position.y + offPos * tileSize;
    } else {
      rangeNeg = position.x - offNeg * tileSize;
      rangePos = position.x + offPos * tileSize;
    }

    animation = SpriteAnimation.fromFrameData(game.images.fromCache('Traps/Saw/On (38x38).png'),
        SpriteAnimationData.sequenced(amount: 8, stepTime: stepTime, textureSize: Vector2.all(38)));
    return super.onLoad();
  }

  @override
  FutureOr<void> update(double dt) {
    if (isVertical) {
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
    }
    super.update(dt);
  }

  void _moveHorizontally(double dt) {
    if (position.x >= rangePos) {
      direction = -1;
    } else if (position.x <= rangeNeg) {
      direction = 1;
    }

    position.x += direction * speed * dt;
  }

  void _moveVertically(double dt) {
    if (position.y >= rangePos) {
      direction = -1;
    } else if (position.y <= rangeNeg) {
      direction = 1;
    }

    position.y += direction * speed * dt;
  }
}