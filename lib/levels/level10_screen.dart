import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Level10Screen extends StatefulWidget {
  const Level10Screen({super.key});

  @override
  State<Level10Screen> createState() => _Level10ScreenState();
}

class _Level10ScreenState extends State<Level10Screen> {
  List<Image?> _tiles = []; // Initialized to an empty list
  List<Image?> _correctOrder = [];
  late int _emptyTileIndex;
  int _moveCount = 0;
  late Timer _timer;
  int _elapsedTime = 0;
  final String _imagePath = 'images/levels/level10-plant.jpg';

  @override
  void initState() {
    super.initState();
    _initializePuzzle();
    _startTimer();
  }

  Future<void> _initializePuzzle() async {
    ByteData imageData = await rootBundle.load(_imagePath);
    Uint8List bytes = imageData.buffer.asUint8List();

    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, completer.complete);
    ui.Image image = await completer.future;

    List<Image?> tiles = await _splitImage(image);
    _correctOrder = List.from(tiles);

    List<Image?> shuffledTiles = List.from(tiles);
    shuffledTiles.add(null); // Add an empty tile

    shuffledTiles.removeAt(shuffledTiles.length - 1);
    shuffledTiles.shuffle();
    shuffledTiles.add(null); // Add the empty tile back

    setState(() {
      _tiles = shuffledTiles;
      _emptyTileIndex = _tiles.length - 1; // The last index is the empty tile
    });
  }

  Future<List<Image?>> _splitImage(ui.Image image) async {
    int tileSize = image.width ~/ 3; // Updated for 3x3 grid
    List<Image?> tiles = [];

    for (int i = 0; i < 3; i++) { // Updated for 3x3 grid
      for (int j = 0; j < 3; j++) {
        if (i == 2 && j == 2) break; // Skip the last tile

        tiles.add(Image.memory(await _extractTile(image, i, j, tileSize)));
      }
    }

    return tiles;
  }

  Future<Uint8List> _extractTile(ui.Image image, int i, int j, int tileSize) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final srcRect = Rect.fromLTWH(
      j * tileSize.toDouble(),
      i * tileSize.toDouble(),
      tileSize.toDouble(),
      tileSize.toDouble(),
    );
    final dstRect = Rect.fromLTWH(0, 0, tileSize.toDouble(), tileSize.toDouble());

    canvas.drawImageRect(image, srcRect, dstRect, Paint());

    final picture = recorder.endRecording();
    final ui.Image tileImage = await picture.toImage(tileSize, tileSize);

    ByteData? byteData = await tileImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _moveTile(int index) {
    if (_canMove(index)) {
      setState(() {
        _tiles[_emptyTileIndex] = _tiles[index];
        _tiles[index] = null;
        _emptyTileIndex = index;
        _moveCount++;
      });

      if (_isPuzzleSolved()) {
        _showWinDialog();
      }
    }
  }

  bool _canMove(int index) {
    int rowDifference = (_emptyTileIndex ~/ 3 - index ~/ 3).abs(); // Updated for 3x3 grid
    int columnDifference = (_emptyTileIndex % 3 - index % 3).abs(); // Updated for 3x3 grid
    return (rowDifference + columnDifference) == 1;
  }

  bool _isPuzzleSolved() {
    for (int i = 0; i < _correctOrder.length; i++) {
      if (_tiles[i] != _correctOrder[i]) {
        return false;
      }
    }
    return true;
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("You Win!"),
          content: const Text("Congratulations, you solved the puzzle!"),
          actions: [
            TextButton(
              child: const Text("Play Again"),
              onPressed: () {
                Navigator.of(context).pop();
                _initializePuzzle();
                setState(() {
                  _moveCount = 0;
                  _elapsedTime = 0;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showOriginalImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.asset(_imagePath),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tiles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Level 1: 3x3 Puzzle'), // Updated title
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 1: 3x3 Puzzle'), // Updated title
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/puzzle-bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Moves: $_moveCount'),
                    Text('Timer: ${_formatTime(_elapsedTime)}'),
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _showOriginalImage,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(4.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Updated for 3x3 grid
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: 9, // Updated for 3x3 grid
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _moveTile(index),
                      child: _buildTile(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTile(int index) {
    if (_tiles[index] == null) {
      return Container(
        color: Colors.transparent,
      );
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _tiles[index]!.image,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.white, width: 2.0),
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
