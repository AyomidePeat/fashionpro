import 'package:fashionpro_app/features/measurement/data/model/measurement_model.dart';
import 'package:hive/hive.dart';

class MeasurementRepository {
  final Box<MeasurementResult> _box;
  MeasurementRepository(this._box);

  Future<void> save(MeasurementResult result) async {
    await _box.add(result);
  }

  List<MeasurementResult> all() => _box.values.toList();
}
