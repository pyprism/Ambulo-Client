import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/network/dio_client.dart';
import '../../data/repositories/friend_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../auth/auth_controller.dart';
import 'friends_providers.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendships = ref.watch(friendshipsProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final authUser = ref.watch(authControllerProvider).value;
    final myUsername = authUser?.username ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(friendshipsProvider);
          ref.invalidate(friendLocationsProvider);
          ref.invalidate(notificationsProvider);
        },
        child: friendships.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => RefreshableEmptyState(
            icon: Icons.error_outline,
            title: 'Could not load friends',
            message: '$e',
          ),
          data: (items) => _FriendsList(
            items: items,
            myUsername: myUsername,
            shareCode: authUser?.shareCode ?? '',
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFriendDialog(context, ref),
        icon: const Icon(Icons.person_add_alt_outlined),
        label: const Text('Add friend'),
      ),
    );
  }
}

/// Runs a friend/notification action, invalidates [friendshipsProvider] on
/// success, and surfaces any failure as a snackbar instead of letting it
/// fail silently.
Future<void> _runFriendAction(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() action,
) async {
  try {
    await action();
    ref.invalidate(friendshipsProvider);
  } on DioException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(describeDioError(e))));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result == true;
}

Future<void> _showAddFriendDialog(BuildContext context, WidgetRef ref) async {
  await showDialog<void>(
    context: context,
    builder: (context) => const _AddFriendDialog(),
  );
}

class _AddFriendDialog extends ConsumerStatefulWidget {
  const _AddFriendDialog();

  @override
  ConsumerState<_AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends ConsumerState<_AddFriendDialog> {
  final _controller = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      // A share code is a short fixed-format token; anything else is
      // treated as a username. Simpler than asking the user to pick a mode.
      final isShareCode =
          RegExp(r'^[A-Za-z0-9]{6,16}$').hasMatch(value) &&
          !value.contains(' ');
      await ref
          .read(friendRepositoryProvider)
          .sendRequest(
            username: isShareCode ? null : value,
            shareCode: isShareCode ? value : null,
          );
      ref.invalidate(friendshipsProvider);
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      setState(() => _error = describeDioError(e));
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a friend'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Username or share code',
            ),
            onSubmitted: (_) => _sending ? null : _send(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _sending ? null : _send,
          child: _sending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send request'),
        ),
      ],
    );
  }
}

class _FriendsList extends ConsumerWidget {
  const _FriendsList({
    required this.items,
    required this.myUsername,
    required this.shareCode,
  });

