import 'package:hive/hive.dart';

part 'measurement_model.g.dart';

@HiveType(typeId: 0)
class MeasurementResult {
  @HiveField(0)
  final double height;
  @HiveField(1)
  final double chest;
  @HiveField(2)
  final double waist;
  @HiveField(3)
  final double hips;
  @HiveField(4)
  final DateTime createdAt;

  MeasurementResult({
    required this.height,
    required this.chest,
    required this.waist,
    required this.hips,
    required this.createdAt,
  });

  factory MeasurementResult.fromJson(Map<String, dynamic> json) {
    return MeasurementResult(
      height: (json["height"] ?? 0).toDouble(),
      chest: (json["chest"] ?? 0).toDouble(),
      waist: (json["waist"] ?? 0).toDouble(),
      hips: (json["hips"] ?? 0).toDouble(),
      createdAt: DateTime.now(),
    );
  }
}
