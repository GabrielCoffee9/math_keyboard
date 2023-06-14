import 'package:flutter/services.dart';
import 'package:math_keyboard/src/foundation/node.dart';

/// Class representing a button configuration.
abstract class KeyboardButtonConfig {
  /// Constructs a [KeyboardButtonConfig].
  const KeyboardButtonConfig({
    this.flex,
    this.keyboardCharacters = const [],
  });

  /// Optional flex.
  final int? flex;

  /// The list of [RawKeyEvent.character] that should trigger this keyboard
  /// button on a physical keyboard.
  ///
  /// Note that the case of the characters is ignored.
  ///
  /// Special keyboard keys like backspace and arrow keys are specially handled
  /// and do *not* require this to be set.
  ///
  /// Must not be `null` but can be empty.
  final List<String> keyboardCharacters;
}

/// Class representing a button configuration for a [FunctionButton].
class BasicKeyboardButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [KeyboardButtonConfig].
  const BasicKeyboardButtonConfig({
    required this.label,
    required this.value,
    this.args,
    this.asTex = false,
    this.texFontSize = 22,
    this.tooltip = false,
    this.highlighted = false,
    List<String> keyboardCharacters = const [],
    int? flex,
  }) : super(
          flex: flex,
          keyboardCharacters: keyboardCharacters,
        );

  /// The label of the button.
  final String label;

  /// The value in tex.
  final String value;

  /// List defining the arguments for the function behind this button.
  final List<TeXArg>? args;

  /// Whether to display the label as TeX or as plain text.
  final bool asTex;

  /// Defines font size label when is Tex.
  final double texFontSize;

  /// the state of tooltip when label is Tex.
  final bool tooltip;

  /// The highlight level of this button.
  final bool highlighted;
}

/// Class representing a button configuration of the Delete Button.
class DeleteButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [DeleteButtonConfig].
  DeleteButtonConfig({int? flex}) : super(flex: flex);
}

/// Class representing a button configuration of the Previous Button.
class PreviousButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [DeleteButtonConfig].
  PreviousButtonConfig({int? flex}) : super(flex: flex);
}

/// Class representing a button configuration of the Next Button.
class NextButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [DeleteButtonConfig].
  NextButtonConfig({int? flex}) : super(flex: flex);
}

/// Class representing a button configuration of the Submit Button.
class SubmitButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [SubmitButtonConfig].
  SubmitButtonConfig({int? flex}) : super(flex: flex);
}

/// Class representing a button configuration of the Page Toggle Button.
class PageButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [PageButtonConfig].
  const PageButtonConfig({int? flex}) : super(flex: flex);
}

/// Class representing a button configuration of the Extra Symbols Page Toggle Button.
class ExtraSymbolsButtonConfig extends KeyboardButtonConfig {
  /// Constructs a [ExtraSymbolsButtonConfig].
  const ExtraSymbolsButtonConfig({int? flex}) : super(flex: flex);
}

/// List of keyboard button configs for the digits from 0-9.
///
/// List access from 0 to 9 will return the appropriate digit button.
final _digitButtons = [
  for (var i = 0; i < 10; i++)
    BasicKeyboardButtonConfig(
      label: '$i',
      value: '$i',
      keyboardCharacters: ['$i'],
    ),
];

const _decimalButton = BasicKeyboardButtonConfig(
  label: '.',
  value: '.',
  keyboardCharacters: ['.', ','],
  highlighted: true,
);

const _subtractButton = BasicKeyboardButtonConfig(
  label: '−',
  value: '-',
  keyboardCharacters: ['-'],
  highlighted: true,
);

/// Keyboard showing extended functionality.
final functionKeyboard = [
  [
    const BasicKeyboardButtonConfig(
      label: r'x^{\Box}',
      value: '^',
      args: [TeXArg.braces],
      asTex: true,
      keyboardCharacters: [
        '^',
        // This is a workaround for keyboard layout that use ^ as a toggle key.
        // In that case, "Dead" is reported as the character (e.g. for German
        // keyboards).
        'Dead',
      ],
    ),
    const BasicKeyboardButtonConfig(
      label: r'\sqrt{\Box}',
      value: r'\sqrt',
      args: [TeXArg.braces],
      asTex: true,
      keyboardCharacters: ['r'],
    ),
    const BasicKeyboardButtonConfig(
      label: r'\sqrt[\Box]{\Box}',
      value: r'\sqrt',
      args: [TeXArg.brackets, TeXArg.braces],
      asTex: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\frac{\Box}{\Box}',
      value: r'\frac',
      args: [TeXArg.braces, TeXArg.braces],
      asTex: true,
      texFontSize: 20,
    ),
  ],
  [
    const BasicKeyboardButtonConfig(
      label: r'\log_{\Box}(\Box)',
      value: r'\log_',
      asTex: true,
      args: [TeXArg.braces, TeXArg.parentheses],
    ),
    const BasicKeyboardButtonConfig(
      label: r'\int\:',
      value: r'\int\:',
      asTex: true,
      texFontSize: 18,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\int_{\Box}^{\Box}\:',
      value: r'\int _',
      args: [TeXArg.braces, TeXArg.power, TeXArg.braces],
      asTex: true,
      texFontSize: 17,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\sum_{\Box}^{\Box}',
      value: r'\sum_',
      args: [TeXArg.braces, TeXArg.power, TeXArg.braces],
      asTex: true,
      texFontSize: 14,
    ),
  ],
  [
    const BasicKeyboardButtonConfig(
      label: r'\ln(\Box)',
      value: r'\ln',
      asTex: true,
      args: [TeXArg.parentheses],
    ),
    const BasicKeyboardButtonConfig(
      label: r'|\Box|',
      value: '',
      asTex: true,
      args: [TeXArg.verticalBars],
      keyboardCharacters: ['|'],
    ),
    const BasicKeyboardButtonConfig(
      label: r'\cdot',
      value: r'\cdot',
      asTex: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'x^\circ',
      value: r'^\circ',
      asTex: true,
    ),
  ],
  [
    const BasicKeyboardButtonConfig(
      label: r'\infty',
      value: r'\infty',
      asTex: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\pi',
      value: r'\pi',
      asTex: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\ge',
      value: r'\ge',
      asTex: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\le',
      value: r'\le',
      asTex: true,
    ),
  ],
  [
    const PageButtonConfig(flex: 3),
    const ExtraSymbolsButtonConfig(flex: 2),
    const BasicKeyboardButtonConfig(
      label: '(',
      value: '(',
      highlighted: true,
      keyboardCharacters: ['('],
    ),
    const BasicKeyboardButtonConfig(
      label: ')',
      value: ')',
      highlighted: true,
      keyboardCharacters: [')'],
    ),
    PreviousButtonConfig(),
    NextButtonConfig(),
    DeleteButtonConfig(),
  ],
];

