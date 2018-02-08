import 'package:flutter/material.dart';
import 'Games.dart';
import 'Widgets.dart';
import 'dart:async';

void main() {
  runApp(new MaterialApp(home: new mainApp()));
}

class mainApp extends StatefulWidget {
  createState() => new mainWidget();
}

class mainWidget extends State<mainApp> {
  List<Widget> gameCards = new List<Widget>();
  bool refresh;
  bool start;

  mainWidget() {
    refresh = false;
    start = false;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Simple NBA"),
            backgroundColor: new Color.fromRGBO(255, 25, 25, 0.8)),
        body: new RefreshIndicator(
            child: new Center(child: checkRefresh()), onRefresh: _refresh),
        backgroundColor: new Color.fromRGBO(245, 245, 245, 1.0));
  }

  Future<Null> _refresh() async {
    List<game> newGames = await loadData();
    this.setState(() {
      refresh = !refresh;
      gameCards = getWidgetFromGame(newGames);
    });
    return new Future<Null>.value();
  }

  Widget checkRefresh() {
    if (!refresh) {
      return new FutureBuilder(
          future: loadData(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> response) {
            if(response.hasError)
              return new Container(
                  child: new Text(response.error.toString(), style: new TextStyle(fontSize: 40.0),),
                  color: Colors.red);
            else if (!response.hasData) {
              if (!start)
                return loadingScreen();
              else
                return new Container(
                    child: new ListView(children: gameCards),
                    padding: new EdgeInsets.all(8.0));
            } else {
              start = true;
              gameCards = getWidgetFromGame(response.data);
              return new Container(
                  child: new ListView(children: gameCards),
                  padding: new EdgeInsets.all(8.0));
            }
          });
    } else {
      return new Container(
          child: new ListView(children: gameCards),
          padding: new EdgeInsets.all(8.0));
    }
  }
}
