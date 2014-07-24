part of tokenizr;

abstract class Token {
  Match match;
  Token();
  get regexProto;
  RegExp get regex =>
      regexProto is String? new RegExp(regexProto) : regexProto;
  String get content =>
      match.group(0);
  Type get nextState;
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