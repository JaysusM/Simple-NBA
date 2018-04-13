import 'package:flutter/material.dart';
import 'player.dart';
import 'teams.dart';

class PlayerCard extends StatelessWidget {
  Player player;

  PlayerCard(this.player);

  @override
  Widget build(BuildContext context) {
    TextStyle style = new TextStyle(fontFamily: 'Signika', fontSize: 18.0);
    TextStyle name = new TextStyle(fontFamily: 'Signika', fontSize: 22.0);

    return new Container(
      child: new Stack(
        children: <Widget>[
          (Team.teamMap.containsKey(player.teamId))
              ? new Positioned(
                  child: new Opacity(child: new Image(
                    image: new AssetImage("assets/"
                        "${Team.teamMap.getValue(player.teamId)["tricode"]}"
                        ".png"),
                    height: 100.0,
                    width: 100.0,
                  ),
                  opacity: 0.1,
                  ),
                  left: 152.0
                )
              : new Container(),
          new Positioned(
            child: new FadeInImage(
              placeholder: new AssetImage("assets/noPlayer.png"),
              image: new NetworkImage(Player.getImage(player.id)),
              height: 110.0,
              width: 110.0,
            ),
            top: 3.0,
            left: 15.0,
          ),
          new Positioned(
            child: new Text(
              "${player.firstName}",
              style: style,
            ),
            left: 150.0,
            top: 5.0,
          ),
          new Positioned(
            child: new Text(
              "${player.lastName}",
              style: name,
            ),
            left: 150.0,
            top: 25.0,
          ),
          new Positioned(
            child: new Text(
              "Jersey: ${player.number}\tPos: ${player.pos}",
              style: style,
            ),
            left: 150.0,
            top: 60.0,
          ),
        ],
      ),
      decoration: new BoxDecoration(
          border: new Border(
              bottom: new BorderSide(width: 2.0, color: Colors.black12))),
      height: 100.0,
    );
  }
}
