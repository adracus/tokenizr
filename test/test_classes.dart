import '../lib/tokenizr.dart';

const letter = "[a-zA-Z]+";

class Number extends Token {
  int value = 0;
  get regexProto => "[0-9]+";
  get nextState => StdState;
  List<Token> get onMatch {
    this.value = int.parse(content);
    return super.onMatch;
  }
}

class Whitespace extends IgnoreToken {
  get regexProto => " ";
  get nextState => StdState;
}

class Operator extends Token {
  get regexProto => r"\+|\-|\*|\/";
  get nextState => StdState;
}

class CmtStartSymbol extends IgnoreToken {
  get regexProto => r"\/\*";
  get nextState => CmtState;
}

class CmtEndSymbol extends IgnoreToken {
  get regexProto => r"\*\/";
  get nextState => StdState;
}

class StdState extends LexerState {
  get tokens => [CmtStartSymbol, Number, Operator, Whitespace];
}

class CmtState extends LexerState {
  get tokens => [CmtEndSymbol];
  get errorHandling => LexerState.ON_ERROR_NOTHING;
  void onEnd() => throw "Unclosed Comment";
}

class ExpLexer extends Lexer {
  get startState => StdState;
  get states => [StdState, CmtState];
}