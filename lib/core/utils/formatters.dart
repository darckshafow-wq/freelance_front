import 'package:intl/intl.dart';

class Formatters {
  static String currency(num value) {
    final format = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'XOF',
      decimalDigits: 0,
    );
    return format.format(value);
  }

  static String date(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
