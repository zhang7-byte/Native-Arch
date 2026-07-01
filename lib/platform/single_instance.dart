import 'single_instance_stub.dart'
    if (dart.library.io) 'single_instance_io.dart' as impl;

/// Single-instance guard. On Windows, if another instance already holds the
/// named lock, this focuses that instance's window and terminates the current
/// process (so no second window opens). Otherwise it acquires the lock and
/// returns so startup can continue. A no-op on web and other platforms.
Future<void> enforceSingleInstance() => impl.enforceSingleInstance();
