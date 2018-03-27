import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

Future<List<Player>> getLeaders(int gameId, int gameDate) async {
  String url = "http://data.nba.net/prod/v1/${gameDate}/${gameId}_boxscore.json";
  var decodJSON = JSON.decode(await http.read(url))["basicGameData"];
  List<Player> leaders = new List<Player>();
  leaders.add(new Player(decodJSON["hTeam"]["leaders"]["points"]["players"][0],
      decodJSON["hTeam"]["teamId"],
      points: decodJSON["hTeam"]["leaders"]["points"]["value"]));
  leaders.add(new Player(decodJSON["hTeam"]["leaders"]["rebounds"]["players"][0],
      decodJSON["hTeam"]["teamId"],
      points: decodJSON["hTeam"]["leaders"]["rebounds"]["value"]));
  leaders.add(new Player(decodJSON["hTeam"]["leaders"]["assists"]["players"][0],
      decodJSON["hTeam"]["teamId"],
      points: decodJSON["hTeam"]["leaders"]["assists"]["value"]));
  leaders.add(new Player(decodJSON["vTeam"]["leaders"]["points"]["players"][0],
      decodJSON["vTeam"]["teamId"],
      points: decodJSON["vTeam"]["leaders"]["points"]["value"]));
  leaders.add(new Player(decodJSON["vTeam"]["leaders"]["rebounds"]["players"][0],
      decodJSON["vTeam"]["teamId"],
      points: decodJSON["vTeam"]["leaders"]["rebounds"]["value"]));
  leaders.add(new Player(decodJSON["vTeam"]["leaders"]["assists"]["players"][0],
      decodJSON["vTeam"]["teamId"],
      points: decodJSON["vTeam"]["leaders"]["assists"]["value"]));

  return null;
}

class Player
{
  String _name, _teamId;
  int _points, _assist, _rebounds, _id;
  var profilePic;

  Player(this._id, this._teamId, {points, assist, rebounds})
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