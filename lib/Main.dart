import 'package:flutter/material.dart';
import 'Games.dart';
import 'Widgets.dart';
import 'dart:async';
import 'Data.dart';
import 'DatabaseCreation.dart';

void main() {
  runApp(new MaterialApp(home: new mainFrame()));
}

class mainFrame extends StatefulWidget {

  mainFrame()
  {
    startDB();
  }

  createState() => new mainFrameState();
}

class mainFrameState extends State<mainFrame>
    with SingleTickerProviderStateMixin {
  TabController _mainNavigationController;
  List<Widget> _standingsWidgets;
  List<game> _calendarData;

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
        future: loadGames(),
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
            new calendarTab(_calendarData),
            standingsTab(_standingsWidgets)
          ],
          controller: _mainNavigationController,
        ));
  }
}

Widget standingsTab(List<Widget> standings) {
  return new Container(
    child: new standingsWidgetView(standings),
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

class standingsWidgetView extends StatefulWidget {
  List<Widget> _standings;

  standingsWidgetView(this._standings);

  createState() => new standingsWidgetViewState(_standings);
}

class standingsWidgetViewState extends State
    with SingleTickerProviderStateMixin {
  List<Widget> _standings;

  standingsWidgetViewState(this._standings);

  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: new AppBar(
            title: new TabBar(tabs: <Tab>[
              new Tab(child: new Text("EAST")),
              new Tab(child: new Text("WEST"))
            ]),
          ),
          body: new TabBarView(children: _standings),
        ));
  }
}

class calendarTab extends StatefulWidget {
  List<game> games;

  calendarTab(this.games);

  State<StatefulWidget> createState() => new calendarTabState();
}

class calendarTabState extends State<calendarTab> {
  List<game> _games;
  Timer timer;

  Widget build(BuildContext context) {
    return new ListView(
      children: _games.map((game) => new gameCard(game)).toList(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  void initState() {
    _games = widget.games;
    super.initState();
    timer = new Timer.periodic(new Duration(seconds: 20), (Timer timer) async {
      List<game> newContent = await loadGames();
      this.setState(() {
        _games = newContent;
      });
    });
  }
}
