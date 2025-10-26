import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shopsphere/models/product_variant.dart';
import 'package:shopsphere/models/product.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

Future<List<File>> pickImages() async {
  List<File> images = [];
  try {
    var files = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (files != null && files.files.isNotEmpty) {
      for (int i = 0; i < files.files.length; i++) {
        images.add(File(files.files[i].path!));
      }
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  return images;
}

String getSelectedConfigName(ProductVariant variant){
  final configList = variant.configuration;
  if (configList.isEmpty) return "";

  final buffer = StringBuffer(" ( ");
  for (int i = 0; i < configList.length; i++) {
    final config = configList[i];
    final key = config.key.toUpperCase();
    final value = config.value.toUpperCase();
    final showKey = !(key == "COLOR" || key == "DISPLAY SIZE");
    buffer.write("$value${showKey ? " $key" : ""}");
    if (i != configList.length - 1) {
      buffer.write(", ");
    }
  }
  buffer.write(" )");
  return buffer.toString();
}