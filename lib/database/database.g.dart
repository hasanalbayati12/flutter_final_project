// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CustomerDao? _customerDaoInstance;

  AirplaneDao? _airplaneDaoInstance;

  FlightDao? _flightDaoInstance;

  ReservationDao? _reservationDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Customer` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `firstName` TEXT NOT NULL, `lastName` TEXT NOT NULL, `address` TEXT NOT NULL, `dateOfBirth` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Airplane` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `airplaneType` TEXT NOT NULL, `passengers` INTEGER NOT NULL, `maxSpeed` TEXT NOT NULL, `rangeDistance` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Flight` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `departureCity` TEXT NOT NULL, `destinationCity` TEXT NOT NULL, `departureTime` TEXT NOT NULL, `arrivalTime` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Reservation` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `customerId` INTEGER NOT NULL, `flightId` INTEGER NOT NULL, `flightDate` TEXT NOT NULL, `reservationName` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CustomerDao get customerDao {
    return _customerDaoInstance ??= _$CustomerDao(database, changeListener);
  }

  @override
  AirplaneDao get airplaneDao {
    return _airplaneDaoInstance ??= _$AirplaneDao(database, changeListener);
  }

  @override
  FlightDao get flightDao {
    return _flightDaoInstance ??= _$FlightDao(database, changeListener);
  }

  @override
  ReservationDao get reservationDao {
    return _reservationDaoInstance ??=
        _$ReservationDao(database, changeListener);
  }
}

class _$CustomerDao extends CustomerDao {
  _$CustomerDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _customerInsertionAdapter = InsertionAdapter(
            database,
            'Customer',
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'dateOfBirth': item.dateOfBirth
                }),
        _customerUpdateAdapter = UpdateAdapter(
            database,
            'Customer',
            ['id'],
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'dateOfBirth': item.dateOfBirth
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Customer> _customerInsertionAdapter;

  final UpdateAdapter<Customer> _customerUpdateAdapter;

  @override
  Future<List<Customer>> findAllCustomers() async {
    return _queryAdapter.queryList('SELECT * FROM Customer',
        mapper: (Map<String, Object?> row) => Customer(
            id: row['id'] as int?,
            firstName: row['firstName'] as String,
            lastName: row['lastName'] as String,
            address: row['address'] as String,
            dateOfBirth: row['dateOfBirth'] as String));
  }

  @override
  Future<Customer?> findCustomerById(int id) async {
    return _queryAdapter.query('SELECT * FROM Customer WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Customer(
            id: row['id'] as int?,
            firstName: row['firstName'] as String,
            lastName: row['lastName'] as String,
            address: row['address'] as String,
            dateOfBirth: row['dateOfBirth'] as String),
        arguments: [id]);
  }

  @override
  Future<void> delete(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM Customer WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<int?> getCustomerCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM Customer',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> insertCustomer(Customer customer) async {
    await _customerInsertionAdapter.insert(customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await _customerUpdateAdapter.update(customer, OnConflictStrategy.abort);
  }
}

