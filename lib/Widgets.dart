import 'package:flutter/material.dart';
import 'Games.dart';

class gameCard extends StatelessWidget
{
  gameCard(team home, team away)
  {
    _title = new Center(
        child: new Text("${home.tricode} (${home.score} - ${away.score}) ${away.tricode}",
            style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)));
    var assetHomeLogo = new AssetImage('assets/${home.tricode.toUpperCase()}.png');
    var assetAwayLogo = new AssetImage('assets/${away.tricode.toUpperCase()}.png');
    _homeLogo = new Container(
        child: new Image(image: assetHomeLogo, height: size, width: size),
        padding: new EdgeInsets.only(right: 15.0, left: 15.0));
    _visitorLogo = new Container(
        child: new Image(image: assetAwayLogo, height: size, width: size),
        padding: new EdgeInsets.only(right: 15.0, left: 15.0));
  }

  double size = 30.0;
  Widget _title, _homeLogo, _visitorLogo;

  @override
  Widget build(BuildContext context) {
    return new Card(
        child: new Container(
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Row(
                      children: <Widget>[
                        _homeLogo, _title, _visitorLogo
                      ],
                      mainAxisAlignment: MainAxisAlignment.center
                  )
                ]
            ),
            padding: new EdgeInsets.only(bottom: 10.0,
                top:10.0)
        )
    );
  }
}
