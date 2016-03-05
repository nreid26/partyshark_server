part of entities;

/// A class representing a song which can be scheduled for a [Playthrough] at a party
class Song extends Object with DeferredIdentifiableMixin {
  //Data
  final int year;
  final Duration duration;
  final String title, artist;

  //Constructor
  Song(this.title, this.artist, this.year, this.duration);
  Song.fromPrimitives(this.title, this.artist, this.year, int secondsDuration) : duration = new Duration(seconds: secondsDuration);
}