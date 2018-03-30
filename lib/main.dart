import 'package:flutter/material.dart';
import 'Games.dart';
import 'Widgets.dart';
import 'dart:async';
import 'Data.dart';
import 'DatabaseCreation.dart';
import 'Dictionary.dart';
import 'LoadingAnimation.dart';
import 'Player.dart';

void main() {
  runApp(new MaterialApp(home: new MainFrame()));
}

//DateTime set day with ET mid-day (when matches are reloaded)
DateTime setHourETTime() {
  DateTime temp = new DateTime.now().toUtc().subtract(new Duration(hours: 5));
  return (temp.hour >= 12) ? temp : temp.subtract(new Duration(days: 1));
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
        future: loadData(setHourETTime()),
        builder: (BuildContext context, AsyncSnapshot response) {
          if (response.hasError)
            return _throwError(response);
          else if (!response.hasData)
            return new loadingAnimation();
          else {
            _calendarData = response.data[0];
            _standingsWidgets = getWidgetFromStandings(response.data[1]);
            return setInfo();
          }
        }
    );
  }

  Widget setInfo() {
    return new Scaffold(
        appBar: new AppBar(
          flexibleSpace: new Container(
              decoration: new BoxDecoration(
                  image: new DecorationImage(image: new AssetImage("assets/242.jpg"),
                      fit: BoxFit.fitWidth))),
            title: new Title(
                color: Colors.white,
                child: new Text("Simple NBA",
                    style: new TextStyle(fontFamily: "Default", color: Colors.white)))),
        bottomNavigationBar: new Material(
          child: new Container( child: new TabBar(tabs: <Tab>[
            new Tab(icon: new Icon(Icons.calendar_today, size: 40.0)),
            new Tab(icon: new Icon(Icons.assessment, size: 40.0))
          ], controller: _mainNavigationController)
            ,
            color: new Color.fromRGBO(147, 0, 0, 1.0),
          )
        ),
        body: new TabBarView(
          children: <Widget>[
            new CalendarTab(_calendarData),
            standingsTab(_standingsWidgets)
          ],
          controller: _mainNavigationController,
        ),
    );
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
              padding:
                  new EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0))));
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
            elevation: 0.0,
            backgroundColor: new Color.fromRGBO(12, 106, 201, 1.0)
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
  DateTime _selectedDate, _startGameDate;

  //I didn't like Dart's HashMap structure so I created a new simpler one.
  //This will store all List of Games from visited dates since App was launched, will show
  //visited date games without using internet connection (offline use).
  Dictionary<String, List<Game>> _gameDate;

  CalendarTabState() {
    _startGameDate = setHourETTime();
    _selectedDate = setHourETTime();
    _gameDate = new Dictionary();
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new SizedBox(
            child: new Stack(
              children: <Widget>[
                new Positioned(
                    child: new Container( child:new IconButton(
                        icon:
                            new Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () {
                          _changeDate(-1);
                        })),
                    left: 5.0,
                    top: 5.0),
                new Center(
                    child: (formatDate(_selectedDate) !=
                            formatDate(_startGameDate))
                        ? new Text(
                            "${_selectedDate.year} - ${numberFormatTwoDigit(
                            _selectedDate
                                .month.toString())} - ${numberFormatTwoDigit(
                            _selectedDate.day.toString())}")
                        : new Text("TODAY")),
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
          elevation: 0.0,
          backgroundColor: new Color.fromRGBO(12, 106, 201, 1.0),
        ),
        body: new Container(
          child: new RefreshIndicator(
            child: (_games.isNotEmpty)
                ? new ListView(
                    children: _games.map((game) => new GameCard(game)).toList()
            )
                : new Center(
                    child: new Text("No games scheduled",
                        style: new TextStyle(
                            fontFamily: "Default", fontSize: 20.0))),
            onRefresh: () async {
              List<Game> newContent = await loadGames(_startGameDate);
              this.setState(() {
                _gameDate.add(formatDate(_startGameDate), newContent);
                if (formatDate(_selectedDate) == formatDate(_startGameDate))
                  _games = newContent;
              });
            }),
          color: Colors.white,
        ));
  }

  void _changeDate(int day) {
    _selectedDate = new DateTime.fromMillisecondsSinceEpoch(
        _selectedDate.add(new Duration(days: day)).millisecondsSinceEpoch);
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
        if (formatDate(_selectedDate) == formatDate(_startGameDate))
          _games = newContent;
      });
    });
  }

  Future _refresh() async {
    List<Game> newContent;

    if (!_gameDate.containsKey(formatDate(_selectedDate)))
      newContent = await loadGames(_selectedDate);
    else
      newContent = _gameDate.getValue(formatDate(_selectedDate));

    this.setState(() {
      _games = newContent;
      if (!_gameDate.containsKey(formatDate(_selectedDate)))
        _gameDate.add(formatDate(_selectedDate), newContent);
    });
    return new Future<Null>.value();
  }
}
