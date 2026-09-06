import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skanskin_app/features/splash/presentation/splash_screen.dart';
import 'package:skanskin_app/shared/widgets/app_button.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('shows the brand name and tagline', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: MaterialApp(home: SplashScreen()),
        ),
      );

      expect(find.text('SkanSkin'), findsOneWidget);
      expect(find.text('استشارات الأمراض الجلدية'), findsOneWidget);
    });
  });

  group('AppButton', () {
    testWidgets('renders its label and fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: MaterialApp(
            home: Scaffold(
              body: AppButton(label: 'إرسال', onPressed: () => taps++),
            ),
          ),
        ),
      );

      expect(find.text('إرسال'), findsOneWidget);
      await tester.tap(find.text('إرسال'));
      expect(taps, 1);
    });

    testWidgets('exposes one semantic tap action when enabled', (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: MaterialApp(
            home: Scaffold(
              body: AppButton(label: 'إرسال', onPressed: () => taps++),
            ),
          ),
        ),
      );

      final node = tester.getSemantics(find.byType(AppButton));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      tester.binding.performSemanticsAction(
        SemanticsActionEvent(
          type: SemanticsAction.tap,
          nodeId: node.id,
          viewId: tester.view.viewId,
        ),
      );
      await tester.pump();
      expect(taps, 1);
      semantics.dispose();
    });

    testWidgets('does not fire when loading', (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: MaterialApp(
            home: Scaffold(
              body: AppButton(
                label: 'إرسال',
                loading: true,
                onPressed: () => taps++,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final node = tester.getSemantics(find.byType(AppButton));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      expect(taps, 0);
      semantics.dispose();
    });

    testWidgets(
      'does not expose tap semantics when disabled or callback is null',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.rtl,
            child: MaterialApp(
              home: Scaffold(
                body: AppButton(
                  label: 'إرسال',
                  enabled: false,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        final disabledNode = tester.getSemantics(find.byType(AppButton));
        expect(
          disabledNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isFalse,
        );

        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.rtl,
            child: MaterialApp(
              home: Scaffold(body: AppButton(label: 'إرسال')),
            ),
          ),
        );

        final callbackNullNode = tester.getSemantics(find.byType(AppButton));
        expect(
          callbackNullNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isFalse,
        );
        semantics.dispose();
      },
    );
  });
}
