import 'dart:async';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:pixel_adventure/components/UI/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  final double width = 640;
  final double height = 360;
  late final JoystickComponent joystick = JoystickComponent(
      knob: SpriteComponent(sprite: Sprite(images.fromCache("HUD/Knob.png"))),
      background: SpriteComponent(sprite: Sprite(images.fromCache("HUD/Joystick.png"))),
      margin: const EdgeInsets.only(left: 16, bottom: 16)
  );
  final JumpButton jumpButton = JumpButton();
  late Player player;
  final bool showJoystick = Platform.isAndroid || Platform.isIOS;
  bool _isLoading = true;
  static const List<String> levelNames = ['Level-01', 'Level-01'];
  int currentLevelIndex = 0;

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  @override
  FutureOr<void> onLoad() async {

    // Load all images to cache
    await images.loadAllImages();

    _loadLevel();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick && (!_isLoading)) {
      updateJoystick();
    }
    return super.update(dt);
  }

  void addJoystickUI() {
    camera.viewport.add(joystick); // Add joystick to viewport so it is always visible
    camera.viewport.add(jumpButton);
  }

  void removeJoystickUI() {
    camera.viewport.remove(joystick);
    camera.viewport.remove(jumpButton);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.direction = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.direction = 1;
        break;
      default:
        player.direction = 0;
        break;
    }
  }

  void loadNextLevel() {
    _isLoading = true;
    removeWhere((component) => component is Level);

    if (showJoystick) removeJoystickUI();

    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      player = Player(character: 'Mask Dude');
      Level world = Level(levelName: levelNames[currentLevelIndex], player: player);

      camera = CameraComponent.withFixedResolution(width: width, height: height, world: world);
      camera.viewfinder.anchor = Anchor.topLeft;

      addAll([world, camera]);

      if (showJoystick) addJoystickUI();

      _isLoading = false;
    });
  }
}
