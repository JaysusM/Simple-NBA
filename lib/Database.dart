import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

startDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = "${dir.path}/db/snba.db";

    if (!(new File(path).existsSync())) {
      Database db = await openDatabase(path, version: 1,
          onCreate: (Database data, int version) async {
            await data.execute(
                "CREATE TABLE team (alt_city_name VARCHAR(18),city VARCHAR(13),conf_name VARCHAR(4),div_name VARCHAR(9),"
                    "full_name VARCHAR(27),is_all_star BOOL,is_nba_franchise BOOL,nickname VARCHAR(15),team_id INT,"
                    "tricode VARCHAR(3),url_name VARCHAR(15))");
            await data.execute("""CREATE TABLE players (
            nbaDebutYear INT,
            dateOfBirthUTC DATETIME,
            heightInches VARCHAR(2) ,
            firstName VARCHAR(12) ,
            heightFeet VARCHAR(1) ,
            personId INT,
            lastName VARCHAR(16) ,
            lastAffiliation VARCHAR(50) ,
            pos VARCHAR(3) ,
            weightKilograms NUMERIC(4, 1),
            weightPounds INT,
            teamId INT,
            draft_roundNum INT,
            draft_teamId INT,
            draft_pickNum INT,
            draft_seasonYear INT,
            jersey INT,
            country VARCHAR(32) ,
            collegeName VARCHAR(33) ,
            yearsPro INT,
            isActive VARCHAR(4) ,
            heightMeters NUMERIC(3, 2)
            )""");
          });

      await db.inTransaction(() async {
        db.rawInsert(await rootBundle.loadString('assets/teams.txt'));
        db.rawInsert(await rootBundle.loadString('assets/players.txt'));
      });

      db.close();
    }
  }