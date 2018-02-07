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

class game
{

  static Iterable<int> _inRange(int supInf) sync* {
    for (int i = 0; i < supInf; i++)
      yield i;
  }

  static Future<List<game>> setGames(Future<String> s) async
  {
    List<game> games = new List<game>();
    var decod = JSON.decode(await s);

    for(int i in _inRange(decod["numGames"]))
    {
      var decodGame = decod["games"][i];
      games.add(new game(
          decodGame["arena"]["city"],
          decodGame["arena"]["name"],
          decodGame["isGameActivated"],
          decodGame["period"]["current"],
          new team(decodGame["vTeam"]["triCode"],
              decodGame["vTeam"]["win"],
              decodGame["vTeam"]["loss"],
              decodGame["vTeam"]["score"],
              decodGame["vTeam"]["teamId"]),
          new team(decodGame["hTeam"]["triCode"],
              decodGame["hTeam"]["win"],
              decodGame["hTeam"]["loss"],
              decodGame["hTeam"]["score"],
              decodGame["hTeam"]["teamId"])));
    }

    return await games;
  }

  String _city, _arena;
  //DateTime _date;
  team home, visitor;
  bool _active;
  int _period;

  game(this._city, this._arena,
      this._active, this._period,
      //this._date,
      this.home, this.visitor);

  //DateTime get date => _date;

  bool get active => _active;

  int get period => _period;

  String get city => _city;

  get arena => _arena;

  @override
  String toString() {
    return "{ City: " + _city //+ ", date: " + _date.toString()
        + ", home: " + home.toString() + ", visitor: " + visitor.toString() + "}";
  }


}

class team
{
  static int _getScore(String score)
  {
    if(score.isEmpty)
      return 0;
    return int.parse(score);
  }

  String _tricode;
  int _win, _loss;
  int _score;
  int _id;

  team(tricode, win,
      loss, score, id)
    : _tricode = tricode,
      _win = int.parse(win),
      _loss = int.parse(loss),
      _score = _getScore(score),
      _id = int.parse(id);

  String get tricode => _tricode;

  int get win => _win;

  get loss => _loss;

  int get score => _score;

  int get id => _id;

  @override
  String toString() {
    return '{ tricode: $_tricode, id: $_id,  win: $_win,  loss: $_loss,  score: $_score}';
  }


}