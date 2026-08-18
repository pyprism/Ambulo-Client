import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories/export_repository.dart';
import '../../data/repositories/import_repository.dart';
import '../../data/repositories/server_import_repository.dart';
import '../../platform/fitness/health_connect_adapter.dart';
import '../../platform/platform_support.dart';
import '../auth/auth_controller.dart';
import 'import_export_providers.dart';

class ImportExportScreen extends ConsumerStatefulWidget {
  const ImportExportScreen({super.key});

  @override
  ConsumerState<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends ConsumerState<ImportExportScreen> {
  bool _exporting = false;
  bool _importing = false;

  ServerImportFormat _archiveFormat = ServerImportFormat.googleTakeout;
  ImportJobStatus? _archiveJob;
  bool _archiveBusy = false;

  bool _healthConnectBusy = false;
  bool _healthConnectRepairBusy = false;

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Import & export')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('Export your data'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Generates a file from everything stored on this '
                    'device, entirely offline.',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final format in ExportFormat.values)
                        OutlinedButton.icon(
                          onPressed: _exporting ? null : () => _export(format),
                          icon: const Icon(Icons.download_outlined),
                          label: Text(format.label),
                        ),
                    ],
                  ),
                  if (_exporting) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader('Import a file'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GPX, GeoJSON, Ambulo JSON, or OwnTracks (.rec/JSON) — '
                    'parsed on this device, nothing leaves it. You review a '
                    'preview before anything is added.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _importing ? null : _pickAndPreviewFile,
                    icon: _importing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_open_outlined),
                    label: const Text('Choose file'),
                  ),
                ],
              ),
            ),
          ),
          if (PlatformSupport.supportsHealthConnect) ...[
            const SizedBox(height: 24),
            _SectionHeader('Connect Health Connect'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pulls your step, distance, and calorie history '
                      'directly from Health Connect (Google Fit\'s data '
                      'source) — no file to export, nothing leaves this '
                      'device until you hit Sync.',
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _healthConnectBusy
                          ? null
                          : _connectHealthConnect,
                      icon: _healthConnectBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.favorite_outline),
                      label: const Text('Connect Health Connect'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Already connected? An earlier version of this app '
                      'could double-count steps/distance/calories on days '
                      'covered by more than one source (phone + watch, '
                      'etc.) — this re-derives and corrects those days '
                      'without touching anything else.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _healthConnectRepairBusy
                          ? null
                          : _repairHealthConnectImports,
                      icon: _healthConnectRepairBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.build_outlined),
                      label: const Text('Fix inflated Health Connect data'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (authUser != null) ...[
            const SizedBox(height: 24),
            _SectionHeader('Import a large archive'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Google Takeout or TCX archives are too large to '
                      'parse on-device — this uploads the file to your '
                      'server, which parses it in the background.',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ServerImportFormat>(
                      initialValue: _archiveFormat,
                      decoration: const InputDecoration(labelText: 'Format'),
                      items: [
                        for (final format in ServerImportFormat.values)
                          DropdownMenuItem(
                            value: format,
                            child: Text(format.label),
                          ),
                      ],
                      onChanged: _archiveBusy
                          ? null
                          : (value) => setState(() => _archiveFormat = value!),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _archiveBusy ? null : _pickAndUploadArchive,
                      icon: _archiveBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file_outlined),
                      label: const Text('Choose archive'),
                    ),
                    if (_archiveJob != null) ...[
                      const SizedBox(height: 16),
                      _ArchiveJobTile(
                        job: _archiveJob!,
                        busy: _archiveBusy,
                        onCommit: _commitArchive,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _export(ExportFormat format) async {
    setState(() => _exporting = true);
    try {
      final content = await ref.read(exportRepositoryProvider).build(format);
      final bytes = Uint8List.fromList(utf8.encode(content));
      final file = XFile.fromData(
        bytes,
        name: 'ambulo_export.${format.fileExtension}',
        mimeType: format.mimeType,
      );
      await SharePlus.instance.share(
        ShareParams(files: [file], text: 'Ambulo ${format.label} export'),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _pickAndPreviewFile() async {
    setState(() => _importing = true);
    ImportPreview preview;
    try {
      // pickFile() forces withData:false, which on web relies on a lazy
      // blob-fetch that's broken in file_picker 12.0.0-beta.7 (throws
      // "file data is not available"). pickFiles(allowMultiple: false)
      // still eagerly loads bytes on web and works.
      // ignore: deprecated_member_use
      final result = await FilePicker.pickFiles(allowMultiple: false);
      final file = result?.files.isNotEmpty == true
          ? result!.files.first
          : null;
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final content = utf8.decode(bytes, allowMalformed: true);
      preview = await ref
          .read(importRepositoryProvider)
          .parseAndPreview(file.name, content);
    } on UnrecognizedImportFormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
      return;
    } catch (e) {
      // Safety net: any unforeseen parse/read failure still degrades to a
      // snackbar instead of an unhandled exception with the spinner stuck.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not import this file: $e')),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _importing = false);
    }

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ImportPreviewDialog(preview: preview),
    );
    if (confirmed != true) return;

    await ref.read(importRepositoryProvider).commit(preview);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Imported ${preview.newPoints.length + preview.additionalRecordCount} records',
        ),
      ),
    );
  }

  Future<void> _pickAndUploadArchive() async {
    setState(() {
      _archiveBusy = true;
      _archiveJob = null;
    });
    try {
      // Same file_picker 12.0.0-beta.7 web bug as _pickAndPreviewFile above:
      // pickFile()'s withData:false lazy-load path is broken on web.
      // ignore: deprecated_member_use
      final result = await FilePicker.pickFiles(allowMultiple: false);
      final file = result?.files.isNotEmpty == true
          ? result!.files.first
          : null;
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final job = await ref
          .read(serverImportRepositoryProvider)
          .upload(format: _archiveFormat, bytes: bytes, filename: file.name);
      await _pollArchiveJob(job.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _archiveBusy = false);
    }
  }

  Future<void> _connectHealthConnect() async {
    setState(() => _healthConnectBusy = true);
    try {
      final summary = await ref
          .read(healthConnectRepositoryProvider)
          .connectAndImportAll();
      if (!mounted) return;
      if (summary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health Connect permission not granted.'),
          ),
        );
        return;
      }
      final total = summary.totalImported;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            total == 0
                ? 'No new Health Connect data to import.'
                : 'Imported $total days of Health Connect data. '
                      'Hit Sync now to upload it.',
          ),
        ),
      );
    } on HealthConnectUnavailableException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          action: e.needsInstall
              ? SnackBarAction(
                  label: 'Install',
                  onPressed: () => ref
                      .read(healthConnectRepositoryProvider)
                      .promptInstallHealthConnect(),
                )
              : null,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Health Connect import failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _healthConnectBusy = false);
    }
  }

  Future<void> _repairHealthConnectImports() async {
    setState(() => _healthConnectRepairBusy = true);
    try {
      final summary = await ref
          .read(healthConnectRepositoryProvider)
          .repairInflatedImports();
      if (!mounted) return;
      if (summary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health Connect permission not granted.'),
          ),
        );
        return;
      }
      final corrected = summary.totalImported;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            corrected == 0
                ? 'No inflated Health Connect data found.'
                : 'Corrected $corrected day(s) of Health Connect data. '
                      'Hit Sync now to upload the fix.',
          ),
        ),
      );
    } on HealthConnectUnavailableException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Health Connect repair failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _healthConnectRepairBusy = false);
    }
  }

  Future<void> _pollArchiveJob(String jobId) async {
    final repo = ref.read(serverImportRepositoryProvider);
    for (var attempt = 0; attempt < 60; attempt++) {
      final job = await repo.status(jobId);
      if (!mounted) return;
      setState(() => _archiveJob = job);
      if (job.isPreviewReady || job.isDone || job.isFailed) return;
      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }

  Future<void> _commitArchive() async {
    final job = _archiveJob;
    if (job == null) return;
    setState(() => _archiveBusy = true);
    try {
      await ref.read(serverImportRepositoryProvider).commit(job.id);
      await _pollArchiveJob(job.id);
    } finally {
      if (mounted) setState(() => _archiveBusy = false);
    }
  }
}

