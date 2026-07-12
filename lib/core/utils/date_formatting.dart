/// `dd/mm/yyyy` - the one date format used anywhere dates are shown as
/// plain text in this app (Profile, Finance, ...), so they all read the
/// same way.
String formatShortDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
