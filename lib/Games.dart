import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

//Return decoded JSON from url web into class <game>
Future<String> _loadData(String url) async { return (await (http.read(url))); }

Future loadData() {
  var url = "http://data.nba.net/10s/prod/v1/20180205/scoreboard.json";
  return game.setGames(_loadData(url));
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
          new team(decodGame["vTeam"]["triCode"],
              decodGame["vTeam"]["win"],
              decodGame["vTeam"]["loss"],
              decodGame["vTeam"]["score"]),
          new team(decodGame["hTeam"]["triCode"],
              decodGame["hTeam"]["win"],
              decodGame["hTeam"]["loss"],
              decodGame["hTeam"]["score"])));
    }

    return await games;
  }

  String _city, _arena;
  //DateTime _date;
  team home, visitor;

  game(this._city, this._arena,
      //this._date,
      this.home, this.visitor);

  //DateTime get date => _date;

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

  team(tricode, win,
      loss, score)
    : _tricode = tricode,
      _win = int.parse(win),
      _loss = int.parse(loss),
      _score = _getScore(score);

  String get tricode => _tricode;

  int get win => _win;

  get loss => _loss;

  int get score => _score;

  set score(int value) {
    _score = value;
  }

  @override
  String toString() {
    return '{ tricode: $_tricode,  win: $_win,  loss: $_loss,  score: $_score}';
  }


}