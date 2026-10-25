import 'package:flutter/material.dart';

import '../models/item.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'ant/ant.dart';
import 'rounded_avatar.dart';

/// The `currentIndex` / `originalItem` state that item-table.tsx receives from
/// its parent (step-2.tsx or scan-receipt.tsx).
class ItemTableController extends ChangeNotifier {
  int? currentIndex;
  Item? originalItem;

  /// Bumped whenever the web table re-mounts its rows (`rendering` flag,
  /// cancel edit), so inputs re-read their default values.
  int version = 0;

  void setCurrentIndex(int? index) {
    currentIndex = index;
    notifyListeners();
  }

  void reset() {
    currentIndex = null;
    originalItem = null;
    notifyListeners();
  }

  void remount() {
    version++;
    notifyListeners();
  }
}

/// Port of item-table.tsx.
class ItemTable extends StatefulWidget {
  final List<Item> items;
  final ValueChanged<List<Item>> onItemsChanged;
  final ItemTableController controller;
  final ValueChanged<int> onPaidByTap;
  final bool showTotal;

  const ItemTable({
    super.key,
    required this.items,
    required this.onItemsChanged,
    required this.controller,
    required this.onPaidByTap,
    this.showTotal = false,
  });

  /// `checkValidOrNot` in common/service.ts.
  static bool checkValidOrNot(
    int index,
    List<Item> items,
    ValueChanged<List<Item>> setItems,
  ) {
    final isValid = items[index].isValid();
    setItems(List.of(items));
    return isValid;
  }

  @override
  State<ItemTable> createState() => _ItemTableState();
}

class _ItemTableState extends State<ItemTable> {
  int? _priceTypeOpenIndex;

  ItemTableController get _ctrl => widget.controller;
  List<Item> get _items => widget.items;

