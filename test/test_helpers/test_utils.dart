import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TestUtils {
  /// Initialize SQLite for testing (using FFI for non-mobile platforms)
  static void initializeSqliteForTest() {
    // Initialize ffi implementation
    sqfliteFfiInit();
    // Set global database factory to ffi
    databaseFactory = databaseFactoryFfi;
  }

  /// Create an in-memory database for testing
  static Future<Database> createInMemoryDatabase() async {
    return await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Expect async function to throw specific error
  static Future<void> expectAsyncThrows<T>(
    Future<void> Function() callback,
  ) async {
    try {
      await callback();
      fail('Expected function to throw $T');
    } catch (e) {
      expect(e, isA<T>());
    }
  }

  /// Helper to wait for async operations
  static Future<void> pump() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
