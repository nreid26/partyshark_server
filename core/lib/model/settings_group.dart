part of model;

/// An enum representing a basic musical genre
enum Genre {
  Rock,
  Metal,
  Jazz,
  Country,
  Pop,
  Classical,
  Folk,
  Electronic
}

/// A class representing the settings on a party
class SettingsGroup extends PartySharkEntity with IdentifiableMixin {
  //Data
  Party _party;
  bool __usingVirtualDj = false;
  Genre defaultGenre = null;
  int userCap = null, playthroughCap = null;
  double __vetoRatio = 0.25;

  //Constructor
  SettingsGroup._(PartySharkModel model, int identity) : super(model, identity);

  //Methods
  bool get hasDefaultGenre => defaultGenre != null;

  Party get party => _party;

  bool get usingVitualDj => __usingVirtualDj;
  void set usingVirtualDj(bool b) { __usingVirtualDj = b ?? __usingVirtualDj;  }

  double get vetoRatio => __vetoRatio;
  void   set vetoRatio(double d) { __vetoRatio = d?.clamp(0.0, 1.0) ?? __vetoRatio; }
}