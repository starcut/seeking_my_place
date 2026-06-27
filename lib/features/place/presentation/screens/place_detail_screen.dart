import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seeking_my_place/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:seeking_my_place/features/place/application/state/selected_place_state.dart';
import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/usecases/delete_place_use_case.dart';
import 'package:seeking_my_place/features/place/domain/usecases/get_place_detail_use_case.dart';
import 'package:seeking_my_place/shared/widgets/app_bar_default.dart';

class PlaceDetailScreen extends ConsumerWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final placeAsync = ref.watch(getPlaceDetailUseCaseProvider(placeId));

    return Scaffold(
      appBar: AppBarDefault(
        title: l10n.placeDetailTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.edit,
            onPressed: () => context.go('/place/$placeId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: l10n.delete,
            onPressed: () => _confirmDelete(context, ref, l10n),
          ),
        ],
      ),
      body: placeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: l10n.fetchError(error),
          onRetry: () => ref.invalidate(getPlaceDetailUseCaseProvider(placeId)),
        ),
        data: (place) => _PlaceDetailBody(place: place),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(deletePlaceUseCaseProvider.notifier).execute(placeId);

    final deleteState = ref.read(deletePlaceUseCaseProvider);
    if (deleteState.hasError) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deleteError(deleteState.error!))),
        );
      }
      return;
    }

    // 5.2.6: 削除対象が選択中だった場合は選択を解除する
    if (ref.read(selectedPlaceStateProvider) == placeId) {
      ref.read(selectedPlaceStateProvider.notifier).select(null);
    }

    if (context.mounted) {
      context.go('/');
    }
  }
}

// -----------------------------------------------------------------------------
// Body
// -----------------------------------------------------------------------------

class _PlaceDetailBody extends StatelessWidget {
  const _PlaceDetailBody({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat('yyyy/MM/dd HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailSection(
            label: l10n.placeDetailTitle,
            child: Text(
              place.placeName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          _DetailSection(
            label: place.address,
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    place.address,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DetailSection(
            label: l10n.registeredAt,
            child: Text(
              dateFormatter.format(place.createdAt.toLocal()),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          _MemoSection(place: place),
          const SizedBox(height: 16),
          if (place.url.isNotEmpty) _UrlSection(place: place),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Sub-widgets
// -----------------------------------------------------------------------------

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        child,
        const Divider(),
      ],
    );
  }
}

class _MemoSection extends StatelessWidget {
  const _MemoSection({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasMemo = place.category.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'メモ',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hasMemo ? place.category : l10n.memoPlaceholder,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: hasMemo ? null : Colors.grey,
            fontStyle: hasMemo ? FontStyle.normal : FontStyle.italic,
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _UrlSection extends ConsumerWidget {
  const _UrlSection({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        const Icon(Icons.link, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            place.url,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 20),
          tooltip: l10n.copyUrlTooltip,
          onPressed: () => _copyUrl(context, l10n),
        ),
      ],
    );
  }

  Future<void> _copyUrl(BuildContext context, AppLocalizations l10n) async {
    await Clipboard.setData(ClipboardData(text: place.url));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.urlCopied)));
    }
  }
}

// -----------------------------------------------------------------------------
// Error view
// -----------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
