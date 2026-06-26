import 'package:flutter/foundation.dart';

abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasError => _error != null;

  @protected
  void safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }
@protected
  void setError(String? value) {
    _error = value;
    safeNotify();
  }
  @protected
  Future<void> execute(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    safeNotify();

    try {
      await action();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      safeNotify();
    }
  }

  void clearError() {
    _error = null;
    safeNotify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
