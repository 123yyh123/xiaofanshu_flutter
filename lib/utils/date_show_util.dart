class DateShowUtil {
  // 下午3:00，昨天下午3:00，前天下午3:00，10-01 15:00，06-01，2021-10-01
  static String showDateWithTime(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));
    DateTime dayBeforeYesterday = now.subtract(const Duration(days: 2));
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      // 如果是今天，显示凌晨、上午、下午、晚上 + 时间，采用12小时制，不显示年月日，例如：上午 10:00，下午 3:00
      return formatDateTimeHourMinute(dateTime);
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      // 如果是昨天，显示昨天 + 时间，采用12小时制，不显示年月日，例如：昨天上午 10:00
      return '昨天 ${formatDateTimeHourMinute(dateTime)}';
    } else if (dateTime.year == dayBeforeYesterday.year &&
        dateTime.month == dayBeforeYesterday.month &&
        dateTime.day == dayBeforeYesterday.day) {
      // 如果是前天，显示前天 + 时间，采用12小时制，不显示年月日，例如：前天下午 3:00
      return '前天 ${formatDateTimeHourMinute(dateTime)}';
    } else if (dateTime.year == now.year && dateTime.month == now.month) {
      // 如果是本月，显示月日 + 时间，采用24小时制，例如：10-01 15:00
      return '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateTime.year == now.year) {
      // 如果是今年，显示月日，06-01，不显示年份
      return '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } else {
      // 如果是往年，显示年月日，2021-10-01
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  static String formatDateTimeHourMinute(DateTime dateTime) {
    if (dateTime.hour < 6) {
      return '凌晨 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateTime.hour < 12) {
      return '上午 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateTime.hour < 18) {
      if (dateTime.hour == 12) {
        return '下午 12:${dateTime.minute.toString().padLeft(2, '0')}';
      }
      return '下午 ${(dateTime.hour - 12).toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '晚上 ${(dateTime.hour - 12).toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
