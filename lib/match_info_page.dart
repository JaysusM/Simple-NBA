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
    return new Container(
        child: new Stack(children: <Widget>[
          (player.isOnCourt)
              ? new Positioned(
                  child: new CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 5.0,
                  ),
                  top: 7.0,
                  left: 7.0,
                )
              : new Container(),
          new Positioned(
              child: new CircleAvatar(
                child: new Container(
                    child: player.image,
                    padding: new EdgeInsets.only(bottom: 20.0)),
                radius: 42.0,
                backgroundColor: new Color.fromRGBO(200, 200, 200, 0.5),
              ),
              left: 10.0,
              top: 10.0),
          new Positioned(
            child: new Text(
                (player.pos == "")
                    ? player.abbName.toUpperCase()
                    : "${player.pos} - ${player.abbName.toUpperCase()}",
                style: new TextStyle(fontFamily: "SignikaB", fontSize: 20.0)),
            left: 115.0,
            top: 10.0,
          ),
          new Positioned(
            child: statWidget("Pts ", player.points),
            left: 10.0,
            top: 100.0,
          ),
          new Positioned(
            child: statWidget("Blk ", "${player.blocks}"),
            left: 10.0,
            top: 120.0,
          ),
          new Positioned(
            child: statWidget("Stl ", "${player.steals}"),
            left: 80.0,
            top: 120.0,
          ),
          new Positioned(
            child: statWidget("Ast ", player.assists),
            left: 80.0,
            top: 100.0,
          ),
          new Positioned(
            child: drawClock(player.min),
            right: 60.0,
            top: 105.0,
          ),
          new Positioned(
            child:
                reboundsWidget(player.rebounds, player.offReb, player.defReb),
            right: 175.0,
            top: 40.0,
          ),
          new Positioned(
              child: statsCircle("FG", player.fgp, player.fga, player.fgm),
              top: 40.0,
              right: 120.0),
          new Positioned(
              child: statsCircle("3P", player.tpp, player.tpa, player.tpm),
              top: 40.0,
              right: 65.0),
          new Positioned(
              child: statsCircle("FT", player.ftp, player.fta, player.ftm),
              top: 40.0,
              right: 10.0),
        new Positioned(child: new IconButton(icon: new Icon(Icons.add_circle), iconSize: 30.0, onPressed: (){}),
    right: 5.0, top: 97.0)
        ]),
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.circular(10.0),
            color: new Color.fromRGBO(255, 139, 0, 1.0),
            border: new Border.all(color: Colors.black, width: 2.0)),
        height: 150.0,
        width: MediaQuery.of(context).size.width - 20,
        margin: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

Widget reboundsWidget(String rebounds, String offReb, String defReb) {
  if (offReb.length < 2) {
    offReb = " $offReb";
    if (defReb.length < 2) offReb = " $offReb";
  }

  if (rebounds.length < 2) rebounds = " $rebounds";

  return new CircleAvatar(
      child: new CircleAvatar(
        child: new Stack(
          children: <Widget>[
            new Positioned(
                child: new Text("REB",
                    style:
                        new TextStyle(fontFamily: 'SignikaR', fontSize: 10.0)),
                top: 3.0,
                left: 15.0),
            new Positioned(
                child: new Text(rebounds,
                    style:
                        new TextStyle(fontFamily: 'SignikaR', fontSize: 14.0)),
                top: 14.0,
                left: 16.8),
            new Positioned(
                child: new Text("Off",
                    style:
                    new TextStyle(fontFamily: 'SignikaR', fontSize: 6.0)),
                top: 19.0,
                left: 3.8),
            new Positioned(
                child: new Text("Def",
                    style:
                    new TextStyle(fontFamily: 'SignikaR', fontSize: 6.0)),
                top: 19.0,
                right: 3.8),
            new Positioned(
                child: new Text("$offReb  |  $defReb",
                    style:
                        new TextStyle(fontFamily: 'SignikaR', fontSize: 10.0)),
                top: 30.0,
                left: 7.5)
          ],
        ),
        radius: 24.0,
        backgroundColor: new Color.fromRGBO(12, 72, 209, 1.0),
      ),
      radius: 25.4,
      backgroundColor: new Color.fromRGBO(255, 215, 2, 1.0));
}

Widget statWidget(String statName, String stat) {
  return new Text("$statName$stat",
      style: new TextStyle(fontSize: 20.0, fontFamily: 'Signika'));
}

Widget drawClock(String time) {
  return new Row(
    children: <Widget>[
      _clockFragment(time.split(":")[0]),
      new Text(" : ",
          style: new TextStyle(fontSize: 20.0, fontFamily: 'Orbitron')),
      _clockFragment(time.split(":")[1])
    ],
  );
}

Widget _clockFragment(String time) {
  return new Container(
    child: new Stack(
      children: <Widget>[
        new Container(
          color: new Color.fromRGBO(255, 255, 255, 0.20),
          height: 15.0,
          width: 30.0,
        ),
        new Positioned(
            child: new Text((time.length < 2) ? "0$time" : time,
                style: new TextStyle(
                    fontFamily: 'Overpass',
                    fontSize: 17.0,
                    color: Colors.white)),
            top: 5.5,
            left: 3.0)
      ],
    ),
    height: 30.0,
    width: 30.0,
    decoration: new BoxDecoration(
        color: Colors.black,
        border: new Border.all(color: Colors.white70, width: 1.0),
        borderRadius: new BorderRadius.all(new Radius.circular(4.0))),
  );
}

Widget statsCircle(
    String statName, String percent, String attempt, String made) {
  if (made.length < 2) {
    made = " $made";
    if (attempt.length < 2) made = " $made";
  }
  if (percent.length < 4 && percent.contains(".")) percent += "0";

  return new CircleAvatar(
      child: new CircleAvatar(
          child: new Stack(
            children: <Widget>[
              new Positioned(
                  child: new Text(statName,
                      style: new TextStyle(
                          fontFamily: 'SignikaR', fontSize: 10.0)),
                  top: 3.0,
                  left: 18.0),
              new Positioned(
                  child: new Text("%$percent",
                      style: new TextStyle(
                          fontFamily: 'SignikaR', fontSize: 14.0)),
                  top: 14.0,
                  left: 4.5),
              new Positioned(
                  child: new Text("$made / $attempt",
                      style: new TextStyle(
                          fontFamily: 'SignikaR', fontSize: 10.0)),
                  top: 30.0,
                  left: 8.0)
            ],
          ),
          radius: 24.0,
          backgroundColor: new Color.fromRGBO(12, 72, 209, 1.0)),
      radius: 25.4,
      backgroundColor: new Color.fromRGBO(255, 215, 2, 1.0));
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
    if (player["teamId"] == game.home.id)
      homePlayers.add(getPlayerStatFromMap(player, db));
    else
      awayPlayers.add(getPlayerStatFromMap(player, db));
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
  Widget image;

  try {
    image = new Image.network(Player.getImage(data["personId"]));
  } catch (exception) {
    image = new Image.asset("noteam.png");
  }

  return new PlayerStats(
      null,
      image,
      data["personId"],
      data["teamId"],
      data["isOnCourt"],
      data["points"],
      data["pos"],
      data["min"],
      data["fgm"],
      data["fga"],
      data["fgp"],
      data["fta"],
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
