import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(title: const Text("Second Screen")),
      body: Container(
        child: SizedBox(
          width: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              const Spacer(),
              const Center(
                child: Text("Navigated from notification"),
              ),
              // This icon button has been added fot ios navigation
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_circle_left_outlined),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
