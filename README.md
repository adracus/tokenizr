tokenizr
========

Dart lexical analysis tool

## What does this tool do?
This tool is meant for lexical analysis of an input string. In order to do so,
you need to subclass various classes: For each token you want to recognize, you
have to subclass the `Token` class, for each State the lexer can go through you
have to subclass the `LexerState` class and finally for the lexer itself you
have to subclass the `Lexer` class.

### Subclassing the `Token` class
In order to correctly subclass the `Token` class, you have to override at least
two methods: `get regexProto` and `Type get nextState`. Additionaly, you can
override the `onMatch` method to do some calculations on a match. By default,
this method returns a List with a single element, the token itself. So, if you've
got a token, which you want to match but which shouldn't appear in the list of
tokens later (like for example, a whitespace token) then you could simply override
the onMatch method to return an empty list. For convenience, this has already
been done for you in the `IgnoreToken` class.

#### `get regexProto`
This method can be overriden in two ways: You can either directly write a
regex or you can define a RegExp object. Examples:

```dart
...
get regexProto => r"."; // Raw string
//or
get regexProto => new RegExp("."); // RegExp object
```

#### `Type get nextState`
Through this method you specify the next state after this token was matched.
For example, you might have a token which matches on `/*` and want to switch
into the comment state after this. Then simply write:

```dart
Type get nextState => CmtState;
```

#### `List<Token> get onMatch`
This method defines the _result_ of a matched token. As said before, if you
want to match but ignore the token, subclass the `IgnoreToken` class.
If you want to, for example, calculate the value of a token, you could proceed
as follows:

```dart
List<Token> get onMatch {
  this.value = int.parse(content);
  return super.onMatch;
}
```

### Subclassing the `LexerState` class
The `LexerState` class has one method you have to override and two methods
you can override. You have to override the `List<Type> get tokens` method,
which specifies the tokens that are being matched in this LexerState.

The two remaining overridable methods are `void onEnd()` and
`int get errorHandling`. The `onEnd` method is called on a state, when
the end of the input string is reached. If you are, for example, in a comment
state, you could throw an exception like `Unclosed commend`. Per default, this
method does nothing.

The `int get errorHandling` method is used to specify the action a `LexerState`
should do if no token could be matched. Per default, this is
`LexerState.ON_ERROR_ERROR_MSG`, which uses the logger to log an error message
containing more detailed information. Other constants controlling this behaviour
are `LexerState.ON_ERROR_NOTHING` and `LexerState.ON_ERROR_THROW_ERROR`, which
should be quite self-explanatory.

### Subclassing the `Lexer` class
Last but not least you need to subclass the Lexer class to build an own Lexer.
The `Lexer` class has one method you have to override and one method you could
override: The method you have to override is the `List<Type> get states`
method, which specifies all states of the `Lexer`. The method you could
override is the `Type get startState` method, but by default, the start state
of a `Lexer` is the first element of the `get states` method.

## Using the `Lexer`
If you're done doing all the subclassing, you can finally use the lexer. To do
this, simply instantiate your lexer and call the `run` method on it with
your input string as arguments. This will, if it can, produce an output
List of `Token`s. Example:

```dart
var lexer = new MyLexer();
var tokens = lexer.run("1 + 2 + 3 + 4");
print(tokens); // Or do something more intelligent with the tokens
```

That's it, for further examples look into the `test` directory. If you've got
enhancements, feel free to create a pull request. Have fun tokenizing!