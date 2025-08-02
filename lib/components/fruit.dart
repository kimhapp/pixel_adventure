import 'dart:async';

import 'package:flame/components.dart';

class Fruit extends SpriteAnimationComponent with HasGameReference {
  Fruit({this.name = 'Apple', super.position, super.size});
  final double stepTime = 0.05;
  final String name;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    animation = SpriteAnimation.fromFrameData(game.images.fromCache('Items/Fruits/$name.png'),
        SpriteAnimationData.sequenced(amount: 17  , stepTime: stepTime, textureSize: Vector2.all(32)));
    return super.onLoad();
  }
}