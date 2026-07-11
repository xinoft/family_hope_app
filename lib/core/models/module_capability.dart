import '../constants/app_module.dart';

/// A single module's granted capabilities, shaped after the backend's
/// `UserPermission` flags so staff capabilities (fetched from the API later)
/// and the parent persona ceiling (defined in [PersonaPolicy]) can share the
/// same model.
class ModuleCapability {
  final bool canView;
  final bool canAdd;
  final bool canUpdate;
  final bool canRemove;
  final bool canApprove;

  const ModuleCapability({
    this.canView = false,
    this.canAdd = false,
    this.canUpdate = false,
    this.canRemove = false,
    this.canApprove = false,
  });

  static const ModuleCapability none = ModuleCapability();
  static const ModuleCapability viewOnly = ModuleCapability(canView: true);
  static const ModuleCapability fullAccess = ModuleCapability(
    canView: true,
    canAdd: true,
    canUpdate: true,
    canRemove: true,
    canApprove: true,
  );

  bool can(CapabilityAction action) => switch (action) {
        CapabilityAction.view => canView,
        CapabilityAction.add => canAdd,
        CapabilityAction.update => canUpdate,
        CapabilityAction.remove => canRemove,
        CapabilityAction.approve => canApprove,
      };

  /// Combines two capability sets, keeping only what both allow. Used to
  /// cap a backend-granted permission with the app-side persona ceiling.
  ModuleCapability intersect(ModuleCapability other) => ModuleCapability(
        canView: canView && other.canView,
        canAdd: canAdd && other.canAdd,
        canUpdate: canUpdate && other.canUpdate,
        canRemove: canRemove && other.canRemove,
        canApprove: canApprove && other.canApprove,
      );
}

/// Resolved capabilities for the signed-in identity, one [ModuleCapability]
/// per [AppModule].
class Capabilities {
  final Map<AppModule, ModuleCapability> _byModule;

  const Capabilities(this._byModule);

  static const Capabilities none = Capabilities({});

  ModuleCapability of(AppModule module) =>
      _byModule[module] ?? ModuleCapability.none;

  bool can(AppModule module, CapabilityAction action) =>
      of(module).can(action);
}
