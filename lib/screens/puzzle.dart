import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PlantPuzzleScreen extends StatefulWidget {
  final String plantName;

  const PlantPuzzleScreen({super.key, required this.plantName});

  @override
  State<PlantPuzzleScreen> createState() => _PlantPuzzleScreenState();
}

class _PlantPuzzleScreenState extends State<PlantPuzzleScreen> {
  List<Image?> _tiles = [];
  List<Image?> _correctOrder = [];
  late int _emptyTileIndex;
  int _moveCount = 0;
  late Timer _timer;
  int _elapsedTime = 0;
  late String _imagePath;
  late Map<String, dynamic> _currentStyle;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlantData();
    _loadStyle();
    _startTimer();
  }

  Future<void> _loadPlantData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/json-files/plants.json');
      final List<dynamic> data = json.decode(response);
      final plant = data.firstWhere(
        (p) => p['name'] == widget.plantName,
        orElse: () => null,
      );

      if (plant != null) {
        setState(() {
          _imagePath = plant['image'];
        });
        await _initializePuzzle();
      }
    } catch (e) {
      debugPrint('Error loading plant data: $e');
    }
  }

  Future<void> _loadStyle() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/json-files/style.json');
      final data = json.decode(jsonString);
      final styles = List<Map<String, dynamic>>.from(data['styles']);

      final prefs = await SharedPreferences.getInstance();
      final savedStyleIndex = prefs.getInt('selectedStyleIndex') ?? 0;

      setState(() {
        _currentStyle = styles.firstWhere(
            (style) => style['id'] == savedStyleIndex + 1,
            orElse: () => styles.first);
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading style: $e');
    }
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
    shuffledTiles.add(null);

    shuffledTiles.removeAt(shuffledTiles.length - 1);
    shuffledTiles.shuffle();
    shuffledTiles.add(null);

    setState(() {
      _tiles = shuffledTiles;
      _emptyTileIndex = _tiles.length - 1;
    });
  }

  Future<List<Image?>> _splitImage(ui.Image image) async {
    int tileSize = image.width ~/ 3;
    List<Image?> tiles = [];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (i == 2 && j == 2) break;

        tiles.add(Image.memory(await _extractTile(image, i, j, tileSize)));
      }
    }

    return tiles;
  }

  Future<Uint8List> _extractTile(
      ui.Image image, int i, int j, int tileSize) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final srcRect = Rect.fromLTWH(
      j * tileSize.toDouble(),
      i * tileSize.toDouble(),
      tileSize.toDouble(),
      tileSize.toDouble(),
    );
    final dstRect =
        Rect.fromLTWH(0, 0, tileSize.toDouble(), tileSize.toDouble());

    canvas.drawImageRect(image, srcRect, dstRect, Paint());

    final picture = recorder.endRecording();
    final ui.Image tileImage = await picture.toImage(tileSize, tileSize);

    ByteData? byteData =
        await tileImage.toByteData(format: ui.ImageByteFormat.png);
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
    int rowDifference = (_emptyTileIndex ~/ 3 - index ~/ 3).abs();
    int columnDifference = (_emptyTileIndex % 3 - index % 3).abs();
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
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Puzzle Game'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_tiles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Puzzle Game'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Game'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_currentStyle['backgroundImage']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0), // Transparent layer
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.black, width: 2.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Moves: $_moveCount',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Timer: ${_formatTime(_elapsedTime)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: _showOriginalImage,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(4.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: 9,
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
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: _tiles[index],
      ),
    );
  }

  String _formatTime(int elapsedTime) {
    final int minutes = elapsedTime ~/ 60;
    final int seconds = elapsedTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