class _ImportPreviewDialog extends StatelessWidget {
  const _ImportPreviewDialog({required this.preview});

  final ImportPreview preview;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${preview.formatLabel} import'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${preview.newPoints.length} new points to add'),
          if (preview.additionalRecordCount > 0)
            Text(
              '${preview.additionalRecordCount} additional backup records to add',
            ),
          if (preview.duplicateCount > 0)
            Text('${preview.duplicateCount} already in your history (skipped)'),
          if (preview.skippedCount > 0)
            Text('${preview.skippedCount} entries could not be parsed'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: !preview.hasRecords
              ? null
              : () => Navigator.of(context).pop(true),
          child: const Text('Import'),
        ),
      ],
    );
  }
}

class _ArchiveJobTile extends StatelessWidget {
  const _ArchiveJobTile({
    required this.job,
    required this.busy,
    required this.onCommit,
  });

  final ImportJobStatus job;
  final bool busy;
  final VoidCallback onCommit;

  @override
  Widget build(BuildContext context) {
    if (job.isFailed) {
      return Text(
        'Import failed: ${job.errorMessage}',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }
    if (job.isDone) {
      return const Text('Import complete.');
    }
    if (job.isPreviewReady) {
      final summary = job.summary;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preview ready: $summary'),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: busy ? null : onCommit,
            child: const Text('Commit import'),
          ),
        ],
      );
    }
    return const Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text('Processing on the server…'),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
