  import 'dart:async';
  
  import 'package:flame/components.dart';
  import 'package:flame_tiled/flame_tiled.dart';
  import 'package:pixel_adventure/components/background_tile.dart';
  import 'package:pixel_adventure/components/collision_block.dart';
  import 'package:pixel_adventure/components/player.dart';
  import 'package:pixel_adventure/pixel_adventure.dart';
  
  class Level extends World with HasGameReference<PixelAdventure> {
    Level({required this.levelName, required this.player});
    String levelName;
    Player player;
    List<CollisionBlock> collisionBlocks = [];
  
    late TiledComponent level;
    final double levelTileSize = 16;
    final backgroundTileSize = 64;
  
    @override
    FutureOr<void> onLoad() async {
      level = await TiledComponent.load('$levelName.tmx', Vector2.all(levelTileSize));
      add(level);
  
      _scrollingBackground();
      _spawningObjects();
      _addCollisions();
  
      return super.onLoad();
    }
  
    void _addCollisions() {
      final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
  
      if (collisionsLayer != null) {
        for (final collision in collisionsLayer.objects) {
          switch (collision.class_) {
            case "Platform":
              final platform = CollisionBlock(
                  position: Vector2(collision.x, collision.y),
                  size: Vector2(collision.width, collision.height),
                  isPlatform: true
              );
              collisionBlocks.add(platform);
              add(platform);
              break;
            default:
              final block = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
              );
              collisionBlocks.add(block);
              add(block);
              break;
          }
        }
      }
      player.collisionBlocks = collisionBlocks;
    }
  
    void _spawningObjects() {
      final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
  
      if (spawnPointsLayer != null) {
        for (final spawnPoint in spawnPointsLayer.objects) {
          switch (spawnPoint.class_) {
            case "Player":
              player.position = Vector2(spawnPoint.x, spawnPoint.y);
              add(player);
              break;
          }
        }
      }
    }
  
    void _scrollingBackground() {
      final backgroundLayer = level.tileMap.getLayer('Background');
  
      final numTileSizeY = (game.size.y / backgroundTileSize).round();
      final numTileSizeX = (game.size.x / backgroundTileSize).round();
  
      if (backgroundLayer != null) {
        final backgroundColor = backgroundLayer.properties.getValue('BackgroundColor');
  
        for (double y = 0; y < numTileSizeY; y++) {
          for (double x = 0; x < numTileSizeX; x++) {
            final backgroundTile = BackgroundTile(
                position: Vector2(x * backgroundTileSize, y * backgroundTileSize),
                color: backgroundColor ?? 'Gray'
            );
  
            add(backgroundTile);
          }
        }
      }
    }
  }