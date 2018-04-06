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
  List<String> statLegend;

  MatchPageState() {
    statLegend = [
      "PLAYER",
      "POS ",
      "MIN ",
      "PTS ",
      "REB ",
      "AST ",
      "STL ",
      "BLK ",
      "TO  ",
      "PF  ",
      "OREB",
      "DREB",
      "FGM ",
      "FGA ",
      "FGP ",
      "3PM ",
      "3PA ",
      "3PP ",
      "FTM ",
      "FTA ",
      "FTP ",
      "+/- "
    ];
  }

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
                        return getWidgetFromStats(stats);
                      }
                    })
                : getWidgetFromStats(stats)));
  }

  Widget getWidgetFromStats(Dictionary stats) {
    return new TabBarView(children: <Widget>[
      teamStats(stats.getValue(widget.game.visitor.id)),
      teamStats(stats.getValue(widget.game.home.id))
    ]);
  }

  Widget teamStats(List<PlayerStats> players) {
    TextStyle defaultStyle = new TextStyle(
        fontSize: 17.0, fontFamily: 'Signika', color: Colors.white);
    return new Container(
      child: new SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: new SizedBox(
          width: 1200.0,
          child: new ListView(
            children: <Widget>[
              new Row(
                children: statLegend
                    .map((stat) => new Column(
                            children: <Widget>[
                          new Container(
                              child: new Text(stat, style: defaultStyle),
                              padding: new EdgeInsets.only(top: 5.0))
                        ]..addAll(players
                                .map((player) =>
                                    getStatValue(stat, player, defaultStyle))
                                .toList())))
                    .toList(),
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              )
            ],
          ),
        ),
      ),
      color: Colors.black87,
    );
  }

  Widget getStatValue(String stat, PlayerStats player, TextStyle style) {
    String value;

    switch (stat.toUpperCase().replaceAll(" ", "")) {
      case "PTS":
        value = player.points;
        break;
      case "REB":
        value = player.rebounds;
        break;
      case "AST":
        value = player.assists;
        break;
      case "TO":
        value = player.turnovers;
        break;
      case "OREB":
        value = player.offReb;
        break;
      case "DREB":
        value = player.defReb;
        break;
      case "BLK":
        value = player.blocks;
        break;
      case "STL":
        value = player.steals;
        break;
      case "PF":
        value = player.pFouls;
        break;
      case "MIN":
        value = player.min;
        break;
      case "+/-":
        value = player.plusMinus;
        break;
      case "FGM":
        value = player.fgm;
        break;
      case "FGA":
        value = player.fga;
        break;
      case "FGP":
        value = player.fgp;
        break;
      case "3PM":
        value = player.tpm;
        break;
      case "3PA":
        value = player.tpa;
        break;
      case "3PP":
        value = player.tpp;
        break;
      case "FTM":
        value = player.ftm;
        break;
      case "FTA":
        value = player.fta;
        break;
      case "FTP":
        value = player.ftp;
        break;
      case "POS":
        value = player.pos;
        break;
      case "PLAYER":
        return new Container(
          child: new Stack(
            children: <Widget>[
              new Positioned(
                child: new Container(
                    child: new CircleAvatar(
                      child: player.image,
                      radius: 20.0,
                      backgroundColor: new Color.fromRGBO(255, 255, 255, 0.5),
                    ),
                    height: 40.0,
                    width: 40.0),
              ),
              new Positioned(
                  child: new Text(player.abbName, style: style),
                  left: 50.0,
                  top: 10.0)
            ],
          ),
          width: 170.0,
        );
      default:
        value = "ERR";
        break;
    }

    return new Container(
      child: new Text(([null, ""].contains(value)) ? " " : value, style: style),
      padding: new EdgeInsets.symmetric(vertical: 9.5),
    );
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
