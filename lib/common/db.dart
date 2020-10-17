import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

const migrationScripts = [
  'script 1',
  'script 2',
  'script 3',
]; // Migration sql scripts, containing a single statements per migration



class DBHelper {







  /*static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath(); // getDatabasesPath()는 경로값을 리턴합니다
    return sql.openDatabase(path.join(dbPath, 'tasks.db'), // join() 메서드는 경로와 생성할 DB 파일의 이름을 매개변수로 받아 데이터베이스를 생성합니다
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE tasks(생성할 column 이름 자료형)');
    }, version: 1);
  }*/

  static Future<Database> database() async {

    print("!!!");

    final dbPath = await sql.getDatabasesPath(); // getDatabasesPath()는 경로값을 리턴합니다



    return sql.openDatabase(path.join(dbPath, 'yammeal.db'), // join() 메서드는 경로와 생성할 DB 파일의 이름을 매개변수로 받아 데이터베이스를 생성합니다
        onCreate: (db, version) {
          return db.execute(
              'CREATE TABLE meals(mealSeq INTEGER PRIMARY KEY, schoolId INTEGER, menuDate TEXT, menus TEXT)');
        },

        onUpgrade: (Database db, int oldVersion, int newVersion) async {
      print("onUpgrad");
        try {
          db.execute("drop table meals");
        }on Exception{

        }
        try {
          db.execute(
              'CREATE TABLE meals(mealSeq INTEGER PRIMARY KEY, schoolId INTEGER, menuDate TEXT, menus TEXT)');
        } on Exception {

        }



        },

        onOpen: (db){
          print("drop!!!!!!!!!!!1");
//          db.execute("drop table meals");
        },


        version: 3);






  }


  static Future<dynamic> select(String table, String where) async {
    final db = await DBHelper.database(); // DBHelper 클래스의 database() 메서드를 실행합니다
    List<Map> result = await db.rawQuery('SELECT * FROM $table $where');
    print("db:");
    print(result);
    return result;
  }

  static Future<dynamic> delete(String table, String where) async {
    final db = await DBHelper.database(); // DBHelper 클래스의 database() 메서드를 실행합니다
    await db.rawQuery('DELETE FROM $table $where');
    return true;
  }



  static Future<void> insert(String table, Map<String, Object> data) async {

    print(data);

    final db = await DBHelper.database(); // DBHelper 클래스의 database() 메서드를 실행합니다
    db.insert(
      table, // 추가할 테이블 명
      data, // 저장할 데이터, Map 형식으로 추가됩니다
    );
  }
}