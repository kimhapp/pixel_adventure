import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class JumpButton extends SpriteComponent with HasGameReference<PixelAdventure> {
  JumpButton();

  static const margin = 16;
  static const buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/JumpButton.png'));
    position = Vector2(game.size.x - margin - buttonSize, game.size.y - margin - buttonSize);
    return super.onLoad();
  }
}