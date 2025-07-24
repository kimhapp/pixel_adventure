import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class BackgroundTile extends SpriteComponent with HasGameReference<PixelAdventure>{
  final String color;

  BackgroundTile({super.position, this.color = 'Gray'});

  @override
  FutureOr<void> onLoad() {
    size = Vector2.all(64);
    sprite = Sprite(game.images.fromCache('Background/$color.png'));
    return super.onLoad();
  }
}