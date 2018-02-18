import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'Games.dart';

//Return decoded JSON from url web into String
Future<String> _loadData(String url) async {
  return (await (http.read(url)));
}

Future loadGames() async {
  var prefix = "http://data.nba.net/10s/";
  var today = prefix + "prod/v1/today.json";
  var decod = JSON.decode(await _loadData(today));
  var url = decod["links"]["todayScoreboard"];
  return setGames(_loadData(prefix + url));
}

Future loadTeams() async {
  var url = "http://data.nba.net/prod/v1/2017/teams.json";
  return team.setTeams(await _loadData(url));
}

Future loadStandings(Future<List<team>> teams) async {
  var url = "http://data.nba.net/prod/v1/current/standings_conference.json";
  return team.setStandings(await _loadData(url), await teams);
}

String setCurrentStartTime(String time) {
  var startTime = DateTime.parse(time);
  var offset = new DateTime.now().timeZoneOffset;
  startTime = startTime.add(offset);
  var hour = startTime.toString().substring(11, 16);
  if (int.parse(hour.substring(0, 2)) > 12)
    return (int.parse(hour.substring(0, 2)) - 12).toString() +
        ":" +
        hour.substring(3) +
        " PM";
  else
    return hour + " AM";
}

Future<List<game>> setGames(Future<String> s) async {
  List<game> games = new List<game>();
  var decod = JSON.decode(await s);

  for (int i in inRange(decod["numGames"])) {
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
