part of tokenizr;

abstract class LexerState {
  static const int ON_ERROR_ERROR_MSG = 1;
  static const int ON_ERROR_THROW_ERROR = 2;
  static const int ON_ERROR_NOTHING = 3;
  List<Type> get tokens;
  int get errorHandling => ON_ERROR_ERROR_MSG;
  LexerState();
  
  StepResult step(String input, Type state) {
    var tMatches = [];
    var maxMatchLength = -1;
    for(var tType in tokens) {
      var mToken = Token.matchType(tType, input);
      if(mToken.match != null && mToken.match.start == 0) {
        tMatches.add(mToken);
        maxMatchLength = max(maxMatchLength, mToken.match.end);
      }
    }
    if(maxMatchLength == -1) return doNoMatchHandling(input);
    print("$maxMatchLength, matches: $tMatches");
    var match = tMatches.firstWhere((t) => t.match.end == maxMatchLength);
    return matchToken(match, input);
  }
  
  StepResult doNoMatchHandling(String input) {
    var msg = "No match for: '" + UTF8.decode([input.codeUnitAt(0)]) + "'";
    if(errorHandling == ON_ERROR_THROW_ERROR) {
      throw msg;
    }
    if(errorHandling == ON_ERROR_ERROR_MSG) {
      log.warning(msg);
    }
    return new StepResult(input.substring(1), this.runtimeType);
  }
  
  static LexerState instanceFromType(Type t) =>
      reflectClass(t).newInstance(new Symbol(''), []).reflectee;
  
  StepResult matchToken(Token t, String input) {
    return new StepResult(input.substring(t.match.end),
        t.nextState, tokens: t.onMatch);
  }
  
  void onEnd() {
  }
  
  toString() =>
      "LexerState " + 
          MirrorSystem.getName(reflectClass(this.runtimeType).simpleName);
}

class StepResult {
  String string;
  Type nextState;
  List<Token> tokens;
  StepResult(this.string, this.nextState, {this.tokens: const[]});
}