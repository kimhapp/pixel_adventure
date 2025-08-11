import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/cupertino.dart';

class BackgroundTile extends ParallaxComponent {
  final String color;
  BackgroundTile({super.position, this.color = 'Gray'});

  static const double scrollSpeed = 40;
  static const double backgroundTileSize = 64;

  @override
  FutureOr<void> onLoad() async {
    priority = -10;
    size = Vector2.all(backgroundTileSize);
    parallax = await game.loadParallax(
      [ParallaxImageData("Background/$color.png")],
      baseVelocity: Vector2(0, -scrollSpeed),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none
    );
    return super.onLoad();
  }
}