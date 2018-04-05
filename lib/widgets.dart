import 'package:flutter/material.dart';
import 'standing_card.dart';
import 'player.dart';
import 'teams.dart';

Widget getWidgetFromPlayer(
    int nameSizeMaxLength, List<Player> players, BuildContext context) {
  return new Column(
    children: <Widget>[
      leaderTile(nameSizeMaxLength, 1, players[3], players[0], context),
      leaderTile(nameSizeMaxLength, 2, players[4], players[1], context),
      leaderTile(nameSizeMaxLength, 3, players[5], players[2], context)
    ],
  );
}

Widget leaderTile(int nameSize, int rowNum, Player player1, Player player2,
    BuildContext context) {
  String stat1, stat2;

  switch (rowNum) {
    case 1:
      stat1 = "(${player1.stat}PTS)";
      stat2 = "(${player2.stat}PTS)";
      break;
    case 2:
      stat1 = "(${player1.stat}REB)";
      stat2 = "(${player2.stat}REB)";
      break;
    default:
      stat1 = "(${player1.stat}AST)";
      stat2 = "(${player2.stat}AST)";
      break;
  }

  if (player1.lastName.length >= nameSize)
    player1.lastName = player1.lastName.substring(0, nameSize);

  if (player2.lastName.length >= nameSize)
    player2.lastName = player2.lastName.substring(0, nameSize);

  return new Row(
    children: <Widget>[
      new Container(
        child: new Center(
            child: new Text("${player1.lastName.toUpperCase()} $stat1")),
        color: new Color.fromRGBO(217, 217, 255, 1.0),
        width: MediaQuery.of(context).size.width / 2 - 5,
        padding: new EdgeInsets.symmetric(vertical: 7.0),
        margin: new EdgeInsets.only(bottom: 3.0, right: 1.0),
      ),
      new Container(
        child: new Center(
            child: new Text("${player2.lastName.toUpperCase()} $stat2")),
        color: new Color.fromRGBO(217, 217, 255, 1.0),
        width: MediaQuery.of(context).size.width / 2 - 5,
        padding: new EdgeInsets.symmetric(vertical: 7.0),
        margin: new EdgeInsets.only(bottom: 3.0, left: 1.0),
      )
    ],
  );
}

getWidgetFromStandings(List<List<Team>> standings) {
  List<Widget> tabs = new List<Widget>();
  var auxIt = standings.iterator;

  while (auxIt.moveNext()) {
    int counter = -1;
    var it = auxIt.current.iterator;
    Color playoffBackground = new Color.fromRGBO(230, 230, 230, 1.0);

    List<Widget> widgets = new List<Widget>();

    widgets.add(standingsHeader());

    while (it.moveNext()) {
      counter++;
      if (counter >= 8) playoffBackground = Colors.white;

      widgets.add(new StandingCard(it.current, playoffBackground));
    }

    tabs.add(new Container(
      child: new ListView(children: widgets),
      color: Colors.black87,
    ));
  }

  return tabs;
}

Widget standingsHeader() {
  return new SizedBox(
    height: 25.0,
    child: new Container(
      child: new Stack(
        children: <Widget>[
          new Positioned(
              child: new Text(
                "W - L     %RATIO",
                style: new TextStyle(
                    fontFamily: 'Overpass',
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0),
              ),
              left: 142.0,
              top: 4.0),
          new Positioned(
            child: new Text("GB",
                style: new TextStyle(
                    fontFamily: 'Default',
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0)),
            top: 4.0,
            right: 10.0,),
        ],
      ),
      color: new Color.fromRGBO(230, 230, 230, 1.0),
      margin: new EdgeInsets.symmetric(vertical: 1.0),
    ),
  );
}