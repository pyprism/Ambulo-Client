import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/server/server_config_controller.dart';

class ServerSetupScreen extends ConsumerStatefulWidget {
  const ServerSetupScreen({super.key});

  @override
  ConsumerState<ServerSetupScreen> createState() => _ServerSetupScreenState();
}

enum _TestState { idle, testing, ok, failed }

class _ServerSetupScreenState extends ConsumerState<ServerSetupScreen> {
  final _controller = TextEditingController();
  _TestState _testState = _TestState.idle;
  String? _testMessage;

  @override
  void initState() {
    super.initState();
    final current = ref.read(serverConfigProvider).value;
    if (current != null) _controller.text = current;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _test() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _testState = _TestState.testing;
      _testMessage = null;
    });
    final error = await ref
        .read(serverConfigProvider.notifier)
        .testConnection(_controller.text.trim());
    if (!mounted) return;
    setState(() {
      _testState = error == null ? _TestState.ok : _TestState.failed;
      _testMessage = error;
    });
  }

  Future<void> _save() async {
    if (_controller.text.trim().isEmpty) return;
    await ref
        .read(serverConfigProvider.notifier)
        .setServerAddress(_controller.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Server address saved')));
    Navigator.of(context).maybePop();
  }

  Future<void> _remove() async {
    await ref.read(serverConfigProvider.notifier).clear();
    if (!mounted) return;
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Server removed — local-only mode')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasServer = ref.watch(serverConfigProvider).value != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Server')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your self-hosted Ambulo server address. Leave this '
                'unset to use the app in local-only mode.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Server address',
                  hintText: 'https://ambulo.example.com',
                ),
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() => _testState = _TestState.idle),
              ),
              if (_controller.text.trim().startsWith('http://')) ...[
                const SizedBox(height: 8),
                _StatusLine(
                  icon: Icons.lock_open_outlined,
                  color: Theme.of(context).colorScheme.error,
                  text:
                      'Plain HTTP is not encrypted — anyone on the network '
                      'can read your data in transit. Use HTTPS unless '
                      'you trust this network (e.g. your own LAN).',
                ),
              ],
              const SizedBox(height: 8),
              if (_testState == _TestState.ok)
                _StatusLine(
                  icon: Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  text: 'Connected successfully',
                )
              else if (_testState == _TestState.failed)
                _StatusLine(
                  icon: Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  text: _testMessage ?? 'Could not connect',
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _testState == _TestState.testing
                          ? null
                          : _test,
                      child: _testState == _TestState.testing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Test connection'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
              if (hasServer) ...[
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _remove,
                  icon: Icon(
                    Icons.link_off,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  label: Text(
                    'Remove server (switch to local-only)',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: color)),
        ),
      ],
    );
  }
}
