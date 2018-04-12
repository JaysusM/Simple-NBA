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

    //I could used nicknames from DB instead but Trail Blazers nickname is too large,
    //so I would have to use that method too
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

    return new Stack(children: <Widget>[
      new Positioned(
        child: new Container(
          child: new SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: new SizedBox(
              width: 1335.0,
              child: new Stack(
                children: <Widget>[
                  new Container(
                    child: new ListView(
                      children: <Widget>[
                        new Row(children: getStatRow(players, style)),
                      ],
                    ),
                    margin: new EdgeInsets.only(top: 36.0),
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
                                      color: new Color.fromARGB(
                                          0xff, 0xdf, 0xf8, 0xeb))),
                              color:
                                  new Color.fromARGB(0xff, 0x36, 0x41, 0x56))),
                      left: 0.0,
                      top: 0.0),
                  new Positioned(
                      child: _getStatLegendRow("POS", style), left: 200.0),
                  new Positioned(
                      child: _getStatLegendRow("PTS", style), left: 249.0),
                  new Positioned(
                      child: _getStatLegendRow("REB", style), left: 298.0),
                  new Positioned(
                      child: _getStatLegendRow("AST", style), left: 347.0),
                  new Positioned(
                      child: _getStatLegendRow("STL", style), left: 396.0),
                  new Positioned(
                      child: _getStatLegendRow("BLK", style), left: 445.0),
                  new Positioned(
                      child: _getStatLegendRow("TO", style), left: 494.0),
                  new Positioned(
                      child: _getStatLegendRow("PF", style), left: 543.0),
                  new Positioned(
                      child: _getStatLegendRow("OREB", style), left: 592.0),
                  new Positioned(
                      child: _getStatLegendRow("DREB", style), left: 641.0),
                  new Positioned(
                      child: _getStatLegendRow("FGM", style), left: 690.0),
                  new Positioned(
                      child: _getStatLegendRow("FGA", style), left: 739.0),
                  new Positioned(
                      child: _getStatLegendRow("FGP", style, 70.0),
                      left: 788.0),
                  new Positioned(
                      child: _getStatLegendRow("3PM", style), left: 858.0),
                  new Positioned(
                      child: _getStatLegendRow("3PA", style), left: 907.0),
                  new Positioned(
                      child: _getStatLegendRow("3PP", style, 70.0),
                      left: 956.0),
                  new Positioned(
                      child: _getStatLegendRow("FTM", style), left: 1026.0),
                  new Positioned(
                      child: _getStatLegendRow("FTA", style), left: 1075.0),
                  new Positioned(
                      child: _getStatLegendRow("FTP", style, 70.0),
                      left: 1124.0),
                  new Positioned(
                      child: _getStatLegendRow("MIN", style, 81.0),
                      left: 1194.0),
                  new Positioned(
                    child: _getStatLegendRow("+/-", style, 60.0),
                    left: 1275.0,
                  )
                ],
              ),
            ),
          ),
          color: Colors.black87,
          width: MediaQuery.of(context).size.width,
          //27.0 from the top bar with legend
          height: MediaQuery.of(context).size.height - 27.0,
        ),
        left: 0.0,
        top: 0.0,
      ),
    ]);
  }

  List<Widget> getStatRow(List<PlayerStats> players, TextStyle style) {
    return [
      new Column(
          children: players
              .map((player) => _getPlayerProfile(player, style))
              .toList()),
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
    TextStyle statsStyle =
        new TextStyle(fontFamily: 'SignikaB', fontSize: 18.0);

    TextStyle seasonStatsStyle =
    new TextStyle(fontFamily: 'SignikaB', fontSize: 16.0);

    return new GestureDetector(
      child: new Container(
        child: new Stack(
          children: <Widget>[
            new Positioned(
              child: new Container(
                  child: new CircleAvatar(
                    child: new FadeInImage(
                        placeholder: new AssetImage("assets/noPlayer.png"),
                        image: new NetworkImage(Player.getImage(player.id))),
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
                      top: 20.0,
                    ),
                    new Positioned(
                      child: new Container(
                          child: new FadeInImage(
                              placeholder:
                                  new AssetImage("assets/noPlayer.png"),
                              image:
                                  new NetworkImage(Player.getImage(player.id))),
                          width: 140.0,
                          height: 140.0),
                      left: 0.0,
                      top: 60.0,
                    ),
                    new Positioned(
                      child: new Text("Match",
                          style: new TextStyle(
                              fontFamily: 'Default', fontSize: 18.0)),
                      left: 145.0,
                      top: 5.0,
                    ),
                    new Positioned(
                      child: new Text("(${player.min})", style: statsStyle),
                      left: 200.0,
                      top: 5.0,
                    ),
                    new Positioned(
                      child: new Text(
                        "PTS: ${player.points}\tREB: ${player.rebounds}\tAST: ${player.assists}",
                        style: statsStyle,
                      ),
                      top: 93.0,
                      left: 140.0,
                    ),
                    new Positioned(
                        child: statsCircle(
                            true, "FG", player.fgp, player.fga, player.fgm),
                        left: 195.0,
                        top: 35.0),
                    new Positioned(
                        child: reboundsWidget(
                            player.rebounds, player.offReb, player.defReb),
                        left: 140.0,
                        top: 35.0),
                    new Positioned(
                        child: statsCircle(
                            true, "3P", player.tpp, player.tpa, player.tpm),
                        left: 250.0,
                        top: 35.0),
                    new Positioned(
                        child: statsCircle(
                            true, "FT", player.ftp, player.fta, player.ftm),
                        left: 305.0,
                        top: 35.0),
                    new Positioned(
                      child: new Text(
                          ""
                          "BLK: ${player.blocks}\t"
                          "STL: ${player.steals}\t"
                          "TO: ${player.turnovers}\t",
                          style: statsStyle),
                      top: 110.0,
                      left: 140.0,
                    ),
              new Positioned(
              child: new Text(
              "Season\n"
              "PPG: ${player.ppm}  "
              "RPG: ${player.rpm}  "
              "APG: ${player.apm}  ",
              style: seasonStatsStyle),
              top: 133.0,
              left: 140.0,
              )
                  ],
                ),
                height: 180.0,
              );
            });
      },
    );
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
                left: 15.8),
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

