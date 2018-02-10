import 'package:flutter/material.dart';
import 'Games.dart';

class gameCard extends StatefulWidget {
  gameCard(game g) {
    _title = new Center(
        child: new Text(
            "${g.visitor.tricode} ${g.visitor.score}-${g.home.score} ${g
                .home.tricode}",
            style: new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: (g.active) ? Colors.red : Colors.black,
                fontFamily: 'Mono')));
    _assetHomeLogo =
        new AssetImage('assets/${g.visitor.tricode.toUpperCase()}.png');
    _assetAwayLogo =
        new AssetImage('assets/${g.home.tricode.toUpperCase()}.png');
    _Game = g;
  }

  AssetImage _assetHomeLogo, _assetAwayLogo;
  Widget _title;
  game _Game;

  createState() => new tapCard(_assetHomeLogo, _title, _assetAwayLogo, _Game);
}

class tapCard extends State<gameCard> {
  tapCard(this._home, this._title, this._away, this._game);

  AssetImage _home, _away;
  Widget _title;
  double _size = 30.0;
  game _game;
  bool tapped = false;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () {
          this.setState(() {
            (tapped) ? tapped = false : tapped = true;
          });
        },
        child: new Card(
          child: new Container(
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[checkTapped()]),
              padding: new EdgeInsets.only(bottom: 10.0, top: 10.0)),
        ));
  }

  Widget checkTapped() {
    if (!tapped) {
      this._size = 30.0;
      return new Row(
        children: <Widget>[
          new Container(
              child: new Image(image: _home, height: _size, width: _size),
              padding: new EdgeInsets.only(right: 10.0, left: 10.0)),
          _title,
          new Container(
              child: new Image(image: _away, height: _size, width: _size),
              padding: new EdgeInsets.only(right: 10.0, left: 10.0))
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    } else {
      this._size = 100.0;
      return new SizedBox(
        height: 200.0,
        width: 200.0,
        child: new Stack(
          children: <Widget>[
            new Positioned(
                child: new Image(image: _home, height: _size, width: _size),
                left: 10.0),
            new Positioned(
              child: new Image(image: _away, height: _size, width: _size),
              right: 10.0,
            ),
            new Positioned(
              child: new Text("${_game.visitor.score}-${_game.home.score}",
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Mono',
                      fontSize: 24.0,
                      color: (_game.active) ? Colors.red : Colors.black)),
              top: 34.0,
              left: MediaQuery.of(context).size.width / 2 -
                  (((20.0 * _game.clock.length) / 2) + 12.0),
            ),
            new Positioned(
                child: new Text("${_game.period} ${_game.clock}",
                    style: new TextStyle(
                        fontSize: 20.0,
                        color: (_game.active) ? Colors.red : Colors.black,
                        fontFamily: 'Mono')),
                top: 70.0,
                left: MediaQuery.of(context).size.width / 2 -
                    (((20.0 * _game.clock.length) / 2) + 8.0)),
            new Positioned(
                child: new Text("${_game.visitor.win}-${_game.visitor.loss}",
                    style: new TextStyle(fontSize: 17.0, color: Colors.black)),
                top: 98.0,
                left: 40.0),
            new Positioned(
                child: new Text("${_game.home.win}-${_game.home.loss}",
                    style: new TextStyle(fontSize: 17.0, color: Colors.black)),
                top: 98.0,
                right: 40.0),
            new Positioned(
                child: new Text((_game.active) ? "" : _game.time,
                    style: new TextStyle(
                        fontSize: 17.0,
                        color: Colors.black,
                        fontFamily: "Mono")),
                top: 6.0,
                left: MediaQuery.of(context).size.width / 2 -
                    (((20.0 * _game.clock.length) / 2) + 4.0))
          ],
        ),
      );
    }
  }
}

Widget getSpecialPlayer() {
  return null;
}

List<Widget> getWidgetFromGame(List<game> games) {
  List<Widget> gameCards = new List<Widget>();

  for (game g in games) {
    gameCards.add(new gameCard(g));
  }

  return gameCards;
}

Widget loadingScreen() {
  return new Container(
      decoration: new BoxDecoration(
          image: new DecorationImage(
              image: new AssetImage("assets/NBA.png"), fit: BoxFit.fitHeight)),
      child: null);
}

class standingCard extends StatelessWidget {
  team _mainTeam;
  Color _color;

  standingCard(this._mainTeam, this._color);

  @override
  Widget build(BuildContext context) {
    return new Card(
        child: new Container(
            child: new Column(
              children: <Widget>[
                new SizedBox(
                  child: new Stack(
                    children: <Widget>[
                      new Positioned(
                          child: new Image(
                              image: new AssetImage(
                                  "assets/${_mainTeam.tricode.toUpperCase()}.png"),
                              height: 30.0,
                              width: 30.0),
                          left: 10.0),

                      new Positioned(child: new Text(
                      _mainTeam.name.substring(_mainTeam.name.lastIndexOf(" ")),
                      style: new TextStyle( fontWeight: FontWeight.bold, fontSize: 20.0)),
                      left: 50.0,
                      top: 5.0),
                      new Positioned(
                          child: new Text(_mainTeam.winLoss,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 23.0),
                          ),
                          right: 20.0,
                      top: 3.0),
                    ],
                  ),
                  height: 30.0,
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
            padding: new EdgeInsets.all(8.0)),
      color: _color,
    );
  }
}

getWidgetFromStandings(List<List<team>> standings) {
  List<Widget> tabs = new List<Widget>();

  var auxIt = standings.iterator;

 while(auxIt.moveNext()) {
   int counter = -1;
   var it = auxIt.current.iterator;
   Color playoffBackground = Colors.orangeAccent;

   List<Widget> widgets = new List<Widget>();

   while (it.moveNext()) {
     counter++;
     if (counter > 8)
       playoffBackground = Colors.white;

     widgets.add(new standingCard(it.current, playoffBackground));
   }

  tabs.add(new Tab(child: new ListView(
   children: widgets,
   padding: new EdgeInsets.all(8.0),
  )));

 }

  return tabs;
}
