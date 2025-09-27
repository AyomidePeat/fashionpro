// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeasurementResultAdapter extends TypeAdapter<MeasurementResult> {
  @override
  final int typeId = 0;

  @override
  MeasurementResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeasurementResult(
      height: fields[0] as double,
      chest: fields[1] as double,
      waist: fields[2] as double,
      hips: fields[3] as double,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MeasurementResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.height)
      ..writeByte(1)
      ..write(obj.chest)
      ..writeByte(2)
      ..write(obj.waist)
      ..writeByte(3)
      ..write(obj.hips)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasurementResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
