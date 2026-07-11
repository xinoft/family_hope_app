import '../constants/app_module.dart';
import '../constants/user_type.dart';
import '../models/module_capability.dart';

/// Source of the app's capability model for each persona.
///
/// Staff capability is meant to come from the backend's
/// `UserGroupPermissionMapping` (per-school configurable RBAC) - until that
/// API integration exists, [staffDefault] is a placeholder granting full
/// access so staff screens are usable during development.
///
/// Parent capability is a fixed product ceiling, not fetched from the API -
/// the backend has no parent authorization model yet, and even once it
/// does, this ceiling should still cap whatever the backend grants so a
/// misconfigured group can never hand a parent more than the product
/// intends (see [ModuleCapability.intersect]).
class PersonaPolicy {
  PersonaPolicy._();

  static const Map<AppModule, ModuleCapability> staffDefault = {
    AppModule.circulars: ModuleCapability.fullAccess,
    AppModule.attendance: ModuleCapability.fullAccess,
    AppModule.timetable: ModuleCapability.fullAccess,
    AppModule.meetings: ModuleCapability.fullAccess,
    AppModule.goals: ModuleCapability.fullAccess,
    AppModule.reports: ModuleCapability.fullAccess,
    AppModule.finance: ModuleCapability.fullAccess,
    AppModule.gallery: ModuleCapability.fullAccess,
    AppModule.approvals: ModuleCapability.fullAccess,
    AppModule.chat: ModuleCapability.fullAccess,
  };

  static const Map<AppModule, ModuleCapability> parentCeiling = {
    AppModule.circulars: ModuleCapability.viewOnly,
    AppModule.attendance: ModuleCapability.viewOnly,
    AppModule.timetable: ModuleCapability.viewOnly,
    AppModule.meetings: ModuleCapability.viewOnly,
    AppModule.goals: ModuleCapability.viewOnly,
    AppModule.reports: ModuleCapability.viewOnly,
    AppModule.finance: ModuleCapability.viewOnly,
    // Staff upload, parents view/download only - never add/update/remove.
    AppModule.gallery: ModuleCapability.viewOnly,
    // Parents respond to approval requests raised by staff, they don't
    // create them.
    AppModule.approvals:
        ModuleCapability(canView: true, canApprove: true),
    // Parents can send messages to the general staff chat box (v1 scope -
    // no picking an individual staff recipient yet).
    AppModule.chat: ModuleCapability(canView: true, canAdd: true),
  };

  static Capabilities resolve(UserType userType) => switch (userType) {
        UserType.staff => const Capabilities(staffDefault),
        UserType.parent => const Capabilities(parentCeiling),
      };
}
