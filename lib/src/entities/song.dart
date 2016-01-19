part of entities;

///A class representing a song which can be scheduled for a playthrough at a party
class Song extends Object with Identifiable {
  //Data
  final int identity, year;
  final Uri streamLocation;
  final Duration duration;
  final String title, artist;

  //Constructor
  Song(this.identity, this.title, this.artist, this.year, this.streamLocation, this.duration);
  Song.fromPrimitives(this.identity, this.title, this.artist, this.year, String streamLocation, int secondsDuration): streamLocation = new Uri(streamLocation), duration = new Duration(seconds: secondsDration);
}