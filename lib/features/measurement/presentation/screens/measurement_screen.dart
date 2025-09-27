import 'dart:io';
import 'package:fashionpro_app/features/measurement/presentation/providers/measurement_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_app_settings/open_app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeasurementScreen extends ConsumerStatefulWidget {
  const MeasurementScreen({super.key});

  @override
  ConsumerState<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends ConsumerState<MeasurementScreen> {
  File? frontPhoto;
  File? sidePhoto;
  final _refCmController = TextEditingController();
  final _refPxController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Color get primaryColor => const Color(0xFF1D3557);
  Color get accentColor => const Color(0xFF457B9D);

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final frontPath = prefs.getString("frontPhoto");
    final sidePath = prefs.getString("sidePhoto");
    final refCm = prefs.getString("refCm");
    final refPx = prefs.getString("refPx");
    if (frontPath != null) frontPhoto = File(frontPath);
    if (sidePath != null) sidePhoto = File(sidePath);
    if (refCm != null) _refCmController.text = refCm;
    if (refPx != null) _refPxController.text = refPx;
    setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (frontPhoto != null) await prefs.setString("frontPhoto", frontPhoto!.path);
    if (sidePhoto != null) await prefs.setString("sidePhoto", sidePhoto!.path);
    await prefs.setString("refCm", _refCmController.text);
    await prefs.setString("refPx", _refPxController.text);
  }

  Future<void> _pickImage(bool isFront) async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      _showSnackbar("Camera permission is permanently denied. Enable it in App Settings.", Colors.red.shade900);
      OpenAppSettings.openAppSettings();
      return;
    }
    if (!status.isGranted) {
      _showSnackbar("Camera permission is required to capture photos.", Colors.orange.shade700);
      return;
    }
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (picked != null) {
        setState(() {
          if (isFront) {
            frontPhoto = File(picked.path);
          } else {
            sidePhoto = File(picked.path);
          }
        });
        _saveData();
      }
    } catch (e) {
      _showSnackbar("Camera launch failed. Check permissions.", Colors.red.shade700);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (frontPhoto == null || sidePhoto == null) {
      _showSnackbar("Please capture both the front and side photos.", Colors.orange.shade700);
      return;
    }
    final refCm = double.tryParse(_refCmController.text)!;
    // final refPx = double.tryParse(_refPxController.text)!;
    await ref.read(measurementProvider.notifier).uploadMeasurement(
           frontPhoto!,
         sidePhoto!,
          refCm,
        );
    _saveData();
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(measurementProvider);
    ref.listen(measurementProvider, (previous, next) {
      if (next.error != null) {
        _showSnackbar(next.error!, Colors.red.shade700);
      } else if (next.result != null) {
        _showSnackbar("Measurements received successfully!", Colors.green.shade700);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text("3D Body Scanner", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructionsCard(),
              const SizedBox(height: 24),
              Text("Reference Object Dimensions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _refCmController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration("Known Width (cm)", Icons.straighten_rounded),
                      onChanged: (_) => _saveData(),
                      validator: (value) {
                        if (value == null || double.tryParse(value) == null || double.tryParse(value)! <= 0) {
                          return 'Enter valid CM value.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _refPxController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      decoration: _inputDecoration("Pixel Width (Px)", Icons.crop_free_rounded).copyWith(
                        hintText: "Input Pixel Width",
                      ),
                      onChanged: (_) => _saveData(),
                      validator: (value) {
                        if (value == null || double.tryParse(value) == null || double.tryParse(value)! <= 0) {
                          return 'Enter valid Px value.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text("Capture Photos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildImageCaptureCard(true, frontPhoto, "Front Profile")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildImageCaptureCard(false, sidePhoto, "Side Profile")),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: state.isLoading
                    ? CircularProgressIndicator(color: accentColor)
                    : SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.cloud_upload_rounded, size: 28),
                          label: const Text("Analyze Measurements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 8,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt_rounded, color: primaryColor, size: 28),
                const SizedBox(width: 8),
                Text("Measurement Prep", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
              ],
            ),
            const Divider(height: 20),
            _buildInstructionItem("Wear tight, form-fitting clothes (e.g., swimsuit, leggings)."),
            _buildInstructionItem("Tuck in loose clothes if unavoidable."),
            _buildInstructionItem("Tie back loose hair."),
            _buildInstructionItem("Stand barefoot with arms raised at 45°."),
            _buildInstructionItem("Use front camera, level at chest height."),
            _buildInstructionItem("Keep background clear, no other person visible."),
            _buildInstructionItem("Camera should be at least 8–10 feet away."),
            _buildInstructionItem("Hold a flat reference object of known size (e.g., A4 paper)."),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF1D3557)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13.5))),
        ],
      ),
    );
  }

  Widget _buildImageCaptureCard(bool isFront, File? photo, String title) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: photo == null ? Colors.grey.shade100 : Colors.transparent,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: photo == null ? Border.all(color: Colors.grey.shade300) : null,
            ),
            child: photo != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.file(photo, fit: BoxFit.cover),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isFront ? Icons.person_outline : Icons.group_rounded, size: 40, color: Colors.grey.shade400),
                        Text(title, style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton.icon(
              onPressed: () => _pickImage(isFront),
              icon: Icon(photo != null ? Icons.refresh_rounded : Icons.camera_alt_rounded, size: 20),
              label: Text(photo != null ? "Recapture" : "Capture", style: const TextStyle(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: accentColor),
      prefixIcon: Icon(icon, color: accentColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }
}
