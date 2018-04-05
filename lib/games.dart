import 'dart:convert';
import 'data.dart';
import 'dart:async';
import 'twitter.dart';
import 'teams.dart';

Iterable<int> inRange(int supInf) sync* {
for (int i = 0; i < supInf; i++)
yield i;
}

Future<List<Game>> setGames(Future<String> content) async {
  List<Game> games = new List<Game>();
  var decod = JSON.decode(await content);

  for (int i in inRange(decod["numGames"])) {
    var decodGame = decod["games"][i];
    games.add(new Game(
        decodGame["gameId"],
        int.parse(decodGame["startDateEastern"]),
        decodGame["arena"]["city"],
        decodGame["arena"]["name"],
        decodGame["statusNum"],
        decodGame["period"]["current"].toString(),
        decodGame["clock"],
        decodGame["startTimeUTC"],
        new ScoreboardTeam(
            decodGame["vTeam"]["teamId"],
            decodGame["vTeam"]["triCode"],
            decodGame["vTeam"]["win"],
            decodGame["vTeam"]["loss"],
            decodGame["vTeam"]["score"]),
        new ScoreboardTeam(
          decodGame["hTeam"]["teamId"],
          decodGame["hTeam"]["triCode"],
          decodGame["hTeam"]["win"],
          decodGame["hTeam"]["loss"],
          decodGame["hTeam"]["score"],
        )));
  }

  return games;
}

class Game
{
  ScoreboardTeam visitor, home;
  bool _active;
  String _city, _arena, _hour, _period, _clock;
  int _status, _date;
  String _id, _homeTwitter, _awayTwitter;

  Game(this._id, this._date, this._city, this._arena,
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
      _clock = "00:00";
    else
      _clock = clock;

    List<String> _formatScores = format(home.score, visitor.score);
    home.setScore(_formatScores[0]);
    visitor.setScore(_formatScores[1]);

    if(int.parse(period) > 4)
      this._period = "OT";
    else
      this._period = period+"Q";

    var twitters = getTwitters(home.id, visitor.id);
    _homeTwitter = twitters[0];
    _awayTwitter = twitters[1];
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
  String get id => _id;
  int get date => _date;
  String get homeTwitter => _homeTwitter;
  String get awayTwitter => _awayTwitter;

  @override
  String toString() {
    return "{ City: " + _city
        + ", home: " + visitor.toString() + ", visitor: " + home.toString() + "}";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Game &&
              runtimeType == other.runtimeType &&
              _id == other._id;

  @override
  int get hashCode => _id.hashCode;

}