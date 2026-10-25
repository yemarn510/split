import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/item.dart';
import '../models/result.dart';
import '../services/history_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'ant/ant.dart';
import 'common_widgets.dart';
import 'item_results.dart';
import 'login_popup.dart';

/// Port of next-button.tsx: "Go Next", or "Share" on the last step.
class NextButton extends StatefulWidget {
  final int currentStep;
  final int stepsLength;
  final List<Result> results;
  final bool goNextDisabled;
  final VoidCallback goNext;
  final LoginState login;
  final ValueChanged<String> onHistorySaved;

  const NextButton({
    super.key,
    required this.currentStep,
    required this.stepsLength,
    required this.results,
    required this.goNextDisabled,
    required this.goNext,
    required this.login,
    required this.onHistorySaved,
  });

  @override
  State<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton> {
  final ValueNotifier<bool> _isSharing = ValueNotifier(false);
  late final HistoryService _history = HistoryService(Supabase.instance.client);

  List<Result> get _results => widget.results.where((r) => r.total > 0).toList();

  @override
  void dispose() {
    _isSharing.dispose();
    super.dispose();
  }

  Future<void> _shareHistory(String memo) async {
    if (_isSharing.value) return;
    _isSharing.value = true;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        AntMessage.error(context, 'Please login with Google before sharing history.');
        return;
      }
      final historyId = await _history.saveHistory(user: user, results: _results, memo: memo);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      widget.onHistorySaved(historyId);
      AntMessage.success(context, 'History saved. Shareable link created.');
    } catch (e) {
      if (!mounted) return;
      final message = e is PostgrestException ? e.message : e.toString();
      AntMessage.error(context, message.isNotEmpty ? message : 'Failed to share history.');
    } finally {
      _isSharing.value = false;
    }
  }

  void _openMemoDialog() {
    if (widget.login.user == null) return;
    final controller = TextEditingController();
    BuildContext? memoContext;

    void confirm() => _shareHistory(controller.text.trim());

    showAntModal<void>(
      context: context,
      title: 'Add a memo',
      width: 360,
      onCancel: () {
        if (_isSharing.value || memoContext == null) return;
        Navigator.of(memoContext!).pop();
      },
      builder: (modalContext) {
        memoContext = modalContext;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AntInput(
              controller: controller,
              placeholder: 'Optional memo (e.g., Dinner at NN)',
              maxLength: 120,
              onSubmitted: (_) => confirm(),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isSharing,
              builder: (_, sharing, __) => AntModalFooter(
                children: [
                  AntButton(
                    label: 'Cancel',
                    onPressed: () {
                      if (_isSharing.value) return;
                      Navigator.of(modalContext).pop();
                    },
                  ),
                  AntButton.primary(label: 'Save', loading: sharing, onPressed: confirm),
                ],
              ),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _openSharePopup() {
    final results = _results;
    showAntModal<void>(
      context: context,
      title: 'Share with your friends',
      width: 400,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: AppColors.shareBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final result in results)
                    HasToPayGroup(
                      name: result.person.name,
                      items: result.items,
                      totals: result.totalToPayFor ?? const {},
                      headingLineHeight: 37.714283,
                    ),
                ],
              ),
            ),
          ),
          ListenableBuilder(
            listenable: Listenable.merge([widget.login, _isSharing]),
            builder: (_, __) => widget.login.user == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: AntButton.primary(
                        horizontalPadding: 32,
                        icon: AntIconData.history,
                        label: 'Save History',
                        loading: _isSharing.value,
                        onPressed: _openMemoDialog,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentStep == 3) {
      return CircleNavButton(
        icon: AntIconData.exportIcon,
        label: 'Share',
        onTap: _openSharePopup,
      );
    }
    return CircleNavButton(
      icon: AntIconData.arrowRight,
      label: 'Go Next',
      dimmed: widget.currentStep == widget.stepsLength - 1 || widget.goNextDisabled,
      onTap: widget.goNext,
    );
  }
}

/// One "X has to pay" block of the share modal and the history page.
class HasToPayGroup extends StatelessWidget {
  final String name;
  final List<Item> items;
  final Map<String, double> totals;
  final double headingLineHeight;

  const HasToPayGroup({
    super.key,
    required this.name,
    required this.items,
    required this.totals,
    required this.headingLineHeight,
  });

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style;
    final bold = base.copyWith(fontWeight: FontWeight.w700);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: name,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.main),
                ),
                const WidgetSpan(child: SizedBox(width: 4)),
                const TextSpan(text: 'has to pay'),
              ]),
              textAlign: TextAlign.center,
              style: cssText(size: 24, lineHeight: headingLineHeight, color: base.color),
            ),
          ),
          ItemResults(items: items),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: DashedLine(color: AppColors.gray400),
          ),
          for (final entry in totals.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text('${entry.key} total', style: bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(toFixed2(entry.value), style: bold),
                  ),
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 1,
            color: AppColors.gray900,
          ),
        ],
      ),
    );
  }
}
