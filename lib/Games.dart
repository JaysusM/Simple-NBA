import 'dart:convert';
import 'Data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:simple_nba/Player.dart';

Iterable<int> inRange(int supInf) sync* {
for (int i = 0; i < supInf; i++)
yield i;
}

//TODO set _active with status from api

class Game
{
  String _city, _arena;
  String _hour;
  ScoreboardTeam visitor, home;
  bool _active;
  String _period;
  String _clock;
  int _status;
  List<Player> leaders;

  Game(this._city, this._arena,
      this._status, String period,
      String clock,
      String date,
      this.visitor, this.home)
    {
    this._hour = setCurrentStartTime(date);
    _active = (_status == 2);

    if(_status == 3)
      _clock = "FINAL";
    else if(_status == 1)
      _clock = "--:--";
    else if(clock.isEmpty)
      _clock = "12:00";
    else
      _clock = clock;

    List<String> _formatScores = format(home.score, visitor.score);
    home.setScore(_formatScores[0]);
    visitor.setScore(_formatScores[1]);

    if(int.parse(period) > 4)
      this._period = "OT";
    else
      this._period = period+"Q";
    }

    //Format score to 3 digits - 3 digits (_ _ _ - _ _ _)
    List<String> format(String homeScore, String visitorScore)
    {
      if(homeScore.length < 3)
        return format (homeScore+" ", visitorScore);
      if(visitorScore.length < 3)
        return format (homeScore, " "+visitorScore);

      List<String> scores = new List<String>();
      scores.addAll([homeScore, visitorScore]);
      return scores;
    }

  bool get active => _active;
  String get period => _period;
  String get city => _city;
  get arena => _arena;
  String get clock => _clock;
  String get time => _hour;
  int get status => _status;

  @override
  String toString() {
    return "{ City: " + _city
        + ", home: " + visitor.toString() + ", visitor: " + home.toString() + "}";
  }
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
  Team(this._id, this._fullName, this._tricode, this._conference, {String win, String loss})
  : _win = win,
  _loss = loss;

  String _id, _fullName, _tricode, _conference, _win, _loss;

  String get id => _id;
  String get name => _fullName;
  String get tricode => _tricode;
  String get conference => _conference;
  String get winLoss => _win + " - " + _loss + "      " +
      (double.parse(_win)/(double.parse(_loss)+double.parse(_win))).toStringAsPrecision(3);

  static Future<List<List<Team>>> setStandingsFromDB(String response) async
  {
    Directory current = await getApplicationDocumentsDirectory();
    Database db = await openDatabase("${current.path}/db/team.db");

    List<List<Team>> standingList = new List<List<Team>>();
    var standings = JSON.decode(response)["league"]["standard"]["conference"];
    var conference = standings["east"];

    for (int i in inRange(2)) {
      List<Team> temporary = new List<Team>();
      for (int j in inRange(15)) {
        List<Map> team = await db.rawQuery(
            "SELECT * FROM team where team_id=${conference[j]["teamId"]}");
        Map currentTeam = team.first;
        temporary.add(new Team(currentTeam["teamId"], currentTeam["full_name"],
            currentTeam["tricode"], currentTeam["conf_name"],
            win: conference[j]["win"], loss: conference[j]["loss"]));
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