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


# Compile
dart compile exe lib\run_genetic_algorithm.dart


# TODO
- [ ] - Двуклетоные юниты
- [ ] - Баги с превращением: 1) Вторая атака превращаемого юнита наследуется 2) Понижение/повышение параметров работает некорректно
- [ ] - Призыв
- [ ] - Превращение себя
- [ ] - Использование предметов
- [ ] - Даровать защиту
- [ ] - Иммуны и защиты
- [ ] - Для AB алгоритма сделать сопернику ролл макс урона и ини
- [ ] - Для AB подумать, как можно учитывать точность
- [ ] - Для neat изменить мутации. Сделать мутации с участием входных/выходных узлов обязательной
