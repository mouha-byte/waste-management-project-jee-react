import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoguide/main.dart';

void main() {
  testWidgets('EcoGuide app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoGuideApp());
    expect(find.text('EcoGuide'), findsWidgets);
  });
}
