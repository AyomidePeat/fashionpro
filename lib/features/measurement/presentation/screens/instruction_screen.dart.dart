import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Instructions")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("✅ Correct Pose", style: Theme.of(context).textTheme.titleLarge),
          Lottie.asset("lottie/correct_pose.json", height: 200),
          const Text("Stand straight, arms slightly apart, tight clothes."),

          const SizedBox(height: 24),
          Text("❌ Wrong Pose", style: Theme.of(context).textTheme.titleLarge),
          Lottie.asset("lottie/wrong_pose.json", height: 200),
          const Text("Avoid crossed arms, baggy clothes, bad lighting."),

          const SizedBox(height: 24),
          Text("✅ Good Background", style: Theme.of(context).textTheme.titleLarge),
          Lottie.asset("lottie/good_bg.json", height: 200),
          const Text("Use a plain wall and good lighting."),
        ],
      ),
    );
  }
}
