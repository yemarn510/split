import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/item.dart';
import '../models/person.dart';
import '../services/scan_service.dart';
import '../theme/app_colors.dart';
import '../widgets/rounded_avatar.dart';

class ScanReceiptSheet extends StatefulWidget {
  final List<Person> people;
  final ValueChanged<List<Item>> onMergeItems;

  const ScanReceiptSheet({
    super.key,
    required this.people,
    required this.onMergeItems,
  });

  @override
  State<ScanReceiptSheet> createState() => _ScanReceiptSheetState();
}

class _ScanReceiptSheetState extends State<ScanReceiptSheet> {
  final _scanService = ScanService();
  final _picker = ImagePicker();

  Person? _paidBy;
  File? _image;
  bool _loading = false;
  List<Item>? _scannedItems;
  String? _paidByError;
  String? _imageError;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      _imageError = null;
      _scannedItems = null;
    });
  }

  Future<void> _scan() async {
    final errors = <String, String>{};
    if (_paidBy == null) errors['paidBy'] = 'Please choose who paid';
    if (_image == null) errors['image'] = 'Please upload an image';
    setState(() {
      _paidByError = errors['paidBy'];
      _imageError = errors['image'];
    });
    if (errors.isNotEmpty) return;

    setState(() => _loading = true);
    try {
      final response = await _scanService.scanReceipt(_image!);
      final items = _scanService.toItems(response, _paidBy!);
      if (!mounted) return;
      setState(() {
        _scannedItems = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scan failed: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload your receipt'),
      content: SizedBox(
        width: 360,
        height: 420,
        child: _scannedItems != null
            ? Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _scannedItems!.length,
                      itemBuilder: (_, i) {
                        final item = _scannedItems![i];
                        return ListTile(
                          dense: true,
                          title: Text(item.name),
                          subtitle: Text(
                            item.isPercentage
                                ? '${item.percent}%'
                                : '${item.quantity} x ${item.price}',
                          ),
                          trailing: Text(
                            item.price.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onMergeItems(_scannedItems!);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save Items'),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Choose Who Paid',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: widget.people.map((person) {
                        final selected = _paidBy?.uuid == person.uuid;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _paidBy = person;
                            _paidByError = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected
                                    ? AppColors.main
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: RoundedAvatar(
                              person: person,
                              size: AvatarSize.lg,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (_paidByError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _paidByError!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (_image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _image!,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.fourth),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.shareBg,
                        ),
                        child: const Text(
                          'No image selected',
                          style: TextStyle(color: AppColors.fourth),
                        ),
                      ),
                    if (_imageError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _imageError!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Gallery'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Camera'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _scan,
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Scan'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
