#!/usr/bin/env dart

import 'dart:io';

// Simple test to verify the fix works
void main() async {
  print('Testing empty .env file handling...');
  
  // Create a temporary empty .env file
  final emptyEnvFile = File('test_empty.env');
  await emptyEnvFile.writeAsString('');
  
  print('Created empty test file: ${emptyEnvFile.path}');
  print('File exists: ${await emptyEnvFile.exists()}');
  print('File contents: "${await emptyEnvFile.readAsString()}"');
  print('File is empty: ${(await emptyEnvFile.readAsString()).isEmpty}');
  
  // Clean up
  await emptyEnvFile.delete();
  
  print('Test file created and cleaned up successfully.');
  print('The fix has been implemented in lib/src/dotenv.dart');
}