class _$AirplaneDao extends AirplaneDao {
  _$AirplaneDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _airplaneInsertionAdapter = InsertionAdapter(
            database,
            'Airplane',
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'airplaneType': item.airplaneType,
                  'passengers': item.passengers,
                  'maxSpeed': item.maxSpeed,
                  'rangeDistance': item.rangeDistance
                }),
        _airplaneUpdateAdapter = UpdateAdapter(
            database,
            'Airplane',
            ['id'],
            (Airplane item) => <String, Object?>{
                  'id': item.id,
                  'airplaneType': item.airplaneType,
                  'passengers': item.passengers,
                  'maxSpeed': item.maxSpeed,
                  'rangeDistance': item.rangeDistance
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Airplane> _airplaneInsertionAdapter;

  final UpdateAdapter<Airplane> _airplaneUpdateAdapter;

  @override
  Future<List<Airplane>> findAllAirplanes() async {
    return _queryAdapter.queryList('SELECT * FROM Airplane',
        mapper: (Map<String, Object?> row) => Airplane(
            id: row['id'] as int?,
            airplaneType: row['airplaneType'] as String,
            passengers: row['passengers'] as int,
            maxSpeed: row['maxSpeed'] as String,
            rangeDistance: row['rangeDistance'] as String));
  }

  @override
  Future<Airplane?> findAirplaneById(int id) async {
    return _queryAdapter.query('SELECT * FROM Airplane WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Airplane(
            id: row['id'] as int?,
            airplaneType: row['airplaneType'] as String,
            passengers: row['passengers'] as int,
            maxSpeed: row['maxSpeed'] as String,
            rangeDistance: row['rangeDistance'] as String),
        arguments: [id]);
  }

  @override
  Future<void> delete(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM Airplane WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<int?> getAirplaneCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM Airplane',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> insertAirplane(Airplane airplane) async {
    await _airplaneInsertionAdapter.insert(airplane, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAirplane(Airplane airplane) async {
    await _airplaneUpdateAdapter.update(airplane, OnConflictStrategy.abort);
  }
}

class _$FlightDao extends FlightDao {
  _$FlightDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _flightInsertionAdapter = InsertionAdapter(
            database,
            'Flight',
            (Flight item) => <String, Object?>{
                  'id': item.id,
                  'departureCity': item.departureCity,
                  'destinationCity': item.destinationCity,
                  'departureTime': item.departureTime,
                  'arrivalTime': item.arrivalTime
                }),
        _flightUpdateAdapter = UpdateAdapter(
            database,
            'Flight',
            ['id'],
            (Flight item) => <String, Object?>{
                  'id': item.id,
                  'departureCity': item.departureCity,
                  'destinationCity': item.destinationCity,
                  'departureTime': item.departureTime,
                  'arrivalTime': item.arrivalTime
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Flight> _flightInsertionAdapter;

  final UpdateAdapter<Flight> _flightUpdateAdapter;

  @override
  Future<List<Flight>> findAllFlights() async {
    return _queryAdapter.queryList('SELECT * FROM Flight',
        mapper: (Map<String, Object?> row) => Flight(
            id: row['id'] as int?,
            departureCity: row['departureCity'] as String,
            destinationCity: row['destinationCity'] as String,
            departureTime: row['departureTime'] as String,
            arrivalTime: row['arrivalTime'] as String));
  }

  @override
  Future<Flight?> findFlightById(int id) async {
    return _queryAdapter.query('SELECT * FROM Flight WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Flight(
            id: row['id'] as int?,
            departureCity: row['departureCity'] as String,
            destinationCity: row['destinationCity'] as String,
            departureTime: row['departureTime'] as String,
            arrivalTime: row['arrivalTime'] as String),
        arguments: [id]);
  }

  @override
  Future<void> delete(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM Flight WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<int?> getFlightCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM Flight',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> insertFlight(Flight flight) async {
    await _flightInsertionAdapter.insert(flight, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateFlight(Flight flight) async {
    await _flightUpdateAdapter.update(flight, OnConflictStrategy.abort);
  }
}

class _$ReservationDao extends ReservationDao {
  _$ReservationDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _reservationInsertionAdapter = InsertionAdapter(
            database,
            'Reservation',
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'flightDate': item.flightDate,
                  'reservationName': item.reservationName
                }),
        _reservationUpdateAdapter = UpdateAdapter(
            database,
            'Reservation',
            ['id'],
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'flightDate': item.flightDate,
                  'reservationName': item.reservationName
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Reservation> _reservationInsertionAdapter;

  final UpdateAdapter<Reservation> _reservationUpdateAdapter;

  @override
  Future<List<Reservation>> findAllReservations() async {
    return _queryAdapter.queryList('SELECT * FROM Reservation',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as int?,
            customerId: row['customerId'] as int,
            flightId: row['flightId'] as int,
            flightDate: row['flightDate'] as String,
            reservationName: row['reservationName'] as String));
  }

  @override
  Future<Reservation?> findReservationById(int id) async {
    return _queryAdapter.query('SELECT * FROM Reservation WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as int?,
            customerId: row['customerId'] as int,
            flightId: row['flightId'] as int,
            flightDate: row['flightDate'] as String,
            reservationName: row['reservationName'] as String),
        arguments: [id]);
  }

  @override
  Future<void> delete(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM Reservation WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<int?> getReservationCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM Reservation',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> insertReservation(Reservation reservation) async {
    await _reservationInsertionAdapter.insert(
        reservation, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateReservation(Reservation reservation) async {
    await _reservationUpdateAdapter.update(
        reservation, OnConflictStrategy.abort);
  }
}
