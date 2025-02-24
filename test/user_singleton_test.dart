import 'package:flutter_test/flutter_test.dart';
import 'package:suspension_pro/core/models/user.dart';
import 'package:suspension_pro/core/models/user_singleton.dart';

void main() {
  late AppUser user;
  late UserSingleton service;

  setUp(() {
    service = UserSingleton();
    user = AppUser(id: '123456', email: 'testUser@gmail.com');
  });
  group('Test UserSingleton functions', () {
    
   test('Create new user when setNewUser method is called and expect userName is Guest', () {
      //Act
      service.setNewUser(user);

      //Assert username is 'Guest' since no userName was provided
      expect(service.uid == '123456', true);
      expect(service.email == 'testUser@gmail.com', true);
      expect(service.userName == 'Guest', true);
    });

    test('Update userName, firstName, and lastname get updated by updateNewUser', () {
      //Act
      service.updateNewUser('testUser', 'Test', 'User');

      //Assert
      expect(service.userName == 'testUser', true);
      expect(service.firstName == 'Test', true);
      expect(service.lastName == 'User', true);
    });

    test('Remove uid when resetUidForLogout is called by AuthService signout', () {
      service.resetUidForLogout();
      expect(service.uid == '', true);
    });
  });
}