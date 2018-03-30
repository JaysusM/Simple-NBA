import 'Teams.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'Games.dart';
import 'Player.dart';

//Read url and return its content
Future<String> _loadData(String url) async {
  return (await (http.read(url)));
}

Future loadGames(DateTime selectedDate) async {
  String url = "http://data.nba.net/prod/v1/${formatDate(selectedDate)}/scoreboard.json";
  return setGames(_loadData(url));
}

String formatDate(DateTime date)
{
  return "${date.year}${numberFormatTwoDigit(date.month.toString())}${numberFormatTwoDigit(date.day.toString())}";
}

String numberFormatTwoDigit(String number)
{
  return (number.startsWith("0") || int.parse(number) > 9) ? number : "0$number";
}

Future loadStandings() async {
  var url = "http://data.nba.net/prod/v1/current/standings_conference.json";
  return Team.setStandingsFromDB(await _loadData(url));
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

Future loadData(DateTime date) async {
  List data = new List();
  data.insert(0, await loadGames(date));
  data.insert(1, await loadStandings());
  return data;
}