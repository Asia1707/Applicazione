/* 
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Card(
              elevation: 10,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('da decidere'),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 107, 83, 138),
        actions: const [Icon(Icons.account_circle_sharp), SizedBox(width: 16)],
        title: const Text('Astemix & Drugbelix'),
        centerTitle: true,
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 240, 207),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: const Alignment(0, 0),
                  constraints: const BoxConstraints(
                    maxWidth: 300,
                    maxHeight: 80,
                  ),
                  color: Colors.black,
                  padding: const EdgeInsets.all(10.0),
                  child: const Text(
                    'WELCOME!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 300,
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Inserire username')],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 300,
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Inserire codice ID')],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
 */