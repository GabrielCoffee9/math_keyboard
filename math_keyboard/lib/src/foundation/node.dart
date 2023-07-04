import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Block representing a node of TeX.
class TeXNode {
  /// Constructs a [TeXNode].
  TeXNode(this.parent);

  /// The parent of the node.
  TeXFunction? parent;

  /// The courser position in this node.
  int courserPosition = 0;

  /// A block can have one or more child blocks.
  final List<TeX> children = [];

  /// Sets the courser to the actual position.
  void setCursor() {
    children.insert(courserPosition, const Cursor());
  }

  /// Removes the courser.
  void removeCursor() {
    children.removeAt(courserPosition);
  }

  /// Returns whether the last child node is the cursor.
  ///
  /// This does *not* traverse the children recursively as that might not be
  /// a guarantee for visually being all the way on the right with the cursor.
  /// Imagine a `\frac` node with a horizontally long string in the nominator:
  /// now, when the cursor is at the end, it is not visually on the right of the
  /// node as the denominator might not even be visible when scrolling to the
  /// right.
  bool cursorAtTheEnd() {
    if (children.isEmpty) return false;
    if (children.last is Cursor) return true;

    return false;
  }

  /// Shift courser to the left.
  NavigationState shiftCursorLeft() {
    if (courserPosition == 0) {
      return NavigationState.end;
    }
    removeCursor();
    courserPosition--;
    if (children[courserPosition] is TeXFunction) {
      return NavigationState.func;
    }
    setCursor();
    return NavigationState.success;
  }

  /// Shift courser to the right.
  NavigationState shiftCursorRight() {
    if (courserPosition == children.length - 1) {
      return NavigationState.end;
    }
    removeCursor();
    courserPosition++;
    if (children[courserPosition - 1] is TeXFunction) {
      return NavigationState.func;
    }
    setCursor();
    return NavigationState.success;
  }

  /// Adds a new node.
  void addTeX(TeX teX) {
    children.insert(courserPosition, teX);
    courserPosition++;
  }

  /// Removes the last node.
  NavigationState remove() {
    if (courserPosition == 0) {
      return NavigationState.end;
    }
    removeCursor();
    courserPosition--;
    if (children[courserPosition] is TeXFunction) {
      return NavigationState.func;
    }
    children.removeAt(courserPosition);
    setCursor();
    return NavigationState.success;
  }

  /// Builds the TeX representation of this node.
  ///
  /// This includes the representation of the children of the node.
  ///
  /// Returns the TeX expression as a [String].
  String buildTeXString({
    Color? cursorColor,
    bool placeholderWhenEmpty = true,
  }) {
    if (children.isEmpty) {
      return placeholderWhenEmpty ? '\\Box' : '';
    }
    final buffer = StringBuffer();
    for (final tex in children) {
      buffer.write(tex.buildString(cursorColor: cursorColor));
    }
    return buffer.toString();
  }

  /// Converts the `TeXNode` instance to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'courserPosition': courserPosition,
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  /// Creates a `TeXNode` instance from its JSON representation.
  factory TeXNode.fromJson(Map<String, dynamic> json) {
    final teXNode = TeXNode(null);
    teXNode.courserPosition = json['courserPosition'] as int;
    final childrenJson = json['children'] as List<dynamic>;
    for (final childJson in childrenJson) {
      if (childJson['type'] == 'TeXFunction') {
        final expression = childJson['expression'] as String;
        final args = (childJson['args'] as List<dynamic>)
            .map<TeXArg>(
                (arg) => TeXArg.values.byName((arg as String).split('.')[1]))
            .toList();
        final argNodesJson = childJson['argNodes'] as List<dynamic>;
        final argNodes = argNodesJson
            .map((nodeJson) =>
                TeXNode.fromJson(nodeJson as Map<String, dynamic>))
            .toList();
        final teXFunction = TeXFunction(expression, teXNode, args, argNodes);
        teXNode.children.add(teXFunction);
      } else {
        final child = TeX.fromJson(childJson as Map<String, dynamic>);
        teXNode.children.add(child);
      }
    }
    return teXNode;
  }
}

/// Class holding a TeX function.
class TeXFunction extends TeX {
  /// Constructs a [TeXFunction].
  ///
  /// [argNodes] can be passed directly if the nodes are already known. In that
  /// case, the [TeXNode.parent] is set in the constructor body. If [argNodes]
  /// is passed empty (default), empty [TeXNode]s will be inserted for each
  /// arg.
  TeXFunction(String expression, this.parent, this.args,
      [List<TeXNode>? argNodes])
      : assert(args.isNotEmpty, 'A function needs at least one argument.'),
        assert(argNodes == null || argNodes.length == args.length),
        argNodes = argNodes ?? List.empty(growable: true),
        super(expression) {
    if (this.argNodes.isEmpty) {
      for (var i = 0; i < args.length; i++) {
        this.argNodes.add(TeXNode(this));
      }
    } else {
      for (final node in this.argNodes) {
        node.parent = this;
      }
    }
  }

