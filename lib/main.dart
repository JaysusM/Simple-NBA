import 'package:flutter/material.dart';
import 'Games.dart';
import 'Widgets.dart';
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
        backgroundColor: Colors.red,
        actions: <Widget>[new Container( child: new IconButton(icon: new Icon(Icons.refresh, color: Colors.blue, size: 30.0), onPressed: _refresh),
        padding: new EdgeInsets.only(right: 15.0, left: 15.0),
        color: new Color.fromRGBO(0, 0, 0, 0.50))]
      ),
      body: new Center(
        child: new Container(
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
            ),
          padding: new EdgeInsets.all(15.0)
         )
      )
    );
  }

  _refresh() {}

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

