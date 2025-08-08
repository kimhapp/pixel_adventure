import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class JumpButton extends SpriteButtonComponent with HasGameReference<PixelAdventure> {
  JumpButton();

  static const margin = 16;
  static const buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    button = Sprite(game.images.fromCache('HUD/JumpButton.png'));
    position = Vector2(game.size.x - margin - buttonSize, game.size.y - margin - buttonSize);

    onPressed = () {
      if (game.player.isGrounded) {
        game.player.hasJumped = true;
      }
    };
    return super.onLoad();
  }

}