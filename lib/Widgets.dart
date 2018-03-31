import 'package:flutter/material.dart';
import 'Games.dart';
import 'Player.dart';
import 'Teams.dart';

class GameCard extends StatefulWidget {
  GameCard(Game g) {
    String text = (g.status == 1)
        ? "${g.visitor.tricode}  ${g.time}  ${g.home.tricode}"
        : "${g.visitor.tricode}  ${g.visitor.score}-${g.home.score}  ${g.home
        .tricode}";

    _title = new Center(
        child: new Text(text,
            style: new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: (g.active) ? Colors.red : Colors.black,
                fontFamily: 'Mono')));

    final String noTeam = 'assets/noteam.png';
    String visitorLogo = 'assets/${g.visitor.tricode.toUpperCase()}.png';
    String homeLogo = 'assets/${g.home.tricode.toUpperCase()}.png';

    //TODO If we don't have picture in our assets we must provide a default one using noteam.png
    _assetVisitorLogo = new AssetImage(visitorLogo);
    _assetHomeLogo = new AssetImage(homeLogo);

    _game = g;
  }

  AssetImage _assetVisitorLogo, _assetHomeLogo;
  Widget _title;
  Game _game;
  List<Player> _leaders;

  set leaders(List<Player> value) {
    _leaders = value;
  }

  get leaders => _leaders;

  State<GameCard> createState() => new TapCard();
}

class TapCard extends State<GameCard> {
  double _size;
  bool tapped;

  TapCard() {
    _size = 30.0;
    tapped = false;
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () {
          this.setState(() {
            tapped = !tapped;
          });
        },
        child: new Card(
          child: new Container(
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[checkTapped(context)]),
              padding: new EdgeInsets.only(bottom: 10.0, top: 10.0),
              decoration: new BoxDecoration(
                  border: new Border(
                      bottom:
                          new BorderSide(width: 1.0, color: Colors.black45)))),
          elevation: 0.0,
        ));
  }

  Widget checkTapped(BuildContext context) {
    if (!tapped) {
      this._size = 30.0;
      return new Row(
        children: <Widget>[
          new Container(
              child: new Image(
                  image: widget._assetVisitorLogo, height: _size, width: _size),
              padding: new EdgeInsets.only(right: 10.0, left: 10.0)),
          widget._title,
          new Container(
              child: new Image(
                  image: widget._assetHomeLogo, height: _size, width: _size),
              padding: new EdgeInsets.only(right: 10.0, left: 10.0))
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
    } else {
      this._size = 100.0;
      return new SizedBox(
        height: 230.0,
        width: 200.0,
        child: new Stack(
          children: <Widget>[
            new Positioned(
                child: new Image(
                    image: widget._assetVisitorLogo,
                    height: _size,
                    width: _size),
                left: 10.0),
            new Positioned(
              child: new Image(
                  image: widget._assetHomeLogo, height: _size, width: _size),
              right: 10.0,
            ),
            new Positioned(
              child: new Text(
                  "${widget._game.visitor.score}-${widget._game.home.score}",
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Mono',
                      fontSize: 24.0,
                      color:
                          (widget._game.active) ? Colors.red : Colors.black)),
              top: 34.0,
              left: MediaQuery.of(context).size.width / 2 -
                  (((20.0 * 4) / 2) + 12.0),
            ),
            new Positioned(
                child: new Text("${widget._game.period} ${widget._game.clock}",
                    style: new TextStyle(
                        fontSize: 20.0,
                        color:
                            (widget._game.active) ? Colors.red : Colors.black,
                        fontFamily: 'Mono')),
                top: 70.0,
                left: MediaQuery.of(context).size.width / 2 -
                    (((20.0 * 4) / 2) + 8.0)),
            new Positioned(
                child: new Text(
                    "${widget._game.visitor.win}-${widget._game.visitor.loss}",
                    style: new TextStyle(fontSize: 17.0, color: Colors.black)),
                top: 98.0,
                left: 40.0),
            new Positioned(
                child: new Text(
                    "${widget._game.home.win}-${widget._game.home.loss}",
                    style: new TextStyle(fontSize: 17.0, color: Colors.black)),
                top: 98.0,
                right: 40.0),
            new Positioned(
                child: new Text(
                    (widget._game.active ||
                            (!widget._game.active &&
                                widget._game.clock == "FINAL"))
                        ? ""
                        : widget._game.time,
                    style: new TextStyle(
                        fontSize: 17.0,
                        color: Colors.black,
                        fontFamily: "Mono")),
                top: 6.0,
                left: MediaQuery.of(context).size.width / 2 - ((20.0 * 4) / 2)),
            new Positioned(
                child: new Container(
                    child: (widget.leaders != null)
                        ? getWidgetFromPlayer(10, widget.leaders, context)
                        : new FutureBuilder(
                            future:
                                loadLeaders(widget._game.id, widget._game.date),
                            builder: (BuildContext c, AsyncSnapshot response) {
                              if (response.hasError)
                                return new FutureBuilder(
                                    future: loadTeamsLeaders(widget._game),
                                    builder: (BuildContext c,
                                        AsyncSnapshot response) {
                                      if (response.hasError)
                                        return new Center(
                                            child: new Text("ERROR"));
                                      else if (!response.hasData)
                                        return new Container(
                                          child: new Text("Loading...",
                                              style: new TextStyle(
                                                  fontSize: 16.0)),
                                          margin: new EdgeInsets.only(
                                              left:
                                                  MediaQuery.of(c).size.width /
                                                      2.5)
                                        );
                                      else {
                                        widget.leaders = response.data;
                                        return getWidgetFromPlayer(
                                            10, response.data, context);
                                      }
                                    });
                              else if (!response.hasData)
                                return new Container(
                                    child: new Text("Loading...",
                                        style: new TextStyle(
                                            fontSize: 16.0)),
                                    margin: new EdgeInsets.only(
                                        left:
                                        MediaQuery.of(c).size.width /
                                            2.5)
                                );
                              else {
                                widget.leaders = response.data;
                                return getWidgetFromPlayer(
                                    12, response.data, context);
                              }
                            }),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width),
                top: 135.0),
          ],
        ),
      );
    }
  }
}

