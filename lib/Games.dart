import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

//Return decoded JSON from url web into String
Future<String> _loadData(String url) async { return (await (http.read(url))); }

Future loadData() async {
  var prefix = "http://data.nba.net/10s/";
  var today = prefix + "prod/v1/today.json";
  var decod = JSON.decode(await _loadData(today));
  var url = decod["links"]["todayScoreboard"];
  return game.setGames(_loadData(prefix+url));
}

Future loadTeams() async {
  var url = "http://data.nba.net/prod/v1/2017/teams.json";
  return team.setTeams(await _loadData(url));
}

Future loadStandings(List<team> teams) async {
  var url = "http://data.nba.net/prod/v1/current/standings_conference.json";
  return team.setStandings(await _loadData(url), teams);
}

Iterable<int> inRange(int supInf) sync* {
for (int i = 0; i < supInf; i++)
yield i;
}

class game
{

  static String setCurrentStartTime(String time)
  {
    var startTime = DateTime.parse(time);
    var offset = new DateTime.now().timeZoneOffset;
    startTime = startTime.add(offset);
    var hour = startTime.toString().substring(11, 16);
    if(int.parse(hour.substring(0,2)) > 12)
      return (int.parse(hour.substring(0,2))-12).toString()+hour.substring(3)+" PM";
    else
      return hour+" AM";
  }

  static Future<List<game>> setGames(Future<String> s) async
  {
    List<game> games = new List<game>();
    var decod = JSON.decode(await s);

    for(int i in inRange(decod["numGames"]))
    {
      var decodGame = decod["games"][i];
      games.add(new game(
          decodGame["arena"]["city"],
          decodGame["arena"]["name"],
          decodGame["isGameActivated"],
          decodGame["period"]["current"].toString(),
          decodGame["clock"],
          decodGame["startTimeUTC"],
          new scoreboardTeam(
              decodGame["vTeam"]["teamId"],
              decodGame["vTeam"]["triCode"],
              decodGame["vTeam"]["win"],
              decodGame["vTeam"]["loss"],
              decodGame["vTeam"]["score"]),
          new scoreboardTeam(
              decodGame["hTeam"]["teamId"],
              decodGame["hTeam"]["triCode"],
              decodGame["hTeam"]["win"],
              decodGame["hTeam"]["loss"],
              decodGame["hTeam"]["score"],
              )));
    }

    return await games;
  }

  String _city, _arena;
  String _hour;
  scoreboardTeam visitor, home;
  bool _active;
  String _period;
  String _clock;

  game(this._city, this._arena,
      this._active, String period,
      String clock,
      String date,
      this.visitor, this.home)
  {
    this._hour = setCurrentStartTime(date);

    if(!_active && int.parse(period) >= 4)
      _clock = "FINAL";
    else if(!_active)
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

  @override
  String toString() {
    return "{ City: " + _city
        + ", home: " + visitor.toString() + ", visitor: " + home.toString() + "}";
  }


}

class scoreboardTeam
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

  scoreboardTeam(id, tricode, win, loss, score)
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

class team
{
  team(this._id, this._fullName, this._tricode, this._conference);

  String _id, _fullName, _tricode, _conference, _win, _loss;

  String get id => _id;
  String get name => _fullName;
  String get tricode => _tricode;
  String get conference => _conference;
  String get winLoss => _win + " - " + _loss + "   %" +
      (double.parse(_win)/(double.parse(_loss)+double.parse(_win))).toStringAsPrecision(3);

  void setWinLoss(String win, String loss)
  {
    _win = win;
    _loss = loss;
  }

  static List<team> setTeams(String response)
  {
    var teams = JSON.decode(response)["league"]["standard"];
    List<team> teamList = new List<team>();

    for(int i in inRange(41))
    {
      var currentTeam = teams[i];
      if(currentTeam["isNBAFranchise"])
      {
        teamList.add(new team(currentTeam["teamId"], currentTeam["fullName"],
            currentTeam["tricode"], currentTeam["confName"]));
      }
    }
    return teamList;
  }

  /*
  TODO This will have lower complexity using a bdd
  TODO wait until SQFLITE reach version 1.0 (or at least reach a stable version) or create your own
  TODO MySQL/Oracle hosted in the cloud
  */
  static List<List<team>> setStandings(String response, List<team> teams)
  {
    List<List<team>> standingList = new List<List<team>>();
    var standings = JSON.decode(response)["league"]["standard"]["conference"];
    var conferenceS = standings["east"];
    for(int i in inRange(2))
    {
      List<team> innerList = new List<team>();
      if(i > 0)
        conferenceS = standings["west"];

      for(int j in inRange(15))
      {
        var it = teams.iterator;
        while(it.moveNext())
        {
            team current = it.current;
            if(current.id == conferenceS[j]["teamId"])
            {
              current.setWinLoss(conferenceS[j]["win"], conferenceS[j]["loss"]);
              innerList.add(current);
              break;
            }
        }
      }
      standingList.add(innerList);
    }
    return standingList;
  }

  @override
  String toString() {
    return 'team{_id: $_id, _fullName: $_fullName, _tricode: $_tricode, _conference: $_conference}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is team &&
              runtimeType == other.runtimeType &&
              _id == other._id;
}