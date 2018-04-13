import 'package:flutter/material.dart';
import 'games.dart';
import 'widgets.dart';
import 'player.dart';
import 'twitter.dart';
import 'match_info_page.dart';

class GameCard extends StatefulWidget {
  GameCard(Game g) {
    String text = (g.status == 1)
        ? "${g.visitor.tricode}  ${g.time}  ${g.home.tricode}"
        : "${g.visitor.tricode}  ${g.visitor.score}-${g.home.score}  ${g.home
        .tricode}";

    _title = new Center(
        child: new Text(text,
            style: new TextStyle(
                fontSize: 21.0,
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
  bool _tapped;

  TapCard() {
    _size = 30.0;
    _tapped = false;
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () {
          this.setState(() {
            _tapped = !_tapped;
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
                          new BorderSide(width: 1.3, color: Colors.black45))),
          ),
          elevation: 0.0,
          color: new Color(0xffffffff),
        ));
  }

  Widget checkTapped(BuildContext context) {
    if (!_tapped) {
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
              child: new twitterButton(
                  "http://twitter.com/${widget._game.awayTwitter}"),
              left: 5.0,
            ),
            new Positioned(
              child: new twitterButton(
                  "http://twitter.com/${widget._game.homeTwitter}"),
              right: 5.0,
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
                    (20.0 * 4 + 10.0) / 2),
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
                  (widget._game.active || widget._game.status == 3)
                      ? "Game Leaders"
                      : "Season Leaders",
                  style: new TextStyle(
                      fontFamily: "Default",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
                top: 105.0,
                left: MediaQuery.of(context).size.width / 3.18 + 5.0),
            new Positioned(
                child: (widget._game.active ||
                        (!widget._game.active && widget._game.clock == "FINAL"))
                    ? new MaterialButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) =>
                                      new MatchPage(widget._game)));
                        },
                        child: new Chip(label: new Text("Stats")
                        ),
                      )
                    : new Text(" ${widget._game.time}",
                        style: new TextStyle(
                            fontSize: 17.0,
                            color: Colors.black,
                            fontFamily: "Mono")),
                top: 0.0,
                left:
                    MediaQuery.of(context).size.width / 2 - ((20.0 * 4.5) / 2)),
            new Positioned(
                child: new Container(
                    child: (widget.leaders != null)
                        ? getWidgetFromPlayer(10, widget.leaders, context)
                        : (widget._game.status != 1)
                            ? new FutureBuilder(
                                future: loadLeaders(
                                    widget._game.id, widget._game.date),
                                builder:
                                    (BuildContext c, AsyncSnapshot response) {
                                  if (response.hasError)
                                    return new Text("\nData is not available yet", textAlign: TextAlign.center);
                                  else if (!response.hasData)
                                    return new Container(
                                        child: new Text("Loading...",
                                            style:
                                                new TextStyle(fontSize: 16.0)),
                                        margin: new EdgeInsets.only(
                                            left: MediaQuery.of(c).size.width /
                                                2.5));
                                  else {
                                    widget.leaders = response.data;
                                    return getWidgetFromPlayer(
                                        12, response.data, context);
                                  }
                                })
                            : new FutureBuilder(
                                future: loadTeamsLeaders(widget._game),
                                builder:
                                    (BuildContext c, AsyncSnapshot response) {
                                  if (response.hasError)
                                    return new Center(child: new Text("ERROR"));
                                  else if (!response.hasData)
                                    return new Container(
                                        child: new Text("Loading...",
                                            style:
                                                new TextStyle(fontSize: 16.0)),
                                        margin: new EdgeInsets.only(
                                            left: MediaQuery.of(c).size.width /
                                                2.5));
                                  else {
                                    widget.leaders = response.data;
                                    return getWidgetFromPlayer(
                                        10, response.data, context);
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
