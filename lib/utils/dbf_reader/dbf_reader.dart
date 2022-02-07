
/*

B (Бинарный)
Все символы кодовой страницы OEM (внутренний формат записи - 10 цифр, содержащих номер .DBT-блока).
C (Символы)
Все символы кодовой страницы OEM
D (Дата)
Числа и символ-разделитель для месяца, дня и года (внутренний формат записи - 8 цифр в формате YYYYMMDD)
G (Общий)
Все символы кодовой страницы OEM или OLE (внутренний формат записи - 10 цифр, содержащих номер .DBT-блока).
N (Числовой)
- . 0 1 2 3 4 5 6 7 8 9
L (Логический)
? Y y N n T t F f (? - не инициализировано)
M (Мемо)
Все символы кодовой страницы OEM (внутренний формат записи - 10 цифр, содержащих номер .DBT-блока)


Теперь уже можно сделать кое-какие вычисления. Например, определить количество полей в DBF-файле.
Размер заголовка DBF-файла в байтах составляет:
32+32xN+1 байт, где N - количество полей.
Этот же размер можно извлечь из 8,9 байтов заголовка - HeaderSize
Следовательно количество полей равно:
N:=(HeaderSize-33)/32 байт.
Сместившись на HeaderSize байт от начала файла, мы переходим к непосредственно к
самим записям, размер которых указан в 10,11 байтах заголовка - RecordSize, а их количество в 04..07 байтах - RecordsCount.

http://www.delphikingdom.com/asp/viewitem.asp?catalogid=624
https://softclipper.net/bazy-dbf/format-fajla-dbf.html

*/

import 'dart:convert';
import 'dart:typed_data';

import 'package:d2_ai_v2/utils/bytes_utils.dart';

class DBFReader {

  /// Заголовок файла
  late final DBFHeader header;
  /// Описание всех столбцов/полей
  final List<DBFColumn> columns = [];
  /// Тело/строки

  void read(Uint8List bytes) {

    header = DBFHeader(bytes: bytes);
    for(var i=0; i<header.fieldsCount; i++) {
      columns.add(DBFColumn(bytes: bytes.sublist(32*(i+1), 32*(i+2))));
    }

    print(header);

    print('asdfasdf');

    /*print(bytes[0]);

    print('---Дата последнего обновления в формате YYMMDD');
    print(bytes[1]);
    print(bytes[2]);
    print(bytes[3]);

    print('---Количество записей в таблице 32-битное число');
    //print(bytes[4]);
    //print(bytes[5]);
    //print(bytes[6]);
    //print(bytes[7]);
    var test = Uint8List(4);
    test[3] = bytes[4];
    test[2] = bytes[5];
    test[1] = bytes[6];
    test[0] = bytes[7];
    print('result = ${test.buffer.asByteData().getUint32(0)}');

    print('---Количество байтов, занимаемых заголовком 16-битное число');
    test = Uint8List(2);
    test[1] = bytes[8];
    test[0] = bytes[9];
    var headerSize = test.buffer.asByteData().getUint16(0);
    print('Result = $headerSize');

    print('---Количество байтов, занимаемых записью 16-битное число');
    test = Uint8List(2);
    test[1] = bytes[10];
    test[0] = bytes[11];
    print('Result = ${test.buffer.asByteData().getUint16(0)}');

    print('---Зарезервированная область, заполнена нулями 2 байта');
    print(bytes[12]);
    print(bytes[13]);

    print('---Флаг, указывающий на наличие незавершенной транзакции');
    print(bytes[14]);

    print('---Флаг кодировки');
    print(bytes[15]);

    print('Зарезервированная область для многопользовательского использования dBASE IV');
    for(var i in bytes.sublist(16, 27)) {
      print(i);
    }

    print('Флаг наличия MDX-файла: 01H - файл присутствует, 00H - файл отсутствует');
    print(bytes[28]);

    print('ID драйвера языка');
    print(bytes[29]);

    print('Зарезервированная область, заполнена нулями');
    print(bytes[30]);
    print(bytes[31]);

    print('--------- 32-n по 32 байта Массив с описаниями полей (структура каждого такого описания показана ниже)');

    print('------------- Рассчёт числа полей-----------------');
    var fieldsCount = (headerSize-33)/32;
    print('Число полей - $fieldsCount');

    for(var i=0; i<fieldsCount; i++) {
      fieldsDescription(bytes.sublist(32*(i+1), 32*(i+2)));
    }

    print(columns);


    print('Переход к записям');*/



    //fieldsDescription(bytes.sublist(64, 64+32));

  }
}


class DBFHeader {

