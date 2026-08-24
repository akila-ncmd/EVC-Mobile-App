import 'package:evc_app/core/widgets/phone_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The frame must letterbox on desktop and stay out of the way on phones.
void main() {
  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size * 2.0;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => PhoneFrame(
            child: Builder(
              builder: (inner) => Text(
                MediaQuery.sizeOf(inner).width.toStringAsFixed(0),
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('phone viewport passes through untouched', (tester) async {
    await pumpAt(tester, const Size(393, 852));
    expect(find.text('393'), findsOneWidget);
  });

  testWidgets('tablet width still passes through', (tester) async {
    await pumpAt(tester, const Size(680, 900));
    expect(find.text('680'), findsOneWidget);
  });

  testWidgets('desktop width reports phone dimensions to the app', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900));
    expect(
      find.text('393'),
      findsOneWidget,
      reason: 'the app should believe it is on a phone, not a 1440px desktop',
    );
  });

  testWidgets('a short desktop window scales down instead of clipping', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 620));
    // No overflow exception means it scaled to fit rather than clipping.
    expect(find.byType(FittedBox), findsWidgets);
    expect(find.text('393'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
