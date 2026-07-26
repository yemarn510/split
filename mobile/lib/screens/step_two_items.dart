import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/item.dart';
import '../models/person.dart';
import '../theme/app_colors.dart';
import '../widgets/rounded_avatar.dart';
import '../widgets/scan_receipt_sheet.dart';

class StepTwoItems extends StatefulWidget {
  final List<Item> items;
  final List<Person> people;
  final ValueChanged<List<Item>> onItemsChanged;

  const StepTwoItems({
    Key? key,
    required this.items,
    required this.people,
    required this.onItemsChanged,
  }) : super(key: key);

  @override
  State<StepTwoItems> createState() => _StepTwoItemsState();
}

class _StepTwoItemsState extends State<StepTwoItems> {
  int? _editingIndex;
  Item? _originalItem;

  @override
  void initState() {
    super.initState();
    if (widget.items.length == 1) {
      _editingIndex = 0;
    }
  }

  bool _validateIndex(int index) {
    final items = List<Item>.from(widget.items);
    final valid = items[index].isValid();
    widget.onItemsChanged(items);
    return valid;
  }

  void _addItem() {
    if (widget.items.isNotEmpty &&
        !_validateIndex(widget.items.length - 1) &&
        _editingIndex == widget.items.length - 1) {
      return;
    }
    final items = List<Item>.from(widget.items)..add(Item());
    widget.onItemsChanged(items);
    setState(() {
      _editingIndex = items.length - 1;
      _originalItem = null;
    });
  }

  void _saveEdit() {
    if (_editingIndex == null) return;
    if (!_validateIndex(_editingIndex!)) return;
    setState(() {
      _editingIndex = null;
      _originalItem = null;
    });
  }

  void _cancelEdit(int index) {
    final items = List<Item>.from(widget.items);
    final editing = items[index];
    if (editing.name.isEmpty && editing.price == 0) {
      items.removeAt(index);
      widget.onItemsChanged(items);
      setState(() {
        _editingIndex = null;
        _originalItem = null;
      });
      return;
    }
    if (_originalItem != null) {
      items[index] = _originalItem!;
      widget.onItemsChanged(items);
    }
    setState(() {
      _editingIndex = null;
      _originalItem = null;
    });
  }

  void _startEdit(int index) {
    if (_editingIndex != null && !_validateIndex(_editingIndex!)) return;
    setState(() {
      _originalItem = widget.items[index].copyWith();
      _editingIndex = index;
    });
  }

  void _deleteItem(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete the task'),
        content: const Text('Are you sure to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final items = List<Item>.from(widget.items)..removeAt(index);
      widget.onItemsChanged(items);
      if (_editingIndex == index) {
        setState(() {
          _editingIndex = null;
          _originalItem = null;
        });
      }
    }
  }

