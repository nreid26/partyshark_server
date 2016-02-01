part of entities;

///A class representing a song which can be scheduled for a [Playthrough] at a party
class Song extends Object with Identifiable {
  //Data
  final int year;
  final Uri streamLocation;
  final Duration duration;
  final String title, artist;

  //Constructor
  Song(this.title, this.artist, this.year, this.streamLocation, this.duration);
  Song.fromPrimitives(this.title, this.artist, this.year, String streamLocation, int secondsDuration) :
        streamLocation = Uri.parse(streamLocation), duration = new Duration(seconds: secondsDuration);
}