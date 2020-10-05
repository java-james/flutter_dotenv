import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Available anywhere in the app
    final foo = DotEnv().env['foo'];
    print('value of foo is $foo');

    return MaterialApp(
      home: Column(children: [
        Text('foo is'),
        Text(foo == null ? "(not defined)" : foo)
      ]),
    );
  }
}
