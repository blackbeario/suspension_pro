import 'package:flutter_test/flutter_test.dart';
import 'package:suspension_pro/features/purchases/presentation/in_app_bloc.dart';

void main() {
  late InAppBloc bloc;
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    bloc = InAppBloc();
  });

  group('Test InAppBloc methods', () {
    test('Ensure credits are returned properly when added', () async {
      //Act (setter)
      bloc.setCredits(3);

      //Assert (getter) credits equal 3
      expect(bloc.credits == 3, true);
    });

    test('Ensure freeCredits are removed when removeFreeCredit method is called', () {
      //Act (setter)
      bloc.removeCredit();

      //Assert (getter) credits equal 2
      expect(bloc.credits == 2, true);
    });
  });
}
