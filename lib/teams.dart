import 'dart:convert';
import 'games.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dictionary.dart';

Future<List<List<Team>>> setStandingsFromDB(String response) async
{
  Directory current = await getApplicationDocumentsDirectory();
  Database db = await openDatabase("${current.path}/db/snba.db");
  Dictionary teamId = new Dictionary();

  List<List<Team>> standingList = new List<List<Team>>();
  var standings = JSON.decode(response)["league"]["standard"]["conference"];
  var conference = standings["east"];

  for (int i in inRange(2)) {
    int index = 1;
    List<Team> temporary = new List<Team>();
    for (int j in inRange(15)) {
      Map currentTeam = await getTeamFromId(conference[j]["teamId"], db);
      teamId.add(conference[j]["teamId"], currentTeam["full_name"]);
      temporary.add(new Team(conference[j]["teamId"], position: index.toString(), name: currentTeam["full_name"],
          tricode: currentTeam["tricode"], conference: currentTeam["conf_name"],
          clinched: conference[j]["clinchedPlayoffsCodeV2"],
          win: conference[j]["win"], loss: conference[j]["loss"], gb: conference[j]["gamesBehind"]));
      index++;
    }
    conference = standings["west"];
    standingList.add(temporary);
  }

  db.close();
  Team.teamIdNames = teamId;

  return standingList;
}

class ScoreboardTeam
{
  static int _getScore(String score)
  {
    if(score.isEmpty)
      return 0;
    return int.parse(score);
  }

  String _tricode;
  int _win, _loss;
  String _score;
  String _id;

  ScoreboardTeam(this._id, tricode, win, loss, score)
  {
    _tricode = tricode;
    _win = int.parse(win);
    _loss = int.parse(loss);
    _score = _getScore(score).toString();
  }

  String get tricode => _tricode;
  int get win => _win;
  get loss => _loss;
  String get score => _score;
  setScore (String score) { _score = score; }
  String get id => _id;

  @override
  String toString() {
    return '{ tricode: $_tricode, id: $_id,  win: $_win,  loss: $_loss,  score: $_score }';
  }
}

class Team
{
  Team(this._id,
      {String win, String loss, String position, String tricode, String conference,
      String clinched, String name, String gb})
      : _win = win,
        _loss = loss,
        _position = position,
        _tricode = tricode,
        _conference = conference,
        _clinched = (clinched != null) ? clinched : "",
        _fullName = name,
        _gb = gb;

  String _position, _id, _fullName, _tricode, _conference, _win, _loss;
  String _clinched, _gb;
  static Dictionary<String,String> teamIdNames;

  String get position => _position;
  String get id => _id;
  String get name => _fullName;
  String get tricode => _tricode;
  String get conference => _conference;
  String get winLoss => _win + "-" + _loss + "  " +
      (double.parse(_win)/(double.parse(_loss)+double.parse(_win))).toStringAsPrecision(3);
  String get clinchedChar => _clinched;
  String get gb => _gb;

  @override
  String toString() {
    return 'team{_id: $_id, _fullName: $_fullName, _tricode: $_tricode, _conference: $_conference}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Team &&
              runtimeType == other.runtimeType &&
              _id == other._id;

  @override
  int get hashCode => _id.hashCode;
}

Future<Map> getTeamFromId(String id, Database db) async {
  List<Map> team = await db.rawQuery(
      "SELECT * FROM team WHERE team_id=$id");
  return team.first;
}