/// Keyboard showing extra symbols.
final extraSymbolsKeyboard = [
  [
    const BasicKeyboardButtonConfig(
      label: r'\alpha',
      value: r'\alpha',
      asTex: true,
      tooltip: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\Alpha',
      value: r'\Alpha',
      asTex: true,
      tooltip: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\beta',
      value: r'\beta',
      asTex: true,
      tooltip: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\Beta',
      value: r'\Beta',
      asTex: true,
      tooltip: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\gamma',
      value: r'\gamma',
      asTex: true,
      tooltip: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\Gamma',
      value: r'\Gamma',
      asTex: true,
      tooltip: true,
    ),
  ],
  [
    const BasicKeyboardButtonConfig(
      label: r'\delta',
      value: r'\delta',
      asTex: true,
      tooltip: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\Delta',
      value: r'\Delta',
      asTex: true,
      tooltip: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\zeta',
      value: r'\zeta',
      asTex: true,
      tooltip: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\Zeta',
      value: r'\Zeta',
      asTex: true,
      tooltip: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\eta',
      value: r'\eta',
      asTex: true,
      tooltip: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\Eta',
      value: r'\Eta',
      asTex: true,
      tooltip: true,
    ),
  ],
  [
    const BasicKeyboardButtonConfig(
      label: r'\theta',
      value: r'\theta',
      asTex: true,
      tooltip: true,
    ),
    const BasicKeyboardButtonConfig(
      label: r'\Theta',
      value: r'\Theta',
      asTex: true,
      tooltip: true,
    ),
  ],
  [
    const PageButtonConfig(flex: 3),
    const ExtraSymbolsButtonConfig(flex: 2),
    const BasicKeyboardButtonConfig(
      label: '(',
      value: '(',
      highlighted: true,
      keyboardCharacters: ['('],
    ),
    const BasicKeyboardButtonConfig(
      label: ')',
      value: ')',
      highlighted: true,
      keyboardCharacters: [')'],
    ),
    PreviousButtonConfig(),
    NextButtonConfig(),
    DeleteButtonConfig(),
  ],
];

/// Standard keyboard for math expression input.
final standardKeyboard = [
  [
    _digitButtons[7],
    _digitButtons[8],
    _digitButtons[9],
    const BasicKeyboardButtonConfig(
      label: '×',
      value: r'\times',
      keyboardCharacters: ['*'],
      highlighted: true,
    ),
    const BasicKeyboardButtonConfig(
      label: '÷',
      value: r'\div',
      keyboardCharacters: ['/'],
      highlighted: true,
    ),
  ],
  [
    _digitButtons[4],
    _digitButtons[5],
    _digitButtons[6],
    const BasicKeyboardButtonConfig(
      label: '+',
      value: '+',
      keyboardCharacters: ['+'],
      highlighted: true,
    ),
    _subtractButton,
  ],
  [
    _digitButtons[1],
    _digitButtons[2],
    _digitButtons[3],
    _decimalButton,
    DeleteButtonConfig(),
  ],
  [
    const PageButtonConfig(),
    _digitButtons[0],
    PreviousButtonConfig(),
    NextButtonConfig(),
    SubmitButtonConfig(),
  ],
];

/// Keyboard getting shown for number input only.
final numberKeyboard = [
  [
    _digitButtons[7],
    _digitButtons[8],
    _digitButtons[9],
    _subtractButton,
  ],
  [
    _digitButtons[4],
    _digitButtons[5],
    _digitButtons[6],
    _decimalButton,
  ],
  [
    _digitButtons[1],
    _digitButtons[2],
    _digitButtons[3],
    DeleteButtonConfig(),
  ],
  [
    PreviousButtonConfig(),
    _digitButtons[0],
    NextButtonConfig(),
    SubmitButtonConfig(),
  ],
];
