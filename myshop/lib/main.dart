import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(GameStoreApp());
}

class GameStoreApp extends StatelessWidget {
  const GameStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GameStore',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameStoreScreen(),
    );
  }
}

class GameStoreScreen extends StatefulWidget {
  GameStoreScreen({Key? key}) : super(key: key);

  @override
  _GameStoreScreenState createState() => _GameStoreScreenState();
}

class _GameStoreScreenState extends State<GameStoreScreen> {
  List<Game> games = [
    Game('Forza Horizon 4', 'assets/forza.jpg', 49.99, 'Гоночная игра в открытом мире.'),
    Game('Stardew Valley', 'assets/stardew_valley.jpg', 14.99, 'Симулятор фермы и ролевой игры.'),
    Game('GTA 5', 'assets/gta5.jpg', 29.99, 'Популярная криминальная экшен-игра.'),
    Game('Metro Exodus', 'assets/metro_exodus.jpg', 39.99, 'Шутер с элементами выживания в постапокалиптической России.')
  ];

  void _removeGame(Game game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление товара'),
        content: const Text('Вы уверены, что хотите удалить товар?'),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Удалить'),
            onPressed: () {
              setState(() {
                games.remove(game);
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GameStore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddGameScreen(
                    onAdd: (game) {
                      setState(() {
                        games.add(game);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: game.imageFilePath != null
                  ? Image.file(
                      File(game.imageFilePath!),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      game.imagePath,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
              title: Center(child: Text(game.name)),
              subtitle: Center(child: Text('${game.price} \$')),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeGame(game),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameDetailScreen(game: game),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class Game {
  final String name;
  final String imagePath;
  final double price;
  final String description;
  String? imageFilePath;

  Game(this.name, this.imagePath, this.price, this.description, {this.imageFilePath});
}

class GameDetailScreen extends StatelessWidget {
  final Game game;

  const GameDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(game.name),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              game.imageFilePath != null
                  ? Image.file(
                      File(game.imageFilePath!),
                      width: 360,
                      height: 240,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      game.imagePath,
                      width: 360,
                      height: 240,
                      fit: BoxFit.cover,
                    ),
              const SizedBox(height: 20),
              Text(
                game.description,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                '${game.price} \$',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
             ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddGameScreen extends StatefulWidget {
  final Function(Game) onAdd;

  const AddGameScreen({Key? key, required this.onAdd}) : super(key: key);

  @override
  _AddGameScreenState createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? imageFilePath;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        imageFilePath = image.path;
      });
    }
  }

  void _submit() {
    if (nameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        imageFilePath != null) {
      final game = Game(
        nameController.text,
        'assets/new_image.jpg',
        double.parse(priceController.text),
        descriptionController.text,
        imageFilePath: imageFilePath,
      );
      widget.onAdd(game);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить игру'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Цена'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
            const SizedBox(height: 20),
            imageFilePath == null
                ? const Text('Фото не выбрано')
                : Image.file(
                    File(imageFilePath!),
                    width: 100,
                    height: 100,
                  ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Выбрать фото'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}
