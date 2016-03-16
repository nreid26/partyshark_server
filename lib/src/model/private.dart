part of model;




Future<Song> _getSong(int songCode) async {
  Song song = _datastore[Song][songCode];

  if (song == null) {
    logger.finer('Queried Deezer for song: $songCode');
    song = await deezer.getSong(songCode);

    if (song != null) { _datastore.add(song); }
  }

  return song;
}








