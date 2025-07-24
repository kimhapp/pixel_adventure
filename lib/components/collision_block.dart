import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent  {
  CollisionBlock({super.position, super.size, this.isPlatform = false});
  bool isPlatform;
  bool isCollidedFromHorizontally = false;
  bool isCollidedFromVertically = false;

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox());
    return super.onLoad();
  }
}