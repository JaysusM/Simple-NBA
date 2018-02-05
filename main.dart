import 'dart:convert';
import 'dart:io';
import 'Games.dart';

Iterable<int> inRange(int supInf) sync* {
  for (int i = 0; i < supInf; i++)
    yield i;
}

List<game> setGames(String s)
{
  List<game> games = new List<game>();
  var decod = JSON.decode(s);

  for(int i in inRange(decod["numGames"]))
    {
      var decodGame = decod["games"][i];
      games.add(new game(
        decodGame["arena"]["city"],
        decodGame["arena"]["name"],
        new Team(decodGame["vTeam"]["triCode"],
        decodGame["vTeam"]["win"],
        decodGame["vTeam"]["loss"],
        decodGame["vTeam"]["score"]),
        new Team(decodGame["hTeam"]["triCode"],
        decodGame["hTeam"]["win"],
        decodGame["hTeam"]["loss"],
        decodGame["hTeam"]["score"])));
    }

    return games;
}


void main() {
  var json = new File("today.json")
          .readAsStringSync();
  List<game> games = setGames(json);

  games.forEach((game) => print(game));
}