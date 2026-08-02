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
import 'package:wooden_mill_app/core/controllers/wood_type_controller.dart';
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

                    // Color Theme Section with Compact Palette Previews (●●●)
                    const Text('Color Theme', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AppColorTheme.values.map((colorOption) {
                          final isSelected = themeController.colorTheme == colorOption;
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          final previewColors = colorOption.getPreviewColors(isDark);

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () => themeController.setColorTheme(colorOption),
                              borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: previewColors.map((c) {
                                        return Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(right: 2),
                                          decoration: BoxDecoration(
                                            color: c,
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      colorOption.displayName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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

              // Wood Rates & Species Management Section
              ListenableBuilder(
                listenable: WoodTypeController.instance,
                builder: (context, child) {
                  final woodTypes = WoodTypeController.instance.woodTypes;

                  return ShadCard(
                    title: 'Wood Pricing & Species Configuration',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configure unit rates (₹/cft) and manage available timber species across the application.',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: ShadTokens.spaceMd),

                        // Wood Species List
                        ...woodTypes.map((wood) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
                              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                              color: theme.colorScheme.surface,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        wood.displayName,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                      Text(
                                        wood.isDefault ? 'Standard System Species' : 'Custom Species',
                                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                ShadBadge(
                                  label: '₹${wood.ratePerCft.toStringAsFixed(0)} / cft',
                                  variant: ShadBadgeVariant.secondary,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  tooltip: 'Edit Rate / Details',
                                  onPressed: () => _handleEditRateWithConfirm(context, wood),
                                ),
                                if (!wood.isDefault)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                    tooltip: 'Delete Species',
                                    onPressed: () => _handleDeleteWoodTypeWithConfirm(context, wood),
                                  ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: ShadTokens.spaceMd),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _handleAddWoodTypeWithConfirm(context),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Wood Species'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _handleResetDefaultsWithConfirm(context),
                              icon: const Icon(Icons.restart_alt, size: 16),
                              label: const Text('Reset Rates to Defaults'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
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

  /// Pre-Action Confirmation Dialog
  Future<bool> _showConfirmBeforeDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Proceed',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusLg),
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        title: Row(
          children: [
            const Icon(Icons.help_outline_rounded, color: Colors.orangeAccent, size: 22),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Post-Action Confirmation & Summary Dialog
  Future<void> _showSuccessAfterDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusLg),
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFF059669), size: 22),
            SizedBox(width: 8),
            Text('Action Complete'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(message, style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// 1. Edit Wood Rate with Pre & Post Confirmation
  void _handleEditRateWithConfirm(BuildContext context, WoodTypeConfig wood) async {
    final confirmBefore = await _showConfirmBeforeDialog(
      context: context,
      title: 'Edit Rate for ${wood.name}?',
      message: 'You are about to modify the rate per CFT for ${wood.name}. This will update volume calculation prices for all new orders.',
      confirmLabel: 'Proceed to Edit',
    );

    if (!confirmBefore) return;
    if (!context.mounted) return;

    final rateController = TextEditingController(text: wood.ratePerCft.toStringAsFixed(0));
    final nameController = TextEditingController(text: wood.name);
    final malayalamController = TextEditingController(text: wood.malayalamName);
    final formKey = GlobalKey<FormState>();

    final double? newRate = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShadTokens.radiusLg),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          title: Text('Edit ${wood.name} Details'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  enabled: !wood.isDefault,
                  decoration: const InputDecoration(labelText: 'Species Name'),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: malayalamController,
                  enabled: !wood.isDefault,
                  decoration: const InputDecoration(labelText: 'Malayalam Name'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: rateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Rate per CFT (₹)',
                  ),
                  validator: (val) {
                    final num = double.tryParse(val ?? '');
                    if (num == null || num <= 0) return 'Enter a valid rate > 0';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() == true) {
                  final parsedRate = double.parse(rateController.text.trim());
                  Navigator.of(context).pop(parsedRate);
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );

    if (newRate == null) return;

    final updated = wood.copyWith(
      name: nameController.text.trim(),
      malayalamName: malayalamController.text.trim(),
      ratePerCft: newRate,
    );

    await WoodTypeController.instance.updateWoodType(updated);

    if (context.mounted) {
      await _showSuccessAfterDialog(
        context: context,
        title: 'Wood Rate Updated',
        message: 'The rate for ${updated.name} has been successfully updated to ₹${newRate.toStringAsFixed(0)} / cft.',
      );
    }
  }

  /// 2. Add Wood Species with Pre & Post Confirmation
  void _handleAddWoodTypeWithConfirm(BuildContext context) async {
    final confirmBefore = await _showConfirmBeforeDialog(
      context: context,
      title: 'Add New Wood Species?',
      message: 'You are about to add a new timber species option. It will immediately become available in the calculator dropdown and order history filters.',
      confirmLabel: 'Proceed to Add',
    );

    if (!confirmBefore) return;
    if (!context.mounted) return;

    final nameController = TextEditingController();
    final malayalamController = TextEditingController();
    final rateController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final isSaved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShadTokens.radiusLg),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          title: const Text('Add New Wood Species'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Wood Name (English)',
                    hintText: 'e.g. Rosewood, Mahogany',
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: malayalamController,
                  decoration: const InputDecoration(
                    labelText: 'Malayalam Name (Optional)',
                    hintText: 'e.g. ഈട്ടി, മഹാഗണി',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: rateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Rate per CFT (₹)',
                    hintText: 'e.g. 5500',
                  ),
                  validator: (val) {
                    final num = double.tryParse(val ?? '');
                    if (num == null || num <= 0) return 'Enter a valid rate > 0';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() == true) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Add Species'),
            ),
          ],
        );
      },
    );

    if (isSaved != true) return;

    final name = nameController.text.trim();
    final rate = double.parse(rateController.text.trim());
    final malayalam = malayalamController.text.trim();

    await WoodTypeController.instance.addWoodType(
      name: name,
      malayalamName: malayalam,
      ratePerCft: rate,
    );

    if (context.mounted) {
      await _showSuccessAfterDialog(
        context: context,
        title: 'New Wood Species Added',
        message: 'Successfully added "$name" with a unit rate of ₹${rate.toStringAsFixed(0)} / cft.',
      );
    }
  }

  /// 3. Delete Wood Species with Pre & Post Confirmation
  void _handleDeleteWoodTypeWithConfirm(BuildContext context, WoodTypeConfig wood) async {
    final confirmBefore = await _showConfirmBeforeDialog(
      context: context,
      title: 'Delete ${wood.name}?',
      message: 'Are you sure you want to remove ${wood.name} from available timber species? Existing order records will remain intact.',
      confirmLabel: 'Confirm Delete',
    );

    if (!confirmBefore) return;

    await WoodTypeController.instance.deleteWoodType(wood.id);

    if (context.mounted) {
      await _showSuccessAfterDialog(
        context: context,
        title: 'Species Removed',
        message: '${wood.name} has been successfully removed from available wood options.',
      );
    }
  }

  /// 4. Reset Defaults with Pre & Post Confirmation
  void _handleResetDefaultsWithConfirm(BuildContext context) async {
    final confirmBefore = await _showConfirmBeforeDialog(
      context: context,
      title: 'Reset Wood Rates to Defaults?',
      message: 'This will reset Teak, Coconut, and Others back to system rates (₹4800, ₹4500, ₹4000) and remove custom added species.',
      confirmLabel: 'Reset Defaults',
    );

    if (!confirmBefore) return;

    await WoodTypeController.instance.resetToDefaults();

    if (context.mounted) {
      await _showSuccessAfterDialog(
        context: context,
        title: 'Rates Reset Complete',
        message: 'All wood species and unit rates have been restored to factory defaults.',
      );
    }
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
