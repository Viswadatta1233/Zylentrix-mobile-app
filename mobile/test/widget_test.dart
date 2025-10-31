import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mobile/main.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/task_provider.dart';
import 'package:mobile/providers/theme_provider.dart';

void main() {
  testWidgets('App initializes successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const TaskFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Login screen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const TaskFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('TaskFlow'), findsWidgets);
    expect(find.text('Login'), findsWidgets);
  });
}