Widget statsCircle(bool isPercentage, String statName, String value,
    [String attempt = "", String made = ""]) {
  if (made.length < 2) {
    made = " $made";
    if (attempt.length < 2) made = " $made";
  }

  if (value == "0.0") value = "0.00";
  if (value.length < 2) value = " $value";
  return new CircleAvatar(
      child: new CircleAvatar(
          child: new Stack(
            children: <Widget>[
              new Positioned(
                  child: new Text(statName,
                      style: new TextStyle(
                          fontFamily: 'SignikaR', fontSize: 10.0)),
                  top: 3.0,
                  left: (statName.length == 2) ? 18.0 : 15.0),
              new Positioned(
                  child: new Text((isPercentage) ? "%$value" : value,
                      style: new TextStyle(
                          fontFamily: 'SignikaR',
                          fontSize: (isPercentage) ? 14.0 : 20.0)),
                  top: 14.0,
                  left: (isPercentage) ? 4.5 : 12.0),
              new Positioned(
                  child: new Text((isPercentage) ? "$made / $attempt" : "",
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

  List<String> scores = Game.formatScore(JSON.decode(content)['basicGameData']['hTeam']['score'],
      JSON.decode(content)['basicGameData']['vTeam']['score']);

  game.visitor
      .setScore(scores[1]);
  game.home.setScore(scores[0]);

  decoder.forEach((player) {
    if (player["teamId"] == game.home.id)
      homePlayers.add(getPlayerStatFromMap(player, db));
    else
      awayPlayers.add(getPlayerStatFromMap(player, db));
  });

  Dictionary<String, List<PlayerStats>> playersStats = new Dictionary();
  await Future.wait([
    setNamesInPlayersList(homePlayers, db),
    setNamesInPlayersList(awayPlayers, db),
  ]);
  db.close();
  playersStats.add(game.home.id, homePlayers);
  playersStats.add(game.visitor.id, awayPlayers);


  setSeasonStats(homePlayers);
  setSeasonStats(awayPlayers);
  return playersStats;
}

Future setNamesInPlayersList(List<Player> players, Database db) async {
  await Future.forEach(players, (player) async {
    player.fullName = await getPlayerNameFromId(player.id, db);
  });
}

Future setSeasonStats(List<PlayerStats> players) async {
  
  String base = JSON.decode(await http.read("http://data.nba.net/10s/prod/v1/today.json"))["links"]["playerProfile"];

  for(PlayerStats p in players) {
    String link = "http://data.nba.net${base.replaceAll("{{personId}}", p.id)}";
    var decoder = JSON.decode(await http.read(link))["league"]["standard"]["stats"]["latest"];

    p.ppm = decoder['ppg'];
    p.rpm = decoder['rpg'];
    p.apm = decoder['apg'];
  }

  return new Future<Null>.value();
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
