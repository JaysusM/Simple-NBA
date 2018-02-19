import 'package:flutter/material.dart';
import 'Games.dart';

class gameCard extends StatefulWidget {
  gameCard(game g){
    _title = new Center(
        child: new Text(
            "${g.visitor.tricode} ${g.visitor.score}-${g.home.score} ${g
                .home.tricode}",
            style: new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: (g.active) ? Colors.red : Colors.black,
                fontFamily: 'Mono')));

    final String noTeam = 'assets/noteam.png';
    String visitorLogo = 'assets/${g.visitor.tricode.toUpperCase()}.png';
    String homeLogo = 'assets/${g.home.tricode.toUpperCase()}.png';

    //TODO If we don't have picture in our assets must we provide it default one using noteam.png
    _assetVisitorLogo = new AssetImage(visitorLogo);
    _assetHomeLogo = new AssetImage(homeLogo);

      _game = g;
    }

  AssetImage _assetVisitorLogo, _assetHomeLogo;
  Widget _title;
  game _game;

  State<gameCard> createState() => new tapCard();
}

class tapCard extends State<gameCard> {

  double _size = 30.0;
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
              child: new Image(image: widget._assetVisitorLogo, height: _size, width: _size),
              padding: new EdgeInsets.only(right: 10.0, left: 10.0)),
          widget._title,
          new Container(
              child: new Image(image: widget._assetHomeLogo, height: _size, width: _size),
              padding: new EdgeInsets.only(right: 10.0, left: 10.0))
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    } else {
      this._size = 100.0;
      return new SizedBox(
        height: 150.0,
        width: 200.0,
        child: new Stack(
          children: <Widget>[
            new Positioned(
                child: new Image(image: widget._assetVisitorLogo, height: _size, width: _size),
                left: 10.0),
            new Positioned(
              child: new Image(image: widget._assetHomeLogo, height: _size, width: _size),
              right: 10.0,
            ),
            new Positioned(
              child: new Text("${widget._game.visitor.score}-${widget._game.home.score}",
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Mono',
                      fontSize: 24.0,
                      color: (widget._game.active) ? Colors.red : Colors.black)),
              top: 34.0,
              left: MediaQuery.of(context).size.width / 2 -
                  (((20.0 * 4) / 2) + 12.0),
            ),
            new Positioned(
                child: new Text("${widget._game.period} ${widget._game.clock}",
                    style: new TextStyle(
                        fontSize: 20.0,
                        color: (widget._game.active) ? Colors.red : Colors.black,
                        fontFamily: 'Mono')),
                top: 70.0,
                left: MediaQuery.of(context).size.width / 2 -
                    (((20.0 * 4) / 2) + 8.0)),
            new Positioned(
                child: new Text("${widget._game.visitor.win}-${widget._game.visitor.loss}",
                    style: new TextStyle(fontSize: 17.0, color: Colors.black)),
                top: 98.0,
                left: 40.0),
            new Positioned(
                child: new Text("${widget._game.home.win}-${widget._game.home.loss}",
                    style: new TextStyle(fontSize: 17.0, color: Colors.black)),
                top: 98.0,
                right: 40.0),
            new Positioned(
                child: new Text(
                    (widget._game.active || (!widget._game.active && widget._game.clock == "FINAL")) ? "" : widget._game.time,
                    style: new TextStyle(
                        fontSize: 17.0,
                        color: Colors.black,
                        fontFamily: "Mono")),
                top: 6.0,
                left: MediaQuery.of(context).size.width / 2 -
                    (((20.0 * 4) / 2) + 4.0))
          ],
        ),
      );
    }
  }
}

Widget getSpecialPlayer() {
  return null;
}

Widget loadingScreen() {
  return new Container(
      decoration: new BoxDecoration(
          image: new DecorationImage(
              image: new AssetImage("assets/NBA.png"), fit: BoxFit.contain)),
      child: null
  );
}

class standingCard extends StatelessWidget {
  Team _mainTeam;
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
                            image: new AssetImage("assets/${_mainTeam.tricode
                                    .toUpperCase()}.png"),
                            height: 30.0,
                            width: 30.0),
                        left: 10.0),
                    new Positioned(
                        child: new Text(_mainTeam.tricode,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                fontFamily: 'Default')),
                        left: 50.0,
                        top: 5.0),
                    new Positioned(
                        child: new Text(
                          _mainTeam.winLoss,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 23.0),
                        ),
                        right: 10.0,
                        top: 3.0),
                  ],
                ),
                height: 30.0,
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.stretch,
          ),
          padding: new EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 2.0)),
      color: _color,
    );
  }
}

getWidgetFromStandings(List<List<Team>> standings) {
  List<Widget> tabs = new List<Widget>();

  var auxIt = standings.iterator;

  while (auxIt.moveNext()) {
    int counter = -1;
    var it = auxIt.current.iterator;
    Color playoffBackground = new Color.fromRGBO(230, 230, 230, 1.0);

    List<Widget> widgets = new List<Widget>();

    while (it.moveNext()) {
      counter++;
      if (counter >= 8) playoffBackground = Colors.white;

      widgets.add(new standingCard(it.current, playoffBackground));
    }

    widgets.insert(0, standingInfo());

    tabs.add(new Tab(
        child: new ListView(
      children: widgets,
      padding: new EdgeInsets.all(8.0),
    )));
  }

  return tabs;
}

Widget standingInfo() {
  return new Card(
    child: new Container(
        child: new Column(
          children: <Widget>[
            new SizedBox(
              child: new Stack(
                children: <Widget>[
                  new Positioned(
                      child: new Text("CODE",
                          style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              fontFamily: 'Default')),
                      left: 50.0,
                      top: 5.0),
                  new Positioned(
                      child: new Text(
                        "W - L    %RATIO",
                        style: new TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 23.0),
                      ),
                      right: 8.0,
                      top: 3.0),
                ],
              ),
              height: 30.0,
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
        padding: new EdgeInsets.all(8.0)),
    color: new Color.fromRGBO(20, 20, 20, 0.30),
  );
}
