import '../lib/tokenizr.dart';

const letter = "[a-zA-Z]+";

class Number extends Token {
  int value = 0;
  get regexProto => "[0-9]+";
  get nextState => "std";
  List<Token> get onMatch {
    this.value = int.parse(content);
    return super.onMatch;
  }
}

class Whitespace extends IgnoreToken {
  get regexProto => " ";
  get nextState => "std";
}

class Operator extends Token {
  get regexProto => r"\+|\-|\*|\/";
  get nextState => "std";
}

class CmtStartSymbol extends IgnoreToken {
  get regexProto => r"\/\*";
  get nextState => "cmt";
}

class CmtEndSymbol extends IgnoreToken {
  get regexProto => r"\*\/";
  get nextState => "std";
}

class StdState extends LexerState {
  get name => "std";
  get tokens => [CmtStartSymbol, Number, Operator, Whitespace];
}

class CmtState extends LexerState {
  get name => "cmt";
  get tokens => [CmtEndSymbol];
  get errorHandling => LexerState.ON_ERROR_NOTHING;
  void onEnd() => throw "Unclosed Comment";
}

class ExpLexer extends Lexer {
  get startState => "std";
  get states => [StdState, CmtState];
}