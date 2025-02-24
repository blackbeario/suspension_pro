import 'package:flutter_test/flutter_test.dart';
import 'package:suspension_pro/views/in_app_purchases/in_app_bloc.dart';

void main() {
  late InAppBloc bloc;
  late int newCredits;

  setUp(() {
    bloc = InAppBloc();
    newCredits = 3;
  });

  group('Test InAppBloc methods', () {
    test('Ensure credits are returned properly when added', () {
      //Act (setter)
      bloc.credits = newCredits;

      //Assert (getter) credits equal 3
      expect(bloc.credits == 3, true);
    });

    test('Ensure freeCredits are removed when removeFreeCredit method is called', () {
      //Act (setter)
      bloc.removeFreeCredit();

      //Assert (getter) credits equal 2
      expect(bloc.freeCredits == 2, true);
      
    });
  });
}
