import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:pixel_adventure/actors/player.dart';
import 'package:pixel_adventure/levels/level.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks {
  final double width = 640;
  final double height = 360;
  final Player player = Player(character: "Pink Man");
  late JoystickComponent joystickComponent;
  bool showJoystick = true;

  @override
  FutureOr<void> onLoad() async {
    // Load all images to cache
    await images.loadAllImages();

    final world = Level(levelName: "Level-01", player: player);

    camera = CameraComponent.withFixedResolution(width: width, height: height, world: world);
    camera.viewfinder.anchor = Anchor.topLeft;

    addAll([camera, world]);

    if (showJoystick) {
      addJoystick();
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      updateJoystick();
    }
    return super.update(dt);
  }

  void addJoystick() {
    joystickComponent = JoystickComponent(
      knob: SpriteComponent(sprite: Sprite(images.fromCache("HUD/Knob.png"))),
      background: SpriteComponent(sprite: Sprite(images.fromCache("HUD/Joystick.png"))),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    camera.viewport.add(joystickComponent); // Add joystick to viewport so it is always visible
  }

  void updateJoystick() {
    switch (joystickComponent.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.playerDirection = PlayerDirection.left;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.playerDirection = PlayerDirection.right;
        break;
      default:
        player.playerDirection = PlayerDirection.none;
        break;
    }
  }
}
