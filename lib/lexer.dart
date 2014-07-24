part of tokenizr;

abstract class Lexer {
  Type _currentState;
  List<LexerState> _states;
  
  Lexer() {
    _states = new LinkedHashSet.from(states).map((t) =>
        LexerState.instanceFromType(t)).toList(growable: false);
    if(states.length == 0) throw "No states specified"; 
    _currentState = startState;
  }
  
  Type get startState => states.first;
  
  List<Type> get states;
  
  LexerState getStateByType(Type type) =>
      _states.where((state) => state.runtimeType == type).first;
  
  LexerState get currentState => getStateByType(_currentState);
  
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