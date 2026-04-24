import 'package:intl/intl.dart';

class DateHelper {
  final DateTime date = DateTime.now();
  static String format = "dd-MMM-yy";
  static const String formatWithMonth = "yyyy-MM-dd";
  static String ddmmyyyy = "dd-MMM-yyyy";

  String getDateWithMothInDigitFormat({required DateTime val}) {
    DateTime specificDate = DateTime(val.year, val.month.toInt(), val.day);
    DateFormat formatter = DateFormat(formatWithMonth);

    // Format the specific date
    String formattedDate = formatter.format(specificDate);
    return formattedDate; //2024-02-21
  }

  String currentMonthName({String? format, DateTime? dateTime}) {
    return DateFormat(format ?? 'MMMM').format(dateTime ?? date); // February
  }

  String currentYear({DateTime? dateTime}) {
    return DateFormat('yyyy').format(dateTime ?? date); // 2024
  }

  DateTime getDaysDifference({int? days = 7}) {
    return DateTime(date.year, date.month, date.day - days!);
  }

  static String timeFormatToLocal(String val) {
    if (val.isNotEmpty) {
      var toLocal = DateTime.parse(val);
      return DateFormat('hh.mm a').format(toLocal);
    }
    return ""; // 04.07 PM
  }

  static String dateOnly(DateTime val) {
    return DateFormat('d MMM yyyy').format(val); // 21 Feb 2024
  }

  static String monthDayYear(DateTime val) {
    return DateFormat('MMM d yyyy').format(val); // Feb 21 2024
  }

  static String monthDateYearWithComma(DateTime val) {
    try {
      return DateFormat('MMM d, yyyy').format(val);
    } catch (e) {
      return "";
    }
// Feb 21, 2024 4:07PM
  }

  static String dateOnlySlash(DateTime? val) {
    if (val == null) return "";
    try {
      return DateFormat('dd/MM/yyyy').format(val).toString(); // 21/02/2024
    } catch (e) {
      return "";
    }
  }

  static String dateTimeFormatWithDot(String date, [bool isUtc = false]) {
    try {
      var val =
      isUtc ? DateTime.parse(date).toUtc() : DateTime.parse(date).toLocal();
      return DateFormat.yMMMd().add_Hm().format(val); // Feb 21, 2024 13:07
    } catch (e) {
      return "";
    }
  }

  static String dateTimeFormatWithDotToLocal(String date) {
    try {
      DateTime dateTime = DateTime.parse(date);
      return DateFormat("dd MMM yyyy, hh:mm a").format(dateTime);
    } on Exception {
      return DateFormat.yMMMd().add_jm().format(DateTime.now());
    }
  }

  static String dayMonthYear(DateTime val) {
    return DateFormat("E, MMM dd").format(val); // Tue, Feb 21
  }

  static String day(DateTime val) {
    return DateFormat("EEEE").format(val); // Tuesday
  }
}