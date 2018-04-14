import "package:http/http.dart" as http;
import "dart:convert";
import "dart:async";
import "package:sqflite/sqflite.dart";
import "games.dart";
import 'teams.dart';
import "package:path_provider/path_provider.dart";

List<Player> setAllPlayers(String content) {
  List<Player> allPlayers = new List();
  List players = JSON.decode(content)["league"]["standard"];
  for (Map player in players) {
    if (Team.teamMap.containsKey(player['teamId']))
      allPlayers.add(new Player(player['personId'], player['teamId'],
          name: [player['firstName'], player['lastName']],
          generalPosition: player['pos'],
          number: player['jersey'],
          draft: player['draft'],
          birthDate: player['dateOfBirthUTC']));
  }
  return allPlayers;
}

Future<List<Player>> loadLeaders(String gameId, int gameDate) async {
  String url = "http://data.nba.net/prod/v1/$gameDate/${gameId}_boxscore.json";
  Database db = await openDatabase(
      "${(await getApplicationDocumentsDirectory()).path}/db/snba.db");

  var decodJSON = JSON.decode(await http.read(url))["stats"];
  List<Player> leaders = new List<Player>();
  leaders.add(await _getLeader(decodJSON, "points", "hTeam", db));
  leaders.add(await _getLeader(decodJSON, "rebounds", "hTeam", db));
  leaders.add(await _getLeader(decodJSON, "assists", "hTeam", db));
  leaders.add(await _getLeader(decodJSON, "points", "vTeam", db));
  leaders.add(await _getLeader(decodJSON, "rebounds", "vTeam", db));
  leaders.add(await _getLeader(decodJSON, "assists", "vTeam", db));

  db.close();
  return leaders;
}

Future _getLeader(
    Map decodedData, String stat, String team, Database db) async {
  Player leader;
  try {
    leader = new Player(
        decodedData[team]["leaders"][stat]["players"][0]["personId"],
        decodedData[team]["teamId"],
        name: await getPlayerNameFromId(
            decodedData[team]["leaders"][stat]["players"][0]["personId"], db),
        stat: decodedData[team]["leaders"][stat]["value"]);
  } catch (Exception) {
    leader = new Player(null, null, name: " - ", stat: "0");
  }
  return leader;
}

Future<List<String>> getPlayerNameFromId(String playerId, Database db) async {
  List<String> playerName = new List();
  try {
    Map query =
        (await db.rawQuery("SELECT * FROM players WHERE personId = $playerId"))
            .first;
    playerName.addAll([query["firstName"], query["lastName"]]);
  } catch (exception) {
    return playerNotFoundInsertIntoDBandReturn(playerId, db);
  }
  return playerName;
}

Future<List<String>> playerNotFoundInsertIntoDBandReturn(
    String playerId, Database db) async {
  try {
    String url = JSON.decode(await http
            .read("http://data.nba.net/10s/prod/v1/today.json"))["links"]
        ["leagueRosterPlayers"];
    String players = await http.read("http://data.nba.net$url");
    var decoder = JSON.decode(players)["league"]["standard"];
    int i = 0;

    while (decoder[i]["personId"] != playerId) {
      i++;
    }

    await db.rawInsert("""INSERT INTO players VALUES (${_checkNull(
        decoder[i]["nbaDebutYear"].toString())},
        \"${_checkNull(decoder[i]["dateOfBirthUTC"])}\", \"${_checkNull(
        decoder[i]["heightInches"])}\",
        \"${_checkNull(decoder[i]["firstName"])}\", \"${_checkNull(
        decoder[i]["heightFeet"])}\",
        ${_checkNull(decoder[i]["personId"])}, \"${_checkNull(
        decoder[i]["lastName"])}\",
        \"${_checkNull(decoder[i]["lastAffiliation"])}\", \"${_checkNull(
        decoder[i]["pos"])}\",
        ${_checkNull(decoder[i]["weightKilograms"])}, ${_checkNull(
        decoder[i]["weightPounds"])},
        ${_checkNull(decoder[i]["teamId"])}, 
        ${_checkNull(decoder[i]["draft"]["roundNum"])},
        ${_checkNull(decoder[i]["draft"]["teamId"])},
        ${_checkNull(decoder[i]["draft"]["pickNum"])},
        ${_checkNull(decoder[i]["draft"]["seasonYear"])},
        ${_checkNull(decoder[i]["jersey"])},
        \"${_checkNull(decoder[i]["country"])}\", \"${_checkNull(
        decoder[i]["collegeName"])}\",
        ${_checkNull(decoder[i]["yearsPro"])}, \"${_checkNull(
        decoder[i]["isActive"])}\",
        ${_checkNull(decoder[i]["heightMeters"])})""");

    return [decoder[i]["firstName"], decoder[i]["lastName"]];
  } catch (exception) {
    return ["-", "-"];
  }
}

