import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

List<String> getTwitters(String homeId, String awayId) {
  List<String> twitterList = new List();
  twitterList.add(getTwitter(homeId));
  twitterList.add(getTwitter(awayId));
  return twitterList;
}

String getTwitter(String id) {
  String twitter;
  switch(id) {
    case "1610612737":
      twitter = "ATLHawks";
      break;
    case "1610612738":
      twitter = "celtics";
      break;
    case "1610612751":
      twitter = "brooklynnets";
      break;
    case "1610612766":
      twitter = "hornets";
      break;
    case "1610612741":
      twitter = "chicagobulls";
      break;
    case "1610612739":
      twitter = "cavs";
      break;
    case "1610612742":
      twitter = "dallasmavs";
      break;
    case "1610612743":
      twitter = "nuggets";
      break;
    case "1610612765":
      twitter = "detroitpistons";
      break;
    case "1610612744":
      twitter = "warriors";
      break;
    case "1610612745":
      twitter = "houstonrockets";
      break;
    case "1610612754":
      twitter = "pacers";
      break;
    case "1610612746":
      twitter = "laclippers";
      break;
    case "1610612747":
      twitter = "lakers";
      break;
    case "1610612763":
      twitter = "memgrizz";
      break;
    case "1610612748":
      twitter = "miamiheat";
      break;
    case "1610612749":
      twitter = "bucks";
      break;
    case "1610612750":
      twitter = "timberwolves";
      break;
    case "1610612740":
      twitter = "pelicansnba";
      break;
    case "1610612752":
      twitter = "nyknicks";
      break;
    case "1610612760":
      twitter = "okcthunder";
      break;
    case "1610612753":
      twitter = "orlandomagic";
      break;
    case "1610612755":
      twitter = "sixers";
      break;
    case "1610612756":
      twitter = "suns";
      break;
    case "1610612757":
      twitter = "trailblazers";
      break;
    case "1610612758":
      twitter = "sacramentokings";
      break;
    case "1610612759":
      twitter = "spurs";
      break;
    case "1610612761":
      twitter = "raptors";
      break;
    case "1610612762":
      twitter = "utahjazz";
      break;
    case "1610612764":
      twitter = "washwizards";
      break;
    default:
      twitter = "nba";
      break;
  }
  return twitter;
}

class twitterButton extends StatelessWidget {

  String url;

  twitterButton(this.url);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage("assets/twitterIcon.png"))),
        height: 25.0,
        width: 25.0,
      ),
      onTap: () { openTeamTwitter(); },
    );
  }

  openTeamTwitter() async {
    if (await canLaunch(url))
      launch(url);
    else
      throw "Could not launch";
  }
}
