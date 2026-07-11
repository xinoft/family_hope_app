/// Which login the user authenticated through. Drives which
/// [PersonaPolicy] ceiling (or, later, which API identity) is used to
/// resolve capabilities - never branch feature UI on this directly, branch
/// on the resolved `Capabilities` instead.
enum UserType { staff, parent }
