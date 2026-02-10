import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FavouritesDbHelper {
  static final FavouritesDbHelper instance = FavouritesDbHelper._init();
  static Database? _database;

  FavouritesDbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favourites.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favourites (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        doctor_id TEXT NOT NULL,
        full_name TEXT NOT NULL,
        title TEXT,
        city TEXT,
        clinic_name TEXT,
        photo_path TEXT,
        rating_avg REAL NOT NULL,
        rating_count INTEGER NOT NULL,
        consultation_fee_cents INTEGER NOT NULL,
        currency TEXT NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(user_id, doctor_id)
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_favourites_user_id ON favourites(user_id)
    ''');
  }

  Future<void> addFavourite({
    required String userId,
    required String doctorId,
    required String fullName,
    String? title,
    String? city,
    String? clinicName,
    String? photoPath,
    required double ratingAvg,
    required int ratingCount,
    required int consultationFeeCents,
    required String currency,
  }) async {
    final db = await instance.database;

    await db.insert(
      'favourites',
      {
        'id': '${userId}_$doctorId',
        'user_id': userId,
        'doctor_id': doctorId,
        'full_name': fullName,
        'title': title,
        'city': city,
        'clinic_name': clinicName,
        'photo_path': photoPath,
        'rating_avg': ratingAvg,
        'rating_count': ratingCount,
        'consultation_fee_cents': consultationFeeCents,
        'currency': currency,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavourite({
    required String userId,
    required String doctorId,
  }) async {
    final db = await instance.database;

    await db.delete(
      'favourites',
      where: 'user_id = ? AND doctor_id = ?',
      whereArgs: [userId, doctorId],
    );
  }

  Future<List<Map<String, dynamic>>> getFavourites(String userId) async {
    final db = await instance.database;

    return await db.query(
      'favourites',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<bool> isFavourite({
    required String userId,
    required String doctorId,
  }) async {
    final db = await instance.database;

    final result = await db.query(
      'favourites',
      where: 'user_id = ? AND doctor_id = ?',
      whereArgs: [userId, doctorId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<void> clearAllFavourites(String userId) async {
    final db = await instance.database;

    await db.delete(
      'favourites',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}