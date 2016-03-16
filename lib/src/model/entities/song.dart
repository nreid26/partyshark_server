part of model;

/// A class representing a song which can be scheduled for a [Playthrough] at a party
class Song extends PartySharkEntity with IdentifiableMixin {
  //Data
  final Duration duration;

  //Constructor
  Song._(PartySharkModel model, int identity, this.duration) : super(model, identity);
}