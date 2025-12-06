import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/bikes/presentation/screens/bike_wizard_screen.dart';
import 'package:ridemetrx/features/bikes/presentation/widgets/bikes_list.dart';
import 'package:ridemetrx/features/bikes/presentation/widgets/new_user_action.dart';
import 'package:ridemetrx/features/connectivity/presentation/widgets/connectivity_widget_wrapper.dart';
import 'package:ridemetrx/features/profile/presentation/screens/profile_screen.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';
import 'package:ridemetrx/features/purchases/presentation/screens/paywall_screen.dart';
import 'package:ridemetrx/features/purchases/domain/paywall_display_manager.dart';

class OfflineBikesList extends ConsumerStatefulWidget {
  const OfflineBikesList({Key? key, required this.bikes}) : super(key: key);

  final List<Bike> bikes;

  @override
  ConsumerState<OfflineBikesList> createState() => _OfflineBikesListState();
}

class _OfflineBikesListState extends ConsumerState<OfflineBikesList> {
  final double profilePicSize = 50;
  bool finished = false;
  bool shouldShowPaywall = false;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _checkPaywallDisplay();
  }

  void _initAnimation() {
    Future.delayed(Duration.zero, () {
      setState(() => finished = !finished);
    });
  }

  Future<void> _checkPaywallDisplay() async {
    final user = ref.read(userNotifierProvider);
    final shouldShow = await PaywallDisplayManager.shouldShowPaywall(
      isPro: user.isPro,
      hasNoBikes: widget.bikes.isEmpty,
    );

    if (mounted) {
      setState(() => shouldShowPaywall = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);

    if (widget.bikes.isEmpty) {
      return SafeArea(
        child: AnimatedSlide(
          offset: finished ? Offset.zero : const Offset(0, 1),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: (profilePicSize / 3) - 8.0),
                  child: Card(
                    color: Colors.white,
                    margin: const EdgeInsets.all(0),
                    shadowColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 6),
                            child: Text(
                              'Welcome ${user.userName}!',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              'Add your first bike to hide these tasks',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          NewUserAction(
                            showAppBar: true,
                            title: _getProfileString(user),
                            icon: const Icon(Icons.edit_note),
                            screen: const ProfileScreen(),
                            complete: user.isProfileComplete,
                            showIcon: true,
                          ),
                          NewUserAction(
                            showAppBar: true,
                            title: 'Add Your First Bike',
                            icon: Icon(Icons.pedal_bike),
                            screen: BikeWizardScreen(),
                            showIcon: true,
                          ),
                          if (shouldShowPaywall)
                            ConnectivityWidgetWrapper(
                              offlineWidget: SizedBox(),
                              stacked: false,
                              child: NewUserAction(
                                title: 'Go Pro!',
                                showAppBar: false,
                                icon: Icon(Icons.monetization_on_outlined),
                                screen: PaywallScreen(
                                  onDismiss: () async {
                                    await PaywallDisplayManager.recordPaywallDismissed();
                                  },
                                ),
                                showIcon: true,
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BikesList(bikes: widget.bikes);
  }

  String _getProfileString(user) {
    if (!user.isProfileComplete) {
      return 'Complete Your Profile';
    }
    return 'Edit Profile';
  }
}
