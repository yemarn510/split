import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/person.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ant/ant.dart';
import '../widgets/common_widgets.dart';
import '../widgets/item_table.dart';
import '../widgets/rounded_avatar.dart';
import '../widgets/scan_receipt.dart';

/// Port of step-2.tsx.
class StepTwoItems extends StatefulWidget {
  final List<Item> items;
  final List<Person> people;
  final ValueChanged<List<Item>> onItemsChanged;

  const StepTwoItems({
    super.key,
    required this.items,
    required this.people,
    required this.onItemsChanged,
  });

  @override
  State<StepTwoItems> createState() => _StepTwoItemsState();
}

class _StepTwoItemsState extends State<StepTwoItems> {
  final ItemTableController _table = ItemTableController();

  @override
  void dispose() {
    _table.dispose();
    super.dispose();
  }

  void _addItem() {
    final items = widget.items;
    if (items.isNotEmpty &&
        !ItemTable.checkValidOrNot(items.length - 1, items, widget.onItemsChanged)) {
      return;
    }
    items.add(Item());
    widget.onItemsChanged(List.of(items));
    _table.setCurrentIndex(items.length - 1);
  }

  void _openPaidByModal(int paidByIndex) {
    final md = Breakpoints.md(context);
    showAntModal<void>(
      context: context,
      title: 'Set Paid By',
      builder: (modalContext) => SizedBox(
        height: 320,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: CssGrid(
            columns: md ? 4 : 3,
            gap: 16,
            children: [
              for (final person in widget.people)
                RoundedAvatar(
                  person: person,
                  size: AvatarSize.lg,
                  onTap: () {
                    final item = widget.items[paidByIndex];
                    item.paidBy = person;
                    item.error.remove('paidBy');
                    widget.onItemsChanged(List.of(widget.items));
                    Navigator.of(modalContext).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openScanModal() {
    showAntModal<void>(
      context: context,
      title: 'Upload your receipt',
      builder: (modalContext) => ScanReceipt(
        people: widget.people,
        mergeItems: (newItems) {
          final kept = widget.items.where((e) => e.name != '' || e.price != 0);
          widget.onItemsChanged([...kept, ...newItems]);
          _table.reset();
          Navigator.of(modalContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final md = Breakpoints.md(context);
      // `w-9/12` + `w-3/12` with `gap-1`, shrunk to fit like flexbox does.
      final addWidth = md ? width * 11 / 12 - 4 : width * 0.75 - 3;
      final cameraWidth = width - addWidth - 4;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: ItemTable(
                items: widget.items,
                onItemsChanged: widget.onItemsChanged,
                controller: _table,
                onPaidByTap: _openPaidByModal,
              ),
            ),
          ),
          Container(
            color: AppColors.second,
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                SizedBox(
                  width: addWidth,
                  child: AntButton.primary(
                    block: true,
                    icon: AntIconData.plus,
                    label: 'Add Item',
                    onPressed: _addItem,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: cameraWidth,
                  child: AntButton.primary(
                    block: true,
                    icon: AntIconData.camera,
                    iconSize: 18,
                    borderColor: AppColors.main,
                    onPressed: _openScanModal,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
