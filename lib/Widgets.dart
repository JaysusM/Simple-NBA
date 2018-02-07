import 'package:flutter/material.dart';
import 'Games.dart';

class gameCard extends StatefulWidget {
  gameCard(game g) {
    _title = new Center(
        child: new Text(
            "${g.home.tricode} (${g.home.score} - ${g.visitor.score}) ${g.visitor.tricode}",
            style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: (g.active) ? Colors.redAccent : Colors.black)));
    _assetHomeLogo = new AssetImage('assets/${g.home.tricode.toUpperCase()}.png');
    _assetAwayLogo = new AssetImage('assets/${g.visitor.tricode.toUpperCase()}.png');
    _Game = g;
  }

  AssetImage _assetHomeLogo, _assetAwayLogo;
  Widget _title;
  game _Game;

  createState() =>
      new tapCard(_assetHomeLogo, _title, _assetAwayLogo, _Game);
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
                    children: <Widget>[
                      new Row(
                          children: checkTapped(),
                          mainAxisAlignment: MainAxisAlignment.center
                      )
                    ]
                ),
                padding: new EdgeInsets.only(bottom: 10.0,
                    top: 10.0)
            ),
        )
    );
  }

  List<Widget> checkTapped() {
    if (!tapped) {
      this._size = 30.0;
      return <Widget>[
        new Container(
            child: new Image(image: _home, height: _size, width: _size),
            padding: new EdgeInsets.only(right: 10.0, left: 10.0)),
        _title,
        new Container(
            child: new Image(image: _away, height: _size, width: _size),
            padding: new EdgeInsets.only(right: 10.0, left: 10.0))
      ];
    }
    else {
      this._size = 50.0;
      return <Widget>[
        new Column(
            children: <Widget>[
              new Row(
                  children: [
                    new Container(
                        child: new Image(
                            image: _home, height: _size, width: _size),
                        padding: new EdgeInsets.only(right: 10.0, left: 10.0)),
                    _title,
                    new Container(
                        child: new Image(
                            image: _away, height: _size, width: _size),
                        padding: new EdgeInsets.only(right: 10.0, left: 10.0))
                  ]),
              new Row(
                  children: <Widget>[
                    new Container(
                      child: new Text("${_game.home.win} - ${_game.home.loss}"),
                      padding: new EdgeInsets.only(right: 30.0, left:5.0)),
                    new Text("${_game.period}Q"),
                    new Container(
                      child: new Text("${_game.visitor.win} - ${_game.visitor.loss}"),
                      padding: new EdgeInsets.only(left: 30.0, right: 5.0)
                    )
                  ]
              ),
              getSpecialPlayer()
            ])
      ];
    }
  }

}

Widget getSpecialPlayer()
{
  return null;
}


List<Widget> getWidgetFromGame(List<game> games) {
  List<Widget> gameCards = new List<Widget>();

  for (game g in games) {
    gameCards.add(new gameCard(g));
  }

  return gameCards;
}

Widget loadingScreen()
{
  return new Container(
      decoration: new BoxDecoration(
          image: new DecorationImage(
              image: new AssetImage("assets/NBA.png"),
              fit: BoxFit.fitHeight
          )
      ),
      child: null
  );
}
