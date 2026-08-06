import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KG ↔️ KOREA Delivery')),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('🇰🇬 Кыргызстан → 🇰🇷 Корея'),
              onPressed: () {},
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text('🇰🇷 Корея → 🇰🇬 Кыргызстан'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
