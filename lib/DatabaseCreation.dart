import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

/// This methods are what we used in order to create our team database

startDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = "${dir.path}/db/snba.db";

    if (!(new File(path).existsSync())) {
      Database db = await openDatabase(path, version: 1,
          onCreate: (Database data, int version) async {
            await data.execute(
                "CREATE TABLE team (alt_city_name VARCHAR(18),city VARCHAR(13),conf_name VARCHAR(4),div_name VARCHAR(9),full_name VARCHAR(27),is_all_star BOOL,is_nba_franchise BOOL,nickname VARCHAR(15),team_id INT,tricode VARCHAR(3),url_name VARCHAR(15))");
            await data.execute("""CREATE TABLE players (
            list_nbaDebutYear INT,
            list_dateOfBirthUTC DATETIME,
            list_heightInches VARCHAR(2) ,
            list_firstName VARCHAR(12) ,
            list_heightFeet VARCHAR(1) ,
            list_personId INT,
            list_lastName VARCHAR(16) ,
            list_lastAffiliation VARCHAR(50) ,
            list_pos VARCHAR(3) ,
            list_weightKilograms NUMERIC(4, 1),
            list_weightPounds INT,
            list_teamId INT,
            list_draft_roundNum INT,
            list_draft_teamId INT,
            list_draft_pickNum INT,
            list_draft_seasonYear INT,
            list_jersey INT,
            list_country VARCHAR(32) ,
            list_collegeName VARCHAR(33) ,
            list_yearsPro INT,
            list_isActive VARCHAR(4) ,
            list_heightMeters NUMERIC(3, 2)
            )""");
      });

      await db.inTransaction(() async {
        db.rawInsert("""INSERT INTO team VALUES
        ('Atlanta','Atlanta','East','Southeast','Atlanta Hawks',0,1,'Hawks',1610612737,'ATL','hawks'),
        ('Boston','Boston','East','Atlantic','Boston Celtics',0,1,'Celtics',1610612738,'BOS','celtics'),
        ('Brisbane','Brisbane','Intl','','Brisbane Bullets',0,0,'Bullets',15017,'BNE','bullets'),
        ('Brooklyn','Brooklyn','East','Atlantic','Brooklyn Nets',0,1,'Nets',1610612751,'BKN','nets'),
        ('Charlotte','Charlotte','East','Southeast','Charlotte Hornets',0,1,'Hornets',1610612766,'CHA','hornets'),
        ('Chicago','Chicago','East','Central','Chicago Bulls',0,1,'Bulls',1610612741,'CHI','bulls'),
        ('Cleveland','Cleveland','East','Central','Cleveland Cavaliers',0,1,'Cavaliers',1610612739,'CLE','cavaliers'),
        ('Dallas','Dallas','West','Southwest','Dallas Mavericks',0,1,'Mavericks',1610612742,'DAL','mavericks'),
        ('Denver','Denver','West','Northwest','Denver Nuggets',0,1,'Nuggets',1610612743,'DEN','nuggets'),
        ('Detroit','Detroit','East','Central','Detroit Pistons',0,1,'Pistons',1610612765,'DET','pistons'),
        ('Golden State','Golden State','West','Pacific','Golden State Warriors',0,1,'Warriors',1610612744,'GSW','warriors'),
        ('Guangzhou','Guangzhou','Intl','','Guangzhou Long-Lions',0,0,'Long-Lions',15018,'GUA','long-lions'),
        ('Haifa','Haifa','Intl','','Maccabi Haifa',0,0,'Maccabi Haifa',93,'MAC','maccabi_haifa'),
        ('Houston','Houston','West','Southwest','Houston Rockets',0,1,'Rockets',1610612745,'HOU','rockets'),
        ('Indiana','Indiana','East','Central','Indiana Pacers',0,1,'Pacers',1610612754,'IND','pacers'),
        ('LA Clippers','LA','West','Pacific','LA Clippers',0,1,'Clippers',1610612746,'LAC','clippers'),
        ('Los Angeles Lakers','Los Angeles','West','Pacific','Los Angeles Lakers',0,1,'Lakers',1610612747,'LAL','lakers'),
        ('Melbourne','Melbourne','Intl','','Melbourne United',0,0,'United',15016,'MEL','united'),
        ('Memphis','Memphis','West','Southwest','Memphis Grizzlies',0,1,'Grizzlies',1610612763,'MEM','grizzlies'),
        ('Miami','Miami','East','Southeast','Miami Heat',0,1,'Heat',1610612748,'MIA','heat'),
        ('Milwaukee','Milwaukee','East','Central','Milwaukee Bucks',0,1,'Bucks',1610612749,'MIL','bucks'),
        ('Minnesota','Minnesota','West','Northwest','Minnesota Timberwolves',0,1,'Timberwolves',1610612750,'MIN','timberwolves'),
        ('New Orleans','New Orleans','West','Southwest','New Orleans Pelicans',0,1,'Pelicans',1610612740,'NOP','pelicans'),
        ('New York','New York','East','Atlantic','New York Knicks',0,1,'Knicks',1610612752,'NYK','knicks'),
        ('Oklahoma City','Oklahoma City','West','Northwest','Oklahoma City Thunder',0,1,'Thunder',1610612760,'OKC','thunder'),
        ('Orlando','Orlando','East','Southeast','Orlando Magic',0,1,'Magic',1610612753,'ORL','magic'),
        ('Philadelphia','Philadelphia','East','Atlantic','Philadelphia 76ers',0,1,'76ers',1610612755,'PHI','sixers'),
        ('Phoenix','Phoenix','West','Pacific','Phoenix Suns',0,1,'Suns',1610612756,'PHX','suns'),
        ('Portland','Portland','West','Northwest','Portland Trail Blazers',0,1,'Trail Blazers',1610612757,'POR','blazers'),
        ('Sacramento','Sacramento','West','Pacific','Sacramento Kings',0,1,'Kings',1610612758,'SAC','kings'),
        ('San Antonio','San Antonio','West','Southwest','San Antonio Spurs',0,1,'Spurs',1610612759,'SAS','spurs'),
        ('Shanghai','Shanghai','Intl','','Shanghai Sharks',0,0,'Shanghai Sharks',12329,'SDS','shanghai_sharks'),
        ('Sydney','Sydney','Intl','','Sydney Kings',0,0,'Kings',15015,'SYD','kings'),
        ('Team','Team','East','East','Team LeBron',1,0,'Team LeBron',1610616833,'LBN','team_lebron'),
        ('Team','Team','West','West','Team Stephen',1,0,'Team Stephen',1610616834,'STP','team_stephen'),
        ('Team Clippers','Team Clippers','West','West','Team Clippers Team Clippers',1,0,'Team Clippers',1610616840,'CLP','team_clippers'),
        ('Team Lakers','Team Lakers','West','West','Team Lakers Team Lakers',1,0,'Team Lakers',1610616839,'LKR','team_lakers'),
        ('Toronto','Toronto','East','Atlantic','Toronto Raptors',0,1,'Raptors',1610612761,'TOR','raptors'),
        ('USA','USA','East','East','USA',1,0,'USA',1610616843,'USA','usa'),
        ('Utah','Utah','West','Northwest','Utah Jazz',0,1,'Jazz',1610612762,'UTA','jazz'),
        ('Washington','Washington','East','Southeast','Washington Wizards',0,1,'Wizards',1610612764,'WAS','wizards'),
        ('World','World','East','East','World',1,0,'World',1610616844,'WLD','world')"""
        );

        db.rawInsert(await rootBundle.loadString('assets/players.txt'));
      });
      db.close();
    }
  }