  /// The functions parent node.
  TeXNode parent;

  /// The delimiters of the arguments.
  final List<TeXArg> args;

  /// The arguments to this function.
  final List<TeXNode> argNodes;

  /// Returns the opening character for a function argument.
  String openingChar(TeXArg type) {
    switch (type) {
      case TeXArg.braces:
        return '{';
      case TeXArg.brackets:
        return '[';
      case TeXArg.verticalBars:
        return '|';
      default:
        return '(';
    }
  }

  /// Returns the closing character for a function argument.
  String closingChar(TeXArg type) {
    switch (type) {
      case TeXArg.braces:
        return '}';
      case TeXArg.brackets:
        return ']';
      case TeXArg.power:
        return '^';
      case TeXArg.verticalBars:
        return '|';
      default:
        return ')';
    }
  }

  @override
  String buildString({Color? cursorColor}) {
    final buffer = StringBuffer(expression);
    for (var i = 0; i < args.length; i++) {
      if (args[i] != TeXArg.power) {
        buffer.write(openingChar(args[i]));
        buffer.write(argNodes[i].buildTeXString(cursorColor: cursorColor));
      }

      buffer.write(closingChar(args[i]));
    }
    return buffer.toString();
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'type': 'TeXFunction',
      'args': args.map((arg) => arg.toString()).toList(),
      'argNodes': argNodes.map((node) => node.toJson()).toList(),
    });
    return json;
  }

  /// Transforms the TeXFunction in a Map<String, dynamic>
  @override
  factory TeXFunction.fromJson(Map<String, dynamic> json) {
    final expression = json['expression'] as String;
    final parent = TeXNode.fromJson(json['parent'] as Map<String, dynamic>);
    final args = (json['args'] as List<dynamic>)
        .map((arg) => _parseTeXArg(arg as String))
        .toList();
    final argNodes = (json['argNodes'] as List<dynamic>)
        .map((nodeJson) => TeXNode.fromJson(nodeJson as Map<String, dynamic>))
        .toList();
    return TeXFunction(expression, parent, args, argNodes);
  }

  static TeXArg _parseTeXArg(String arg) {
    switch (arg) {
      case 'braces':
        return TeXArg.braces;
      case 'brackets':
        return TeXArg.brackets;
      case 'power':
        return TeXArg.power;
      case 'verticalBars':
        return TeXArg.verticalBars;
      case 'parentheses':
        return TeXArg.parentheses;
      default:
        throw FormatException('Invalid TeXArg: $arg');
    }
  }
}

/// Class holding a single TeX expression.
class TeXLeaf extends TeX {
  /// Constructs a [TeXLeaf].
  const TeXLeaf(String expression) : super(expression);

  @override
  String buildString({Color? cursorColor}) {
    return expression;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'TeXLeaf',
      'expression': expression,
    };
  }

  ///Transforms the TeXLeaf in a Map<String, dynamic>
  @override
  factory TeXLeaf.fromJson(Map<String, dynamic> json) {
    final expression = json['expression'] as String;
    return TeXLeaf(expression);
  }
}

/// Class holding TeX.
abstract class TeX {
  /// Constructs a [TeX].
  const TeX(this.expression);

  /// The expression of this TeX
  final String expression;

  /// Builds the string representation of this TeX expression.
  String buildString({required Color? cursorColor});

  /// Converts the `TeX` instance to a JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'expression': expression,
    };
  }

  /// Creates a `TeX` instance from its JSON representation.
  factory TeX.fromJson(Map<String, dynamic> json) {
    final expression = json['expression'] as String;
    return TeXLeaf(expression);
  }
}

/// Class describing the cursor as a TeX expression.
class Cursor extends TeX {
  /// Creates a TeX [Cursor].
  const Cursor() : super('');

  @override
  String buildString({required Color? cursorColor}) {
    if (cursorColor == null) {
      throw FlutterError('Cursor.buildString() called without a cursorColor.');
    }
    final colorString =
        '#${(cursorColor.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    return '\\textcolor{$colorString}{\\cursor}';
  }
}

/// The state of a node when trying to navigate back- or forward.
enum NavigationState {
  /// The upcoming tex expression in navigation direction is a function.
  func,

  /// The current courser position is already at the end.
  end,

  /// Navigating was successful.
  success,
}

/// How the argument is marked.
enum TeXArg {
  /// { }
  ///
  /// In most of the cases, braces will be used. (E.g arguments of fractions).
  braces,

  /// [ ]
  ///
  /// Brackets are only used for the nth root at the moment.
  brackets,

  /// ^
  ///
  /// Indicates a raise to the power between arguments, must be informed in correct order.
  ///
  /// E.g: TeXArg.braces, TeXArg.power, TeXArg.braces, results => {}^{}.
  power,

  /// | |
  ///
  /// Vertical bars
  verticalBars,

  /// ()
  ///
  /// Parentheses are used for base n logarithm right now, but could be used
  /// for functions like sin, cos, tan, etc. as well, so the user doesn't have
  /// to close the parentheses manually.
  parentheses,
}
