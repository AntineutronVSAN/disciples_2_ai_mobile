
/// ---------------- Провайдеры игровых объектов ------------------
const String smnsD2UnitsProviderIDkey = 'UNIT_ID';
const String smnsD2UnitsProviderAssetPath = 'assets/dbf/smns_path_0_999/Globals/Gunits.dbf';

const String smnsD2AttacksProviderIDkey = 'ATT_ID';
const String smnsD2AttacksProviderAssetPath = 'assets/dbf/smns_path_0_999/Globals/Gattacks.dbf';

const String smnsD2TransfProviderIDkey = '';
const String smnsD2TransfProviderAssetPath = 'assets/dbf/smns_path_0_999/Globals/Gtransf.dbf';

const String smnsD2ImmuCProviderIDkey = '';
const String smnsD2ImmuCProviderAssetPath = 'assets/dbf/smns_path_0_999/Globals/GimmuC.dbf';

const String smnsD2ImmuProviderIDkey = '';
const String smnsD2ImmuProviderAssetPath = 'assets/dbf/smns_path_0_999/Globals/Gimmu.dbf';

const String smnsD2GDynUpgProviderIDkey = '';
const String smnsD2GDynUpgProviderAssetPath = 'assets/dbf/smns_path_0_999/Globals/GDynUpgr.DBF';

const String smnsD2GlobalProviderIDkey = '';
const String smnsD2GlobalProviderAssetPath = 'assets/dbf/smns_path_0_999/Globals/Tglobal.dbf';

const int maxUnitXp = 9999;
const int maxUnitDamage = 999;


/// ---------------- Простая нейронная сеть ------------------

/// Размер вектора о общей информации о игре
const int gameInfoVectorLength = 1;
/// Размер вектора, описывающего юнита
const int unitVectorLength = 15;
/// Размер вектора, описывающего атаку
const int attackVectorLength = 37;
/// Число атак у юнита
const int attacksCount = 2;
/// Размер вектора, описывающего число клеток на поле боя
const int cellsCount = 12;
/// Размер вектора, описывающего число возможных действий
const int actionsCount = 14;

/// Общий размер вектора ячейки (юнит + общая информация)
const int cellVectorLength = gameInfoVectorLength + unitVectorLength + attackVectorLength*attacksCount;
/// Общий размер входного вектора
const int inputVectorLength = cellVectorLength*cellsCount;

/*
/// Размер вектора о общей информации о игре
const int gameInfoVectorLength = 1;
/// Размер вектора, описывающего юнита
const int unitVectorLength = 15;
/// Размер вектора, описывающего атаку 1
const int attackVectorLength = 37;
/// Размер вектора, описывающего атаку 2
const int attack2VectorLength = 37;
/// Размер вектора, описывающего число клеток на поле боя
const int cellsCount = 12;
/// Размер вектора, описывающего число возможных действий
const int actionsCount = 14;
/// Число нейронов в скрытом слое
const int neuralNetworkHiddenCount = 300;
/// Число скрытых слоёв в нейронной сети
const int neuralNetworkHiddenLayersCount = 5;

const int oneUnitVectorLength =

/// Размер входного вектора в нейросеть
const int neuralNetworkInputVectorLength =
    gameInfoVectorLength * cellsCount +
        (unitVectorLength + attackVectorLength + attack2VectorLength)*cellsCount;
*/


/// ----------------------------------------------------------

class NeuralNetworkConfig {

}