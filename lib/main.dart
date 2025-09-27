import 'package:fashionpro_app/core/app_theme/app_theme.dart';
import 'package:fashionpro_app/features/measurement/data/model/measurement_model.dart';
import 'package:fashionpro_app/features/measurement/presentation/screens/measurement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<MeasurementResult>("measurements");

  runApp(const ProviderScope(child: FashionProApp()));
}

class FashionProApp extends StatelessWidget {
  const FashionProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FashionPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MeasurementScreen(),
    );
  }
}
