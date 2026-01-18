import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class KeywordHandler {
  // DB 생성
  Future<Database> initializedDB() async{
    String path = join(await getDatabasesPath(), "keyword.db");
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async{
        await db.execute(
          '''
            CREATE TABLE keyword(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              word TEXT unique,
              createDate TEXT
            )
          '''
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 기존 DB가 있으면 간단히 재생성(개발 중일 때만)
        await db.execute('DROP TABLE IF EXISTS keyword');
        await db.execute('''
          CREATE TABLE keyword(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              word TEXT unique,
              createDate TEXT
          )
        ''');
      },
    );
  }

  Future<int> existKeyword(String word) async{
    final db = await initializedDB();
    final result = await db.rawQuery(
    '''
      select count(id) from keyword
      where word = ?
    ''',
    [word]
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 입력
  Future<void> insertKeyword(String word) async{
    final db = await initializedDB();
    await db.rawInsert(
      '''
        INSERT INTO keyword(word, createDate)
        VALUES(?, datetime('now','localtime'))
      ''',
      [
        word
      ]
    );
  }

  Future<void> updateKeyword(String word) async{
    final db = await initializedDB();
    await db.rawUpdate(
      '''
        update keyword 
        set createDate = datetime('now','localtime')
        where word = ?
      ''',
      [word]
    );
  }

  // 최근 5개만 조회
  Future<List<String>> queryKeyword() async{
    final db = await initializedDB();
    final result = await db.rawQuery('''
      select word from keyword
      order by createDate desc
      limit 5
      ''');
    return result.map((e) => e['word'] as String).toList();
  }
}