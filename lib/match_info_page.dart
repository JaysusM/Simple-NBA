import 'package:flutter/material.dart';
import 'games.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'teams.dart';
import 'dictionary.dart';
import 'player.dart';
import 'dart:convert';
import 'loading_animation.dart';
import 'package:path_provider/path_provider.dart';

class MatchPage extends StatefulWidget {
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

//TODO Use nicknames instead
    homeLastName = homeTeam.name.substring(homeTeam.name.lastIndexOf(" ") + 1);
    awayLastName = awayTeam.name.substring(awayTeam.name.lastIndexOf(" ") + 1);
  }

  String getTeamNameFromId(String id, String defaultValue) {
    String name = Team.teamIdNames.getValue(id);
    return (name == null) ? defaultValue : name;
  }

  @override
  State createState() => new MatchPageState();
}

class MatchPageState extends State<MatchPage> {
  Dictionary stats;
  Timer timer;


  @override
  void initState() {
    timer = new Timer.periodic(new Duration(seconds: 20), (timer) async {
      Dictionary newContent = await loadMatchStats(widget.game);
      this.setState(() {
        stats = newContent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,
        child: new Scaffold(
            appBar: new AppBar(
                leading: new Row(
                  children: <Widget>[
                    new IconButton(
                        icon: new Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  ],
                ),
                title: new TabBar(tabs: <Tab>[
                  new Tab(text: widget.awayLastName.toUpperCase()),
                  new Tab(text: widget.homeLastName.toUpperCase())
                ]),
                actions: <Widget>[
                  new IconButton(
                      icon: new Icon(Icons.refresh),
                      onPressed: () async {
                        var newContent = await loadMatchStats(widget.game);
                        this.setState(() {
                          stats = newContent;
                        });
                      })
                ],
                flexibleSpace:
                    new Image.asset("assets/header.jpg", fit: BoxFit.fitWidth)),
            body: (stats == null)
                ? new FutureBuilder(
                    future: loadMatchStats(widget.game),
                    builder: (BuildContext context, AsyncSnapshot response) {
                      if (response.hasError) {
                        return new Container();
                      } else if (response.connectionState ==
                          ConnectionState.waiting) {
                        return new loadingAnimation();
                      } else {
                        stats = response.data;
                        return getWidgetFromStats(stats, false);
                      }
                    })
                : getWidgetFromStats(stats, true)));
  }

  Widget getWidgetFromStats(Dictionary stats, bool showSnackbar) {
    return new TabBarView(children: <Widget>[
      new ListView(
        children: stats
            .getValue(widget.game.visitor.id)
            .map((player) => playerCard(player, context))
            .toList(),
      ),
      new ListView(
        children: stats
            .getValue(widget.game.home.id)
            .map((player) => playerCard(player, context))
            .toList(),
      )
    ]);
  }

  Widget playerCard(PlayerStats player, BuildContext context) {
    TextStyle defaultStyle = new TextStyle(fontFamily: "Overpass", fontSize: 20.0);
    return new Container(
        child: new Stack(children: <Widget>[
            (player.isOnCourt) ? new Positioned(
            child: new CircleAvatar(
              backgroundColor: Colors.red,
              radius: 5.0,
            ),
            top: 7.0,
            left: 7.0,
          ) : new Container(),
          new Positioned(
              child: new CircleAvatar(
                child: player.image,
                radius: 42.0,
                backgroundColor: new Color.fromRGBO(200, 200, 200, 0.5),
              ),
              left: 10.0,
              top: 10.0),
          new Positioned(
            child: new Text((player.pos == "")
                ? player.abbName.toUpperCase()
                : "${player.pos} - ${player.abbName.toUpperCase()}", style: defaultStyle),
            left: 100.0,
            top: 10.0,
          ),
          new Positioned(
            child: new Text(
              "Points: ${player.points}",
              style: defaultStyle,
            ),
            left: 120.0,
            top: 45.0,
          ),
          new Positioned(
            child: new Text(
              "Rebounds: ${player.rebounds}",
              style: defaultStyle,
            ),
            left: 120.0,
            top: 65.0,
          ),
          new Positioned(
            child: new Text(
              "Assists: ${player.assists}",
              style: defaultStyle,
            ),
            left: 120.0,
            top: 85.0,
          ),
          new Positioned(
            child: new Text(
              "Minutes: ${player.min}",
              style: defaultStyle,
            ),
            left: 120.0,
            top: 105.0,
          )
        ]),
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.circular(10.0),
            color: Colors.blueAccent),
        height: 150.0,
        width: MediaQuery.of(context).size.width - 20,
        margin: new EdgeInsets.all(10.0));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

Future loadMatchStats(Game game) async {
  Database db = await openDatabase(
      "${(await getApplicationDocumentsDirectory()).path}/db/snba.db");

  String url = "http://data.nba.net/prod/v1/${game.date}/${game
      .id}_boxscore.json";
  String content = await http.read(url);
  List decoder = JSON.decode(content)["stats"]["activePlayers"];
  List<PlayerStats> homePlayers = new List();
  List<PlayerStats> awayPlayers = new List();

  decoder.forEach((player) async {
    if (player["teamId"] == game.home.id) {
      homePlayers.add(getPlayerStatFromMap(player, db)
        ..image = new Image.network(Player.getImage(player["personId"])));
    } else {
      awayPlayers.add(getPlayerStatFromMap(player, db)
        ..image = new Image.network(Player.getImage(player["personId"])));
    }
  });

  Dictionary<String, List<PlayerStats>> playersStats = new Dictionary();
  await Future.wait([
    setNamesInPlayersList(homePlayers, db),
    setNamesInPlayersList(awayPlayers, db)
  ]);
  db.close();
  playersStats.add(game.home.id, homePlayers);
  playersStats.add(game.visitor.id, awayPlayers);
  return playersStats;
}

Future setNamesInPlayersList(List<Player> players, Database db) async {
  await Future.forEach(players, (player) async {
    player.fullName = await getPlayerNameFromId(player.id, db);
  });
}

PlayerStats getPlayerStatFromMap(Map data, Database db) {
  return new PlayerStats(
      null,
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
