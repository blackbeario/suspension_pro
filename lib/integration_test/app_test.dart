import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_driver/flutter_driver.dart' as flutterDriver;
import 'package:integration_test/integration_test.dart';
import 'package:suspension_pro/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    flutterDriver.FlutterDriver? driver;

    setUpAll(() async {
      driver = await flutterDriver.FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver!.close();
      }
    });

    testWidgets('verify login and sign up fields and buttons work', (
      tester,
    ) async {
      // Load app widget.
      await tester.pumpWidget(const MyApp(showHome: true));

      final emailField = flutterDriver.find.byValueKey('emailField');
      final passwordField = flutterDriver.find.byValueKey('passwordField');
      final signInButton = flutterDriver.find.byValueKey('signInButton');

      // final createAccountButton = flutterDriver.find.byValueKey('createAccountButton');

      final signUpEmailField = flutterDriver.find.byValueKey('signUpEmailField');
      final signUpPasswordField = flutterDriver.find.byValueKey('signUpPasswordField');
      final signUpButton = flutterDriver.find.byValueKey('signUpButton');

      // Verify the Sign In button exists.
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('createAccountButton'), findsOneWidget);

      test('create new account', () async {
        await driver!.tap(signUpEmailField);
        await driver!.enterText('newTester@vibesoftware.io');

        await driver!.tap(signUpPasswordField);
        await driver!.enterText('@s#3ville!');

        await driver!.tap(signUpButton);
        expect(find.text('Add Your First Bike'), findsOneWidget);
      });

      test('sign into account', () async {
        await driver!.tap(emailField);
        await driver!.enterText('newTester@vibesoftware.io');

        await driver!.tap(passwordField);
        await driver!.enterText('@s#3ville!');

        await driver!.tap(signInButton);
        expect(find.text('Bikes & Settings'), findsOneWidget);
      });

      // Trigger a frame.
      await tester.pumpAndSettle();

      // Verify the counter increments by 1.
      expect(find.text('1'), findsOneWidget);
    });
  });
}
