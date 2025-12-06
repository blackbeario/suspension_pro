import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/community/domain/models/community_setting.dart';
import 'package:ridemetrx/features/community/domain/community_notifier.dart';
import 'package:ridemetrx/features/bikes/domain/bikes_notifier.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Detailed view of a community setting
/// Shows all suspension values and allows importing
class SettingDetailScreen extends ConsumerStatefulWidget {
  final CommunitySetting setting;

  const SettingDetailScreen({
    Key? key,
    required this.setting,
  }) : super(key: key);

  @override
  ConsumerState<SettingDetailScreen> createState() => _SettingDetailScreenState();
}

class _SettingDetailScreenState extends ConsumerState<SettingDetailScreen> {
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    // Increment view count when user opens detail view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(communityNotifierProvider.notifier).incrementViewCount(widget.setting.settingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting Details'),
        actions: [
          // Import button
          TextButton.icon(
            onPressed: _isImporting ? null : _showImportDialog,
            icon: const Icon(Icons.file_download),
            label: const Text('Import'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User header
          _buildUserHeader(),
          const SizedBox(height: 24),

          // Bike info (if available)
          if (widget.setting.bikeMake != null || widget.setting.bikeModel != null) ...[
            _buildSection(
              title: 'Bike',
              child: _buildBikeInfo(),
            ),
            const SizedBox(height: 24),
          ],

          // Components section
          _buildSection(
            title: 'Components',
            child: _buildComponents(),
          ),
          const SizedBox(height: 24),

          // Fork settings
          if (widget.setting.forkSettings != null) ...[
            _buildSection(
              title: 'Fork Settings',
              child: _buildComponentSettings(
                widget.setting.forkSettings!,
                isFork: true,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Shock settings
          if (widget.setting.shockSettings != null) ...[
            _buildSection(
              title: 'Shock Settings',
              child: _buildComponentSettings(
                widget.setting.shockSettings!,
                isFork: false,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Tire pressures
          if (widget.setting.frontTire != null || widget.setting.rearTire != null) ...[
            _buildSection(
              title: 'Tire Pressures',
              child: _buildTirePressures(),
            ),
            const SizedBox(height: 24),
          ],

          // Rider context
          _buildSection(
            title: 'Rider Info',
            child: _buildRiderInfo(),
          ),
          const SizedBox(height: 24),

          // Location
          if (widget.setting.location != null) ...[
            _buildSection(
              title: 'Location',
              child: _buildLocation(),
            ),
            const SizedBox(height: 24),
          ],

          // Notes
          if (widget.setting.notes != null && widget.setting.notes!.isNotEmpty) ...[
            _buildSection(
              title: 'Notes',
              child: Text(widget.setting.notes!),
            ),
            const SizedBox(height: 24),
          ],

          // Engagement metrics
          _buildMetrics(),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            widget.setting.userName.isNotEmpty ? widget.setting.userName[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.setting.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  if (widget.setting.isPro) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade600,
                            Colors.amber.shade800,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Shared ${timeago.format(widget.setting.created)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildBikeInfo() {
    return Row(
      children: [
        Icon(
          Icons.pedal_bike,
          size: 24,
          color: Colors.purple.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.setting.bikeDisplay,
            style: TextStyle(
              color: Colors.purple.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComponents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.setting.fork != null) ...[
          _buildComponentInfo(
            label: 'Fork',
            brand: widget.setting.fork!.brand,
            model: widget.setting.fork!.model,
            year: widget.setting.fork!.year,
          ),
        ],
        if (widget.setting.fork != null && widget.setting.shock != null) const SizedBox(height: 12),
        if (widget.setting.shock != null) ...[
          _buildComponentInfo(
            label: 'Shock',
            brand: widget.setting.shock!.brand,
            model: widget.setting.shock!.model,
            year: widget.setting.shock!.year,
          ),
        ],
      ],
    );
  }

  Widget _buildComponentInfo({
    required String label,
    required String brand,
    required String model,
    String? year,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          year != null ? '$year $brand $model' : '$brand $model',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildComponentSettings(dynamic settings, {required bool isFork}) {
    // ComponentSetting has toJson() method that returns Map<String, dynamic>
    final settingsMap = settings.toJson();

    return Column(
      children: settingsMap.entries.map<Widget>((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatSettingKey(entry.key),
                style: TextStyle(color: Colors.grey.shade700),
              ),
              Text(
                entry.value?.toString() ?? '-',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatSettingKey(String key) {
    // Convert camelCase to Title Case with spaces
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildTirePressures() {
    return Column(
      children: [
        if (widget.setting.frontTire != null) _buildInfoRow('Front', widget.setting.frontTire!),
        if (widget.setting.frontTire != null && widget.setting.rearTire != null) const SizedBox(height: 8),
        if (widget.setting.rearTire != null) _buildInfoRow('Rear', widget.setting.rearTire!),
      ],
    );
  }

  Widget _buildRiderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.setting.riderWeight != null) _buildInfoRow('Weight', widget.setting.riderWeight!),
      ],
    );
  }

  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.setting.location?.name != null) _buildInfoRow('Trail', widget.setting.location!.name!),
        if (widget.setting.location?.trailType != null)
          _buildInfoRow('Type', widget.setting.location!.trailTypeDisplay),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildMetrics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetricColumn(
          icon: Icons.file_download,
          label: 'Imports',
          value: widget.setting.imports.toString(),
          color: Colors.blue,
        ),
        _buildMetricColumn(
          icon: Icons.thumb_up,
          label: 'Upvotes',
          value: widget.setting.upvotes.toString(),
          color: Colors.green,
        ),
        _buildMetricColumn(
          icon: Icons.visibility,
          label: 'Views',
          value: widget.setting.views.toString(),
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildMetricColumn({
    required IconData icon,
    required String label,
    required String value,
    required MaterialColor color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color.shade600, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color.shade700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showImportDialog() {
    // Get bikes from Hive (now loaded on initialization)
    final bikesState = ref.read(bikesNotifierProvider);
    final bikes = bikesState.bikes;

    if (bikes.isEmpty) {
      // No bikes to import to
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a bike first before importing settings'),
        ),
      );
      return;
    }

    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Import Setting'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select which bike to import this setting to:'),
            const SizedBox(height: 16),
            ...bikes.map((bike) {
              final bikeName = bike.yearModel != null ? '${bike.yearModel} ${bike.id}' : bike.id;
              return Material(
                child: ListTile(
                  title: Text(bikeName),
                  onTap: () async {
                    Navigator.pop(context);
                    final settingName = await _showSettingNameDialog(bike.id);
                    if (settingName != null && settingName.isNotEmpty) {
                      _importToBike(bike.id, settingName);
                    }
                  },
                ),
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showSettingNameDialog(String bikeId) async {
    final controller = TextEditingController(text: '');

    return showAdaptiveDialog<String>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Choose Setting Name'),
        content: CupertinoTextField(
          controller: controller,
          autofocus: true,
          placeholder: 'Enter setting name',
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.systemGrey4),
            borderRadius: BorderRadius.circular(8),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              Navigator.of(context).pop(value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final settingName = controller.text.trim();
              if (settingName.isNotEmpty) {
                Navigator.of(context).pop(settingName);
              }
            },
            child: const Text('Clone'),
          ),
        ],
      ),
    );
  }

  Future<void> _importToBike(String bikeId, String newSettingName) async {
    setState(() => _isImporting = true);

    try {
      final String success = await ref.read(communityNotifierProvider.notifier).importSetting(
            widget.setting,
            newSettingName,
            bikeId,
          );

      if (success.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setting imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }
}
