/// Central route path constants - the only place route strings should be
/// written literally. Deep links (push notifications, shared links) should
/// resolve to one of these too.
class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  /// Default screen - parent login. Staff login is reached from a link on
  /// this page rather than a separate role-picker screen.
  static const root = '/';
  static const staffLogin = '/login/staff';
  static const home = '/home';
  static const profile = '/home/profile';
  static const circulars = '/home/circulars';
  static const attendance = '/home/attendance';
  static const timetable = '/home/timetable';
  static const meetings = '/home/meetings';
  static const goals = '/home/goals';
  static const reports = '/home/reports';
  static const finance = '/home/finance';
  static const gallery = '/home/gallery';
  static const approvals = '/home/approvals';
  static const chat = '/home/chat';
}
