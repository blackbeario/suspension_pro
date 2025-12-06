import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/community/domain/models/community_setting.dart';
import 'package:ridemetrx/features/community/presentation/screens/setting_detail_screen.dart';
import 'package:ridemetrx/core/services/haptic_service.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Card widget displaying a community setting
/// Shows bike components, engagement metrics, and user info
class SettingCard extends ConsumerWidget {
  final CommunitySetting setting;

  const SettingCard({
    Key? key,
    required this.setting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          HapticService.light();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SettingDetailScreen(setting: setting),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: User info and Pro badge
              _buildHeader(context),
              const SizedBox(height: 12),

              // Bike info (if available)
              if (setting.bikeMake != null || setting.bikeModel != null) ...[
                _buildBikeInfo(context),
                const SizedBox(height: 12),
              ],

              // Components display
              _buildComponents(context),
              const SizedBox(height: 12),

              // Location (if available)
              if (setting.location != null) ...[
                _buildLocation(context),
                const SizedBox(height: 12),
              ],

              // Rider context
              if (setting.riderWeight != null) ...[
                _buildRiderInfo(context),
                const SizedBox(height: 12),
              ],

              // Engagement metrics
              _buildMetrics(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // User avatar placeholder
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            setting.userName.isNotEmpty
                ? setting.userName[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // User name and timestamp
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    setting.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (setting.isPro) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade600,
                            Colors.amber.shade800,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 10,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                timeago.format(setting.created, locale: 'en_short'),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBikeInfo(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.pedal_bike,
          size: 16,
          color: Colors.purple.shade600,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            setting.bikeDisplay,
            style: TextStyle(
              color: Colors.purple.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildComponents(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (setting.fork != null) ...[
            _buildComponentRow(
              icon: Icons.motion_photos_on,
              label: 'Fork',
              value: '${setting.fork!.brand} ${setting.fork!.model}',
              year: setting.fork!.year,
            ),
          ],
          if (setting.fork != null && setting.shock != null)
            const SizedBox(height: 8),
          if (setting.shock != null) ...[
            _buildComponentRow(
              icon: Icons.sync_alt,
              label: 'Shock',
              value: '${setting.shock!.brand} ${setting.shock!.model}',
              year: setting.shock!.year,
            ),
          ],
          if (setting.fork == null && setting.shock == null)
            Text(
              'No components specified',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComponentRow({
    required IconData icon,
    required String label,
    required String value,
    String? year,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            year != null ? '$year $value' : value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLocation(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 16,
          color: Colors.green.shade600,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            setting.locationDisplay,
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRiderInfo(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.person,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 6),
        Text(
          'Rider: ${setting.riderWeight}',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildMetrics(BuildContext context) {
    return Row(
      children: [
        _buildMetricChip(
          icon: Icons.file_download,
          label: setting.imports.toString(),
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        _buildMetricChip(
          icon: Icons.thumb_up,
          label: setting.upvotes.toString(),
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        _buildMetricChip(
          icon: Icons.visibility,
          label: setting.views.toString(),
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
