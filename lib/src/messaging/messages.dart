part of messaging;

class PartyMsg extends Jsonable {
  final JsonProperty<int> code = new SimpleProperty<int>('code');
  final JsonProperty<int> adminCode = new SimpleProperty<int>('admin_code');
  final JsonProperty<String> player = new SimpleProperty<String>('player');
  final JsonProperty<bool> isPlaying = new SimpleProperty<bool>('is_playing');
}

class PlayerTransferMsg extends Jsonable {
  final JsonProperty<int> code = new SimpleProperty<int>('code');
  final JsonProperty<String> requester = new SimpleProperty<String>('requester');
  final JsonProperty<TransferStatus> status = new _TransferStatusProperty('status');
  final JsonProperty<DateTime> creationTime = new DateTimeProperty('creation_time');
}

class PlaythroughMsg extends Jsonable {
  final JsonProperty<int> code = new SimpleProperty<int>('code');
  final JsonProperty<int> songCode = new SimpleProperty<int>('song_code');
  final JsonProperty<int> position = new SimpleProperty<int>('position');
  final JsonProperty<int> upvotes = new SimpleProperty<int>('upvotes');
  final JsonProperty<int> downvotes = new SimpleProperty<int>('downvotes');
  final JsonProperty<String> suggester = new SimpleProperty<String>('suggester');
  final JsonProperty<Vote> vote = new _VoteProperty('vote');
  final JsonProperty<Duration> completedDuration = new _DurationProperty('completed_duration');
  final JsonProperty<DateTime> creationTime = new DateTimeProperty('creation_time');
}

class SettingsMsg extends Jsonable {
  final JsonProperty<bool> virtualDj = new SimpleProperty<bool>('virtual_dj');
  final JsonProperty<Genre> defaultGenre = new _GenreProperty('default_genre');
  final JsonProperty<int> userCap = new SimpleProperty<int>('user_cap');
  final JsonProperty<int> playthroughCap = new SimpleProperty<int>('playthrough_cap');
  final JsonProperty<double> vetoRatio = new SimpleProperty<double>('veto_ratio');
}

class UserMsg extends Jsonable {
  final JsonProperty<int> adminCode = new SimpleProperty<int>('admin_code');
  final JsonProperty<bool> isAdmin = new SimpleProperty<bool>('is_admin');
  final JsonProperty<String> username = new SimpleProperty<String>('username');
}

class SongMsg extends Jsonable {
  final JsonProperty<int> code = new SimpleProperty<int>('code');
  final JsonProperty<Duration> duration = new _DurationProperty('duration');
}

class EmptyMsg extends Object with Jsonable {
  static final EmptyMsg only = new EmptyMsg();
}