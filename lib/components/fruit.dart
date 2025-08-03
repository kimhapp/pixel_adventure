import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Fruit extends SpriteAnimationComponent with HasGameReference, CollisionCallbacks {
  Fruit({this.name = 'Apple', super.position, super.size});
  final double stepTime = 0.05;
  final String name;
  final RectangleHitbox hitbox = RectangleHitbox(
    position: Vector2.all(10),
    size: Vector2.all(12),
    collisionType: CollisionType.passive,
  );

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    add(hitbox);
    animation = SpriteAnimation.fromFrameData(game.images.fromCache('Items/Fruits/$name.png'),
        SpriteAnimationData.sequenced(amount: 17, stepTime: stepTime, textureSize: Vector2.all(32)));
    return super.onLoad();
  }

  void destroy() {
    remove(hitbox);
    animation = SpriteAnimation.fromFrameData(game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(amount: 6, stepTime: stepTime, textureSize: Vector2.all(32), loop: false));
    removeOnFinish = true;
  }
}