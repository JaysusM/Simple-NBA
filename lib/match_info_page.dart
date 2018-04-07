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
                  new Tab(child: new Text(widget.awayLastName.toUpperCase(), style: new TextStyle(
                    fontFamily: 'Signika',
                    fontSize: 17.0
                  ))),
                  new Tab(child: new Text(widget.homeLastName.toUpperCase(), style: new TextStyle(
                      fontFamily: 'Signika',
                      fontSize: 17.0
                  )))
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
                    new Container(
                      color: new Color.fromARGB(0xff, 0x18, 0x2b, 0x4a)
                    )),
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
        fontSize: 17.0, fontFamily: 'Overpass', color: Colors.white);
    return new Container(
      child: new SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: new SizedBox(
          width: 1254.0,
          child: new ListView(children: <Widget>[
            new Row(children: getStatRow(statLegend, players, defaultStyle))
          ]),
        ),
      ),
      color: Colors.black87,
    );
  }

  List<Widget> getStatRow(
      List<String> stats, List<PlayerStats> players, TextStyle style) {
    return [
      new Column(
          children: <Widget>[
        new Container(
            child: new Text("PLAYER", style: style),
            width: 200.0,
            alignment: Alignment.center,
            padding: new EdgeInsets.only(top: 7.5, bottom: 5.0),
            decoration: new BoxDecoration(
                border: new Border(
                    bottom:
                    new BorderSide(width: 2.0, color: new Color.fromARGB(0xff,0xdf,0xf8,0xeb))),
                color: new Color.fromARGB(0xff,0x36,0x41,0x56))),
      ]..addAll(players.map((player) => _getPlayerProfile(player, style)))),
      new Column(
          children: _getStatLegendRow("POS", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.pos, style)))),
      new Column(
          children: _getStatLegendRow("PTS", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.points, style)))),
      new Column(
          children: _getStatLegendRow("REB", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.rebounds, style)))),
      new Column(
          children: _getStatLegendRow("AST", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.assists, style)))),
      new Column(
          children: _getStatLegendRow("STL", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.steals, style)))),
      new Column(
          children: _getStatLegendRow("BLK", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.blocks, style)))),
      new Column(
          children: _getStatLegendRow("TO", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.turnovers, style)))),
      new Column(
          children: _getStatLegendRow("PF", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.pFouls, style)))),
      new Column(
          children: _getStatLegendRow("OREB", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.offReb, style)))),
      new Column(
          children: _getStatLegendRow("DREB", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.defReb, style)))),
      new Column(
          children: _getStatLegendRow("FGM", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.fgm, style)))),
      new Column(
          children: _getStatLegendRow("FGA", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.fga, style)))),
      new Column(
          children: _getStatLegendRow("FGP", style, 70.0)..addAll(players.map((player) => _getPlayerStatRow(4, player.fgp, style)))),
      new Column(
          children: _getStatLegendRow("3PM", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.tpm, style)))),
      new Column(
          children: _getStatLegendRow("3PA", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.tpa, style)))),
      new Column(
          children: _getStatLegendRow("3PP", style, 70.0)..addAll(players.map((player) => _getPlayerStatRow(4, player.tpp, style)))),
      new Column(
          children: _getStatLegendRow("FTM", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.ftm, style)))),
      new Column(
          children: _getStatLegendRow("FTA", style)..addAll(players.map((player) => _getPlayerStatRow(2, player.fta, style)))),
      new Column(
          children: _getStatLegendRow("FTP", style, 70.0)..addAll(players.map((player) => _getPlayerStatRow(4, player.ftp, style)))),
      new Column(
          children: _getStatLegendRow("+/-", style, 60.0)..addAll(players.map((player) => _getPlayerStatRow(3, player.plusMinus, style)))),

    ];
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  List<Widget> _getStatLegendRow(String statName, TextStyle style, [double width = 49.0]) {
    return <Widget>[new Container(
        child: new Text(statName, style: style),
        width: width,
        alignment: Alignment.center,
        padding: new EdgeInsets.only(top: 7.5, bottom: 5.0),
        decoration: new BoxDecoration(
            border: new Border(
                bottom:
                new BorderSide(width: 2.0, color: new Color.fromARGB(0xff,0xdf,0xf8,0xeb))),
            color: new Color.fromARGB(0xff,0x36,0x41,0x56)))];
  }

  Widget _getPlayerStatRow(int length, String stat, TextStyle style) {
    return new Container(
      child: new Text(
          _formatStat(length, stat),
          style: style),
      padding: new EdgeInsets.all(14.0),
      decoration: new BoxDecoration(
          border: new Border(
              bottom:
              new BorderSide(width: 2.0, color: new Color.fromARGB(0xff,0xdf,0xf8,0xeb))),
      color: new Color.fromARGB(0x1a,0xcd,0xcd,0xcd)),
    );
  }

  String _formatStat(int length, String stat) {
    return (stat.length < length) ? _formatStat(length, " $stat") : stat;
  }

  Widget _getPlayerProfile(PlayerStats player, TextStyle style) {
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
              child: new Text(player.abbName.toUpperCase(), style: style),
              left: 50.0,
              top: 10.0)
        ],
      ),
      width: 200.0,
      padding: new EdgeInsets.all(5.0),
      decoration: new BoxDecoration(
          border: new Border(
              bottom: new BorderSide(width: 2.0, color: new Color.fromARGB(0xff,0xdf,0xf8,0xeb))),
      color: new Color.fromARGB(0x1a,0xcd,0xcd,0xcd)),
    );
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
