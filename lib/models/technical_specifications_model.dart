class TechnicalSpecificationsModel {
  final String tsId;
  final String productId;
  final String operatingSystem;
  final String processor;
  final String graphicsCard;
  final int ram;
  final int rom;
  final double screenSize;
  final String camera;
  final String batteryCapacity;
  final double weight;


  TechnicalSpecificationsModel({
    required this.tsId,
    required this.productId,
    required this.operatingSystem,
    required this.processor,
    required this.graphicsCard,
    required this.ram,
    required this.rom,
    required this.screenSize,
    required this.camera,
    required this.batteryCapacity,
    required this.weight,
  });
}
