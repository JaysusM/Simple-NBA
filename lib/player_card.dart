import 'package:flutter/material.dart';
import 'player.dart';
import 'teams.dart';
import 'data.dart';
import 'loading_animation.dart';

class LeaguePlayersListWidget extends StatefulWidget {
  State createState() => new LeaguePlayersListWidgetState();
}

class LeaguePlayersListWidgetState extends State {
  final TextEditingController controller = new TextEditingController();
  String filter = "";
  List<Player> players;

  @override
  void initState() {
    controller.addListener(() {
      this.setState(() {
        filter = controller.text.toLowerCase();
      });
    });
    super.initState();
  }

  Widget throwError(String s) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text(
              "Simple NBA",
              style: new TextStyle(fontFamily: 'Default', fontSize: 22.0),
            ),
            backgroundColor: new Color.fromARGB(0xff, 0x18, 0x2b, 0x4a)),
        body: new Container(
            child: new Stack(children: <Widget>[
              new Container(
                child: new Center(
                    child: new Text(
                      "$s Error loading app, check "
                          "your internet connection. Press the button to reload the app.",
                      style: new TextStyle(fontFamily: 'Signika', fontSize: 18.0),
                    )),
                padding: new EdgeInsets.all(15.0),
              ),
              new Container(
                child: new Center(
                    child: new FloatingActionButton(
                      onPressed: () {
                        this.setState(() {});
                      },
                      child: new Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                      backgroundColor: new Color(0xff34435a),
                    )),
                padding: new EdgeInsets.only(top: 150.0),
              )
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Title(
            color: Colors.white,
            child: new Text("Players",
                style:
                    new TextStyle(fontFamily: "Default", color: Colors.white)),
          ),
          backgroundColor: new Color.fromARGB(0xff, 0x18, 0x2b, 0x4a),
          flexibleSpace: new Container(
            child: new TextField(
              controller: controller,
              decoration: new InputDecoration(
                  hintText: 'Filter players',
                  contentPadding: new EdgeInsets.only(left: 3.0, top: 10.0),
                  icon: new Container(
                    child: new Icon(Icons.search),
                    padding: new EdgeInsets.only(top: 10.0, left: 5.0),
                  )),
            ),
            margin: new EdgeInsets.only(top: 31.0, left: 160.0, right: 10.0),
            decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.all(new Radius.circular(55.0)),
                border: new Border.all(width: 2.0, color: Colors.white12)),
            width: MediaQuery.of(context).size.width - 80.0,
            height: 40.0,
          )),
      body: (players == null)
        ? new FutureBuilder(
          future: loadAllPlayers(),
          builder: (BuildContext context, AsyncSnapshot response) {
            if (response.hasError)
              return throwError(response.error.toString());
            else if (response.connectionState == ConnectionState.waiting)
              return new loadingAnimation();
            else {
              players = response.data;
              return loadFilteredPlayersView();
            }
          })
          : loadFilteredPlayersView()
    );
  }

  Widget loadFilteredPlayersView() {
    List<Widget> filteredPlayersWidget =
    players.where((player) =>
    player.firstName
        .toLowerCase()
        .startsWith(filter) ||
        player.lastName
            .toLowerCase()
            .startsWith(filter))
        .map((player) => new PlayerCard(player))
        .toList();

    return (filteredPlayersWidget.isNotEmpty)
    ? new ListView(children: filteredPlayersWidget)
        : new Center(child: new Text(
    "No players found",
    style: new TextStyle(
    fontFamily: 'Signika',
    fontSize: 20.0,
    color: Colors.black),
    ));
  }

}

class PlayerCard extends StatefulWidget {
  Player player;

  PlayerCard(this.player);
  
  State createState() => new PlayerCardState();
}

class PlayerCardState extends State<PlayerCard> with SingleTickerProviderStateMixin {

  bool isBack;

