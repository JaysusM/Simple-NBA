import 'dart:convert';
import 'Games.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

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
  int _id;

  ScoreboardTeam(id, tricode, win, loss, score)
  {
    _tricode = tricode;
    _win = int.parse(win);
    _loss = int.parse(loss);
    _score = _getScore(score).toString();
    _id = int.parse(id);
  }

  String get tricode => _tricode;
  int get win => _win;
  get loss => _loss;
  String get score => _score;
  setScore (String score) { _score = score; }
  int get id => _id;

  @override
  String toString() {
    return '{ tricode: $_tricode, id: $_id,  win: $_win,  loss: $_loss,  score: $_score}';
  }
}

class Team
{
  Team(this._position, this._id, this._fullName, this._tricode, this._conference, {String win, String loss})
      : _win = win,
        _loss = loss;

  String _position, _id, _fullName, _tricode, _conference, _win, _loss;

  String get position => _position;
  String get id => _id;
  String get name => _fullName;
  String get tricode => _tricode;
  String get conference => _conference;
  String get winLoss => _win + " - " + _loss + "      " +
      (double.parse(_win)/(double.parse(_loss)+double.parse(_win))).toStringAsPrecision(3);

  static Future<List<List<Team>>> setStandingsFromDB(String response) async
  {
    Directory current = await getApplicationDocumentsDirectory();
    Database db = await openDatabase("${current.path}/db/snba.db");

    List<List<Team>> standingList = new List<List<Team>>();
    var standings = JSON.decode(response)["league"]["standard"]["conference"];
    var conference = standings["east"];

    for (int i in inRange(2)) {
      int index = 1;
      List<Team> temporary = new List<Team>();
      for (int j in inRange(15)) {
        List<Map> team = await db.rawQuery(
            "SELECT * FROM team WHERE team_id=${conference[j]["teamId"]}");
        Map currentTeam = team.first;
        temporary.add(new Team(index.toString(), currentTeam["teamId"], currentTeam["full_name"],
            currentTeam["tricode"], currentTeam["conf_name"],
            win: conference[j]["win"], loss: conference[j]["loss"]));
        index++;
      }
      conference = standings["west"];
      standingList.add(temporary);
    }

    db.close();
    return standingList;
  }

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