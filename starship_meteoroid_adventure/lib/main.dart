import 'package:flutter/material.dart'; // Фреймворк для создания пользовательского интерфейса.
import 'package:provider/provider.dart'; // Используется для управления состоянием через контекст.
import 'package:shared_preferences/shared_preferences.dart'; // Для сохранения рекорда на устройстве.
import 'dart:async'; // Для управления таймерами и асинхронной работой.
import 'dart:math'; // Для генерации случайных чисел.

// Основной метод запуска приложения.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(), // Создаём объект GameState для управления состоянием игры.
      child: SpaceScrollerGame(), // Корневой виджет приложения.
    ),
  );
}

// Класс для управления состоянием игры, включая рекорд.
class GameState extends ChangeNotifier {
  int _highScore = 0; // Переменная для хранения рекорда.

  int get highScore => _highScore; // Геттер для доступа к рекорду.

  GameState() {
    _loadHighScore(); // Загружаем рекорд при инициализации.
  }

  // Обновление рекорда, если текущий счёт выше.
  void updateHighScore(int score) {
    if (score > _highScore) {
      _highScore = score;
      _saveHighScore(); // Сохраняем новый рекорд.
      notifyListeners(); // Уведомляем слушателей об изменениях.
    }
  }

  // Сохранение рекорда в память устройства.
  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('highScore', _highScore);
  }

  // Загрузка рекорда из памяти устройства.
  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('highScore') ?? 0;
    notifyListeners();
  }
}

// Основной виджет приложения.
class SpaceScrollerGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Starship: Meteoroid Adventure', // Название приложения.
      home: MainMenuScreen(), // Главный экран приложения.
    );
  }
}

// Экран главного меню.
class MainMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final highScore = context.watch<GameState>().highScore; // Получаем рекорд из состояния.

    return Scaffold(
      backgroundColor: Colors.black, // Чёрный фон.
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Starship: Meteoroid Adventure', // Название игры.
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '🚀', // Иконка ракеты.
              style: TextStyle(fontSize: 100),
            ),
            SizedBox(height: 20),
            Text(
              //'High Score: $highScore', // Отображение рекорда.
              'Рекорд: $highScore', // Отображение рекорда.
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => SpaceGameScreen())); // Переход к игре.
              },
              //child: Text('Start Game'), // Кнопка старта.
              child: Text('Начать игру 🎮'),
            ),
          ],
        ),
      ),
    );
  }
}

// Экран самой игры.
class SpaceGameScreen extends StatefulWidget {
  @override
  _SpaceGameScreenState createState() => _SpaceGameScreenState();
}

class _SpaceGameScreenState extends State<SpaceGameScreen> {
  double spaceshipPosition = 0.0; // Положение ракеты по горизонтали.
  List<double> obstaclePositions = [0.0, 0.5, -0.5]; // Позиции препятствий по горизонтали.
  List<double> obstacleHeights = [0.0, -1.0, -2.0]; // Высоты препятствий.
  double speed = 0.0025; // Начальная скорость.
  double speedAdd = 0.0002; // Увеличение скорости.
  //Timer? gameTimer; // Таймер игрового цикла.
  //Timer? movementTimer; // Таймер движения ракеты.
  int score = 0; // Текущий счёт.
  bool isGameOver = false; // Флаг конца игры.
  final Random random = Random(); // Генератор случайных чисел.

  // Начало игрового цикла.
  void startGame() {
    Future<void> gameLoop() async {
      while (!isGameOver) {
        await Future.delayed(Duration(milliseconds: 8)); // Задержка для 120 FPS.
        setState(() {
          for (int i = 0; i < obstacleHeights.length; i++) {
            obstacleHeights[i] += speed; // Сдвигаем препятствия вниз.
            if (obstacleHeights[i] > 1.0) { // Если препятствие прошло экран.
              obstacleHeights[i] = -1.0; // Возвращаем его наверх.
              obstaclePositions[i] = (random.nextDouble() * 2.0 - 1.0); // Новая случайная позиция.
              score++; // Увеличиваем счёт.
              speed += speedAdd; // Увеличиваем скорость.
            }
          }
        });
        checkCollision(); // Проверка на столкновения.
      }
    }

    gameLoop();
  }

  // Управление движением ракеты.
  void moveSpaceship(double direction) {
    if (isGameOver) return;
    setState(() {
      spaceshipPosition += direction; // Меняем позицию.
      spaceshipPosition = spaceshipPosition.clamp(-1.0, 1.0); // Ограничиваем положение.
    });
  }
  bool isMoving = false;
  // Начало движения при удержании кнопки.
  void startContinuousMovement(double direction) async {
    isMoving = true;
    while (isMoving && !isGameOver) {
      moveSpaceship(direction * 0.025);
      await Future.delayed(Duration(milliseconds: 8));
    }
  }

