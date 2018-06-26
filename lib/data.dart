import 'teams.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'games.dart';
import 'dart:convert';
import 'bracket.dart';
import 'player.dart';

String setCurrentStartTime(String time) {
  var startTime = DateTime.parse(time);
  var offset = new DateTime.now().timeZoneOffset;
  startTime = startTime.add(offset);
  var hour = startTime.toString().substring(11, 16);
  if (int.parse(hour.substring(0, 2)) > 12)
    return (int.parse(hour.substring(0, 2)) - 12).toString() +
        ":" +
        hour.substring(3) +
        "PM";
  else
    return hour + "AM";
}

String formatDate(DateTime date)
{
  return "${date.year}${numberFormatTwoDigit(date.month.toString())}${numberFormatTwoDigit(date.day.toString())}";
}

String numberFormatTwoDigit(String number)
{
  return (number.startsWith("0") || int.parse(number) > 9) ? number : "0$number";
}

Future<List<Game>> loadGames(DateTime selectedDate) async {
  String url = "http://data.nba.net/prod/v1/${formatDate(selectedDate)}/scoreboard.json";
  return setGames(http.read(url));
}

Future<List<List<Team>>> loadStandings() async {
  var url = "http://data.nba.net/prod/v1/current/standings_conference.json";
  return setStandingsFromDB(await http.read(url));
}

Future<List<Bracket>> loadPlayoffsBrackets() async {
  Map linkDecoder = jsonDecode(await http.read("http://data.nba.net/10s/prod/v1/today.json"));
  String url = linkDecoder["links"]["playoffsBracket"];
  return setPlayoffsBrackets(await http.read("http://data.nba.net$url"));
}

Future<List<Player>> loadAllPlayers() async {
  Map linkDecoder = jsonDecode(await http.read("http://data.nba.net/10s/prod/v1/today.json"));
  String url = linkDecoder["links"]["leagueRosterPlayers"];
  return setAllPlayers(await http.read("http://data.nba.net$url"));
}

Future<dynamic> loadData(DateTime date) async {
  List data = new List();
  data.insert(0, await loadGames(date));
  data.insert(1, await loadStandings());
  data.insert(2, await loadPlayoffsBrackets());
  return data;
}

Future<dynamic> loadDataNoCalendar() async {
  List data = new List();
  data.insert(0, await loadStandings());
  data.insert(1, await loadPlayoffsBrackets());
  return data;
}