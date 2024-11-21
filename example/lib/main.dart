import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(
    fileName: "assets/.env",
    mergeWith: {
      'TEST_VAR': '5',
    },
    baseEnvFileName: "assets/.base.env",
  ); // mergeWith optional, you can include Platform.environment for Mobile/Desktop app

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_dotenv Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dotenv Demo'),
        ),
        body: SingleChildScrollView(
          child: FutureBuilder<List<String>>(
            future: Future.wait([
              rootBundle.loadString('assets/.env'),
              rootBundle.loadString('assets/.base.env'),
            ]),
            initialData: const ['', ''],
            builder: (context, snapshot) => Container(
              padding: const EdgeInsets.all(50),
              child: Column(
                children: [
                  Text(
                    'Env map: ${dotenv.env.toString()}',
                  ),
                  const Divider(thickness: 5),
                  const Text('Original'),
                  const Divider(),
                  Text(snapshot.data?.toString() ?? ''),
                  Text(dotenv.get('MISSING',
                      fallback: 'Default fallback value')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
