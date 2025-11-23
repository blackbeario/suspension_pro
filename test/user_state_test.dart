import 'package:flutter_test/flutter_test.dart';
import 'package:suspension_pro/features/auth/domain/models/user.dart';
import 'package:suspension_pro/features/auth/domain/user_state.dart';

void main() {
  late AppUser user;
  late UserState userState;

  setUp(() {
    user = AppUser(id: '123456', email: 'testUser@gmail.com');
    userState = UserState.fromAppUser(user);
  });

  group('Test UserState functions', () {
    test('Create new UserState from AppUser and expect default userName is Guest', () {
      //Assert username is 'Guest' since no userName was provided
      expect(userState.uid == '123456', true);
      expect(userState.email == 'testUser@gmail.com', true);
      expect(userState.userName == 'Guest', true);
      expect(userState.isAuthenticated, true);
    });

    test('Update userName, firstName, and lastname using copyWith', () {
      //Act
      final updatedState = userState.copyWith(
        userName: 'testUser',
        firstName: 'Test',
        lastName: 'User',
      );

      //Assert
      expect(updatedState.userName == 'testUser', true);
      expect(updatedState.firstName == 'Test', true);
      expect(updatedState.lastName == 'User', true);
    });

    test('UserState.empty() creates unauthenticated state', () {
      final emptyState = UserState.empty();
      expect(emptyState.isAuthenticated, false);
      expect(emptyState.uid == '', true);
    });
  });
}