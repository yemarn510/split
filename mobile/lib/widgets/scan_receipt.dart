import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/item.dart';
import '../models/person.dart';
import '../models/scanner.dart';
import '../services/scan_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ant/ant.dart';
import 'item_table.dart';
import 'rounded_avatar.dart';

/// Body of the "Upload your receipt" modal (scan-receipt.tsx).
class ScanReceipt extends StatefulWidget {
  final List<Person> people;
  final ValueChanged<List<Item>> mergeItems;

  const ScanReceipt({super.key, required this.people, required this.mergeItems});

  @override
  State<ScanReceipt> createState() => _ScanReceiptState();
}

class _ScanReceiptState extends State<ScanReceipt> {
  final _scanService = ScanService();
  final _picker = ImagePicker();
  final _table = ItemTableController();

  Person? _paidBy;
  XFile? _image;
  ScanResponse? _response;
  bool _loading = false;
  bool _open = false;
  List<Item> _scannedItems = [];
  final Map<String, String> _error = {};

  @override
  void dispose() {
    _table.dispose();
    super.dispose();
  }

  /// The browser's file chooser for `<input type="file">` on a phone.
  Future<void> _chooseFile() async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final ImageSource? source = isIOS
        ? await showCupertinoModalPopup<ImageSource>(
            context: context,
            builder: (sheetContext) => CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(sheetContext, ImageSource.gallery),
                  child: const Text('Photo Library'),
                ),
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(sheetContext, ImageSource.camera),
                  child: const Text('Take Photo'),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Cancel'),
              ),
            ),
          )
        : await showModalBottomSheet<ImageSource>(
            context: context,
            builder: (sheetContext) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt_outlined),
                    title: const Text('Camera'),
                    onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text('Files'),
                    onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                  ),
                ],
              ),
            ),
          );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !mounted) return;
    setState(() {
      _error.remove('image');
      _image = picked;
    });
  }

  bool _scanIsValid() {
    _error.clear();
    if (_paidBy == null) _error['paidBy'] = 'Please choose who paid';
    if (_image == null) _error['image'] = 'Please upload an image';
    setState(() {});
    return _error.isEmpty;
  }

  Future<void> _scanImage() async {
    if (!_scanIsValid()) return;
    setState(() => _loading = true);
    try {
      final response = await _scanService.scanReceipt(File(_image!.path));
      if (!mounted) return;
      setState(() {
        _response = response;
        _scannedItems = _scanService.toItems(response, _paidBy);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AntMessage.error(context, 'Scan failed: $e');
    }
  }

  Widget _errorText(String key) {
    final message = _error[key];
    if (message == null) return const SizedBox.shrink();
    return Text(
      message,
      style: cssText(size: 11.2, lineHeight: 17.6, color: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_scannedItems.isNotEmpty) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: ItemTable(
                  items: _scannedItems,
                  onItemsChanged: (items) => setState(() => _scannedItems = items),
                  controller: _table,
                  onPaidByTap: (_) {},
                  showTotal: true,
                ),
              ),
            ),
            AntButton.primary(
              block: true,
              label: 'Save Items',
              onPressed: () => widget.mergeItems(_scannedItems),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // `my-3`; the top margin collapses with the title's 8px bottom margin.
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 350),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AntPopover(
                    open: _open,
                    title: 'Choose Who Paid',
                    contentBuilder: (_) => _PersonList(
                      people: widget.people,
                      onSelect: (person) => setState(() {
                        _paidBy = person;
                        _open = false;
                        _error.remove('paidBy');
                      }),
                    ),
                    child: _paidBy != null
                        ? GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _open = !_open),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Paid By',
                                  style: cssText(
                                    size: 16,
                                    lineHeight: 25.142857,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                RoundedAvatar(person: _paidBy!),
                              ],
                            ),
                          )
                        : AntButton(
                            block: true,
                            icon: AntIconData.user,
                            label: 'Choose Paid By',
                            onPressed: () => setState(() => _open = !_open),
                          ),
                  ),
                  _errorText('paidBy'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 1, color: AppColors.gray200),
                  ),
                  if (!_loading && _response == null)
                    AntButton(
                      block: true,
                      icon: AntIconData.inbox,
                      label: 'Click to upload',
                      onPressed: _chooseFile,
                    ),
                  if (_image != null)
                    _UploadListItem(
                      file: _image!,
                      onRemove: () => setState(() => _image = null),
                    ),
                  _errorText('image'),
                ],
              ),
            ),
          ),
        ),
        AntButton.primary(
          block: true,
          label: 'Scan Image',
          disabled: _loading,
          icon: _loading ? AntIconData.loading : null,
          onPressed: _scanImage,
        ),
      ],
    );
  }
}

/// `PersonList` in scan-receipt.tsx.
class _PersonList extends StatelessWidget {
  final List<Person> people;
  final ValueChanged<Person> onSelect;

  const _PersonList({required this.people, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < people.length; i++) ...[
              if (i > 0) const SizedBox(width: 20),
              RoundedAvatar(person: people[i], onTap: () => onSelect(people[i])),
            ],
          ],
        ),
      ),
    );
  }
}

/// antd `<Upload listType="picture">` list item.
class _UploadListItem extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;

  const _UploadListItem({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 66,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Image.file(File(file.path), fit: BoxFit.contain),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                file.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.ant,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(5),
              child: AntIcon(AntIconData.delete, size: 14, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
