part of model;

/// A class representing a song which can be scheduled for a [Playthrough] at a party
class Song extends PartySharkEntity with IdentifiableMixin {
  //Constructor
  Song._(PartySharkModel model, int identity) : super(model, identity);
}