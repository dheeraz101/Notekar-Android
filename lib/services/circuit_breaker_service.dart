import 'dart:async';
import 'package:notekar/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Circuit breaker state for failure isolation.
enum CircuitState {
  closed, // Healthy, normal operation
  open, // Tripped after consecutive failures, calls bypassed
  halfOpen, // Tentative probe after reset/cooldown
}

/// Provides failure isolation for non-critical background services,
/// diagnostics, and telemetry routines. Prevents runaway exceptions
/// and crash loops from degrading the core logging and tracking experience.
class CircuitBreakerService {
  CircuitBreakerService._();
  static final CircuitBreakerService instance = CircuitBreakerService._();

  SharedPreferences? _prefs;
  static const int failureThreshold = 3;

  final Map<String, int> _inMemoryFailures = {};
  final Map<String, CircuitState> _inMemoryStates = {};

  void init(SharedPreferences prefs) {
    _prefs = prefs;
  }

  String _failureKey(String serviceId) => 'cb_failures_$serviceId';
  String _stateKey(String serviceId) => 'cb_state_$serviceId';

  /// Returns whether the circuit is currently OPEN (tripped / disabled).
  bool isOpen(String serviceId) {
    final cached = _inMemoryStates[serviceId];
    if (cached != null) {
      return cached == CircuitState.open;
    }
    final storedState = _prefs?.getString(_stateKey(serviceId));
    if (storedState == 'open') {
      _inMemoryStates[serviceId] = CircuitState.open;
      return true;
    }
    return false;
  }

  /// Returns the current consecutive failure count for [serviceId].
  int getFailureCount(String serviceId) {
    return _inMemoryFailures[serviceId] ??
        _prefs?.getInt(_failureKey(serviceId)) ??
        0;
  }

  /// Executes an operation within the protected circuit.
  /// If the circuit is open, execution is safely bypassed and [fallback] is returned.
  Future<T?> run<T>({
    required String serviceId,
    required Future<T> Function() action,
    T? fallback,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    if (isOpen(serviceId)) {
      AppLogger().warn(
        'CircuitBreaker [$serviceId] is OPEN. Operation safely skipped to protect app stability.',
      );
      return fallback;
    }

    try {
      final result = await action();
      // On success, reset failures if any existed
      if (getFailureCount(serviceId) > 0) {
        await reset(serviceId);
      }
      return result;
    } catch (e, st) {
      final newFailures = getFailureCount(serviceId) + 1;
      _inMemoryFailures[serviceId] = newFailures;
      await _prefs?.setInt(_failureKey(serviceId), newFailures);

      AppLogger().error(
        'CircuitBreaker caught failure in [$serviceId] (failure $newFailures/$failureThreshold): $e',
        e,
        st,
      );

      onError?.call(e, st);

      if (newFailures >= failureThreshold) {
        _inMemoryStates[serviceId] = CircuitState.open;
        await _prefs?.setString(_stateKey(serviceId), 'open');
        AppLogger().warn(
          'CircuitBreaker tripped OPEN for [$serviceId] after $newFailures consecutive failures.',
        );
      }

      return fallback;
    }
  }

  /// Manually resets the circuit breaker for a specific service.
  Future<void> reset(String serviceId) async {
    _inMemoryFailures[serviceId] = 0;
    _inMemoryStates[serviceId] = CircuitState.closed;
    await _prefs?.remove(_failureKey(serviceId));
    await _prefs?.remove(_stateKey(serviceId));
    AppLogger().info('CircuitBreaker for [$serviceId] reset to CLOSED.');
  }

  /// Resets all registered circuit breakers (e.g., upon app update or in God Mode).
  Future<void> resetAll() async {
    _inMemoryFailures.clear();
    _inMemoryStates.clear();
    final prefs = _prefs;
    if (prefs != null) {
      final keysToRemove = prefs
          .getKeys()
          .where((k) => k.startsWith('cb_failures_') || k.startsWith('cb_state_'))
          .toList();
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
    }
    AppLogger().info('All CircuitBreakers reset to CLOSED.');
  }
}
