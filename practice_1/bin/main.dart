import 'package:practice_1/features/core/data/open_meteo/weather_repository_open_meteo.dart';
import 'package:practice_1/features/core/data/overpass/overpass_api.dart';
import 'package:practice_1/features/core/data/open_meteo/open_meteo_api.dart';
import 'package:practice_1/features/core/presentation/app.dart';
import 'dart:io';
import 'package:lakos/lakos.dart';
import 'package:path/path.dart' as path;
import 'package:lakos/src/build_model.dart';
import 'package:test/test.dart';

// Функция для создания .dot файла
void createDotFile(String projectPath, String outputFilePath) {
  final buffer = StringBuffer();
  buffer.writeln('digraph G {');

  // Рекурсивно обходим все файлы в проекте
  void parseDirectory(Directory dir) {
    for (var entity in dir.listSync(recursive: false)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final nodeName = path.basename(entity.path);
        buffer.writeln('"$nodeName";');
      } else if (entity is Directory) {
        parseDirectory(entity);
      }
    }
  }

  // Стартуем с корневой директории проекта
  parseDirectory(Directory(projectPath));

  buffer.writeln('}');

  // Сохраняем результат в файл
  File(outputFilePath).writeAsStringSync(buffer.toString());
  print('DOT файл успешно создан: $outputFilePath');
}

// Функция для конвертации .dot файла в .png
Future<void> convertDotToPng(String dotFilePath, String pngFilePath) async {
  try {
    // Запускаем процесс 'dot' с аргументами для конвертации .dot в .png
    final result = await Process.run('dot', ['-Tpng', dotFilePath, '-o', pngFilePath]);

    if (result.exitCode == 0) {
      print('PNG картинка успешно создана: $pngFilePath');
    } else {
      print('Ошибка при создании PNG: ${result.stderr}');
    }
  } catch (e) {
    print('Не удалось запустить Graphviz: $e');
  }
}

void createLakosGraph() async {
  // Создаем экземпляр LakosDiagramGenerator
  var model = buildModel(Directory('.'), ignoreGlob: 'test/**', showMetrics: true);

  // Генерация графа в формате DOT
  var dotOutput = model.getOutput(OutputFormat.dot);

  // Сохраняем граф в DOT-файл
  var dotFile = File('project_graph.dot');
  dotFile.writeAsString(dotOutput);

  // Проверяем наличие циклов зависимостей
  if (!model.metrics!.isAcyclic) {
    print('Dependency cycle detected.');
  }

  // Выводим метрики по SLOC
  var nodesSortedBySloc = model.nodes.values.toList();
  nodesSortedBySloc.sort((a, b) => a.sloc!.compareTo(b.sloc!));
  for (var node in nodesSortedBySloc) {
    print('${node.sloc}: ${node.id}');
  }

  // Конвертируем DOT в PNG используя Graphviz (предполагается, что Graphviz установлен)
  var result = await Process.run('dot', ['-Tpng', 'project_graph.dot', '-o', 'project_graph1.png']);

  if (result.exitCode == 0) {
    print('Graph generated and saved as project_graph2.png');
  } else {
    print('Error generating graph: ${result.stderr}');
  }
}


void main(List<String> arguments) async {
  var overpassApi = OverpassApi();
  var openMeteoApi = OpenMeteoApi();
  var weatherRepository = WeatherRepositoryOpenMeteo(overpassApi, openMeteoApi);

  var app = App(weatherRepository);
  app.run();
  createLakosGraph();
}
