part of messaging;

class UserMessenger {
  UserMsg userToMsg(User user) {
    return new UserMsg()
      ..adminCode.isDefined = false
      ..username.value = user.username
      ..isAdmin.value = user.isAdmin;
  }
}