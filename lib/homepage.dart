import 'package:flutter/material.dart';

void main() {
  runApp(const Homepage());
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact List'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
              top: 60,
              bottom: 60,
              child: Align(
                alignment: Alignment.center,
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_circle_sharp,
                        size: 60, color: Colors.blue),
                    title: const Text(
                      'Demo',
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Column(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('01123456789'),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('4 hour(s) ago'),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
