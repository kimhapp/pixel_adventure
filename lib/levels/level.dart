import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/actors/player.dart';

class Level extends World {
  Level({required this.levelName});
  String levelName;

  late TiledComponent level;
  final double tileSize = 16;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(tileSize));
    add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    for (final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.class_) {
        case "Player":
          final player = Player(
            position: Vector2(spawnPoint.x, spawnPoint.y),
            character: "Pink Man"
          );
          add(player);
          break;
      }
    }
    return super.onLoad();
  }
}