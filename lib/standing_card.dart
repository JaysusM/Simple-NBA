import 'package:flutter/material.dart';
import 'teams.dart';

class StandingCard extends StatelessWidget {
  final Team _mainTeam;
  final Color _color;

  StandingCard(this._mainTeam, this._color);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Container(
          child: new Column(
            children: <Widget>[
              new SizedBox(
                child: new Stack(
                  children: <Widget>[
                    new Positioned(
                        child: new Text(
                            (_mainTeam.position.length > 1)
                                ? _mainTeam.position
                                : " ${_mainTeam.position}",
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                                fontFamily: 'Overpass')),
                        left: 0.0,
                        top: 6.5),
                    new Positioned(
                        child: new Image(
                            image: new AssetImage("assets/${_mainTeam.tricode
                                .toUpperCase()}.png"),
                            height: 30.0,
                            width: 30.0),
                        left: 25.0),
                    new Positioned(
                      child: new Text(_mainTeam.clinchedChar,
                          style: new TextStyle(
                              fontFamily: "Overpass", fontSize: 12.0)),
                      top: 1.0,
                      left: 103.0,
                    ),
                    new Positioned(
                        child: new Text(_mainTeam.tricode,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                fontFamily: 'Overpass')),
                        left: 65.0,
                        top: 5.0),
                    new Positioned(
                        child: new Text(
                          _mainTeam.winLoss,
                          style: new TextStyle(
                              fontFamily: 'Overpass',
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0),
                        ),
                        left: 126.0,
                        top: 3.0),
                    new Positioned(
                        child: new Text(_mainTeam.gb,
                            style: new TextStyle(
                                fontFamily: 'Overpass',
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0)),
                    top: 3.0,
                    right: 6.0,)
                  ],
                ),
                height: 30.0,
                width: MediaQuery.of(context).size.width,
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.stretch,
          ),
          padding: new EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 2.0)),
      color: _color,
      margin: new EdgeInsets.only(bottom: 1.0),
    );
  }
}
