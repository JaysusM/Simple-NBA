import 'package:flutter/material.dart';
import 'Games.dart';
import 'dart:async';

void main() {
  runApp(new MaterialApp(
      home: new mainWidget()
    )
  );
}

class mainWidget extends StatelessWidget
{

  List<game> games = new List<game>();

  @override
  Widget build(BuildContext context)
  {
    return new Scaffold(
      appBar: new AppBar(
       title: new Text("Simple NBA"),
        backgroundColor: Colors.red
      ),
      body: new Container(
        child: new FutureBuilder(
              future: loadData(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> response) {
                if(!response.hasData)
                  return new Text("Loading...");
                else
                  {
                    return new Column(
                      children: getWidgetFromGame(response.data)
                    );
                  }
              }
          )
       )
    );
  }
}

class gameCard extends StatelessWidget
{
  gameCard(team home, team away)
  {
    _title = new Text("${home.tricode} ( ${home.score} - ${away.score} ) ${away.tricode}");
  }

  Widget _title;

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Card(
        child: new Column(
          children: <Widget>[
              this._title
          ]
        )
      )
    );
  }
}

List<Widget> getWidgetFromGame(List<game> games)
{
  List<Widget> gameCards = new List<Widget>();

  for(game g in games)
    {
      gameCards.add(new gameCard(g.home, g.visitor));
    }
  return gameCards;
}