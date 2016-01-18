part of entities;

class Song extends Object with Identifiable {
  //Data
  final int identity, year;
  final Url streamLocation;
  final Duration duration;
  final String title, artist;

  //Constructor
  Song(this.identity, this.title, this.artist, this.year, this.streamLocation, this.duration);
  Song(int identity, String title, String artist, int year, String streamLocation, int secondsDuration): this(identity, title, artist, year, new Url(streamLocation), new Duration(seconds: secondsDration));
}