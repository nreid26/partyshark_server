part of entities;

/// A class representing a song which can be scheduled for a [Playthrough] at a party
class Song extends Object with IdentifiableMixin {
  //Data
  final int identity;
  final int year;
  final Duration duration;
  final String title, artist;

  //Constructor
  Song(this.identity, this.title, this.artist, this.year, this.duration);
}