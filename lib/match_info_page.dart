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

    if (homeLastName.toUpperCase() == 'TIMBERWOLVES') homeLastName = 'WOLVES';
    if (awayLastName.toUpperCase() == 'TIMBERWOLVES') awayLastName = 'WOLVES';
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
                  new Tab(
                      child: new Column(
                    children: <Widget>[
                      new Text("${widget.awayLastName.toUpperCase()}",
                          style: new TextStyle(
                              fontFamily: 'Signika', fontSize: 16.0)),
                      new Text("${widget.game.visitor.score}",
                          style: new TextStyle(
                              fontFamily: 'Signika', fontSize: 16.0))
                    ],
                  )),
                  new Tab(
                      child: new Column(
                    children: <Widget>[
                      new Text("${widget.homeLastName.toUpperCase()}",
                          style: new TextStyle(
                              fontFamily: 'Signika', fontSize: 16.0)),
                      new Text("${widget.game.home.score}",
                          style: new TextStyle(
                              fontFamily: 'Signika', fontSize: 16.0))
                    ],
                  ))
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
                flexibleSpace: new Container(
                    color: new Color.fromARGB(0xff, 0x18, 0x2b, 0x4a))),
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
    TextStyle style = new TextStyle(
        fontSize: 17.0, fontFamily: 'Overpass', color: Colors.white);
    ScrollController statsController = new ScrollController();
    ScrollController playersController = new ScrollController();

    statsController.addListener(() {
      playersController.animateTo(statsController.offset,
          duration: new Duration(microseconds: 1),
          curve: Curves.linear);
    });

    playersController.addListener(() {
      statsController.animateTo(playersController.offset,
          duration: new Duration(microseconds: 1),
          curve: Curves.linear);
    });

    return new Stack(children: <Widget>[
      new Positioned(
        child: new Container(
          child: new SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: new SizedBox(
              width: 1135.0,
              child: new Stack(
                children: <Widget>[
                  new Container(
                    child: new ListView(
                      children: <Widget>[
                        new Row(children: getStatRow(players, style)),
                      ],
                      controller: statsController,
                    ),
                    margin: new EdgeInsets.only(top: 36.0),
                  ),
                  new Positioned(
                      child: _getStatLegendRow("POS", style), left: 0.0),
                  new Positioned(
                      child: _getStatLegendRow("PTS", style), left: 49.0),
                  new Positioned(
                      child: _getStatLegendRow("REB", style), left: 98.0),
                  new Positioned(
                      child: _getStatLegendRow("AST", style), left: 147.0),
                  new Positioned(
                      child: _getStatLegendRow("STL", style), left: 196.0),
                  new Positioned(
                      child: _getStatLegendRow("BLK", style), left: 245.0),
                  new Positioned(
                      child: _getStatLegendRow("TO", style), left: 294.0),
                  new Positioned(
                      child: _getStatLegendRow("PF", style), left: 343.0),
                  new Positioned(
                      child: _getStatLegendRow("OREB", style), left: 392.0),
                  new Positioned(
                      child: _getStatLegendRow("DREB", style), left: 441.0),
                  new Positioned(
                      child: _getStatLegendRow("FGM", style), left: 490.0),
                  new Positioned(
                      child: _getStatLegendRow("FGA", style), left: 539.0),
                  new Positioned(
                      child: _getStatLegendRow("FGP", style, 70.0),
                      left: 588.0),
                  new Positioned(
                      child: _getStatLegendRow("3PM", style), left: 658.0),
                  new Positioned(
                      child: _getStatLegendRow("3PA", style), left: 707.0),
                  new Positioned(
                      child: _getStatLegendRow("3PP", style, 70.0),
                      left: 756.0),
                  new Positioned(
                      child: _getStatLegendRow("FTM", style), left: 826.0),
                  new Positioned(
                      child: _getStatLegendRow("FTA", style), left: 875.0),
                  new Positioned(
                      child: _getStatLegendRow("FTP", style, 70.0),
                      left: 924.0),
                  new Positioned(
                      child: _getStatLegendRow("MIN", style, 81.0),
                      left: 994.0),
                  new Positioned(
                    child: _getStatLegendRow("+/-", style, 60.0),
                    left: 1075.0,
                  )
                ],
              ),
            ),
          ),
          color: Colors.black87,
          //200.0 from the left part of the screen the player name
          width: MediaQuery.of(context).size.width - 200.0,
          //27.0 from the top bar with legend
          height: MediaQuery.of(context).size.height - 27.0,
        ),
        left: 200.0,
        top: 0.0,
      ),
      new Positioned(
          child: new Container(
              child: new Text("PLAYER", style: style),
              width: 200.0,
              alignment: Alignment.center,
              padding: new EdgeInsets.only(top: 7.5, bottom: 5.0),
              decoration: new BoxDecoration(
                  border: new Border(
                      bottom: new BorderSide(
                          width: 2.0,
                          color: new Color.fromARGB(0xff, 0xdf, 0xf8, 0xeb))),
                  color: new Color.fromARGB(0xff, 0x36, 0x41, 0x56))),
          left: 0.0,
          top: 0.0),
      new Positioned(
        child: new Container(
            child: new ListView(
              children: <Widget>[
                new Column(
                    children: players
                        .map((player) => _getPlayerProfile(player, style))
                        .toList())
              ],
              controller: playersController,
            ),
            width: 200.0,
            height: MediaQuery.of(context).size.height - 113.0,
            decoration: new BoxDecoration(
                border: new Border(
                    bottom: new BorderSide(
                        width: 2.0,
                        color: new Color.fromARGB(0xff, 0xdf, 0xf8, 0xeb))),
                color: new Color.fromARGB(0xff, 0x33, 0x33, 0x33))),
        left: 0.0,
        top: 36.0,
      )
    ]);
  }

  List<Widget> getStatRow(List<PlayerStats> players, TextStyle style) {
    return [
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.pos, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.points, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.rebounds, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.assists, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.steals, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.blocks, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.turnovers, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.pFouls, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.offReb, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.defReb, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.fgm, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.fga, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(4, player.fgp, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.tpm, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.tpa, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(4, player.tpp, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.ftm, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(2, player.fta, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(4, player.ftp, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(5, player.min, style))
              .toList()),
      new Column(
          children: players
              .map((player) => _getPlayerStatRow(3, player.plusMinus, style))
              .toList()),
    ];
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Widget _getStatLegendRow(String statName, TextStyle style,
      [double width = 49.0]) {
    return new Container(
        child: new Text(statName, style: style),
        width: width,
        alignment: Alignment.center,
        padding: new EdgeInsets.only(top: 7.5, bottom: 5.0),
        decoration: new BoxDecoration(
            border: new Border(
                bottom: new BorderSide(
                    width: 2.0,
                    color: new Color.fromARGB(0xff, 0xdf, 0xf8, 0xeb))),
            color: new Color.fromARGB(0xff, 0x36, 0x41, 0x56)));
  }

  Widget _getPlayerStatRow(int length, String stat, TextStyle style) {
    return new Container(
      child: new Text(_formatStat(length, stat), style: style),
      padding: new EdgeInsets.all(14.0),
      decoration: new BoxDecoration(
          border: new Border(
              bottom: new BorderSide(
                  width: 2.0,
                  color: new Color.fromARGB(0xff, 0xdf, 0xf8, 0xeb))),
          color: new Color.fromARGB(0x1a, 0xcd, 0xcd, 0xcd)),
    );
  }

  String _formatStat(int length, String stat) {
    return (stat.length < length) ? _formatStat(length, " $stat") : stat;
  }

  Widget _getPlayerProfile(PlayerStats player, TextStyle style) {
    return new GestureDetector(
      child: new Container(
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
                child: new Text(player.abbName.toUpperCase(), style: style),
                left: 50.0,
                top: 10.0)
          ],
        ),
        width: 200.0,
        padding: new EdgeInsets.all(5.0),
        decoration: new BoxDecoration(
            border: new Border(
                bottom: new BorderSide(
                    width: 2.0,
                    color: new Color.fromARGB(0xff, 0xdf, 0xf8, 0xeb))),
            color: new Color.fromARGB(0x1a, 0xcd, 0xcd, 0xcd)),
      ),
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return new Container(
                child: new Stack(
                  children: <Widget>[
                    new Positioned(
                      child: new Container(
                        child: new Column(
                          children: <Widget>[
                            new Text(player.firstName,
                                style: new TextStyle(
                                    fontFamily: 'Default', fontSize: 18.0)),
                            new Text(player.lastName,
                                style: new TextStyle(
                                    fontFamily: 'Default', fontSize: 18.0)),
                          ],
                        ),
                        width: 140.0,
                        color: Colors.white10,
                      ),
                      left: 0.0,
                      top: 10.0,
                    ),
                    new Positioned(
                      child: new Container(
                          child: player.image, width: 120.0, height: 120.0),
                      left: 10.0,
                      top: 50.0,
                    ),
                    new Positioned(
                      child: new Text("Match",
                          style: new TextStyle(
                              fontFamily: 'Default', fontSize: 18.0)),
                      left: 160.0,
                      top: 10.0,
                    ),
                    new Positioned(
                        child: statsCircle(
                            "FG", player.fgp, player.fga, player.fgm),
                        left: 160.0,
                        top: 35.0)
                  ],
                ),
                height: 150.0,
              );
            });
      },
    );
  }
}

Widget statsCircle(String statName, String percent,
    [String attempt = "", String made = ""]) {
  if (made.length < 2) {
    made = " $made";
    if (attempt.length < 2) made = " $made";
  }

  print(percent);
  if (percent == "0.0") percent = "0.00";

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

  game.visitor
      .setScore(JSON.decode(content)['basicGameData']['vTeam']['score']);
  game.home.setScore(JSON.decode(content)['basicGameData']['hTeam']['score']);

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

  //TODO make it work
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