  // Остановка движения при отпускании кнопки.
  void stopContinuousMovement() {
    isMoving = false;
  }

  // Проверка столкновений.
  void checkCollision() {
    for (int i = 0; i < obstacleHeights.length; i++) {
      if ((obstacleHeights[i] > 0.65 && obstacleHeights[i] < 0.70) && // Зона столкновения по вертикали.
          (spaceshipPosition > obstaclePositions[i] - 0.4 && spaceshipPosition < obstaclePositions[i] + 0.4)) { // Зона по горизонтали.
        gameOver();
      }
    }
  }

  // Конец игры.
  void gameOver() {
    setState(() {
      isGameOver = true; // Устанавливаем флаг конца игры.
    });
    //gameTimer?.cancel();
    //movementTimer?.cancel();
    final gameState = context.read<GameState>();
    gameState.updateHighScore(score); // Обновляем рекорд.

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        //title: Text('Game Over'),
        title: Text('Игра окончена 👾'),
        //content: Text('Your score: $score'),
        content: Text('Очки: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame(); // Перезапуск игры.
            },
            //child: Text('Restart'),
            child: Text('Заново'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => MainMenuScreen()),
                    (route) => false,
              ); // Возврат в главное меню.
            },
            //child: Text('Main Menu'),
            child: Text('Главное меню'),
          ),
        ],
      ),
    );
  }

  // Сброс игры к начальным значениям.
  void resetGame() {
    setState(() {
      spaceshipPosition = 0.0;
      obstacleHeights = [0.0, -1.0, -2.0];
      obstaclePositions = [0.0, 0.5, -0.5];
      speed = 0.0025;
      score = 0;
      isGameOver = false;
    });
    startGame(); // Перезапускаем игровой цикл.
  }

  @override
  void initState() {
    super.initState();
    startGame(); // Инициализация игры.
  }

  @override
  void dispose() {
    //gameTimer?.cancel(); // Освобождаем ресурсы.
    //movementTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highScore = context.watch<GameState>().highScore;

    return Scaffold(
      backgroundColor: Colors.black, // Чёрный фон.
      body: Column(
        children: [
          SizedBox(height: 50),
          //Text('Score: $score', style: TextStyle(color: Colors.white, fontSize: 24)), // Текущий счёт.
          Text('Текущий счёт: $score', style: TextStyle(color: Colors.white, fontSize: 24)), // Текущий счёт.
          //Text('High Score: $highScore', style: TextStyle(color: Colors.white, fontSize: 20)), // Рекорд.
          Text('Рекорд: $highScore', style: TextStyle(color: Colors.white, fontSize: 20)), // Рекорд.
          Expanded(
            child: Stack(
              children: [
                // Положение ракеты.
                Positioned(
                  bottom: 50,
                  left: MediaQuery.of(context).size.width / 2 + spaceshipPosition * 100 - 25,
                  child: Transform.rotate(
                    angle: -pi / 4, // Поворот ракеты.
                    child: Text('🚀', style: TextStyle(fontSize: 50)),
                  ),
                ),
                // Отображение препятствий.
                for (int i = 0; i < obstacleHeights.length; i++)
                  Positioned(
                    top: MediaQuery.of(context).size.height * obstacleHeights[i],
                    left: MediaQuery.of(context).size.width / 2 + obstaclePositions[i] * 100 - 25,
                    child: Text('🌑', style: TextStyle(fontSize: 50)),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Кнопка движения влево.
              GestureDetector(
                onTapDown: (_) {
                  startContinuousMovement(-1.0);
                },
                onTapUp: (_) {
                  stopContinuousMovement();
                },
                onTapCancel: () {
                  stopContinuousMovement();
                },
                child: ElevatedButton(
                  onPressed: isGameOver ? null : () => moveSpaceship(-0.1),
                  //child: Text('Left'),
                  child: Text('<<<'),
                ),
              ),
              // Кнопка движения вправо.
              GestureDetector(
                onTapDown: (_) {
                  startContinuousMovement(1.0);
                },
                onTapUp: (_) {
                  stopContinuousMovement();
                },
                onTapCancel: () {
                  stopContinuousMovement();
                },
                child: ElevatedButton(
                  onPressed: isGameOver ? null : () => moveSpaceship(0.1),
                  //child: Text('Right'),
                  child: Text('>>>'),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
