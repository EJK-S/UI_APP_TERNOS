// lib/utils/pdf_service.dart (ACTUALIZADO)

import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
// 1. IMPORTAR EL MODELO DE ALQUILER
import 'package:proyecto_tienda_ternos/models/alquiler.dart';

class PdfGenerationService {
  // -----------------------------------------------------------------
  // --- LÓGICA DE PDF DE VENTA (La que ya teníamos) ---
  // -----------------------------------------------------------------
  Future<void> generateVentaPdf(Venta venta, Cliente? cliente) async {
    final doc = pw.Document();

    final String nombreCliente = cliente != null
        ? '${cliente.nombre} ${cliente.apellidos ?? ''}'
        : (venta.clienteId == 1
              ? 'Mostrador'
              : 'Cliente (ID: ${venta.clienteId})');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(context, 'Boleta de Venta', venta.codigo),
                pw.SizedBox(height: 20),
                _buildVentaClientInfo(context, venta, nombreCliente),
                pw.Divider(height: 30),
                pw.Text(
                  'Detalle de Items',
                  style: pw.Theme.of(context).header4,
                ),
                pw.SizedBox(height: 10),
                _buildVentaItemsTable(context, venta),
                pw.Spacer(),
                _buildVentaTotal(context, venta),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    '¡Gracias por su compra!',
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  // --- Helpers Específicos de Venta ---
  pw.Widget _buildVentaClientInfo(
    pw.Context context,
    Venta venta,
    String nombreCliente,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _infoRow(
          context,
          'Fecha:',
          DateFormat('dd/MM/yyyy').format(venta.fecha),
        ),
        _infoRow(context, 'Cliente:', nombreCliente),
        _infoRow(context, 'Método de Pago:', venta.metodoPago),
      ],
    );
  }

  pw.Widget _buildVentaItemsTable(pw.Context context, Venta venta) {
    final f = NumberFormat('S/ ###,##0.00', 'es_PE');
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Descripción',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Cant.',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'P. Unit.',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Total',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(venta.producto),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(venta.cantidad.toString()),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(f.format(venta.precioUnitario)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(f.format(venta.total)),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildVentaTotal(pw.Context context, Venta venta) {
    final f = NumberFormat('S/ ###,##0.00', 'es_PE');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _totalRow(context, 'Subtotal:', f.format(venta.total)),
        _totalRow(context, 'Descuentos:', f.format(0.00)),
        pw.Divider(),
        _totalRow(context, 'TOTAL:', f.format(venta.total), isTotal: true),
      ],
    );
  }

  // -----------------------------------------------------------------
  // --- 2. NUEVA LÓGICA DE PDF DE ALQUILER ---
  // -----------------------------------------------------------------
  Future<void> generateAlquilerPdf(Alquiler alquiler, Cliente? cliente) async {
    final doc = pw.Document();
    final String nombreCliente = cliente != null
        ? '${cliente.nombre} ${cliente.apellidos ?? ''}'
        : 'Cliente (ID: ${alquiler.clienteId})';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(context, 'Contrato de Alquiler', alquiler.codigo),
                pw.SizedBox(height: 20),
                _buildAlquilerClientInfo(context, alquiler, nombreCliente),
                pw.Divider(height: 30),
                pw.Text(
                  'Detalle del Alquiler',
                  style: pw.Theme.of(context).header4,
                ),
                pw.SizedBox(height: 10),
                _buildAlquilerItemsTable(context, alquiler),
                pw.Spacer(),
                _buildAlquilerTotal(context, alquiler),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    '¡Gracias por su preferencia!',
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  // --- Helpers Específicos de Alquiler ---
  pw.Widget _buildAlquilerClientInfo(
    pw.Context context,
    Alquiler alquiler,
    String nombreCliente,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _infoRow(context, 'Cliente:', nombreCliente),
        _infoRow(
          context,
          'Fecha Alquiler:',
          DateFormat('dd/MM/yyyy').format(alquiler.fechaInicio),
        ),
        _infoRow(
          context,
          'Fecha Devolución:',
          DateFormat('dd/MM/yyyy').format(alquiler.fechaDevolucion),
        ),
        _infoRow(context, 'Método de Pago:', alquiler.metodoPago),
      ],
    );
  }

  pw.Widget _buildAlquilerItemsTable(pw.Context context, Alquiler alquiler) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Descripción',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'ID Prenda',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(alquiler.producto),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(alquiler.prendaId),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildAlquilerTotal(pw.Context context, Alquiler alquiler) {
    // (Los montos en Alquiler son Strings, no necesitamos NumberFormat)
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _totalRow(context, 'Monto Alquiler:', alquiler.montoTotal),
        _totalRow(context, 'Garantía:', alquiler.garantia), // (RN-10)
        pw.Divider(),
        _totalRow(
          context,
          'TOTAL PAGADO:',
          alquiler
              .montoTotal, // El total pagado es el monto, la garantía es aparte.
          isTotal: true,
        ),
      ],
    );
  }

  // -----------------------------------------------------------------
  // --- 3. HELPERS GENÉRICOS (Usados por ambas funciones) ---
  // -----------------------------------------------------------------

  pw.Widget _buildHeader(pw.Context context, String title, String codigo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(title, style: pw.Theme.of(context).header3),
        pw.Text('Cód: $codigo', style: pw.Theme.of(context).header5),
      ],
    );
  }

  pw.Widget _infoRow(pw.Context context, String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 10),
          pw.Text(value),
        ],
      ),
    );
  }

  pw.Widget _totalRow(
    pw.Context context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final style = isTotal
        ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)
        : pw.TextStyle(fontSize: 12);

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(label, style: style),
          pw.SizedBox(width: 20),
          pw.Container(
            width: 100,
            alignment: pw.Alignment.centerRight,
            child: pw.Text(value, style: style),
          ),
        ],
      ),
    );
  }
}
