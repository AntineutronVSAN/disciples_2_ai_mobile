# d2_ai_v2

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Generate toJson/fromJson models
flutter pub run build_runner build --delete-conflicting-outputs

# Profiling
dart run --pause-isolates-on-start --observe main.dart
dart --pause-isolates-on-start --observe lib\run_genetic_algorithm.dart

# Compile genetic algorithm
dart compile exe lib\run_genetic_algorithm.dart

# Benchmarking
flutter pub run benchmark

# Testing
flutter test

# Обязательно

- Запускать юнит-тесты после изменений в AttackController

# TODO
- [ ] - Двуклетоные юниты
- [ ] - Баги с превращением: 1) Вторая атака превращаемого юнита наследуется 2) Понижение/повышение параметров работает некорректно
- [ ] - Призыв
- [ ] - Превращение себя
- [ ] - Использование предметов
- [ ] - Даровать защиту
- [x] - Иммуны и защиты
- [x] - Для AB алгоритма сделать сопернику ролл макс урона и ини
- [x] - Для AB подумать, как можно учитывать точность (пока сделать точность для всех 100%)
- [ ] - Для neat изменить мутации. Сделать мутации с участием входных/выходных узлов обязательной
- [ ] - Лечение восстанавливает форму
- [ ] - Вынести ML в отдельный пакет
- [ ] - Сделать DBF парсер
- [ ] - Баг карающего клинка с двойным щитом
- [ ] - Юнит тесты тауматургии и вампиризма
