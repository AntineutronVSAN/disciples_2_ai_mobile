

const int maxUnitXp = 9999;
const int maxUnitDamage = 999;


/// ---------------- Простая нейронная сеть ------------------
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
/// Размер входного вектора в нейросеть
const int neuralNetworkInputVectorLength =
    gameInfoVectorLength * cellsCount +
        (unitVectorLength + attackVectorLength + attack2VectorLength)*cellsCount;

/// ----------------------------------------------------------

class NeuralNetworkConfig {

}