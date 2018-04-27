import 'package:flutter/material.dart';
import 'bracket.dart';

class PlayoffBracketWidget extends StatelessWidget {
  Bracket bracket;
  double verticalMargin;
  Color color;

  PlayoffBracketWidget(this.bracket,
      [this.verticalMargin = 0.0, this.color = Colors.white]);

  TextStyle style =
      new TextStyle(fontFamily: "Signika", fontSize: 18.0, color: Colors.black);
  TextStyle winnerStyle =
  new TextStyle(fontFamily: "SignikaB", fontSize: 18.0, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Card(
        child: new Container(
          child: new Stack(
            children: <Widget>[
              new Center(
                  child: new Container(
                child: new Opacity(
                  child: new Image(
                    image: (['EAST', 'WEST']
                            .contains(bracket.confName.toUpperCase()))
                        ? new AssetImage("assets/"
                            "${bracket.confName.toUpperCase()}.png")
                        : new AssetImage("assets/finals.gif"),
                    fit: BoxFit.cover,
                  ),
                  opacity: 0.05,
                ),
                width: 220.0,
                padding: new EdgeInsets.symmetric(horizontal: 10.0),
              )
              ),
              new Positioned(
                child: new Text(
                  (this.bracket.roundNum != "4")
                      ? "Round ${this.bracket
                      .roundNum} - ${this.bracket.confName}"
                      : "NBA Finals",
                  style: style,
                ),
                left: 13.3,
                top: 6.0,
              ),
              new Positioned(
                child: new Container(
                  height: 2.0,
                  width: 220.0,
                  color: Colors.black12,
                ),
                top: 31.5,
              ),
              new Positioned(
                child: new Column(
                  children: <Widget>[
                    getTeamRow(
                        this.bracket.topRowDatabaseInfo,
                        this.bracket.topRowSeed,
                        this.bracket.topRowIsSeriesWinner),
                    getTeamRow(
                        this.bracket.bottomRowDatabaseInfo,
                        this.bracket.bottomRowSeed,
                        this.bracket.bottomRowIsSeriesWinner),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                left: 10.0,
                top: 39.0,
              ),
              new Positioned(
                child: new Container(
                  height: 100.0,
                  width: 2.0,
                  color: Colors.black12,
                ),
                left: 175.0,
              ),
              new Positioned(
                child: new Text(this.bracket.topRowWins, style:
    (!this.bracket.topRowIsSeriesWinner) ? style : winnerStyle),
                left: 188.0,
                top: 40.0,
              ),
              new Positioned(
                child: new Text(this.bracket.bottomRowWins, style:
    (!this.bracket.bottomRowIsSeriesWinner) ? style : winnerStyle),
                left: 188.0,
                top: 63.0,
              )
            ],
          ),
          decoration: new BoxDecoration(
            border: new Border.all(width: 1.2, color: Colors.black12),
          ),
        ),
        elevation: 1.0,
        color: (bracket.roundNum == 4.toString()) ? color :
        bracket.confName.toUpperCase() == "WEST" ? new Color.fromRGBO(255, 0, 0, 0.02)
        : new Color.fromRGBO(0, 0, 255, 0.02),
      ),
      height: 100.0,
      width: 220.0,
      margin: new EdgeInsets.symmetric(vertical: verticalMargin),
    );
  }

  Widget getTeamRow(Map team, String seed, bool isWinner) {
    TextStyle winnersStyle = new TextStyle(
        fontFamily: 'SignikaB', fontSize: 18.0, color: Colors.black);
    TextStyle winnersStyleSeed = new TextStyle(
        fontFamily: 'SignikaB', fontSize: 13.0, color: Colors.black);

    return (team == null)
        ? new Container()
        : new Row(
            children: <Widget>[
              new CircleAvatar(
                child: new Image(
                    image: new AssetImage(
                        "assets/${team['tricode'].toString().toUpperCase()}.png"),
                    height: 20.0,
                    width: 20.0),
                radius: 10.0,
                backgroundColor: new Color.fromRGBO(255, 255, 255, 0.1),
              ),
              new Container(
                padding: new EdgeInsets.only(right: 6.0),
              ),
              new Text(team["nickname"],
                  style: (isWinner) ? winnersStyle : style),
              new Container(
                padding: new EdgeInsets.only(right: 5.0),
              ),
              new Container(
                child: new Text("($seed)",
                    style:
    (!isWinner) ? new TextStyle(fontFamily: 'Signika', fontSize: 10.0) : winnersStyleSeed),
                padding: new EdgeInsets.only(top: 3.0),
              )
            ],
          );
  }
}

class BidirectionalPlayoffsView extends StatefulWidget {
  List<List<Bracket>> roundBrackets;

  BidirectionalPlayoffsView(List<Bracket> brackets) {
    List<Bracket> round1 = new List();
    List<Bracket> round2 = new List();
    List<Bracket> round3 = new List();
    List<Bracket> round4 = new List();

    brackets.forEach((bracket) {
      switch (int.parse(bracket.roundNum)) {
        case 1:
          round1.add(bracket);
          break;
        case 2:
          round2.add(bracket);
          break;
        case 3:
          round3.add(bracket);
          break;
        case 4:
          round4.add(bracket);
          break;
      }
    });

    roundBrackets = [round1, round2, round3, round4];
  }

  State createState() => new PlayoffsViewState();
}

class PlayoffsViewState extends State<BidirectionalPlayoffsView> {
  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: new SizedBox(
              child: new ListView(children: getPositionedBrackets()),
              height: 105.0 * widget.roundBrackets[0].length,
              width: 225.0 * 4,
            )));
  }

  List<Widget> getPositionedBrackets() {
    return [
      new Container(
        child: new Stack(
          children: <Widget>[
            new Positioned(
                child: new Column(
                  children: widget.roundBrackets[0]
                      .map((bracket) => new PlayoffBracketWidget(bracket))
                      .toList(),
                ),
                left: 0.0,
                top: 0.0),
            new Positioned(
                child: new Column(
                  children: widget.roundBrackets[1]
                      .map((bracket) => new PlayoffBracketWidget(bracket, 50.0))
                      .toList(),
                ),
                left: 225.0,
                top: 0.0),
            new Positioned(
                child: new Column(
                  children: widget.roundBrackets[2]
                      .map(
                          (bracket) => new PlayoffBracketWidget(bracket, 151.0))
                      .toList(),
                ),
                left: 450.0,
                top: 0.0),
            new Positioned(
                child: new Container(
                  child: new Column(
                    children: widget.roundBrackets[3]
                        .map((bracket) => new PlayoffBracketWidget(bracket,
                            350.0, new Color.fromRGBO(255, 215, 2, 1.0)))
                        .toList(),
                  ),
                ),
                left: 675.0,
                top: 0.0),
          ],
        ),
        height: 100.0 * widget.roundBrackets[0].length,
        width: 225.0 * 4,
      )
    ];
  }
}