  @override
  void initState() {
    super.initState();
    if (_items.length == 1) _ctrl.currentIndex = 0;
    _ctrl.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant ItemTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
    if (oldWidget.items.length != widget.items.length) {
      _ctrl.version++;
      _priceTypeOpenIndex = null;
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _setItems(List<Item> items) => widget.onItemsChanged(items);

  bool _checkValid(int index) => ItemTable.checkValidOrNot(index, _items, _setItems);

  void _saveEdit() {
    if (!_checkValid(_ctrl.currentIndex!)) return;
    _setItems(List.of(_items));
    _ctrl.originalItem = null;
    _ctrl.setCurrentIndex(null);
  }

  void _cancelEdit(int index) {
    final editing = _items[index];
    if (editing.name == '' && editing.price == 0) {
      _deleteItem(index);
      return;
    }
    _items[index] = _ctrl.originalItem ?? Item();
    _setItems(_items.map((e) => e.clone()).toList());
    _ctrl.originalItem = null;
    _ctrl.currentIndex = null;
    _ctrl.remount();
  }

  void _editItem(int index) {
    // `if (params.currentIndex && ...)`: index 0 is falsy on the web.
    final current = _ctrl.currentIndex;
    if (current != null && current != 0 && !_checkValid(current)) return;
    _ctrl.originalItem = _items[index].clone();
    _ctrl.setCurrentIndex(index);
  }

  void _deleteItem(int index) {
    _items.removeAt(index);
    _setItems(List.of(_items));
    if (_ctrl.currentIndex == index) _ctrl.setCurrentIndex(null);
  }

  void _setIsPercentage(int index, bool isPercentage) {
    final item = _items[index];
    if (item.isPercentage == isPercentage) return;
    item.isPercentage = isPercentage;
    item.percent = isPercentage ? item.price : 0;
    _priceTypeOpenIndex = null;
    _setItems(List.of(_items));
    _ctrl.remount();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cols = _Columns(constraints.maxWidth);
      final base = DefaultTextStyle.of(context).style;
      final sm = Breakpoints.sm(context);
      final headerStyle = base.copyWith(fontWeight: FontWeight.w700, color: AppColors.main);
      final headerPadding =
          sm ? const EdgeInsets.all(12) : const EdgeInsets.fromLTRB(4, 4, 4, 12);

      Widget th(String text, double width) => SizedBox(
            width: width,
            child: Padding(
              padding: headerPadding,
              child: Text(text, textAlign: TextAlign.center, style: headerStyle),
            ),
          );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              th('No.', cols.no),
              th('Paid By', cols.paidBy),
              th('Name', cols.name),
              th('Qty', cols.qty),
              th('Price', cols.price),
              SizedBox(width: cols.actions),
            ],
          ),
          for (var i = 0; i < _items.length; i++)
            KeyedSubtree(
              key: ValueKey('${_items[i].uuid}-${_ctrl.version}'),
              child: _buildRow(context, i, cols),
            ),
          if (widget.showTotal) _buildTotal(cols),
        ],
      );
    });
  }

  Widget _buildRow(BuildContext context, int index, _Columns cols) {
    final item = _items[index];
    final editing = _ctrl.currentIndex == index;
    final md = Breakpoints.md(context);
    final inputCellPadding = EdgeInsets.symmetric(horizontal: md ? 12 : 4, vertical: 8);

    Widget td(double width, Widget child, {EdgeInsets padding = const EdgeInsets.all(8)}) =>
        SizedBox(width: width, child: Padding(padding: padding, child: child));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        td(cols.no, Text('${index + 1}', textAlign: TextAlign.center)),
        td(
          cols.paidBy,
          AntErrorTooltip(
            message: item.error['paidBy'],
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.onPaidByTap(index),
              child: Center(
                child: item.paidBy != null
                    ? RoundedAvatar(person: item.paidBy!)
                    : const UnknownPerson(),
              ),
            ),
          ),
        ),
        td(
          cols.name,
          AntErrorTooltip(
            message: item.error['name'],
            child: AntInput(
              initialValue: item.name,
              enabled: editing,
              placeholder: 'KFC, McDonalds, etc.',
              onChanged: (value) {
                item.name = value;
                item.error.remove('name');
                _setItems(_items);
              },
            ),
          ),
          padding: inputCellPadding,
        ),
        td(
          cols.qty,
          AntErrorTooltip(
            message: item.error['quantity'],
            child: Row(
              children: [
                if (item.quantity > 1 && !editing)
                  SplitItemButton(
                    item: item,
                    items: _items,
                    index: index,
                    setItems: _setItems,
                  ),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 30,
                      child: AntInput(
                        initialValue: jsNum(item.quantity),
                        enabled: editing,
                        placeholder: '1',
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) {
                          item.quantity = parseJsNumber(value);
                          item.error.remove('quantity');
                          _setItems(_items);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          padding: inputCellPadding,
        ),
        td(
          cols.price,
          AntErrorTooltip(
            message: item.error['price'],
            child: AntInput(
              initialValue: jsNum(item.percent != 0 ? item.percent : item.price),
              enabled: editing,
              placeholder: '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                item.price = parseJsNumber(value);
                item.percent = item.isPercentage ? item.price : 0;
                item.error.remove('price');
                _setItems(_items);
              },
              suffix: _priceTypeSuffix(index, item, editing),
            ),
          ),
          padding: inputCellPadding,
        ),
        td(cols.actions, _actions(index, editing, md)),
      ],
    );
  }

  Widget _priceTypeSuffix(int index, Item item, bool editing) {
    return AntPopover(
      open: _priceTypeOpenIndex == index,
      title: 'Price / Percentage',
      onTapOutside: () => setState(() => _priceTypeOpenIndex = null),
      contentBuilder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change this to Price or Percentage',
              style: cssText(size: 16, lineHeight: 25.142857, color: AppColors.text),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in const [false, true]) ...[
                  AntRadio(
                    checked: item.isPercentage == option,
                    label: option ? 'Percentage %' : 'Money \$',
                    onTap: () {
                      if (_ctrl.currentIndex != index) return;
                      _setIsPercentage(index, option);
                    },
                  ),
                  if (!option) const SizedBox(width: 8),
                ],
              ],
            ),
          ],
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(
          () => _priceTypeOpenIndex = _priceTypeOpenIndex == index ? null : index,
        ),
        child: AntIcon(
          item.isPercentage ? AntIconData.percentage : AntIconData.dollar,
          size: 14,
          color: editing ? AppColors.text : AppColors.textDisabled,
        ),
      ),
    );
  }

  Widget _actions(int index, bool editing, bool md) {
    final gap = SizedBox(width: md ? 12 : 4);
    Widget icon(AntIconData data, Color color, VoidCallback? onTap) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AntIcon(data, size: 20, color: color),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: editing
            ? [
                icon(AntIconData.check, AppColors.main, _saveEdit),
                gap,
                icon(AntIconData.close, AppColors.danger, () => _cancelEdit(index)),
              ]
            : [
                icon(AntIconData.edit, AppColors.main, () => _editItem(index)),
                gap,
                AntPopconfirm(
                  title: 'Delete the task',
                  description: 'Are you sure to delete this item?',
                  okText: 'Yes',
                  cancelText: 'No',
                  onConfirm: () => _deleteItem(index),
                  child: const AntIcon(AntIconData.delete, size: 20, color: AppColors.danger),
                ),
              ],
      ),
    );
  }

  Widget _buildTotal(_Columns cols) {
    final total = _items
        .where((e) => !e.isPercentage)
        .fold<double>(0, (sum, e) => sum + e.price);
    final style = cssText(size: 20, lineHeight: 28, weight: FontWeight.w700)
        .copyWith(color: DefaultTextStyle.of(context).style.color);
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.main, width: 2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: cols.no + cols.paidBy + cols.name + cols.qty,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 12, 16),
              child: Text('Total', textAlign: TextAlign.right, style: style),
            ),
          ),
          SizedBox(
            width: cols.price + cols.actions,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 8, 16),
              child: Text(toFixed2(total), style: style),
            ),
          ),
        ],
      ),
    );
  }
}