  final List<Friendship> items;
  final String myUsername;
  final String shareCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _ShareCodeCard(username: myUsername, shareCode: shareCode),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: const EmptyState(
              icon: Icons.people_outline,
              title: 'No friends yet',
              message:
                  'Send a request by username or share code to get started.',
            ),
          ),
        ],
      );
    }

    final incoming = items
        .where((f) => f.isIncomingRequest(myUsername))
        .toList();
    final outgoing = items
        .where((f) => f.isOutgoingRequest(myUsername))
        .toList();
    final accepted = items
        .where((f) => f.status == FriendshipStatus.accepted)
        .toList();
    final blocked = items
        .where((f) => f.status == FriendshipStatus.blocked)
        .toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _ShareCodeCard(username: myUsername, shareCode: shareCode),
        if (incoming.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader('Requests'),
          Card(
            child: Column(
              children: [
                for (final f in incoming)
                  _IncomingRequestTile(friendship: f, myUsername: myUsername),
              ],
            ),
          ),
        ],
        if (outgoing.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader('Sent requests'),
          Card(
            child: Column(
              children: [
                for (final f in outgoing)
                  _OutgoingRequestTile(friendship: f, myUsername: myUsername),
              ],
            ),
          ),
        ],
        if (accepted.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader('Friends'),
          Card(
            child: Column(
              children: [
                for (final f in accepted)
                  _AcceptedFriendTile(friendship: f, myUsername: myUsername),
              ],
            ),
          ),
        ],
        if (blocked.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader('Blocked'),
          Card(
            child: Column(
              children: [
                for (final f in blocked)
                  _BlockedTile(friendship: f, myUsername: myUsername),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ShareCodeCard extends StatelessWidget {
  const _ShareCodeCard({required this.username, required this.shareCode});

  final String username;
  final String shareCode;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.qr_code_outlined),
        title: Text(
          shareCode.isEmpty
              ? (username.isEmpty ? 'Your share code' : '@$username')
              : shareCode,
        ),
        subtitle: Text(
          username.isEmpty
              ? 'Share this so friends can add you, or add them by username.'
              : '@$username · share this code so friends can add you',
        ),
        trailing: shareCode.isEmpty
            ? null
            : Wrap(
                children: [
                  IconButton(
                    tooltip: 'Copy',
                    icon: const Icon(Icons.copy_outlined),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: shareCode));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share code copied')),
                        );
                      }
                    },
                  ),
                  // Web has no reliable native share sheet (no navigator.share
                  // support outside HTTPS on Chrome/Edge/Safari, and the
                  // mailto: fallback is silent when there's no mail handler),
                  // so Copy above is the only share action offered there.
                  if (!kIsWeb)
                    IconButton(
                      tooltip: 'Share',
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () => SharePlus.instance.share(
                        ShareParams(
                          text:
                              'Add me on Ambulo — my share code is $shareCode',
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _IncomingRequestTile extends ConsumerWidget {
  const _IncomingRequestTile({
    required this.friendship,
    required this.myUsername,
  });

  final Friendship friendship;
  final String myUsername;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.person_outline),
      title: Text(friendship.otherUsername(myUsername)),
      subtitle: const Text('Wants to be your friend'),
      trailing: Wrap(
        spacing: 4,
        children: [
          IconButton(
            tooltip: 'Accept',
            icon: const Icon(Icons.check),
            onPressed: () => _runFriendAction(
              context,
              ref,
              () => ref.read(friendRepositoryProvider).accept(friendship.id),
            ),
          ),
          IconButton(
            tooltip: 'Decline',
            icon: const Icon(Icons.close),
            onPressed: () async {
              final confirmed = await _confirm(
                context,
                title: 'Decline this request?',
                message:
                    '${friendship.otherUsername(myUsername)}\'s friend request will be removed.',
                confirmLabel: 'Decline',
              );
              if (!confirmed || !context.mounted) return;
              await _runFriendAction(
                context,
                ref,
                () => ref.read(friendRepositoryProvider).revoke(friendship.id),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OutgoingRequestTile extends ConsumerWidget {
  const _OutgoingRequestTile({
    required this.friendship,
    required this.myUsername,
  });

  final Friendship friendship;
  final String myUsername;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.hourglass_empty),
      title: Text(friendship.otherUsername(myUsername)),
      subtitle: const Text('Request sent, awaiting response'),
      trailing: TextButton(
        onPressed: () async {
          final confirmed = await _confirm(
            context,
            title: 'Cancel this request?',
            message:
                'Your friend request to ${friendship.otherUsername(myUsername)} will be withdrawn.',
            confirmLabel: 'Cancel request',
          );
          if (!confirmed || !context.mounted) return;
          await _runFriendAction(
            context,
            ref,
            () => ref.read(friendRepositoryProvider).revoke(friendship.id),
          );
        },
        child: const Text('Cancel'),
      ),
    );
  }
}

class _AcceptedFriendTile extends ConsumerWidget {
  const _AcceptedFriendTile({
    required this.friendship,
    required this.myUsername,
  });

  final Friendship friendship;
  final String myUsername;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharing = friendship.mySharing(myUsername);
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(friendship.otherUsername(myUsername)),
      subtitle: Text(
        sharing ? 'Sharing your location' : 'Location sharing off',
      ),
      trailing: Wrap(
        spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Switch(
            value: sharing,
            onChanged: (value) => _runFriendAction(
              context,
              ref,
              () => ref
                  .read(friendRepositoryProvider)
                  .setShare(friendship.id, value),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'block') {
                final confirmed = await _confirm(
                  context,
                  title: 'Block ${friendship.otherUsername(myUsername)}?',
                  message:
                      'They won\'t be able to see your location or send you '
                      'requests until you unblock them.',
                  confirmLabel: 'Block',
                );
                if (!confirmed || !context.mounted) return;
                await _runFriendAction(
                  context,
                  ref,
                  () => ref.read(friendRepositoryProvider).block(friendship.id),
                );
              } else if (value == 'remove') {
                final confirmed = await _confirm(
                  context,
                  title: 'Remove ${friendship.otherUsername(myUsername)}?',
                  message:
                      'This ends the friendship and location sharing both ways.',
                  confirmLabel: 'Remove',
                );
                if (!confirmed || !context.mounted) return;
                await _runFriendAction(
                  context,
                  ref,
                  () =>
                      ref.read(friendRepositoryProvider).revoke(friendship.id),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'block', child: Text('Block')),
              PopupMenuItem(value: 'remove', child: Text('Remove friend')),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlockedTile extends ConsumerWidget {
  const _BlockedTile({required this.friendship, required this.myUsername});

  final Friendship friendship;
  final String myUsername;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iBlocked = friendship.blockedByUsername == myUsername;
    return ListTile(
      leading: const Icon(Icons.block),
      title: Text(friendship.otherUsername(myUsername)),
      subtitle: Text(iBlocked ? 'Blocked by you' : 'Blocked'),
      trailing: iBlocked
          ? TextButton(
              onPressed: () => _runFriendAction(
                context,
                ref,
                () => ref.read(friendRepositoryProvider).revoke(friendship.id),
              ),
              child: const Text('Unblock'),
            )
          : null,
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
