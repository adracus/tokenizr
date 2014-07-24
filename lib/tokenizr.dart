library tokenizr;

import 'dart:convert';
import 'dart:mirrors';
import 'dart:collection' show LinkedHashSet;
import 'package:logging/logging.dart';
import 'dart:math' show max;

part 'lexer.dart';
part 'token.dart';
part 'lexer_state.dart';

final log = Logger.root;