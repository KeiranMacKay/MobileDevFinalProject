import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Simple model class representing a bill/expense.
class Expense {
  final int? id;
  final String name;
  final String place;
  final String date; // Stored as 'YYYY-MM-DD'
  final double price;
  final bool isRecurring;
  final String? notes;
  final String? receiptUri; // ADDITION FOR PHOTO CAPTURE

  Expense({
    this.id,
    required this.name,
    required this.place,
    required this.date,
    required this.price,
    required this.isRecurring,
    this.notes,
    this.receiptUri,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'place': place,
      'date': date,
      'price': price,
      'is_recurring': isRecurring ? 1 : 0,
      'notes': notes,
      'receipt_uri': receiptUri,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      name: map['name'] as String,
      place: map['place'] as String,
      date: map['date'] as String,
      price: (map['price'] as num).toDouble(),
      isRecurring: (map['is_recurring'] as int) == 1,
      notes: map['notes'] as String?,
      receiptUri: map['receipt_uri'] as String?,
    );
  }
}

/// Simple model for "per-person total for a month".
class PersonMonthlyTotal {
  final String name;
  final double total;

  PersonMonthlyTotal({
    required this.name,
    required this.total,
  });
}

/// Singleton database helper.
/// On Android/iOS it uses sqflite normally.
/// On Windows/Web it returns null for [database] so we don't crash.
class WalletFlowDB {
  WalletFlowDB._privateConstructor();
  static final WalletFlowDB instance = WalletFlowDB._privateConstructor();

  Database? _database;

  /// Returns null on unsupported platforms (e.g. Windows, web).
  Future<Database?> get database async {
    // Only support real DB on Android/iOS for this project
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      debugPrint(
        'WalletFlowDB: database not initialized on this platform '
        '(kIsWeb=$kIsWeb, isAndroid=${Platform.isAndroid}, isIOS=${Platform.isIOS})',
      );
      return null;
    }

    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'walletflow.db');

    return await openDatabase(
      path,
      version: 2, // bump version
      onCreate: (db, version) async {
        // initial table creation
        await db.execute('''
        CREATE TABLE IF NOT EXISTS expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          place TEXT NOT NULL,
          date TEXT NOT NULL,
          price REAL NOT NULL,
          is_recurring INTEGER NOT NULL,
          notes TEXT,
          receipt_uri TEXT
        )
      ''');
        await db.execute('''
        CREATE TABLE IF NOT EXISTS members (
          member_id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          nickname TEXT NOT NULL,
          color_hex TEXT,
          UNIQUE(user_id, nickname)
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add members table to existing DB
          await db.execute('''
        CREATE TABLE IF NOT EXISTS members (
          member_id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          nickname TEXT NOT NULL,
          color_hex TEXT,
          UNIQUE(user_id, nickname)
        )
      ''');
        }
      },
    );
  }

  /// Insert a new expense. Returns inserted row id or null if DB unavailable.
  Future<int?> insertExpense(Expense expense) async {
    final db = await database;
    if (db == null) {
      debugPrint('WalletFlowDB: insertExpense ignored (no DB on this platform)');
      return null;
    }

    final id = await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('WalletFlowDB: inserted expense id=$id, data=${expense.toMap()}');
    return id;
  }

  /// Get recent expenses (newest first). Returns empty list if DB unavailable.
  Future<List<Expense>> getRecentExpenses({int limit = 50}) async {
    final db = await database;
    if (db == null) {
      debugPrint('WalletFlowDB: getRecentExpenses -> empty (no DB on this platform)');
      return [];
    }

    final result = await db.query(
      'expenses',
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );
    return result.map((row) => Expense.fromMap(row)).toList();
  }

  /// Get per-person totals for a specific month (default = current month).
  ///
  /// This powers "Your Spending This Month" on the Home screen.
  Future<List<PersonMonthlyTotal>> getCurrentMonthTotals({
    int? year,
    int? month,
  }) async {
    final db = await database;
    if (db == null) {
      debugPrint(
        'WalletFlowDB: getCurrentMonthTotals -> empty (no DB on this platform)',
      );
      return [];
    }

    final now = DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;

    final ym =
        '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}';

    // date stored as 'YYYY-MM-DD', so we match 'YYYY-MM-%'
    final result = await db.rawQuery('''
      SELECT name, SUM(price) AS total
      FROM expenses
      WHERE date LIKE ?
      GROUP BY name
      ORDER BY name COLLATE NOCASE
    ''', ['$ym%']);

    return result.map((row) {
      final name = row['name'] as String;
      final totalNum = row['total'] as num? ?? 0;
      return PersonMonthlyTotal(
        name: name,
        total: totalNum.toDouble(),
      );
    }).toList();
  }
}
