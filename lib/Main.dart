import 'package:flutter/material.dart';
import 'Games.dart';
import 'Widgets.dart';
import 'dart:async';
import 'Data.dart';

void main() {
  runApp(new MaterialApp(home: new dataLoaderWidget()));
}

class dataLoaderWidget extends StatelessWidget {
  var _gameCards, _standingsCards;

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: loadData(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> response) {
          if (response.hasError) {
            print(response.error);
          } else if (!response.hasData)
            return loadingScreen();
          else {
            _gameCards = getWidgetFromGame(response.data);
            return new FutureBuilder(
                future: loadStandings(loadTeams()),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> response) {
                  if (response.hasError) {
                    print(response.error);
                  } else if (!response.hasData)
                    return loadingScreen();
                  else {
                    this._standingsCards =
                        getWidgetFromStandings(response.data);
                    return new designWidget(_gameCards, _standingsCards);
                  }
                });
          }
        });
  }
}

class designWidget extends StatefulWidget {
  List<Widget> _gameCards, _standingsCards;

  designWidget(this._gameCards, this._standingsCards);

  createState() => new designWidgetState(_gameCards, _standingsCards);
}

class designWidgetState extends State<designWidget>
    with SingleTickerProviderStateMixin {
  List<Widget> _gameCards = new List<Widget>();
  List<Widget> _standingsContent = new List<Widget>();
  TabController _controllerMain;

  designWidgetState(this._gameCards, this._standingsContent);

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

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text(
              "Simple NBA",
              style: new TextStyle(fontFamily: 'Defaut', fontSize: 25.0),
            ),
            backgroundColor: new Color.fromRGBO(255, 25, 25, 0.8)),
        bottomNavigationBar: new Material(
          child: new TabBar(tabs: <Tab>[
            new Tab(icon: new Icon(Icons.calendar_today, size: 30.0)),
            new Tab(icon: new Icon(Icons.assessment, size: 30.0))
          ], controller: _controllerMain),
          color: Colors.red,
        ),
        body: new TabBarView(children: <Widget>[
          new calendarTab(this._gameCards),
          new standingsScroll(this._standingsContent)
        ], controller: _controllerMain),
        backgroundColor: new Color.fromRGBO(245, 245, 245, 1.0));
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

class calendarTab extends StatefulWidget {
  var _gameCards;

  calendarTab(this._gameCards);

  createState() => new calendarTabStatus(_gameCards);
}

class calendarTabStatus extends State<calendarTab> {
  List<Widget> _gameCards;

  calendarTabStatus(this._gameCards);

  Widget build(BuildContext context) {
    return new RefreshIndicator(child:
    new Container(
        child: new ListView(children: _gameCards)),
        onRefresh: _refresh);
  }

  _refresh() async {
    List<game> newContent = await loadData();
    setState(() {
      _gameCards = getWidgetFromGame(newContent);
    });
    return new Future<Null>.value();
  }
}
