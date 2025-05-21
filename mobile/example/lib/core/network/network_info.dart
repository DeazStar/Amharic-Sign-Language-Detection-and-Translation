// lib/core/network/network_info.dart

import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Abstract class defining the contract for checking network connectivity.
/// This allows the application to depend on an abstraction rather than a concrete
/// implementation, making it easier to test and swap implementations if needed.
abstract class NetworkInfo {
  /// Returns `true` if the device has an active internet connection, `false` otherwise.
  Future<bool> get isConnected;
}

/// Concrete implementation of [NetworkInfo] using the `internet_connection_checker` package.
class NetworkInfoImpl implements NetworkInfo {
  /// An instance of [InternetConnectionChecker] used to perform the connectivity check.
  /// It's injected via the constructor for better testability and flexibility.
  final InternetConnectionChecker connectionChecker;

  /// Constructor for [NetworkInfoImpl].
  /// Requires an instance of [InternetConnectionChecker].
  NetworkInfoImpl(this.connectionChecker);

  /// Checks if the device has an active internet connection.
  ///
  /// This implementation leverages the `internet_connection_checker` package's
  /// `hasConnection` getter.
  @override
  Future<bool> get isConnected async {
    // The `hasConnection` getter from internet_connection_checker
    // performs the actual check.
    return await connectionChecker.hasConnection;
  }
}
