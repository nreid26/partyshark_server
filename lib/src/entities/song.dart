part of entities;

/// A class representing a song which can be scheduled for a [Playthrough] at a party
class Song extends Object with IdentifiableMixin {
  //Data
  final int identity;
  final Duration duration;

  //Constructor
  Song(this.identity, this.duration);
}