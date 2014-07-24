library tokenizr;

import 'dart:convert';
import 'dart:mirrors';
import 'dart:collection' show LinkedHashSet;
import 'package:logging/logging.dart';
import 'dart:math' show max;

final log = Logger.root;

abstract class Token {
  Match match;
  Token();
  get regexProto;
  RegExp get regex =>
      regexProto is String? new RegExp(regexProto) : regexProto;
  String get content =>
      match.group(0);
  String get nextState;
  List<Token> get onMatch => [this];
  static Token instanceFromType(Type type) =>
      reflectClass(type).newInstance(new Symbol(''), []).reflectee;
  
  static Token matchType(Type type, String input) {
    var inst = Token.instanceFromType(type);
    inst.match = inst.regex.firstMatch(input);
    return inst;
  }
  toString() => 
      MirrorSystem.getName(reflect(this).type.simpleName)
          +" Content: '$content'";
}

abstract class IgnoreToken extends Token {
  List<Token> get onMatch => [];
}

class StepResult {
  String string;
  String nextState;
  List<Token> tokens;
  StepResult(this.string, this.nextState, {this.tokens: const[]}) {
    if(nextState == null) nextState = "std";
  }
}

abstract class LexerState {
  static const int ON_ERROR_ERROR_MSG = 1;
  static const int ON_ERROR_THROW_ERROR = 2;
  static const int ON_ERROR_NOTHING = 3;
  String get name;
  List<Type> get tokens => [];
  int get errorHandling => ON_ERROR_ERROR_MSG;
  LexerState();
  
  StepResult step(String input, String state) {
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
    return new StepResult(input.substring(1), name);
  }
  
  static LexerState instanceFromType(Type t) =>
      reflectClass(t).newInstance(new Symbol(''), []).reflectee;
  
  StepResult matchToken(Token t, String input) {
    return new StepResult(input.substring(t.match.end),
        t.nextState, tokens: t.onMatch);
  }
  
  void onEnd() {
  }
  
  int get hashCode => name.hashCode;
  operator==(Object compare) => name == compare;
}

abstract class Lexer {
  String _currentState;
  List<LexerState> _states;
  
  Lexer() {
    _states = new LinkedHashSet.from(states).map((t) =>
        LexerState.instanceFromType(t)).toList(growable: false);
    _currentState = startState;
  }
  
  String get startState;
  
  List<Type> get states;
  LexerState getStateByName(String name) =>
      _states.where((state) => state.name == name).first;
  
  LexerState get currentState => getStateByName(_currentState);
  
  List<Token> run(String input) {
    _currentState = startState;
    var result = [];
    while(input.length > 0) {
      var res = step(input);
      _currentState = res.nextState;
      input = res.string;
      result.addAll(res.tokens);
    }
    this.currentState.onEnd();
    return result;
  }
  
  StepResult step(String input) =>
      this.currentState.step(input, _currentState);
}