  @override
  void initState() {
    super.initState();
    isBack = false;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = new TextStyle(fontFamily: 'Signika', fontSize: 18.0);
    TextStyle name = new TextStyle(fontFamily: 'Signika', fontSize: 22.0);

    return new GestureDetector(child: new Container(
      child: (!isBack) ? new Stack(
        children: <Widget>[
          (Team.teamMap.containsKey(widget.player.teamId))
              ? new Positioned(
                    child: new Image(
                      image: new AssetImage("assets/"
                          "${Team.teamMap.getValue(widget.player.teamId)["tricode"]}"
                          ".png"),
                      height: 40.0,
                      width: 40.0,
                    ),
                  top: 10.0,
                  left: 10.0)
              : new Container(),
          new Positioned(
            child: new FadeInImage(
              placeholder: new AssetImage("assets/noPlayer.png"),
              image: new NetworkImage(Player.getImage(widget.player.id)),
              height: 110.0,
              width: 110.0,
            ),
            top: 3.0,
            left: 15.0,
          ),
          new Positioned(
            child: new Text(
              "${widget.player.firstName}",
              style: style,
            ),
            left: 150.0,
            top: 5.0,
          ),
          new Positioned(
            child: new Text(
              "${widget.player.lastName}",
              style: name,
            ),
            left: 150.0,
            top: 25.0,
          ),
          new Positioned(
            child: new Text(
              "Pos: ${widget.player.pos}\t     ${widget.player.years} Years",
              style: style,
            ),
            left: 150.0,
            top: 52.0,
          ),
          new Positioned(
            child: new Text(
              "#${widget.player.number}",
              style: style,
            ),
            left: 105.0,
            top: 10.0,
          ),
          new Positioned(
            child: new Text(
    (widget.player.draft['pickNum'].isNotEmpty)
        ? "Draft ${widget.player.draft['seasonYear']}\tPick ${widget.player.draft['pickNum']}"
        : "Undrafted",
              style: style,
            ),
            left: 150.0,
            top: 75.0,
          ),
        ],
      )
      : new Stack(
        children: <Widget>[
          (Team.teamMap.containsKey(widget.player.teamId))
              ? new Positioned(
              child: new Image(
                image: new AssetImage("assets/"
                    "${Team.teamMap.getValue(widget.player.teamId)["tricode"]}"
                    ".png"),
                height: 40.0,
                width: 40.0,
              ),
              top: 10.0,
              left: 10.0)
              : new Container(),
          new Positioned(
            child: new FadeInImage(
              placeholder: new AssetImage("assets/noPlayer.png"),
              image: new NetworkImage(Player.getImage(widget.player.id)),
              height: 110.0,
              width: 110.0,
            ),
            top: 3.0,
            left: 15.0,
          ),
          new Positioned(
            child: new Text(
              "${widget.player.firstName}",
              style: style,
            ),
            left: 150.0,
            top: 5.0,
          ),
          new Positioned(
            child: new Text(
              "${widget.player.lastName}",
              style: name,
            ),
            left: 150.0,
            top: 25.0,
          ),
          new Positioned(
            child: new Text(
              "#${widget.player.number}",
              style: style,
            ),
            left: 105.0,
            top: 10.0,
          ),
          new Positioned(
            child: (widget.player.ppg == null)
                ? new FutureBuilder(future: setSeasonStats(widget.player),
            builder: (BuildContext context, AsyncSnapshot response) {
              if(response.hasError)
                return new Center(child: const Text("Error"));
              else if(response.connectionState == ConnectionState.waiting)
                return new Text("\nLoading...", style: style);
              else
                return statsText(style);
            }) : statsText(style),
            left: 150.0,
            top: 52.0,
          )
        ],
      ),
      decoration: new BoxDecoration(
          border: new Border(
              bottom: new BorderSide(width: 2.0, color: Colors.black12))),
      height: 100.0,
    ),
    onTap: () {
      this.setState(() {
        isBack = !isBack;
      });
    },
    );
  }

  Widget statsText(TextStyle style) {
    return new Text(
      "PPG: ${widget.player.ppg}\tRPG: ${widget.player.rpg}\nAPG: ${widget.player.apg}",
      style: style,
    );
  }
}
