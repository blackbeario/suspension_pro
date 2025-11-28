import 'package:hive_ce/hive.dart';
import 'package:ridemetrx/core/hive_helper/hive_types.dart';
import 'package:ridemetrx/core/hive_helper/hive_adapters.dart';
import 'package:ridemetrx/core/hive_helper/fields/app_user_fields.dart';


part 'user.g.dart';


@HiveType(typeId: HiveTypes.appUser, adapterName: HiveAdapters.appUser)
class AppUser extends HiveObject{
	@HiveField(AppUserFields.id)
  String id;
	@HiveField(AppUserFields.userName)
  String? userName;
  @HiveField(AppUserFields.firstName)
  String? firstName;
  @HiveField(AppUserFields.lastName)
  String? lastName;
	@HiveField(AppUserFields.profilePic)
  String? profilePic;
	@HiveField(AppUserFields.email)
  final String email;
	@HiveField(AppUserFields.created)
  final DateTime? created;
	@HiveField(AppUserFields.aiCredits)
  int? aiCredits;
  @HiveField(AppUserFields.isPro)
  bool? isPro;
  @HiveField(AppUserFields.subscriptionExpiryDate)
  DateTime? subscriptionExpiryDate;


  AppUser({
    required this.id,
    this.userName,
    this.firstName,
    this.lastName,
    this.profilePic,
    required this.email,
    this.created,
    this.aiCredits,
    this.isPro,
    this.subscriptionExpiryDate,
  });

  factory AppUser.fromSnapshot(Map<String, dynamic> data) => AppUser(
        id: data['uid'] ?? '',
        userName: data['username'] ?? 'Guest',
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        profilePic: data['profilePic'] ?? '',
        email: data['email'] ?? '',
        aiCredits: data['aiCredits'] ?? 0,
        created: data['created'] != null ? DateTime.fromMillisecondsSinceEpoch(data['created']) : null,
        isPro: data['isPro'] ?? false,
        subscriptionExpiryDate: data['subscriptionExpiryDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data['subscriptionExpiryDate'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'username': userName,
        'firstName': firstName,
        'lastName': lastName,
        'profilePic': profilePic,
        'email': email,
        'aiCredits': aiCredits,
        'created': created?.millisecondsSinceEpoch,
        'isPro': isPro ?? false,
        'subscriptionExpiryDate': subscriptionExpiryDate?.millisecondsSinceEpoch,
      };
}