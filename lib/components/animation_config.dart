class AnimationConfig {
  final int amount;
  final double stepTime;
  final double textureSize;
  final bool loop;
  final bool hasCharacterName;
  final bool hasTextureName;

  const AnimationConfig({
    required this.amount,
    required this.stepTime,
    required this.textureSize,
    this.loop = true,
    this.hasCharacterName = true,
    this.hasTextureName = true
  });
}