String _checkNull(String val) {
  return (val == "") ? null.toString() : val;
}

Future<List<Player>> loadTeamsLeaders(Game game) async {
  List<Player> leaders = new List();
  Database db = await openDatabase(
      "${(await getApplicationDocumentsDirectory()).path}/db/snba.db");

  String prefix = "http://data.nba.net";
  String url = "$prefix/10s/prod/v1/today.json";

  var decodJSON = JSON.decode(await http.read(url));
  url = "$prefix${decodJSON["links"]["teamLeaders2"]}";
  leaders.addAll(await _loadTeamLeaders(game.home.id.toString(), url, db));
  leaders.addAll(await _loadTeamLeaders(game.visitor.id.toString(), url, db));

  db.close();
  return leaders;
}

Future setSeasonStatsPlayers(List<PlayerStats> players) async {

  String base = JSON.decode(await http.read("http://data.nba.net/10s/prod/v1/today.json"))["links"]["playerProfile"];

  for(PlayerStats p in players) {
    String link = "http://data.nba.net${base.replaceAll("{{personId}}", p.id)}";
    var decoder = JSON.decode(await http.read(link))["league"]["standard"]["stats"]["regularSeason"]["season"];

    p.ppm = getArithmeticMeanForStat("ppg", decoder);
    p.rpm = getArithmeticMeanForStat("rpg", decoder);
    p.apm = getArithmeticMeanForStat("apg", decoder);
  }

  return new Future<Null>.value();
}

Future setSeasonStats(Player player) async {

  String base = JSON.decode(await http.read("http://data.nba.net/10s/prod/v1/today.json"))["links"]["playerProfile"];
  
  String link = "http://data.nba.net${base.replaceAll("{{personId}}", player.id)}";
  var decoder = JSON.decode(await http.read(link))["league"]["standard"]["stats"]["regularSeason"]["season"];

  player.ppg = getArithmeticMeanForStat("ppg", decoder);
  player.rpg = getArithmeticMeanForStat("rpg", decoder);
  player.apg = getArithmeticMeanForStat("apg", decoder);

  return new Future<Null>.value();
}

String getArithmeticMeanForStat(String statName, List decoder) {
  double stat = 0.0;
  int seasonStages=0;
  int seasonYear = decoder[0]['seasonYear'];

  for(Map stage in decoder) {
    if(stage['seasonYear'] != seasonYear)
      break;

    if (stage['total'][statName] != "-1"){
      stat += double.parse(stage['total'][statName]);
      seasonStages++;
    }
  }

  return (stat/seasonStages).toString();
}

Future<List<Player>> _loadTeamLeaders(
    String teamId, String url, Database db) async {
  String link = url.replaceAll("{{teamId}}", teamId);

  var decodJSON = JSON.decode(await http.read(link));

  List<Player> leaders = new List<Player>();

  if (decodJSON['league']['standard']['ppg'].isNotEmpty) {
    leaders.add(new Player(
        decodJSON["league"]["standard"]["ppg"][0]["personId"], teamId,
        name: await getPlayerNameFromId(
            decodJSON["league"]["standard"]["ppg"][0]["personId"], db),
        stat: decodJSON["league"]["standard"]["ppg"][0]["value"]));
    leaders.add(new Player(
        decodJSON["league"]["standard"]["trpg"][0]["personId"], teamId,
        name: await getPlayerNameFromId(
            decodJSON["league"]["standard"]["trpg"][0]["personId"], db),
        stat: decodJSON["league"]["standard"]["trpg"][0]["value"]));
    leaders.add(new Player(
        decodJSON["league"]["standard"]["apg"][0]["personId"], teamId,
        name: await getPlayerNameFromId(
            decodJSON["league"]["standard"]["apg"][0]["personId"], db),
        stat: decodJSON["league"]["standard"]["apg"][0]["value"]));
  } else {
    leaders.addAll([
      new Player(null, teamId, name: ["-\t","-\t"], stat: "0"),
      new Player(null, teamId, name: ["-\t","-\t"], stat: "0"),
      new Player(null, teamId, name: ["-\t","-\t"], stat: "0")
    ]);
  }
  return leaders;
}

