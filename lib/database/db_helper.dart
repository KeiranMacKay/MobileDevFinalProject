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
    this.receiptUri, // ADDITION FOR PHOTO CAPTURE
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

    // If you want, you can later copy an asset DB here.
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Very simple schema focused on this app's needs.
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
}