  Future<void> _pickPaidBy(int itemIndex) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Set Paid By'),
          content: SizedBox(
            width: double.maxFinite,
            height: 320,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: widget.people.length,
              itemBuilder: (_, personIndex) {
                final person = widget.people[personIndex];
                return RoundedAvatar(
                  person: person,
                  size: AvatarSize.lg,
                  onTap: () {
                    final items = List<Item>.from(widget.items);
                    final item = items[itemIndex].copyWith(paidBy: person);
                    item.error.remove('paidBy');
                    items[itemIndex] = item;
                    widget.onItemsChanged(items);
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _togglePercentage(int index, bool isPercentage) {
    final items = List<Item>.from(widget.items);
    final item = items[index];
    if (item.isPercentage == isPercentage) return;
    items[index] = item.copyWith(
      isPercentage: isPercentage,
      percent: isPercentage ? item.price : 0,
      price: item.price,
    );
    widget.onItemsChanged(items);
    setState(() {});
  }

  Future<void> _showPriceType(int index) async {
    if (_editingIndex != index) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Price / Percentage'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Change this to Price or Percentage'),
              const SizedBox(height: 12),
              RadioListTile<bool>(
                title: const Text('Money \$'),
                value: false,
                groupValue: widget.items[index].isPercentage,
                onChanged: (v) {
                  _togglePercentage(index, false);
                  Navigator.pop(ctx);
                },
              ),
              RadioListTile<bool>(
                title: const Text('Percentage %'),
                value: true,
                groupValue: widget.items[index].isPercentage,
                onChanged: (v) {
                  _togglePercentage(index, true);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                  child: Row(
                    children: const [
                      SizedBox(
                        width: 28,
                        child: Text(
                          'No.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.main,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Paid By',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.main,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.main,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Qty',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.main,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Price',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.main,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(width: 56),
                    ],
                  ),
                ),
                ...List.generate(widget.items.length, (index) {
                  final item = widget.items[index];
                  final editing = _editingIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${index + 1}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.main),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Tooltip(
                            message: item.error['paidBy'] ?? '',
                            preferBelow: false,
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                            child: item.paidBy != null
                                ? RoundedAvatar(
                                    person: item.paidBy!,
                                    onTap: () => _pickPaidBy(index),
                                  )
                                : UnknownPerson(
                                    onTap: () => _pickPaidBy(index),
                                  ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: _ErrorField(
                              error: item.error['name'],
                              child: SizedBox(
                                height: _itemFieldHeight,
                                child: TextFormField(
                                  initialValue: item.name,
                                  enabled: editing,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.2,
                                    color: editing
                                        ? AppColors.main
                                        : Colors.black54,
                                  ),
                                  decoration: _itemFieldDecoration(
                                    hintText: 'KFC, McDonalds...',
                                  ),
                                  onChanged: (v) {
                                    final items =
                                        List<Item>.from(widget.items);
                                    final updated =
                                        items[index].copyWith(name: v);
                                    updated.error.remove('name');
                                    items[index] = updated;
                                    widget.onItemsChanged(items);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: _ErrorField(
                              error: item.error['quantity'],
                              child: SizedBox(
                                height: _itemFieldHeight,
                                child: TextFormField(
                                  initialValue: '${item.quantity}',
                                  enabled: editing,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.2,
                                    color: editing
                                        ? AppColors.main
                                        : Colors.black54,
                                  ),
                                  decoration: _itemFieldDecoration(
                                    hintText: '1',
                                    horizontalPadding: 4,
                                  ),
                                  onChanged: (v) {
                                    final items =
                                        List<Item>.from(widget.items);
                                    final updated = items[index].copyWith(
                                      quantity: int.tryParse(v) ?? 0,
                                    );
                                    updated.error.remove('quantity');
                                    items[index] = updated;
                                    widget.onItemsChanged(items);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: _ErrorField(
                              error: item.error['price'],
                              child: SizedBox(
                                height: _itemFieldHeight,
                                child: TextFormField(
                                  initialValue: item.isPercentage
                                      ? '${item.percent == 0 ? item.price : item.percent}'
                                      : (item.price == 0
                                          ? ''
                                          : '${item.price}'),
                                  enabled: editing,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.2,
                                    color: editing
                                        ? AppColors.main
                                        : Colors.black54,
                                  ),
                                  decoration: _itemFieldDecoration(
                                    hintText: '0.00',
                                    suffix: GestureDetector(
                                      onTap: () => _showPriceType(index),
                                      behavior: HitTestBehavior.opaque,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 4),
                                        child: Icon(
                                          item.isPercentage
                                              ? Icons.percent
                                              : Icons.attach_money,
                                          size: 16,
                                          color: AppColors.main,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onChanged: (v) {
                                    final items =
                                        List<Item>.from(widget.items);
                                    final value = double.tryParse(v) ?? 0;
                                    final updated = items[index].copyWith(
                                      price: value,
                                      percent: items[index].isPercentage
                                          ? value
                                          : 0,
                                    );
                                    updated.error.remove('price');
                                    items[index] = updated;
                                    widget.onItemsChanged(items);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 56,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: editing
                                ? [
                                    GestureDetector(
                                      onTap: _saveEdit,
                                      child: const Icon(
                                        Icons.check,
                                        color: AppColors.main,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _cancelEdit(index),
                                      child: const Icon(
                                        Icons.close,
                                        color: AppColors.danger,
                                        size: 22,
                                      ),
                                    ),
                                  ]
                                : [
                                    GestureDetector(
                                      onTap: () => _startEdit(index),
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        color: AppColors.main,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _deleteItem(index),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.danger,
                                        size: 22,
                                      ),
                                    ),
                                  ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        Container(
          color: AppColors.second,
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                flex: 9,
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Item'),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => ScanReceiptSheet(
                          people: widget.people,
                          onMergeItems: (scanned) {
                            final kept = widget.items
                                .where((e) => e.name.isNotEmpty || e.price != 0)
                                .toList();
                            widget.onItemsChanged([...kept, ...scanned]);
                            setState(() {
                              _editingIndex = null;
                              _originalItem = null;
                            });
                          },
                        ),
                      );
                    },
                    child: const Icon(Icons.camera_alt_outlined, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

const double _itemFieldHeight = 36;

InputDecoration _itemFieldDecoration({
  required String hintText,
  double horizontalPadding = 8,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hintText,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: 8,
    ),
    suffixIcon: suffix,
    suffixIconConstraints: const BoxConstraints(
      minWidth: 20,
      minHeight: 20,
    ),
  );
}

class _ErrorField extends StatelessWidget {
  final String? error;
  final Widget child;

  const _ErrorField({this.error, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        child,
        if (error != null && error!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              error!,
              style: const TextStyle(color: AppColors.danger, fontSize: 10),
            ),
          ),
      ],
    );
  }
}
