import 'package:flutter/material.dart';
import 'Games.dart';
import 'Widgets.dart';

void main() {
  runApp(new MaterialApp(
      home: new mainWidget()
  )
  );
}

class mainWidget extends StatelessWidget {
  List<game> games = new List<game>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Simple NBA"),
            backgroundColor: Colors.red,
            actions: <Widget>[new Container(
                child: new Icon(Icons.refresh, color: Colors.white, size: 30.0),
                padding: new EdgeInsets.only(right: 20.0)
            )
            ]
        ),
        body: new Center(
            child: new Container(
                child: new FutureBuilder(
                    future: loadData(),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> response) {
                      if (!response.hasData)
                        return new Text("Loading...");
                      else {
                        games = response.data;
                        return new ListView(
                            children: getWidgetFromGame(games)
                        );
                      }
                    }
                ),
                padding: new EdgeInsets.all(8.0)
            )
        ),
      backgroundColor: Colors.orangeAccent
    );
  }
}