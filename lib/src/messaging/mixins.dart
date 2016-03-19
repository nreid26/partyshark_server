part of messaging;

class UserMessenger {
  UserMsg userToMsg(User user) {
    return new UserMsg()
      ..adminCode.isDefined = false
      ..username.value = user.username
      ..isAdmin.value = user.isAdmin;
  }
}

class PlaythroughMessenger {
  PlaythroughMsg playthroughToMsg(Playthrough p) {
    return new PlaythroughMsg()
      ..suggester.value = p.suggester.username
      ..completedDuration.value = p.completedDuration
      ..code.value = p.identity
      ..position.value = p.position
      ..songCode.value = p.song.identity
      ..creationTime.value = p.creationTime
      ..downvotes.value = p.downvotes
      ..upvotes.value = p.upotes
      ..vote.value = p.ballots.firstWhere((b) => b.voter == p.suggester, orElse: () => null)?.vote;
  }
}

class PlayerTransferMessenger {
  PlayerTransferMsg transferToMsg(PlayerTransfer trans) {
    return new PlayerTransferMsg()
        ..code.value = trans.identity
        ..creationTime.value = trans.creationTime
        ..requester.value = trans.requester.username
        ..status.value = trans.status;
  }
}