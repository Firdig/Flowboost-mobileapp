import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../widgets/custom_widgets.dart';

class NewGoalScreen extends StatelessWidget {
  const NewGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
        title: const Text('New Goal'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create', style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 18)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Your New Goal', style: kHeaderStyle),
            const SizedBox(height: 20),
            RetroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Set Your Goal :', style: kLabelStyle),
                  const SizedBox(height: 10),
                  const Text('What do you want to Achieve?', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextFormField(initialValue: 'Belajar Javascript'),
                  const SizedBox(height: 15),
                  const Text('What the progress :', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Center(child: RetroButton(text: 'add new task +', onPressed: () {})),
                ],
              ),
            ),
            const SizedBox(height: 20),
            RetroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Set Self Reward :', style: kLabelStyle),
                  const SizedBox(height: 10),
                  const Text('What reward after complete the goal?', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextFormField(initialValue: 'Playing game all day', maxLines: 2),
                  const SizedBox(height: 15),
                  const Text('Reward Suggestion :', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Padding(padding: EdgeInsets.only(left: 10, bottom: 5), child: Text('Buy your wishlist book')),
                  const Padding(padding: EdgeInsets.only(left: 10, bottom: 15), child: Text('Buy a new Game')),
                  Center(child: RetroButton(text: 'generate new suggestion', onPressed: () {})),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}