  late final int hasMemoFile;
  late final int modifiedDay;
  late final int modifiedMonth;
  late final int modifiedYear;
  late final int recordsCount;
  late final int headerSizeBytes;
  late final int recordSizeBytes;
  late final int reservedArea1;
  late final int reservedArea2;
  late final int hasNonCompleteTransactions;
  late final int encodingFlag;
  late final Uint8List reservedMultiUsersArea;
  late final int hasMdxFile;
  late final int languageDriverId;
  late final int reservedArea3;
  late final int reservedArea4;
  late final int fieldsCount;

  DBFHeader({required Uint8List bytes}) {
    hasMemoFile = bytes[0];

    modifiedYear = bytes[1];
    modifiedMonth = bytes[2];
    modifiedDay = bytes[3];

    var tempList = Uint8List(4);
    tempList[3] = bytes[4];
    tempList[2] = bytes[5];
    tempList[1] = bytes[6];
    tempList[0] = bytes[7];
    recordsCount = tempList.buffer.asByteData().getUint32(0);

    tempList = Uint8List(2);
    tempList[1] = bytes[8];
    tempList[0] = bytes[9];
    headerSizeBytes = tempList.buffer.asByteData().getUint16(0);

    //print('---Количество байтов, занимаемых записью 16-битное число');
    tempList = Uint8List(2);
    tempList[1] = bytes[10];
    tempList[0] = bytes[11];
    recordSizeBytes = tempList.buffer.asByteData().getUint16(0);

    //print('---Зарезервированная область, заполнена нулями 2 байта');
    reservedArea1 = bytes[12];
    reservedArea2 = bytes[13];

    //print('---Флаг, указывающий на наличие незавершенной транзакции');
    hasNonCompleteTransactions = bytes[14];

    //print('---Флаг кодировки');
    encodingFlag = bytes[15];

    //print('Зарезервированная область для многопользовательского использования dBASE IV');
    reservedMultiUsersArea = bytes.sublist(16, 28);

    //print('Флаг наличия MDX-файла: 01H - файл присутствует, 00H - файл отсутствует');
    hasMdxFile = bytes[28];

    //print('ID драйвера языка');
    languageDriverId = bytes[29];

    //print('Зарезервированная область, заполнена нулями');
    reservedArea3 = bytes[30];
    reservedArea4 = bytes[31];

    fieldsCount = (headerSizeBytes-33)~/32;
  }

  @override
  String toString() {
    print('Дата изменения: $modifiedYear.$modifiedMonth.$modifiedDay');
    print('Число записей: $recordsCount');
    print('Размер заголовка: $headerSizeBytes');
    print('Размер записи: $recordSizeBytes');
    print('Число полей: $fieldsCount');
    return '';
  }
}

class DBFColumn {

  late final String fieldName;
  late final String type;
  late final Uint8List reservedArea;
  late final int binFieldSize;
  late final int binFieldNumber;
  late final Uint8List reservedArea2;
  late final int workPlaceId;
  late final Uint8List reservedArea3;
  late final int mdxFieldFlag;

  DBFColumn({required Uint8List bytes}) {
    assert(bytes.length == 32);

    //print('\n0-10 11 байт Имя поля в ASCII (заполнено нулями).');
    var list = Uint8List(11);
    for(var i=0; i < 11; i++ ) {
      list[i] = bytes[i];
    }
    final name = const Utf8Decoder().convert(list);
    fieldName = name;

    //print('11 1 байт Тип поля в ASCII (C, D, F, L, M или N)');
    list = Uint8List(1);
    list[0] = bytes[11];
    //print(const Utf8Decoder().convert(list));
    type = const Utf8Decoder().convert(list);

    //print('12-15 4 байта Зарезервированная область');
    reservedArea = bytes.sublist(12, 16);

    //print('16 1 байт Размер поля в бинарном формате');
    //print(bytes[16]);
    binFieldSize = bytes[16];

    //print('17 1 байт Порядковый номер поля в бинарном формате');
    //print(bytes[17]);
    binFieldNumber = bytes[17];

    //print('18-19 2 байта Зарезервированная область');
    //print(bytes[18]);
    //print(bytes[19]);
    reservedArea2 = bytes.sublist(18,20);

    //print('20 1 байт ID рабочей области');
    //print(bytes[20]);
    workPlaceId = bytes[20];

    /*print('21-30 10 байт Зарезервированная область');
    for(var i in bytes.sublist(21, 30)) {
      //print(i);
    }*/
    reservedArea3 = bytes.sublist(21, 31);

    //print('31 1 байт Флаг MDX-поля: 01H если поле имеет метку индекса в MDX-файле, 00H - нет.');
    //print(bytes[31]);
    mdxFieldFlag = bytes[31];
  }

}
