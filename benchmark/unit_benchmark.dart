
import 'package:benchmark/benchmark.dart';
import 'package:d2_ai_v2/models/g_immu/g_immu_provider.dart';
import 'package:d2_ai_v2/models/g_immu_c/g_immu_c_provider.dart';
import 'package:d2_ai_v2/models/providers.dart';
import 'package:d2_ai_v2/models/unit.dart';
import 'package:d2_ai_v2/repositories/game_repository.dart';


void main() {
  final GameRepository gameRepository = GameRepository(
      gunitsProvider: GunitsProvider(),
      tglobalProvider: TglobalProvider(),
      gattacksProvider: GattacksProvider(),
      gtransfProvider: GtransfProvider(),
      gDynUpgrProvider: GDynUpgrProvider(),
      gimmuProvider: GimmuProvider(),
      gimmuCProvider: GimmuCProvider())..init();

  final Unit testUnit = gameRepository.getRandomUnit();


  benchmark('Unit.copywith(currentHp: 20)', () {

    for(var i=0; i<2000000; i++ ) {
      testUnit.copyWith(currentHp: 20);
    }
  });

  benchmark('Unit.deepCopy()', () {

    for(var i=0; i<2000000; i++ ) {
      testUnit.deepCopy();
    }
  });

  benchmark('Unit.copywith(isMoving: false)', () {

    for(var i=0; i<2000000; i++ ) {
      testUnit.copyWith(isMoving: false);
    }
  });
  benchmark('Unit.isMoving = false)', () {

    for(var i=0; i<2000000; i++ ) {
      testUnit.isMoving = false;
    }
  });
}
