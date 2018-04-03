import 'package:flutter/material.dart';
import 'StandingCard.dart';
import 'Player.dart';
import 'Teams.dart';

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
      stat1 = "(${player1.points}PTS)";
      stat2 = "(${player2.points}PTS)";
      break;
    case 2:
      stat1 = "(${player1.rebounds}REB)";
      stat2 = "(${player2.rebounds}REB)";
      break;
    default:
      stat1 = "(${player1.assist}AST)";
      stat2 = "(${player2.assist}AST)";
      break;
  }

  if (player1.name.length >= nameSize)
    player1.name = player1.name.substring(0, nameSize);

  if (player2.name.length >= nameSize)
    player2.name = player2.name.substring(0, nameSize);

  return new Row(
    children: <Widget>[
      new Container(
        child: new Center(
            child: new Text("${player1.name.toUpperCase()} $stat1")),
        color: new Color.fromRGBO(217, 217, 255, 1.0),
        width: MediaQuery.of(context).size.width / 2 - 5,
        padding: new EdgeInsets.symmetric(vertical: 7.0),
        margin: new EdgeInsets.only(bottom: 3.0, right: 1.0),
      ),
      new Container(
        child: new Center(
            child: new Text("${player2.name.toUpperCase()} $stat2")),
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

    while (it.moveNext()) {
      counter++;
      if (counter >= 8) playoffBackground = Colors.white;

      widgets.add(new StandingCard(it.current, playoffBackground));
    }

    tabs.add(new Tab(
        child: new Container(
      child: new ListView(children: widgets),
      decoration: new BoxDecoration(
          border: new Border.all(width: 0.1),
          borderRadius: new BorderRadius.all(new Radius.circular(4.0)),
          boxShadow: <BoxShadow>[
            new BoxShadow(
                offset: new Offset(2.0, 1.0),
                color: Colors.grey,
                blurRadius: 6.0)
          ]),
      margin: new EdgeInsets.fromLTRB(8.0, 17.0, 8.0, 5.0),
    )));
  }

  return tabs;
}
