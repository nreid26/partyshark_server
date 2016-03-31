part of model;

/// A class representing a song which can be scheduled for a [Playthrough] at a party
class Song extends PartysharkEntity with IdentifiableMixin {
  //Constructor
  Song._(PartysharkModel model, int identity) : super(model, identity);
}