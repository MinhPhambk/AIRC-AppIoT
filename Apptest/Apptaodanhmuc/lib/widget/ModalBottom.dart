import 'package:flutter/material.dart';


class ModalBottom extends StatelessWidget {
  const ModalBottom({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      //KeyBoard
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            vertical: 20, horizontal: 20),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Your Task'),
            ),
            //Khoảng cách
            const SizedBox(
              height: 20,
            ),
            SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("Add Task"))),
          ],
        ),
      ),
    );
  }
}