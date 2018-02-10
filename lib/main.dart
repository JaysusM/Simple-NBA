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

class mainWidget extends State<mainApp> with SingleTickerProviderStateMixin {
  List<Widget> gameCards = new List<Widget>();
  bool refresh, start, standingsLoaded;
  TabController _controllerMain;
  var standingsContent;

  @override
  void initState() {
    super.initState();
    _controllerMain = new TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _controllerMain.dispose();
    super.dispose();
  }

  mainWidget() {
    refresh = false;
    start = false;
    standingsLoaded = false;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Simple NBA"),
            backgroundColor: new Color.fromRGBO(255, 25, 25, 0.8)),
        bottomNavigationBar: new Material(
          child: new TabBar(tabs: <Tab>[
            new Tab(icon: new Icon(Icons.calendar_today, size: 40.0)),
            new Tab(icon: new Icon(Icons.assessment, size: 40.0))
          ], controller: _controllerMain),
          color: Colors.red,
        ),
        body: new TabBarView(
            children: <Widget>[calendarTab(), standingsTab()],
            controller: _controllerMain),
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

  Widget calendarTab() {
    return new RefreshIndicator(child: checkRefresh(), onRefresh: _refresh);
  }

  Widget checkRefresh() {
    if (!refresh) {
      return new FutureBuilder(
          future: loadData(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> response) {
            if (response.hasError)
              return new Container(
                  child: new Text(
                    response.error.toString(),
                    style: new TextStyle(fontSize: 40.0),
                  ),
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

  Widget standingsTab() {
    return new FutureBuilder(
        future: loadTeams(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> responseTeams) {
          if (standingsLoaded)
            return new Container(
                child: new standingsScroll(standingsContent),
                padding: new EdgeInsets.only(top: 8.0));
          else if (!responseTeams.hasData) {
            return loadingScreen();
          } else {
            return new FutureBuilder(
                future: loadStandings(responseTeams.data),
                builder: (BuildContext context,
                    AsyncSnapshot<dynamic> responseStandings) {
                  if (responseStandings.hasError)
                    return new Text(responseStandings.error);
                  else if (!responseStandings.hasData) {
                    return loadingScreen();
                  } else {
                    standingsLoaded = true;
                    standingsContent =
                        getWidgetFromStandings(responseStandings.data);
                    return new standingsScroll(standingsContent);
                  }
                });
          }
        });
  }
}

class standingsScroll extends StatefulWidget {
  standingsScroll(this._standings);

  List<Widget> _standings;

  createState() => new standingsState(_standings);
}

class standingsState extends State with SingleTickerProviderStateMixin {
  standingsState(this._standings);

  List<Widget> _standings;
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        bottomNavigationBar: new Material(
          child: new TabBar(tabs: <Widget>[
            new Tab(
                child: new Text("EAST", style: new TextStyle(fontSize: 15.0))),
            new Tab(
                child: new Text("WEST", style: new TextStyle(fontSize: 15.0)))
          ], controller: _controller),
          color: Colors.red,
        ),
        body: new TabBarView(children: _standings, controller: _controller));
  }
}
