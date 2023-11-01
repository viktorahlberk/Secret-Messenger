class UserProfile {
  UserProfile(
    this._uid,
    this._key,
    this._userName,
    this._email,
    this._profilePictureUrl,
  );
  final _key;
  get key => _key;

  final String? _uid;
  get uid => _uid;

  final String? _userName;
  get userName => _userName;

  final String? _email;
  get email => _email;

  final String? _profilePictureUrl;
  get profilePictureUrl => _profilePictureUrl;

  Map toJson() => {
        'id': _uid,
        'userName': _userName,
        'email': _email,
        'profilePictureUrl': _profilePictureUrl,
      };
}
