import 'package:flutter/foundation.dart' show kIsWeb;
//import 'dart:html' as html;

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:topografia/Network/User/login.dart';
import 'package:path_provider/path_provider.dart';

Future<String> save_excel(
  List<List> content,
  Usuario? user, {
  String name = "",
  String sheetName = "",
}) async {
  String filePath = "download";

  name = name.replaceAll(".xlsx", "");
  var excel = Excel.createExcel();

  late Sheet sheet;

  if (user != null) {
    excel.rename("Sheet1", "${user.nomeUsuario ?? 'Resposta'}");
    sheet = excel["${user.nomeUsuario ?? 'Resposta'}"];
  } else if (sheetName != "") {
    excel.rename("Sheet1", sheetName);
    sheet = excel[sheetName];
  } else if (name != "") {
    excel.rename("Sheet1", name);
    sheet = excel[name];
  } else {
    excel.rename("Sheet1", "Sheet");
    sheet = excel["Sheet"];
  }

  for (int row = 0; row < content.length; row++) {
    List row_element = content[row];
    for (int col = 0; col < row_element.length; col++) {
      var cell_element = row_element[col];

      Data cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));

      cell.value = cell_element;
    }
  }

  List<int>? fileBytes = excel.save();

  String nameExcel = (name.isEmpty ? (user != null ? user.nomeUsuario : "excel") : name) ?? "";
  if (kIsWeb) {
    //TODO: Se for web descomentar aqui
    /*final blob = html.Blob([fileBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement()
      ..href = url
      ..download = '$nameExcel.xlsx'
      ..style.display = 'none'
      ..click();*/
  } else {
    final directory = await getExternalStorageDirectories(type: StorageDirectory.documents);

    String appDocumentsPath = await directory![0].path;
    filePath = "$appDocumentsPath/$nameExcel.xlsx";

    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes ?? []);
  }

  return filePath;
}
