import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wooden_mill_app/core/constants/app_constants.dart';
import 'package:wooden_mill_app/core/theme/app_color_theme.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/theme/theme_controller.dart';
import 'package:wooden_mill_app/main.dart';
import 'package:wooden_mill_app/core/utils/export_helper.dart';
import 'package:wooden_mill_app/repositories/backup_repository.dart';
import 'package:wooden_mill_app/repositories/order_repository.dart';
import 'package:wooden_mill_app/widgets/shad_badge.dart';
import 'package:wooden_mill_app/widgets/shad_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackupRepository _backupRepository = BackupRepository();
  DateTime? _lastBackupTime;

  @override
  void initState() {
    super.initState();
    _loadBackupStatus();
  }

  Future<void> _loadBackupStatus() async {
    final time = await _backupRepository.getLastBackupTime();
    setState(() {
      _lastBackupTime = time;
    });
  }

  void _handleCreateBackup() async {
    final file = await _backupRepository.createBackup();
    await _loadBackupStatus();

    if (!mounted) return;
    if (file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup created successfully:\n${file.path.split('/').last}'),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to create backup'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleRestoreBackup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusLg),
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        title: const Text('Restore Database Backup?'),
        content: const Text(
          'Restoring from a backup will replace your current local order records with the backup file data. Do you wish to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final file = await _backupRepository.createBackup();
    if (file != null) {
      final ok = await _backupRepository.restoreBackupFromFile(file);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database restored successfully!'),
            backgroundColor: Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleExportFromSettings() async {
    final repo = OrderRepository();
    final orders = await repo.getAllOrders();
    if (!mounted) return;
    ExportHelper.showExportOptionsModal(context, orders);
  }

  void _handleResetSettings() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusLg),
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        title: const Text('Reset Settings to Defaults?'),
        content: const Text(
          'This will reset your Theme Mode to System Default, Color Theme to Timber, and Display Size to Recommended. Your saved orders and history will NOT be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Reset Settings'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await themeController.resetSettings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings restored to defaults'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_outlined),
            tooltip: 'Reset Settings',
            onPressed: _handleResetSettings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: themeController,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(ShadTokens.spaceLg),
            children: [
              // Appearance Section
              ShadCard(
                title: 'Appearance',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(value: ThemeMode.system, label: Text('System')),
                        ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                        ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                      ],
                      selected: {themeController.themeMode},
                      onSelectionChanged: (set) {
                        if (set.isNotEmpty) {
                          themeController.setThemeMode(set.first);
                        }
                      },
                    ),
                    const SizedBox(height: ShadTokens.spaceLg),

                    // Color Theme Section with Palette Previews (● ● ●)
                    const Text('Color Theme', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.8,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: AppColorTheme.values.length,
                      itemBuilder: (context, index) {
                        final colorOption = AppColorTheme.values[index];
                        final isSelected = themeController.colorTheme == colorOption;
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        final previewColors = colorOption.getPreviewColors(isDark);

                        return InkWell(
                          onTap: () => themeController.setColorTheme(colorOption),
                          borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25)
                                  : theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
                              border: Border.all(
                                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Row(
                                  children: previewColors.map((c) {
                                    return Container(
                                      width: 10,
                                      height: 10,
                                      margin: const EdgeInsets.only(right: 3),
                                      decoration: BoxDecoration(
                                        color: c,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    colorOption.displayName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: ShadTokens.spaceLg),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Display Size & Density', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        if (themeController.displayDensity != AppDisplayDensity.recommended)
                          TextButton(
                            onPressed: () => themeController.setDisplayDensity(AppDisplayDensity.recommended),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            child: const Text('Reset to Recommended', style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<AppDisplayDensity>(
                      initialValue: themeController.displayDensity,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: AppDisplayDensity.values.map((density) {
                        return DropdownMenuItem(
                          value: density,
                          child: Text(density.label),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          themeController.setDisplayDensity(val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ShadTokens.spaceLg),

              // Wood Rates Section
              ShadCard(
                title: 'Wood Species Unit Rates',
                child: Column(
                  children: AppConstants.woodTypes.map((wood) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(wood.displayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ShadBadge(
                            label: '₹${wood.ratePerCft.toStringAsFixed(0)} / cft',
                            variant: ShadBadgeVariant.secondary,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: ShadTokens.spaceLg),

              // Data & Backup Section
              ShadCard(
                title: 'Data & Backup',
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Last Backup Timestamp', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            Text('Encrypted JSON backup file', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        Text(
                          _lastBackupTime != null
                              ? DateFormat('dd MMM, hh:mm a').format(_lastBackupTime!)
                              : 'Never',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ShadTokens.spaceMd),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleCreateBackup,
                            icon: const Icon(Icons.upload_file_outlined, size: 16),
                            label: const Text('Create Backup'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleRestoreBackup,
                            icon: const Icon(Icons.download_for_offline_outlined, size: 16),
                            label: const Text('Restore Backup'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ShadTokens.spaceMd),
                    Divider(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _handleExportFromSettings,
                        icon: const Icon(Icons.file_download_outlined, size: 16),
                        label: const Text('Export Order History (CSV / PDF)'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ShadTokens.spaceLg),

              // About Section
              ShadCard(
                title: 'About Application',
                child: Column(
                  children: [
                    _buildInfoRow('Application Name', 'Timbr', theme),
                    _buildInfoRow('Version', AppConstants.appVersionName, theme),
                    _buildInfoRow('Build Number', AppConstants.appBuildNumber, theme),
                  ],
                ),
              ),
              const SizedBox(height: ShadTokens.spaceLg),

              // Reset Action Button Card
              ShadCard(
                child: Center(
                  child: TextButton.icon(
                    onPressed: _handleResetSettings,
                    icon: Icon(Icons.restore, size: 18, color: theme.colorScheme.error),
                    label: Text(
                      'Reset All Settings to Defaults',
                      style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
