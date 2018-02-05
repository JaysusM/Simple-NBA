class game
{

  String _city, _arena;
  //DateTime _date;
  Team home, visitor;

  game(this._city, this._arena,
      //this._date,
      this.home, this.visitor);

  //DateTime get date => _date;

  String get city => _city;

  get arena => _arena;

  @override
  String toString() {
    return "{ City: " + _city //+ ", date: " + _date.toString()
        + ", home: " + home.toString() + ", visitor: " + visitor.toString() + "}";
  }


}

class Team
{
  static int _getScore(String score)
  {
    if(score.isEmpty)
      return 0;
    return int.parse(score);
  }

  String _tricode;
  int _win, _loss;
  int _score;

  Team(tricode, win,
      loss, score)
    : _tricode = tricode,
      _win = int.parse(win),
      _loss = int.parse(loss),
      _score = _getScore(score);

  String get tricode => _tricode;

  int get win => _win;

  get loss => _loss;

  int get score => _score;

  set score(int value) {
    _score = value;
  }

  @override
  String toString() {
    return 'Team{ tricode: $_tricode,  win: $_win,  loss: $_loss,  score: $_score}';
  }


}