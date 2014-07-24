import 'test_classes.dart';
import '../lib/tokenizr.dart';
import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';

main() {
  log.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  log.level = Level.ALL;
  
  var lexer = new ExpLexer();
  test('Parse simple expressions', () {
    var tokens = lexer.run('1 + 3 - 2 * 4 - 100');
    expect(tokens[0].value, equals(1));
    expect(tokens[1].content, equals("+"));
    expect(tokens[2].value, equals(3));
    expect(tokens[3].content, equals("-"));
    expect(tokens[4].value, equals(2));
    expect(tokens[5].content, equals("*"));
    expect(tokens[6].value, equals(4));
    expect(tokens[7].content, equals("-"));
    expect(tokens[8].value, equals(100));
  });
  
  print("State : " + lexer.getStateByType(StdState).toString());
  
  test('Parse expression with comment inside', () {
    var tokens = lexer.run('1 + 3 /* Wait for it... */ * 0');
    expect(tokens[0].value, equals(1));
    expect(tokens[1].content, equals("+"));
    expect(tokens[2].value, equals(3));
    expect(tokens[3].content, equals("*"));
    expect(tokens[4].value, equals(0));
  });
}