import 'dart:io';
import 'package:fashionpro_app/features/measurement/presentation/providers/measurement_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class MeasurementScreen extends ConsumerStatefulWidget {
  const MeasurementScreen({super.key});

  @override
  ConsumerState<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends ConsumerState<MeasurementScreen> {
  File? frontPhoto;
  File? sidePhoto;
  final _heightController = TextEditingController();

  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        if (isFront) {
          frontPhoto = File(picked.path);
        } else {
          sidePhoto = File(picked.path);
        }
      });
    }
  }

  Future<void> _submit() async {
    if (frontPhoto == null || sidePhoto == null || _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide both photos and your height."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final heightCm = double.tryParse(_heightController.text);
    if (heightCm == null || heightCm < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid height in cm."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // Trigger upload
    await ref.read(measurementProvider.notifier).uploadMeasurement(
          frontPhoto!,
          sidePhoto!,
          heightCm,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(measurementProvider);

    // 🔥 Listen for success/error changes
    ref.listen(measurementProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      } else if (next.result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Measurements received successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        // TODO: Navigate to results screen if needed
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Body Measurement")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              " Capture Instructions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              " Wear tight clothes or tuck in loose clothes\n"
              " Stand barefoot, arms at 45°\n"
              " Tie up loose hair\n"
              " Good lighting + plain background\n"
              " No other humans in frame",
            ),
            const Divider(height: 32),

            // Height input
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Your Height (cm)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      frontPhoto != null
                          ? Image.file(frontPhoto!, height: 150, fit: BoxFit.cover)
                          : Container(
                              height: 150,
                              color: Colors.grey.shade200,
                              child: const Center(child: Text("Front Photo")),
                            ),
                      ElevatedButton(
                        onPressed: () => _pickImage(true),
                        child: const Text("Capture Front"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      sidePhoto != null
                          ? Image.file(sidePhoto!, height: 150, fit: BoxFit.cover)
                          : Container(
                              height: 150,
                              color: Colors.grey.shade200,
                              child: const Center(child: Text("Side Photo")),
                            ),
                      ElevatedButton(
                        onPressed: () => _pickImage(false),
                        child: const Text("Capture Side"),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            state.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text("Submit for Measurement"),
                  ),
          ],
        ),
      ),
    );
  }
}