class Player {
  String _firstName,
      _lastName,
      _teamId,
      _id,
      _stat,
      _generalPosition,
      _number,
      _yearsOld,
      ppg,
      rpg,
      apg,
      _birthDate;
  Map _draft;

  Player(this._id, this._teamId,
      {stat, name, generalPosition, number, draft, birthDate = ""})
      : this._stat = stat {
    fullName = name;
    _generalPosition = generalPosition;
    _number = number;
    _draft = draft;
    _birthDate = birthDate;
    _yearsOld = (birthDate.isNotEmpty) ? _calculateYears(birthDate.split("-")) : "- ";
  }

  String _calculateYears(List<String> birthDate) {
    int years = new DateTime.now().year - int.parse(birthDate[0]);
    return (new DateTime.now().isAfter(
      new DateTime(new DateTime.now().year, int.parse(birthDate[1]), int.parse(birthDate[2]))
    )) ? years.toString() : (years-1).toString();
  }

  get birthDate => _birthDate;
  get draft => _draft;
  get id => _id;
  get stat => _stat;
  get teamId => _teamId;
  String get firstName => _firstName;
  get number => _number;
  get pos => _generalPosition;
  get years => _yearsOld;
  get lastName => _lastName;

  set fullName(List<String> name) {
    firstName = (name != null) ? name[0] : null;
    lastName = (name != null) ? name[1] : null;
  }

  set firstName(String value) {
    _firstName = value;
  }

  set lastName(String value) {
    _lastName = value;
  }

  String get name => _firstName + " " + _lastName;

  String get abbName {
    if (firstName == null) if (lastName == null)
      return "";
    else
      return lastName;
    else if (lastName == null)
      return firstName;
    else
      return (lastName.length < 10)
          ? firstName.substring(0, 1) + ". " + lastName
          : lastName;
  }

  static getImage(String playerId) {
    return "https://ak-static.cms.nba.com/wp-content/uploads/headshots/nba/latest/260x190/$playerId.png";
  }

  @override
  String toString() {
    return "Player{_name: $name}";
  }
}

class PlayerStats extends Player {
  PlayerStats(
      List<String> fullName,
      String id,
      String teamId,
      this._isOnCourt,
      this._points,
      this._pos,
      this._min,
      this._fgm,
      this._fga,
      this._fgp,
      this._fta,
      this._ftm,
      this._ftp,
      this._tpm,
      this._tpa,
      this._tpp,
      this._offReb,
      this._defReb,
      this._rebounds,
      this._assists,
      this._pFouls,
      this._steals,
      this._turnovers,
      this._blocks,
      this._plusMinus)
      : super(id, teamId, name: fullName);

  bool _isOnCourt;
  String _pos,
      _min,
      _fgm,
      _fga,
      _fgp,
      _fta,
      _ftm,
      _ftp,
      _tpm,
      _tpa,
      _tpp,
      _offReb,
      _defReb,
      _pFouls,
      _steals,
      _turnovers,
      _blocks,
      _plusMinus,
      _points,
      _assists,
      _rebounds,
      _ppm,
      _rpm,
      _apm;

  bool get isOnCourt => _isOnCourt;

  get pos => _pos;

  get min => _min;

  get fgm => _fgm;

  get fga => _fga;

  get fgp => _fgp;

  get fta => _fta;

  get ftm => _ftm;

  get ftp => _ftp;

  get tpm => _tpm;

  get tpa => _tpa;

  get tpp => _tpp;

  get offReb => _offReb;

  get defReb => _defReb;

  get pFouls => _pFouls;

  get steals => _steals;

  get turnovers => _turnovers;

  get blocks => _blocks;

  get plusMinus => _plusMinus;

  get points => _points;

  get assists => _assists;

  get rebounds => _rebounds;

  get ppm => _ppm;

  get apm => _apm;

  get rpm => _rpm;

  set rpm(value) {
    _rpm = value;
  }

  set apm(value) {
    _apm = value;
  }

  set ppm(value) {
    _ppm = value;
  }
}
