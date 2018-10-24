import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'teams.dart';
import 'database.dart';

const int PLAYOFFS_MATCHES = 15;

Future<List<Bracket>> setPlayoffsBrackets(String content) async {
  List decoder = jsonDecode(content)['series'];
  List<Bracket> brackets = new List();
  Map seriesDecoder;

  Database db = database.dbConnection;

  for(int i = 0; i < PLAYOFFS_MATCHES; i++) {
      seriesDecoder = decoder[i];
      String topRowId = seriesDecoder['topRow']['teamId'];
      String bottomRowId = seriesDecoder['bottomRow']['teamId'];
      brackets.add(
        new Bracket(seriesDecoder['roundNum'], seriesDecoder['confName'],
            seriesDecoder['seriesId'], seriesDecoder['isScheduleAvailable'],
            seriesDecoder['isSeriesCompleted'],
            seriesDecoder['gameNumber'], seriesDecoder['topRow']['teamId'],
            seriesDecoder['topRow']['seedNum'], seriesDecoder['topRow']['wins'],
            seriesDecoder['topRow']['isSeriesWinner'], seriesDecoder['bottomRow']['teamId'],
            seriesDecoder['bottomRow']['seedNum'], seriesDecoder['bottomRow']['wins'],
            seriesDecoder['bottomRow']['isSeriesWinner'], (topRowId == "") ? null : await getTeamFromId(topRowId, db),
            (bottomRowId == "") ? null : await getTeamFromId(bottomRowId, db))
      );
  }
  return brackets;
}

class Bracket {

  String roundNum, confName, seriesId, topRowId, topRowSeed, topRowWins,
  bottomRowId, bottomRowSeed, bottomRowWins;

  Map topRowDatabaseInfo, bottomRowDatabaseInfo;

  int gameNumber;

  bool isSeriesCompleted, isScheduleAvailable, topRowIsSeriesWinner, bottomRowIsSeriesWinner;

  Bracket(this.roundNum, this.confName, this.seriesId, this.isScheduleAvailable,
      this.isSeriesCompleted, this.gameNumber, this.topRowId, this.topRowSeed, this.topRowWins,
      this.topRowIsSeriesWinner, this.bottomRowId, this.bottomRowSeed, this.bottomRowWins,
      this.bottomRowIsSeriesWinner, this.topRowDatabaseInfo, this.bottomRowDatabaseInfo);
}