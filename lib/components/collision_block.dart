import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent  {
  CollisionBlock({super.position, super.size, this.isPlatform = false}) {
    debugMode = true;
    add(RectangleHitbox());
  }
  bool isPlatform;
}