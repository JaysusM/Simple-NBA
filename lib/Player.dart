import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'Games.dart';
import 'package:flutter/material.dart' show Widget;

Future<List<Player>> loadLeaders(String gameId, int gameDate) async {
  String url = "http://data.nba.net/prod/v1/$gameDate/${gameId}_boxscore.json";
  Directory currentDir = await getApplicationDocumentsDirectory();
  Database db = await openDatabase("${currentDir.path}/db/snba.db");
  var decodJSON = JSON.decode(await http.read(url))["stats"];
  List<Player> leaders = new List<Player>();
  leaders.add(new Player(decodJSON["hTeam"]["leaders"]["points"]["players"][0]["personId"],
      decodJSON["hTeam"]["teamId"],
      name: await getPlayerNameFromId(decodJSON["hTeam"]["leaders"]["points"]["players"][0]["personId"], db),
      points: decodJSON["hTeam"]["leaders"]["points"]["value"]));
  leaders.add(new Player(decodJSON["hTeam"]["leaders"]["rebounds"]["players"][0]["personId"],
      decodJSON["hTeam"]["teamId"],
      name: await getPlayerNameFromId(decodJSON["hTeam"]["leaders"]["rebounds"]["players"][0]["personId"], db),
      rebounds: decodJSON["hTeam"]["leaders"]["rebounds"]["value"]));
  leaders.add(new Player(decodJSON["hTeam"]["leaders"]["assists"]["players"][0]["personId"],
      decodJSON["hTeam"]["teamId"],
      name: await getPlayerNameFromId(decodJSON["hTeam"]["leaders"]["assists"]["players"][0]["personId"], db),
      assist: decodJSON["hTeam"]["leaders"]["assists"]["value"]));
  leaders.add(new Player(decodJSON["vTeam"]["leaders"]["points"]["players"][0]["personId"],
      decodJSON["vTeam"]["teamId"],
      name: await getPlayerNameFromId(decodJSON["vTeam"]["leaders"]["points"]["players"][0]["personId"], db),
      points: decodJSON["vTeam"]["leaders"]["points"]["value"]));
  leaders.add(new Player(decodJSON["vTeam"]["leaders"]["rebounds"]["players"][0]["personId"],
      decodJSON["vTeam"]["teamId"],
      name: await getPlayerNameFromId(decodJSON["vTeam"]["leaders"]["rebounds"]["players"][0]["personId"], db),
      rebounds: decodJSON["vTeam"]["leaders"]["rebounds"]["value"]));
  leaders.add(new Player(decodJSON["vTeam"]["leaders"]["assists"]["players"][0]["personId"],
      decodJSON["vTeam"]["teamId"],
      name: await getPlayerNameFromId(decodJSON["vTeam"]["leaders"]["assists"]["players"][0]["personId"], db),
      assist: decodJSON["vTeam"]["leaders"]["assists"]["value"]));
  db.close();
  return leaders;
}

Future<String> getPlayerNameFromId(String playerId, Database db) async {
  String playerName;
  try {
    playerName = (await db.rawQuery("SELECT lastName FROM players WHERE personId = $playerId")).first["lastName"];
  } catch (exception) {
    playerName = " - ";
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
      name: await getPlayerNameFromId(decodJSON["league"]["standard"]["ppg"][0]["personId"], db),
      points: decodJSON["league"]["standard"]["ppg"][0]["value"]));
  leaders.add(new Player(decodJSON["league"]["standard"]["trpg"][0]["personId"],
      teamId,
      name: await getPlayerNameFromId(decodJSON["league"]["standard"]["trpg"][0]["personId"], db),
      rebounds: decodJSON["league"]["standard"]["trpg"][0]["value"]));
  leaders.add(new Player(decodJSON["league"]["standard"]["apg"][0]["personId"],
      teamId,
      name: await getPlayerNameFromId(decodJSON["league"]["standard"]["apg"][0]["personId"], db),
      assist: decodJSON["league"]["standard"]["apg"][0]["value"]));

  return leaders;
}

class Player
{
  String _name, _teamId, _id;
  String _points, _assist, _rebounds;

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
  String get name => _name;

  set name(String value) {
    _name = value;
  }

  static getImage(String playerId)
  {
    return "https://ak-static.cms.nba.com/wp-content/uploads/headshots/nba/latest/260x190/$playerId.png";
  }

  @override
  String toString() {
    return 'Player{_name: $name}';
  }
}

class PlayerStats extends Player {
  PlayerStats(String name, String id, String teamId, this._isOnCourt, String points, this._pos, this._min, this._fgm,
      this._fga, this._fgp, this._ftm, this._ftp, this._tpm, this._tpa,
      this._tpp, this._offReb, this._defReb, String rebounds, String assists,
      this._pFouls, this._steals, this._turnovers, this._blocks,
      this._plusMinus) : super(id, teamId, name: name, points: points, assist: assists, rebounds: rebounds);

  bool _isOnCourt;
  String _pos, _min, _fgm, _fga, _fgp, _ftm, _ftp,
  _tpm, _tpa, _tpp, _offReb, _defReb,
  _pFouls, _steals, _turnovers, _blocks, _plusMinus;
  Widget _image;

  bool get isOnCourt => _isOnCourt;
  get pos => _pos;
  get min => _min;
  get fgm => _fgm;
  get fga => _fga;
  get fgp => _fgp;
  get ftm => _ftm;
  get ftp => _ftp;
  get tpm => _tpm;
  get tpa => _tpa;
  get tpp => _tpp;
  get offReb => _offReb;
  get defReb => _defReb;
  get pFouls => _pFouls;
  get steals => _steals;
  get turnovers => _turnovers;
  get blocks => _blocks;
  get plusMinus => _plusMinus;
  get image => _image;

  set image(Widget value) {
    this._image = value;
  }
}