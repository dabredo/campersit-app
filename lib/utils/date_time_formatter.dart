String convertDateTimeToString(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day/$month/${dateTime.year} $hour:$minute';
}

String formatDateTime(int dateTime) {
  return convertDateTimeToString(DateTime.fromMillisecondsSinceEpoch(dateTime));
}
