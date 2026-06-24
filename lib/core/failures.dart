
abstract class Failure {
  final String message;
  final String? details;
  const Failure({required this.message, this.details});
}

class NetworkFailure extends Failure {
  const NetworkFailure()
      : super(message: 'مفيش انترنت، تأكد من الاتصال وحاول تاني');
}

class ServerFailure extends Failure {
  const ServerFailure({String? details})
      : super(message: 'حصل خطأ في السيرفر، حاول بعد شوية', details: details);
}

class CacheFailure extends Failure {
  const CacheFailure({String? details})
      : super(message: 'حصل خطأ في التخزين المحلي', details: details);
}

class AuthFailure extends Failure {
  const AuthFailure({String message = 'خطأ في تسجيل الدخول', String? details})
      : super(message: message, details: details);
}

class PermissionFailure extends Failure {
  const PermissionFailure({required String permission})
      : super(message: 'محتاج إذن $permission عشان يشتغل صح');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({String message = 'البيانات دي مش موجودة'})
      : super(message: message);
}

class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message: message);
}

class UnknownFailure extends Failure {
  const UnknownFailure({String? details})
      : super(message: 'حصل خطأ غير متوقع', details: details);
}