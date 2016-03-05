part of messaging;

class PartyMsg extends Jsonable {
  final JsonProperty<int> code = new SimpleProperty('code');
  final JsonProperty<int> adminCode = new SimpleProperty('admin_code');
  final JsonProperty<String> player = new SimpleProperty('player');
  final JsonProperty<bool> isPlaying = new SimpleProperty('is_playing');
}

class PlayerTransferMsg extends Jsonable {
  final JsonProperty<int> code = new SimpleProperty('code');
  final JsonProperty<String> requester = new SimpleProperty('requester');
  final JsonProperty<TransferStatus> status = new _TransferStatusProperty('status');
  final JsonProperty<DateTime> creationTime = new DateTimeProperty('creation_time');
}

class PlaythroughMsg extends Jsonable {
  final JsonProperty<int> code = new SimpleProperty('code');
  final JsonProperty<int> songCode = new SimpleProperty('song_code');
  final JsonProperty<int> position = new SimpleProperty('position');
  final JsonProperty<int> upvotes = new SimpleProperty('upvotes');
  final JsonProperty<int> downvotes = new SimpleProperty('downvotes');
  final JsonProperty<String> suggester = new SimpleProperty('suggester');
  final JsonProperty<Vote> vote = new _VoteProperty('vote');
  final JsonProperty<Duration> completedDuration = new _DurationProperty('completed_duration');
  final JsonProperty<DateTime> creationTime = new DateTimeProperty('creation_time');
}

class SettingsMsg extends Jsonable {
  final JsonProperty<bool> virtualDj = new SimpleProperty('virtual_dj');
  final JsonProperty<Genre> defaultGenre = new _GenreProperty('default_genre');
  final JsonProperty<int> userCap = new SimpleProperty('user_cap');
  final JsonProperty<int> playthroughCap = new SimpleProperty('playthrough_cap');
  final JsonProperty<double> vetoRatio = new SimpleProperty('veto_ratio');
}

class UserMsg extends Jsonable {
  final JsonProperty<int> adminCode = new SimpleProperty('admin_code');
  final JsonProperty<bool> isAdmin = new SimpleProperty('is_admin');
  final JsonProperty<String> username = new SimpleProperty('username');
}

class SongMsg extends Jsonable {
  final JsonProperty<int> code = new SimpleProperty('code');
  final JsonProperty<int> year = new SimpleProperty('year');
  final JsonProperty<Duration> duration = new _DurationProperty('duration');
  final JsonProperty<String> title = new SimpleProperty('title');
  final JsonProperty<String> artist = new SimpleProperty('artist');
}