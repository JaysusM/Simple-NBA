import 'package:http/http.dart' as http;

class player
{
  String _name, _teamId;
  int _points, _assist, _rebounds, _id;
  var profilePic;

  player(this._id, this._teamId, {points, assist, rebounds})
  : this._points = points,
  this._assist = assist,
  this._rebounds = rebounds,
  this.profilePic = getImage(_id);

  get id => _id;
  get rebounds => _rebounds;
  get assist => _assist;
  int get points => _points;
  get teamId => _teamId;
  String get name => _name;

  static getImage(int playerId) async
  {
    var url = "https://ak-static.cms.nba.com/wp-content/uploads/headshots/nba/latest/260x190/$playerId.png";
    return await (http.readBytes(url));
  }
}