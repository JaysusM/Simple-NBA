import 'package:flutter/material.dart';
import 'Games.dart';

class gameCard extends StatefulWidget {
  gameCard(team home, team away) {
    _title = new Center(
        child: new Text(
            "${home.tricode} (${home.score} - ${away.score}) ${away.tricode}",
            style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)));
    _assetHomeLogo = new AssetImage('assets/${home.tricode.toUpperCase()}.png');
    _assetAwayLogo = new AssetImage('assets/${away.tricode.toUpperCase()}.png');
    _home = home;
    _away = away;
  }

  AssetImage _assetHomeLogo, _assetAwayLogo;
  Widget _title;
  team _home, _away;

  createState() =>
      new tapCard(_assetHomeLogo, _title, _assetAwayLogo, _home, _away);
}

class tapCard extends State<gameCard> {

  tapCard(this._home, this._title, this._away, this._homeInstance,
      this._awayInstance);

  AssetImage _home, _away;
  Widget _title;
  double _size = 30.0;
  team _homeInstance, _awayInstance;
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
            )
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
                      child: new Text("${_homeInstance.win} - ${_homeInstance.loss}"),
                      padding: new EdgeInsets.only(right: 50.0, left:5.0)),
                    new Container(
                      child: new Text("${_awayInstance.win} - ${_awayInstance.loss}"),
                      padding: new EdgeInsets.only(left: 50.0, right: 5.0)
                    )
                  ]
              )
            ])
      ];
    }
  }

}


List<Widget> getWidgetFromGame(List<game> games) {
  List<Widget> gameCards = new List<Widget>();

  for (game g in games) {
    gameCards.add(new gameCard(g.home, g.visitor));
  }

  return gameCards;
}


