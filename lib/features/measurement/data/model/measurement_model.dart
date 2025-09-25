class MeasurementResult {
  final double height;
  final double chest;
  final double waist;
  final double hips;

  MeasurementResult({
    required this.height,
    required this.chest,
    required this.waist,
    required this.hips,
  });

  factory MeasurementResult.fromJson(Map<String, dynamic> json) {
    return MeasurementResult(
      height: (json["height"] ?? 0).toDouble(),
      chest: (json["chest"] ?? 0).toDouble(),
      waist: (json["waist"] ?? 0).toDouble(),
      hips: (json["hips"] ?? 0).toDouble(),
    );
  }
}