Widget getWidgetFromPlayer(int nameSizeMaxLength, List<Player> players, BuildContext context) {
  return new Column(
    children: <Widget>[
      leaderTile(nameSizeMaxLength, 1, players[3], players[0], context),
      leaderTile(nameSizeMaxLength, 2, players[4], players[1], context),
      leaderTile(nameSizeMaxLength, 3, players[5], players[2], context)
    ],
  );
}

Widget leaderTile(
    int nameSize, int rowNum, Player player1, Player player2, BuildContext context) {
  String stat1, stat2;

  switch (rowNum) {
    case 1:
      stat1 = "(${player1.points}PTS)";
      stat2 = "(${player2.points}PTS)";
      break;
    case 2:
      stat1 = "(${player1.rebounds}REB)";
      stat2 = "(${player2.rebounds}REB)";
      break;
    default:
      stat1 = "(${player1.assist}AST)";
      stat2 = "(${player2.assist}AST)";
      break;
  }

  if (player1.sName.length >= nameSize) player1.name = player1.sName.substring(0, nameSize);

  if (player2.sName.length >= nameSize) player2.name = player2.sName.substring(0, nameSize);

  return new Row(
    children: <Widget>[
      new Container(
        child: new Center(
            child: new Text("${player1.sName.toUpperCase()} $stat1")),
        color: new Color.fromRGBO(217, 217, 255, 1.0),
        width: MediaQuery.of(context).size.width / 2 - 5,
        padding: new EdgeInsets.symmetric(vertical: 7.0),
        margin: new EdgeInsets.only(bottom: 3.0, right: 1.0),
      ),
      new Container(
        child: new Center(
            child: new Text("${player2.sName.toUpperCase()} $stat2")),
        color: new Color.fromRGBO(217, 217, 255, 1.0),
        width: MediaQuery.of(context).size.width / 2 - 5,
        padding: new EdgeInsets.symmetric(vertical: 7.0),
        margin: new EdgeInsets.only(bottom: 3.0, left: 1.0),
      )
    ],
  );
}

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
                        child: new Text(_mainTeam.position,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                                fontFamily: 'Default')),
                        left: 5.0,
                        top: 6.5),
                    new Positioned(
                        child: new Image(
                            image: new AssetImage("assets/${_mainTeam.tricode
                                .toUpperCase()}.png"),
                            height: 30.0,
                            width: 30.0),
                        left: 25.0),
                    new Positioned(
                        child: new Text(_mainTeam.tricode,
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                fontFamily: 'Default')),
                        left: 65.0,
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
      margin: new EdgeInsets.only(bottom: 1.0),
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

      widgets.add(new StandingCard(it.current, playoffBackground));
    }

    tabs.add(new Tab(
        child: new Container(
      child: new ListView(children: widgets),
      decoration: new BoxDecoration(
          border: new Border.all(width: 0.1),
          borderRadius: new BorderRadius.all(new Radius.circular(4.0)),
          boxShadow: <BoxShadow>[
            new BoxShadow(
                offset: new Offset(2.0, 1.0),
                color: Colors.grey,
                blurRadius: 6.0)
          ]),
      margin: new EdgeInsets.fromLTRB(8.0, 17.0, 8.0, 0.0),
    )));
  }

  return tabs;
}
