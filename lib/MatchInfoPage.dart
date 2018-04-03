import 'package:flutter/material.dart';
import 'Games.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'Teams.dart';
import 'Dictionary.dart';
import 'Player.dart';
import 'dart:convert';
import 'LoadingAnimation.dart';

class MatchPage extends StatelessWidget {
  Game game;
  Team homeTeam, awayTeam;
  String homeLastName, awayLastName;

  MatchPage(this.game) {
    homeTeam = new Team(game.home.id,
        name: getTeamNameFromId(game.home.id, game.home.tricode),
        tricode: game.home.tricode);

    awayTeam = new Team(game.visitor.id,
        name: getTeamNameFromId(game.visitor.id, game.visitor.tricode),
        tricode: game.visitor.tricode);

    homeLastName = homeTeam.name.substring(homeTeam.name.lastIndexOf(" ") + 1);
    awayLastName = awayTeam.name.substring(awayTeam.name.lastIndexOf(" ") + 1);
  }

  String getTeamNameFromId(String id, String defaultValue) {
    String name = Team.teamIdNames.getValue(id);
    return (name == null) ? defaultValue : name;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Center(
            child: new Container(
          child: new Text("$awayLastName @ $homeLastName"),
          padding: new EdgeInsets.only(right: 40.0),
        )),
        flexibleSpace: new Container(
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage("assets/header.jpg"),
                  fit: BoxFit.fitWidth)),
        ),
      ),
      body: new FutureBuilder(
          future: loadMatchStats(game),
          builder: (BuildContext context, AsyncSnapshot response) {
            if (response.hasError) {
              return new Container();
            } else if (response.connectionState == ConnectionState.waiting) {
              return new loadingAnimation();
            } else {
              print(response.data.getValue(game.home.id));
              return playerCard(
                  response.data.getValue(game.home.id)[0], context);
            }
          }),
    );
  }

  Widget playerCard(PlayerStats player, BuildContext context) {
    return new Container(
        child: new Stack(children: <Widget>[
          new Positioned(
              child: new CircleAvatar(
            child: player.image,
                radius: 50.0,
                backgroundColor: new Color.fromRGBO(200, 200, 200, 0.5),
          ),
          left: 30.0,
          top: 25.0),
          new Positioned(
              child: new Text(player.id, style: new TextStyle(fontFamily: "Mono", fontSize: 20.0)),
              left: 200.0,
              top: 25.0,
          )
        ]),
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.circular(10.0),
            color: Colors.blueAccent),
        height: 150.0,
        width: MediaQuery.of(context).size.width - 20,
        margin: new EdgeInsets.all(10.0));
  }

  Future loadMatchStats(Game game) async {
    String url = "http://data.nba.net/prod/v1/${game.date}/${game
        .id}_boxscore.json";
    String content = await http.read(url);
    List decoder = JSON.decode(content)["stats"]["activePlayers"];
    List<PlayerStats> homePlayers = new List();
    List<PlayerStats> awayPlayers = new List();

    Database db = await openDatabase("${(await getApplicationDocumentsDirectory()).path}/db/snba.db");

    decoder.forEach((player) async {
      if (player["teamId"] == game.home.id) {
        homePlayers.add(await getPlayerStatFromMap(player, db)
          ..image = new Image.network(Player.getImage(player["personId"])));
      } else {
        awayPlayers.add(await getPlayerStatFromMap(player, db)
          ..image = new Image.network(Player.getImage(player["personId"])));
      }
    });

    Dictionary<String, List<PlayerStats>> playersStats = new Dictionary();
    playersStats.add(game.home.id, homePlayers);
    playersStats.add(game.visitor.id, awayPlayers);
    db.close();
    return playersStats;
  }

  Future<PlayerStats> getPlayerStatFromMap(Map data, Database db) async {
    return new PlayerStats(
        await getPlayerNameFromId(data["personId"], db),
        data["personId"],
        data["teamId"],
        data["isOnCourt"],
        data["points"],
        data["pos"],
        data["min"],
        data["fgm"],
        data["fga"],
        data["fgp"],
        data["ftm"],
        data["ftp"],
        data["tpm"],
        data["tpa"],
        data["tpp"],
        data["offReb"],
        data["defReb"],
        data["totReb"],
        data["assists"],
        data["pFouls"],
        data["steals"],
        data["turnovers"],
        data["blocks"],
        data["plusMinus"]);
  }
}
