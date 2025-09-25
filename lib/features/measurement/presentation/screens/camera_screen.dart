import 'dart:io';
import 'package:fashionpro_app/core/network/error_handler.dart';
import 'package:fashionpro_app/features/measurement/presentation/providers/measurement_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';


class CameraCaptureScreen extends ConsumerStatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  ConsumerState<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  File? frontImage;
  File? sideImage;

  Future<void> pickImage(bool isFront) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        if (isFront) {
          frontImage = File(picked.path);
        } else {
          sideImage = File(picked.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final measurementState = ref.watch(measurementResultProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Capture Measurements")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => pickImage(true),
                    child: Container(
                      height: 160,
                      color: Colors.grey[200],
                      child: frontImage != null
                          ? Image.file(frontImage!, fit: BoxFit.cover)
                          : const Center(child: Text("Tap to capture front")),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => pickImage(false),
                    child: Container(
                      height: 160,
                      color: Colors.grey[200],
                      child: sideImage != null
                          ? Image.file(sideImage!, fit: BoxFit.cover)
                          : const Center(child: Text("Tap to capture side")),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: frontImage != null && sideImage != null
                  ? () async {
                      await ref
                          .read(measurementResultProvider.notifier)
                          .capture(frontImage!, sideImage!);
                    }
                  : null,
              child: const Text("Upload & Get Measurements"),
            ),
            const SizedBox(height: 24),
            measurementState.when(
              data: (result) {
                if (result == null) return const SizedBox();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text("Height: ${result.height} cm"),
                        Text("Chest: ${result.chest} cm"),
                        Text("Waist: ${result.waist} cm"),
                        Text("Hips: ${result.hips} cm"),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text(ErrorHandler.getMessage(e),
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
