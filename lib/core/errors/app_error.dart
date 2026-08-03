enum ErrorCode {
  bleError,
  connectionTimeout,
  modbusTimeout,
  modbusCrcError,
  modbusException,
  invalidRegisterValue,
  deviceNotReady,
  databaseError,
  cancelled,
  unknown,
}

class AppError implements Exception {
  const AppError({
    required this.code,
    required this.message,
    this.details,
    this.cause,
  });

  final ErrorCode code;
  final String message;
  final String? details;
  final Object? cause;

  @override
  String toString() => details == null ? message : '$message ($details)';
}

class ModbusExceptionError extends AppError {
  ModbusExceptionError({required this.functionCode, required this.exceptionCode})
    : super(
        code: ErrorCode.modbusException,
        message: '设备返回 Modbus 异常',
        details:
            '功能码 0x${functionCode.toRadixString(16)}, 异常码 0x${exceptionCode.toRadixString(16)}',
      );

  final int functionCode;
  final int exceptionCode;
}
