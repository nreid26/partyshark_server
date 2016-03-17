part of model;

abstract class PartySharkEntity {
  final PartySharkModel __model;
  final int identity;

  PartySharkEntity(this.__model, this.identity);
}

Future<Song> _getSong(int songCode) async {
  if (song == null) {
    deezer.SongMsg msg = await deezer.getSong(songCode);

    if (!msg.code.isDefined || !msg.duration.isDefined || msg.code.value != songCode) {
      return null;
    }
    else {
      song = new Song._(this, songCode, msg.duration.value);
    }
  }

  return song;
}