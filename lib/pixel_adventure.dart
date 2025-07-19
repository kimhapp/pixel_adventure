import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/levels/level.dart';

class PixelAdventure extends FlameGame {
  final double width = 640;
  final double height = 360;

  @override
  final world = Level();

  @override
  FutureOr<void> onLoad() async {
    // Load all images to cache
    await images.loadAllImages();

    camera = CameraComponent.withFixedResolution(width: width, height: height, world: world);
    camera.viewfinder.anchor = Anchor.topLeft;

    addAll([camera, world]);
    return super.onLoad();
  }
}
