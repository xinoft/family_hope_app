/// Feature modules exposed by the app. Names intentionally mirror the
/// module codes used by the backend's permission system (e.g. `GAL`,
/// `ATTND`) so the two stay easy to cross-reference as API-driven staff
/// permissions are wired in later.
enum AppModule {
  circulars,
  attendance,
  timetable,
  meetings,
  goals,
  reports,
  finance,
  gallery,
  approvals,
  chat,
}

/// Actions mirroring the backend's `UserPermission` flags
/// (`HaveView`/`HaveAdd`/`HaveUpdate`/`HaveRemove`/`HaveApprove`).
enum CapabilityAction { view, add, update, remove, approve }
