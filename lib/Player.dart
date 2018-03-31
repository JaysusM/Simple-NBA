import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'Games.dart';

Future<List<Player>> loadLeaders(String gameId, int gameDate) async {
  String url = "http://data.nba.net/prod/v1/$gameDate/${gameId}_boxscore.json";
  Directory currentDir = await getApplicationDocumentsDirectory();
  Database db = await openDatabase("${currentDir.path}/db/snba.db");
  var decodJSON = JSON.decode(await http.read(url))["stats"];
  List<Player> leaders = new List<Player>();
  leaders.add(new Player(decodJSON["hTeam"]["leaders"]["points"]["players"][0]["personId"],
      decodJSON["hTeam"]["teamId"],
      name: await getPlayerName(decodJSON["hTeam"]["leaders"]["points"]["players"][0]["personId"], db),
      points: decodJSON["hTeam"]["leaders"]["points"]["value"]));
  leaders.add(new Player(decodJSON["hTeam"]["leaders"]["rebounds"]["players"][0]["personId"],
      decodJSON["hTeam"]["teamId"],
      name: await getPlayerName(decodJSON["hTeam"]["leaders"]["rebounds"]["players"][0]["personId"], db),
      rebounds: decodJSON["hTeam"]["leaders"]["rebounds"]["value"]));
  leaders.add(new Player(decodJSON["hTeam"]["leaders"]["assists"]["players"][0]["personId"],
      decodJSON["hTeam"]["teamId"],
      name: await getPlayerName(decodJSON["hTeam"]["leaders"]["assists"]["players"][0]["personId"], db),
      assist: decodJSON["hTeam"]["leaders"]["assists"]["value"]));
  leaders.add(new Player(decodJSON["vTeam"]["leaders"]["points"]["players"][0]["personId"],
      decodJSON["vTeam"]["teamId"],
      name: await getPlayerName(decodJSON["vTeam"]["leaders"]["points"]["players"][0]["personId"], db),
      points: decodJSON["vTeam"]["leaders"]["points"]["value"]));
  leaders.add(new Player(decodJSON["vTeam"]["leaders"]["rebounds"]["players"][0]["personId"],
      decodJSON["vTeam"]["teamId"],
      name: await getPlayerName(decodJSON["vTeam"]["leaders"]["rebounds"]["players"][0]["personId"], db),
      rebounds: decodJSON["vTeam"]["leaders"]["rebounds"]["value"]));
  leaders.add(new Player(decodJSON["vTeam"]["leaders"]["assists"]["players"][0]["personId"],
      decodJSON["vTeam"]["teamId"],
      name: await getPlayerName(decodJSON["vTeam"]["leaders"]["assists"]["players"][0]["personId"], db),
      assist: decodJSON["vTeam"]["leaders"]["assists"]["value"]));
  db.close();
  return leaders;
}

Future<String> getPlayerName(String playerId, Database db) async {
  String playerName;
  try {
    playerName = (await db.rawQuery("SELECT lastName FROM players WHERE personId = $playerId")).first["lastName"];
  } catch (exception) {
    playerName = "DBError";
  }
  return playerName;
}

Future<List<Player>> loadTeamsLeaders(Game game) async {
  List<Player> leaders = new List();
  Database db = await openDatabase("${(await getApplicationDocumentsDirectory()).path}/db/snba.db");

  String prefix = "http://data.nba.net";
  String url = "$prefix/10s/prod/v1/today.json";

  var decodJSON = JSON.decode(await http.read(url));
  url = "$prefix${decodJSON["links"]["teamLeaders2"]}";

  leaders.addAll(await _loadTeamLeaders(game.home.id.toString(), url, db));
  leaders.addAll(await _loadTeamLeaders(game.visitor.id.toString(), url, db));

  db.close();
  return leaders;
}

Future<List<Player>> _loadTeamLeaders(String teamId, String url, Database db) async {
  String link = url.replaceAll("{{teamId}}", teamId);

  var decodJSON = JSON.decode(await http.read(link));

  List<Player> leaders = new List<Player>();
  leaders.add(new Player(decodJSON["league"]["standard"]["ppg"][0]["personId"],
      teamId,
      name: await getPlayerName(decodJSON["league"]["standard"]["ppg"][0]["personId"], db),
      points: decodJSON["league"]["standard"]["ppg"][0]["value"]));
  leaders.add(new Player(decodJSON["league"]["standard"]["trpg"][0]["personId"],
      teamId,
      name: await getPlayerName(decodJSON["league"]["standard"]["trpg"][0]["personId"], db),
      rebounds: decodJSON["league"]["standard"]["trpg"][0]["value"]));
  leaders.add(new Player(decodJSON["league"]["standard"]["apg"][0]["personId"],
      teamId,
      name: await getPlayerName(decodJSON["league"]["standard"]["apg"][0]["personId"], db),
      assist: decodJSON["league"]["standard"]["apg"][0]["value"]));
  return leaders;
}

class Player
{
  String _name, _teamId, _id;
  String _points, _assist, _rebounds;
  var profilePic;

  Player(this._id, this._teamId, {points, assist, rebounds, name})
  : this._points = points,
  this._assist = assist,
  this._rebounds = rebounds,
  this._name = name;

  get id => _id;
  get rebounds => _rebounds;
  get assist => _assist;
  get points => _points;
  get teamId => _teamId;
  String get sName => _name;

  set name(String value) {
    _name = value;
  }

  static getImage(String playerId) async
  {
    var url = "https://ak-static.cms.nba.com/wp-content/uploads/headshots/nba/latest/260x190/$playerId.png";
    return await (http.readBytes(url));
  }

  @override
  String toString() {
    return 'Player{_name: $sName}';
  }
}