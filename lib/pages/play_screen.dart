import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'dart:math';
import '../main.dart';

class GameScreen extends StatefulWidget {
  final String difficulty;
  final int wordLength;

  const GameScreen({super.key, required this.difficulty, required this.wordLength});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late String targetWord;
  List<List<String>> guesses = List.generate(6, (_) => List.filled(0, '', growable: true));
  List<List<Color>> gridColors = List.generate(6, (_) => List.filled(0, Colors.transparent, growable: true));
  int currentRow = 0;
  int currentCol = 0;

  @override
  void initState() {
    super.initState();
    targetWord = generateWord(widget.wordLength).toLowerCase();
  }

  String generateWord(int length) {
    final random = Random();

    // Filter words by the desired length
    final filteredWords = all.where((word) => word.length == length).toList();

    // Return a random word from the filtered list
    return filteredWords[random.nextInt(filteredWords.length)];
  }

  void handleLetterInput(String letter) {
    if (currentCol < widget.wordLength) {
      setState(() {
        guesses[currentRow].add(letter);
        currentCol++;
      });
    }
  }

  void handleDelete() {
    if (currentCol > 0) {
      setState(() {
        guesses[currentRow].removeLast();
        currentCol--;
      });
    }
  }

  void handleEnter() {
    final currentGuess = guesses[currentRow].join().toLowerCase();
    if (currentCol == widget.wordLength) {
      setState(() {
        gridColors[currentRow] = List.generate(widget.wordLength, (index) {
          if (targetWord[index] == currentGuess[index]) {
            return Colors.green;
          } else if (targetWord.contains(currentGuess[index])) {
            return Colors.yellow;
          } else {
            return Colors.grey;
          }
        });

        if (currentGuess == targetWord) {
          _showEndGameDialog("Congratulations!", "You guessed the word: $targetWord");
        } else if (currentRow == 5) {
          _showEndGameDialog("Game Over", "The correct word was: $targetWord");
        } else {
          currentRow++;
          currentCol = 0;
        }
      });
    }
  }

  void _showEndGameDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                targetWord = generateWord(widget.wordLength).toLowerCase();
                guesses = List.generate(6, (_) => List.filled(0, '', growable: true));
                gridColors = List.generate(6, (_) => List.filled(0, Colors.transparent, growable: true));
                currentRow = 0;
                currentCol = 0;
              });
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
                    (route) => false,
              );
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget buildKeyboard() {
    const rows = [
      'QWERTYUIOP',
      'ASDFGHJKL',
      'ZXCVBNM'
    ];

    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth / 12;
    buttonWidth = buttonWidth > 50 ? 50 : buttonWidth;

    return Column(
      children: [
        ...rows.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.split('').map((char) {
              return Container(
                margin: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () => handleLetterInput(char),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(buttonWidth, buttonWidth),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  child: Text(char),
                ),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 4.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: handleDelete,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, buttonWidth),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('Backspace'),
            ),
            const SizedBox(width: 4.0),
            ElevatedButton(
              onPressed: handleEnter,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth * 2, buttonWidth),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('Enter'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeSurfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      appBar: AppBar(
        leading: BackButton(color: themeSurfaceColor),
        title: Text('${widget.difficulty} Difficulty',
          style: TextStyle(color: themeSurfaceColor),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Game Grid with responsive sizing
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double gridSize = widget.wordLength * 55 + 5 * (widget.wordLength - 1);

                return SizedBox(
                  width: gridSize,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: 6 * widget.wordLength,
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.wordLength,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                    ),
                    itemBuilder: (context, index) {
                      int row = index ~/ widget.wordLength;
                      int col = index % widget.wordLength;

                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: gridColors[row].length > col ? gridColors[row][col] : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          guesses[row].length > col ? guesses[row][col].toUpperCase() : '',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          buildKeyboard(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
