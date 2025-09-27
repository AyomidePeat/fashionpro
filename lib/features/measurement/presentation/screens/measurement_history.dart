import 'package:fashionpro_app/features/measurement/presentation/providers/report_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MeasurementHistoryScreen extends ConsumerWidget {
  const MeasurementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(repoProvider);
    final history = repo.all().reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: history.isEmpty
          ? const Center(child: Text("No saved measurements"))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (c, i) {
                final r = history[i];
                return ListTile(
                  title: Text("Height: ${r.height} cm"),
                  subtitle: Text("Chest: ${r.chest}, Waist: ${r.waist}, Hips: ${r.hips}"),
                  trailing: Text("${r.createdAt.day}/${r.createdAt.month}"),
                );
              },
            ),
    );
  }
}