/// Column widths of the auto-layout `<table>` measured on a 373px table:
/// No. 34, Paid By 61, Name 83, Qty 55, Price 81, actions 60.
class _Columns {
  final double no = 34;
  final double actions = 60;
  late final double paidBy;
  late final double name;
  late final double qty;
  late final double price;

  _Columns(double width) {
    final rest = (width - no - actions).clamp(0.0, double.infinity);
    paidBy = rest * 61 / 280;
    name = rest * 83 / 280;
    qty = rest * 55 / 280;
    price = rest * 81 / 280;
  }
}

/// split-item.tsx: the scissor icon and its "Split Items by Quantity" modal.
class SplitItemButton extends StatelessWidget {
  final Item item;
  final List<Item> items;
  final int index;
  final ValueChanged<List<Item>> setItems;

  const SplitItemButton({
    super.key,
    required this.item,
    required this.items,
    required this.index,
    required this.setItems,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showAntModal<void>(
        context: context,
        title: 'Split Items by Quantity',
        width: 600,
        builder: (_) => _SplitItemContent(
          item: item,
          items: items,
          index: index,
          setItems: setItems,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 10),
        child: const AntIcon(AntIconData.scissor, size: 16),
      ),
    );
  }
}

class _SplitItemContent extends StatefulWidget {
  final Item item;
  final List<Item> items;
  final int index;
  final ValueChanged<List<Item>> setItems;

  const _SplitItemContent({
    required this.item,
    required this.items,
    required this.index,
    required this.setItems,
  });

  @override
  State<_SplitItemContent> createState() => _SplitItemContentState();
}

class _SplitItemContentState extends State<_SplitItemContent> {
  late List<Item> _splitted = [widget.item.clone()];

  void _undo() => setState(() => _splitted = [widget.item.clone()]);

  void _splitItem(int index) {
    final initial = _splitted[index];
    final initialQuantity = initial.quantity;
    final newQuantity = initialQuantity - 1;
    final newItem = Item(
      name: initial.name,
      price: initial.price * (1 / initialQuantity),
      quantity: 1,
      image: initial.image,
      error: initial.error,
      sharedNumber: initial.sharedNumber,
      paidBy: initial.paidBy,
      isPercentage: initial.isPercentage,
      percent: initial.percent,
    );
    initial.quantity = newQuantity;
    initial.price = initial.price * (newQuantity / initialQuantity);
    setState(() => _splitted.add(newItem));
  }

  void _save() {
    final all = widget.items.map((e) => e.clone()).toList();
    final items = [
      ...all.sublist(0, widget.index),
      ..._splitted,
      ...all.sublist(widget.index + 1),
    ].map((e) => e.clone()).toList();
    widget.setItems(items);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = DefaultTextStyle.of(context)
        .style
        .copyWith(color: AppColors.main, fontWeight: FontWeight.w700);

    return LayoutBuilder(builder: (context, constraints) {
      // `w-1/3` x3 plus a 40px column, shrunk to fit like flexbox does.
      final k = constraints.maxWidth / (constraints.maxWidth + 40);
      final third = constraints.maxWidth / 3 * k;
      final last = 40 * k;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                for (final label in const ['Item Name', 'Quantity', 'Price'])
                  SizedBox(
                    width: third,
                    child: Text(label, textAlign: TextAlign.center, style: headerStyle),
                  ),
                SizedBox(width: last),
              ],
            ),
          ),
          for (var i = 0; i < _splitted.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.gray200)),
              ),
              child: Row(
                children: [
                  SizedBox(width: third, child: Text(_splitted[i].name)),
                  SizedBox(
                    width: third,
                    child: Text(jsNum(_splitted[i].quantity), textAlign: TextAlign.center),
                  ),
                  SizedBox(
                    width: third,
                    child: Text(jsNum(_splitted[i].price), textAlign: TextAlign.center),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _splitItem(i),
                    child: SizedBox(
                      width: last,
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: AntIcon(AntIconData.scissor, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AntButton(
                  block: true,
                  icon: AntIconData.undo,
                  label: 'Undo',
                  onPressed: _undo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AntButton.primary(
                  block: true,
                  icon: AntIconData.check,
                  label: 'Save',
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
