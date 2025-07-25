import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class BackgroundTile extends SpriteComponent with HasGameReference<PixelAdventure>{
  final String color;
  BackgroundTile({super.position, this.color = 'Gray'});

  final double scrollSpeed = 0.4;
  double backgroundTileSize = 64;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    size = Vector2.all(64.6);
    sprite = Sprite(game.images.fromCache('Background/$color.png'));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y += scrollSpeed;
    int screenHeight = (game.size.y / backgroundTileSize).round();

    if (position.y > screenHeight * backgroundTileSize) {
      position.y = -backgroundTileSize;
    }
    super.update(dt);
  }
}