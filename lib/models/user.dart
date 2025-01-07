import 'package:hive/hive.dart';
import 'package:suspension_pro/hive_helper/hive_types.dart';
import 'package:suspension_pro/hive_helper/hive_adapters.dart';
import 'package:suspension_pro/hive_helper/fields/app_user_fields.dart';


part 'user.g.dart';


@HiveType(typeId: HiveTypes.appUser, adapterName: HiveAdapters.appUser)
class AppUser extends HiveObject{
	@HiveField(AppUserFields.id)
  final String id;
	@HiveField(AppUserFields.username)
  final String? username;
	@HiveField(AppUserFields.profilePic)
  final String? profilePic;
	@HiveField(AppUserFields.email)
  final String email;
	@HiveField(AppUserFields.created)
  final DateTime? created;
	@HiveField(AppUserFields.proAccount)
  final bool? proAccount;

  AppUser({
    required this.id,
    this.username,
    this.profilePic,
    required this.email,
    this.created,
    this.proAccount,
  });

  factory AppUser.fromSnapshot(Map<String, dynamic> data) => AppUser(
        id: data['id'] ?? '',
        username: data['username'] ?? 'Guest',
        profilePic: data['profilePic'] ?? '',
        email: data['email'] ?? '',
        proAccount: data['proAccount'] ?? false,
        created: data['created'] != null ? DateTime.fromMillisecondsSinceEpoch(data['created']) : null,
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'profilePic': profilePic,
        'email': email,
        'proAccount': proAccount,
        'created': created?.millisecondsSinceEpoch
      };
}