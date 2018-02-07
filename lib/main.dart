import 'package:flutter/material.dart';
import 'Games.dart';
import 'Widgets.dart';

void main() {
  runApp(new MaterialApp(
      home: new mainWidget()
  )
  );
}

class mainWidget extends StatelessWidget {
  List<game> games = new List<game>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Simple NBA"),
            backgroundColor: new Color.fromRGBO(255, 25, 25, 0.8)
        ),
        body: new RefreshIndicator(child:
          new Center(
             child: new FutureBuilder(
                future: loadData(),
                builder: (BuildContext context,
                    AsyncSnapshot<dynamic> response) {
                  if (!response.hasData)
                    return loadingScreen();
                  else {
                    games = response.data;
                    return new Container(
                      child: new ListView(
                        children: getWidgetFromGame(games)
                      ),
                      padding: new EdgeInsets.all(8.0)
                    );
                  }
                }
             )
        ),
        onRefresh: () async {
          games = await loadData();
        }
      ),
      backgroundColor: new Color.fromRGBO(40, 40, 190, 1.0)
    );
  }
}