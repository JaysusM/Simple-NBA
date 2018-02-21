import 'package:flutter/material.dart';
import 'Games.dart';
import 'Widgets.dart';
import 'dart:async';
import 'Data.dart';
import 'DatabaseCreation.dart';
import 'SimpleHashMap.dart';

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
                    style: new TextStyle(fontFamily: "Default")))),
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
  return new Scaffold(
      appBar: new AppBar(title: new Text("Error launching app, restart it")),
      body: new Directionality(
      textDirection: TextDirection.ltr,
      child: new Container(
          child: new Center(
              child: new Text(
                  "Error loading data (check your connection): \n ${response
                      .error
                      .toString()}",
                  style: new TextStyle(height: 15.0))),
          color: Colors.grey,
          padding: new EdgeInsets.all(10.0))));
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


//FormatDate in this class will be used to compare dates without time, just day-month-year
class CalendarTabState extends State<CalendarTab> {
  List<Game> _games;
  Timer _timer;
  DateTime _currentDate;
  //The add -17 hours will set up date to be 12.00PM at 17.00PM UTC, time when matches
  //start in NBA, this way won't set up a wrong date as currentDate
  final DateTime _startGameDate = new DateTime.now().toUtc().add(new Duration(hours: -17));
  //I didn't like Dart's HashMap structure so I created a new simpler one.
  //This will store all List of Games from visited dates since App was launched, will show
  //visited date games without using internet connection (offline use).
  HashMap<String, List<Game>> _gameDate;
  
  CalendarTabState()
  {
    _currentDate = _startGameDate;
    _gameDate = new HashMap();
  }
  

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
                      child: (formatDate(_currentDate) != formatDate(_startGameDate)) ? new Text("${_currentDate.year} - ${numberFormatTwoDigit(_currentDate
                          .month.toString())} - ${numberFormatTwoDigit(_currentDate.day.toString())}") :
                  new Text("TODAY")),
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
            elevation: 0.0,),
        body: (_games.isNotEmpty)
            ? new ListView(
                children: _games.map((game) => new GameCard(game)).toList(),
              )
            : new Center(
                child: new Text("No games scheduled",
                    style:
                        new TextStyle(fontFamily: "Default", fontSize: 20.0))),
    );
  }

  void _changeDate(int day) {
    _currentDate = new DateTime.fromMillisecondsSinceEpoch(_currentDate.add(new Duration(days: day))
    .millisecondsSinceEpoch);
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
      List<Game> newContent = await loadGames(_startGameDate);
      this.setState(() {
        _gameDate.add(formatDate(_startGameDate), newContent);
        if(formatDate(_currentDate) == formatDate(_startGameDate))
          _games = newContent;
      });
    });
  }

  Future _refresh() async {
    List<Game> newContent;

    if(!_gameDate.containsKey(formatDate(_currentDate)))
      newContent = await loadGames(_currentDate);
    else
      newContent = _gameDate.getValue(formatDate(_currentDate));

    this.setState(() {
      _games = newContent;
      if(!_gameDate.containsKey(formatDate(_currentDate)))
        _gameDate.add(formatDate(_currentDate), newContent);
    });
    return new Future<Null>.value();
  }
}

