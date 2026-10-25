import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/item.dart';
import '../models/person.dart';
import '../models/scanner.dart';

class ScanService {
  Future<ScanResponse> scanReceipt(File imageFile) async {
    final request =
        http.MultipartRequest('POST', Uri.parse(AppConfig.scanApiUrl));
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw Exception('Scan failed (${streamed.statusCode}): $body');
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected scan response');
    }
    return ScanResponse.fromJson(decoded);
  }

  /// `seeTheResult` in scan-receipt.tsx.
  List<Item> toItems(ScanResponse response, Person? paidBy) {
    return response.items
        .map(
          (each) => Item(
            name: each.translatedName,
            price: each.isPercentage ? each.percent : each.price * each.quantity,
            paidBy: paidBy,
            quantity: each.quantity,
            isPercentage: each.isPercentage,
            percent: each.percent,
          ),
        )
        .toList();
  }
}
