import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/sale_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/inventory_model.dart';
import '../../shared/utils/formatting.dart';

class ReportingService {
  static Future<void> generateSalesReport({
    required String shopName,
    required List<SaleRecord> sales,
    required DateTime date,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(shopName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text("Sales Report - ${date.day}/${date.month}/${date.year}"),
              pw.Divider(),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headers: ['Item', 'Qty', 'Price', 'Total', 'Profit'],
                data: sales.map((s) => [
                  s.name,
                  s.qty.toString(),
                  Formatter.formatCurrency(s.price),
                  Formatter.formatCurrency(s.price * s.qty),
                  Formatter.formatCurrency(s.profit),
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                   pw.Text(
                    "Total Sales: Rs ${Formatter.formatCurrency(sales.fold(0, (sum, s) => sum + (s.price * s.qty).toInt()))}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static Future<void> generateExpenseReport({
    required String shopName,
    required List<ExpenseItem> expenses,
    required DateTime date,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(shopName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text("Expense Report - ${date.day}/${date.month}/${date.year}"),
              pw.Divider(),
              pw.SizedBox(height: 16),
              pw.TableHelper.fromTextArray(
                headers: ['Title', 'Category', 'Amount'],
                data: expenses.map((e) => [
                  e.title,
                  e.category,
                  Formatter.formatCurrency(e.amount),
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    "Total Expenses: Rs ${Formatter.formatCurrency(expenses.fold(0.0, (sum, e) => sum + e.amount))}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static Future<void> generateInventoryExcel({
    required String shopName,
    required List<InventoryItem> items,
  }) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Inventory'];
    excel.delete('Sheet1'); // Remove default sheet

    // Styles
    CellStyle headerStyle = CellStyle(
      bold: true,
      fontFamily: getFontFamily(FontFamily.Arial),
      backgroundColorHex: ExcelColor.fromHexString("#E53935"), // Red
      fontColorHex: ExcelColor.fromHexString("#FFFFFF"),
    );

    // Headers
    sheetObject.appendRow([
      TextCellValue("Item Name"),
      TextCellValue("Barcode"),
      TextCellValue("Price (Rs)"),
      TextCellValue("Current Stock"),
      TextCellValue("Stock Value (Rs)"),
    ]);

    for (int i = 0; i < 5; i++) {
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerStyle;
    }

    // Data
    for (var item in items) {
      sheetObject.appendRow([
        TextCellValue(item.name),
        TextCellValue(item.barcode),
        DoubleCellValue(item.price),
        IntCellValue(item.stock),
        DoubleCellValue(item.price * item.stock),
      ]);
    }

    final String fileName = "inventory_report_${DateTime.now().millisecondsSinceEpoch}.xlsx";
    final directory = await getTemporaryDirectory();
    final file = File("${directory.path}/$fileName");
    
    final bytes = excel.save();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Inventory Stock Report - $shopName');
    }
  }
}
