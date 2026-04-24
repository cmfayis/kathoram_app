
extension NumberFormats on String? {
  num get stringToNum {
    try {
      if (this == null) return 0;
      return num.parse(this!);
    } catch (e) {
      return 0;
    }
  }

  DateTime? get stringToDate {
    try {
      if (this == null) return null;
      return DateTime.parse(this!);
    } catch (e) {
      return null;
    }
  }
}

extension DateValidation on DateTime? {
  bool isDateSame(DateTime? date) {
    try {
      if (this == null || date == null) return false;

      var temp = DateTime(this!.year, this!.month, this!.day);
      var validateDate = DateTime(date.year, date.month, date.day);
      if (temp.isDateSame(validateDate)) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  bool isDateAfterVali(DateTime? date) {
    try {
      if (this == null || date == null) return false;
      var temp = DateTime(this!.year, this!.month, this!.day);
      var validateDate = DateTime(date.year, date.month, date.day);
      if (temp.isAfter(validateDate)) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  bool isDateBefore(DateTime? date) {
    try {
      if (this == null || date == null) return false;
      var temp = DateTime(this!.year, this!.month, this!.day);
      var validateDate = DateTime(date.year, date.month, date.day);

      if (temp.isBefore(validateDate)) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}