import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/material.dart';

abstract class ExportUtils {
  /// Saves a raw string (e.g. CSV content returned by the server) to a user-chosen path.
  /// Returns false if the user cancelled the picker.
  static Future<bool> saveRawString(String content, String filename, String ext) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save ${ext.toUpperCase()}',
      fileName: '$filename.$ext',
      type: FileType.custom,
      allowedExtensions: [ext],
    );
    if (path == null) return false;
    await File(path).writeAsString(content);
    return true;
  }

  static Future<void> exportToCsv(
    List<List<String>> rows,
    String filename,
  ) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save CSV',
      fileName: '$filename.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (path == null) return;

    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(
        row.map((cell) => '"${cell.replaceAll('"', '""')}"').join(','),
      );
    }

    await File(path).writeAsString(buffer.toString());
  }

  static Future<void> exportToExcel(
    List<List<dynamic>> rows,
    String filename, {
    List<String>? headers,
  }) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Excel',
      fileName: '$filename.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (path == null) return;

    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = filename;

    int startRow = 1;
    if (headers != null) {
      for (var i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
        sheet.getRangeByIndex(1, i + 1).cellStyle.bold = true;
      }
      startRow = 2;
    }

    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < rows[r].length; c++) {
        final cell = sheet.getRangeByIndex(r + startRow, c + 1);
        final value = rows[r][c];
        if (value is num) {
          cell.setNumber(value.toDouble());
        } else {
          cell.setText(value?.toString() ?? '');
        }
      }
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();
    await File(path).writeAsBytes(bytes);
  }

  static Future<void> exportToPdf(
    String title,
    List<List<String>> rows,
    String filename, {
    List<String>? headers,
  }) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF',
      fileName: '$filename.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path == null) return;

    final doc = PdfDocument();
    final page = doc.pages.add();

    page.graphics.drawString(
      title,
      PdfStandardFont(PdfFontFamily.helvetica, 16,
          style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 30),
    );

    final grid = PdfGrid();
    grid.columns.add(
        count: headers?.length ?? (rows.isNotEmpty ? rows[0].length : 1));

    if (headers != null) {
      final headerRow = grid.headers.add(1)[0];
      for (var i = 0; i < headers.length; i++) {
        headerRow.cells[i].value = headers[i];
        headerRow.cells[i].style.backgroundBrush =
            PdfSolidBrush(PdfColor(0, 105, 92));
        headerRow.cells[i].style.textBrush =
            PdfBrushes.white;
        headerRow.cells[i].style.font =
            PdfStandardFont(PdfFontFamily.helvetica, 9,
                style: PdfFontStyle.bold);
      }
    }

    for (final row in rows) {
      final pdfRow = grid.rows.add();
      for (var i = 0; i < row.length; i++) {
        pdfRow.cells[i].value = row[i];
      }
    }

    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, 40, page.getClientSize().width,
          page.getClientSize().height - 40),
    );

    final bytes = await doc.save();
    doc.dispose();
    await File(path).writeAsBytes(bytes);
  }
}
