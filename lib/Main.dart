import 'package:flutter/material.dart';
import 'Games.dart';
import 'Widgets.dart';
import 'dart:async';
import 'Data.dart';
import 'DatabaseCreation.dart';
import 'dart:collection';

void main() {
  runApp(new MaterialApp(home: new MainFrame()));
}

class MainFrame extends StatefulWidget {
  MainFrame() {
    //We create db if it doesn't exist
    startDB();
  }

  createState() => new MainFrameState();
}

class MainFrameState extends State<MainFrame>
    with SingleTickerProviderStateMixin {
  TabController _mainNavigationController;
  List<Widget> _standingsWidgets;
  List<Game> _calendarData;

  @override
  void initState() {
    super.initState();
    _mainNavigationController = new TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _mainNavigationController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: loadGames(new DateTime.now().toUtc()),
        builder: (BuildContext context, AsyncSnapshot response) {
          if (response.hasError)
            return _throwError(response);
          else if (!response.hasData)
            return loadingScreen();
          else {
            _calendarData = response.data;
            return new FutureBuilder(
                future: loadStandings(),
                builder: (BuildContext context, AsyncSnapshot response) {
                  if (response.hasError)
                    return _throwError(response);
                  else if (!response.hasData)
                    return loadingScreen();
                  else {
                    _standingsWidgets = getWidgetFromStandings(response.data);
                    return setInfo();
                  }
                });
          }
        });
  }

  Widget setInfo() {
    return new Scaffold(
        appBar: new AppBar(
            title: new Title(
                color: Colors.white,
                child: new Text("Simple NBA",
                    style: new TextStyle(fontFamily: "Default"))),
            elevation: 0.0),
        bottomNavigationBar: new Material(
          child: new TabBar(tabs: <Tab>[
            new Tab(icon: new Icon(Icons.calendar_today, size: 40.0)),
            new Tab(icon: new Icon(Icons.assessment, size: 40.0))
          ], controller: _mainNavigationController),
          color: Colors.red,
        ),
        body: new TabBarView(
          children: <Widget>[
            new CalendarTab(_calendarData),
            standingsTab(_standingsWidgets)
          ],
          controller: _mainNavigationController,
        ));
  }
}

Widget standingsTab(List<Widget> standings) {
  return new Container(
    child: new StandingsWidgetView(standings),
    color: Colors.grey,
  );
}

Widget _throwError(AsyncSnapshot response) {
  return new Directionality(
      textDirection: TextDirection.ltr,
      child: new Container(
          child: new Center(
              child: new Text(
                  "Error loading data (check your connection): \n ${response
                      .error
                      .toString()}",
                  style: new TextStyle(height: 15.0))),
          color: Colors.grey,
          padding: new EdgeInsets.all(10.0)));
}

class StandingsWidgetView extends StatefulWidget {
  final List<Widget> _standings;

  StandingsWidgetView(this._standings);

  createState() => new StandingsWidgetViewState(_standings);
}

class StandingsWidgetViewState extends State
    with SingleTickerProviderStateMixin {
  List<Widget> _standings;

  StandingsWidgetViewState(this._standings);

  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: new AppBar(
            title: new TabBar(tabs: <Tab>[
              new Tab(child: new Text("EAST")),
              new Tab(child: new Text("WEST"))
            ]),
            flexibleSpace: new Container(color: Colors.white, height: 0.15),
          ),
          body: new TabBarView(children: _standings),
        ));
  }
}

class CalendarTab extends StatefulWidget {
  final List<Game> games;

  CalendarTab(this.games);

  State<StatefulWidget> createState() => new CalendarTabState();
}

class CalendarTabState extends State<CalendarTab> {
  List<Game> _games;
  Timer _timer;
  DateTime _currentDate = new DateTime.now().toUtc();
  final DateTime _utcDate = new DateTime.now().toUtc();

  /*
  TODO create new ordered data structure map and insert
  TODO searched dates to reduce complexity
  */

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new SizedBox(
              child: new Stack(
                children: <Widget>[
                  new Positioned(
                      child: new IconButton(
                          icon: new Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                          onPressed: () {
                            _changeDate(-1);
                          }),
                      left: 5.0,
                      top: 5.0),
                  new Center(
                      child: new Text("${_currentDate.year} - ${numberFormatTwoDigit(_currentDate
                          .month.toString())} - ${numberFormatTwoDigit(_currentDate.day.toString())}")),
                  new Positioned(
                      child: new IconButton(
                          icon: new Icon(Icons.arrow_forward_ios,
                              color: Colors.white),
                          onPressed: () {
                            _changeDate(1);
                          }),
                      right: 5.0,
                      top: 5.0)
                ],
              ),
            ),
            flexibleSpace: new Container(height: 0.15, color: Colors.white)),
        body: (_games.isNotEmpty)
            ? new ListView(
                children: _games.map((game) => new GameCard(game)).toList(),
              )
            : new Center(
                child: new Text("No games scheduled for today",
                    style:
                        new TextStyle(fontFamily: "Default", fontSize: 20.0))),
    );
  }

  void _changeDate(int day) {
    _currentDate = _currentDate.add(new Duration(days: day));
    _refresh();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  void initState() {
    _games = widget.games;
    super.initState();
    _timer = new Timer.periodic(new Duration(seconds: 20), (Timer timer) async {
      List<Game> newContent = await loadGames(_utcDate);
      this.setState(() {
        _games = newContent;
      });
    });
  }

  Future _refresh() async {
    List<Game> newContent = await loadGames(_currentDate);
    this.setState(() {
      _games = newContent;
    });
    return new Future<Null>.value();
  }
}
