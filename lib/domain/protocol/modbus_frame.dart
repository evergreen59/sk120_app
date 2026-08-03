import '../../core/errors/app_error.dart';

int modbusCrc16(Iterable<int> bytes) {
  var crc = 0xFFFF;
  for (final byte in bytes) {
    crc ^= byte & 0xFF;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 1) == 1 ? (crc >> 1) ^ 0xA001 : crc >> 1;
    }
  }
  return crc & 0xFFFF;
}

List<int> withModbusCrc(Iterable<int> payload) {
  final frame = payload.map((byte) => byte & 0xFF).toList();
  final crc = modbusCrc16(frame);
  return [...frame, crc & 0xFF, (crc >> 8) & 0xFF];
}

String bytesToHex(Iterable<int> bytes) => bytes
    .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
    .join(' ');

class ModbusProtocolException implements Exception {
  const ModbusProtocolException(this.message, {this.raw});

  final String message;
  final List<int>? raw;

  @override
  String toString() => message;
}

class ModbusRequest {
  const ModbusRequest._({
    required this.slaveAddress,
    required this.functionCode,
    required this.startAddress,
    required this.quantity,
    this.values = const [],
  });

  factory ModbusRequest.readRegisters({
    required int slaveAddress,
    required int startAddress,
    required int quantity,
  }) {
    _checkU16(slaveAddress, 'slaveAddress');
    if (slaveAddress < 1 || slaveAddress > 247) {
      throw ArgumentError.value(slaveAddress, 'slaveAddress', '必须在 1-247 范围内');
    }
    if (quantity < 1 || quantity > 125) {
      throw ArgumentError.value(quantity, 'quantity', '必须在 1-125 范围内');
    }
    _checkU16(startAddress, 'startAddress');
    return ModbusRequest._(
      slaveAddress: slaveAddress,
      functionCode: 0x03,
      startAddress: startAddress,
      quantity: quantity,
    );
  }

  factory ModbusRequest.writeRegister({
    required int slaveAddress,
    required int address,
    required int value,
  }) {
    _checkU16(slaveAddress, 'slaveAddress');
    _checkU16(address, 'address');
    _checkU16(value, 'value');
    return ModbusRequest._(
      slaveAddress: slaveAddress,
      functionCode: 0x06,
      startAddress: address,
      quantity: 1,
      values: [value],
    );
  }

  factory ModbusRequest.writeRegisters({
    required int slaveAddress,
    required int startAddress,
    required List<int> values,
  }) {
    _checkU16(slaveAddress, 'slaveAddress');
    _checkU16(startAddress, 'startAddress');
    if (values.isEmpty || values.length > 123) {
      throw ArgumentError.value(values.length, 'values', '必须包含 1-123 个寄存器');
    }
    for (final value in values) {
      _checkU16(value, 'values');
    }
    return ModbusRequest._(
      slaveAddress: slaveAddress,
      functionCode: 0x10,
      startAddress: startAddress,
      quantity: values.length,
      values: List.unmodifiable(values),
    );
  }

  final int slaveAddress;
  final int functionCode;
  final int startAddress;
  final int quantity;
  final List<int> values;

  bool get isRead => functionCode == 0x03;

  List<int> toBytes() {
    final payload = <int>[
      slaveAddress,
      functionCode,
      (startAddress >> 8) & 0xFF,
      startAddress & 0xFF,
    ];
    if (functionCode == 0x03) {
      payload.addAll([(quantity >> 8) & 0xFF, quantity & 0xFF]);
    } else if (functionCode == 0x06) {
      final value = values.single;
      payload.addAll([(value >> 8) & 0xFF, value & 0xFF]);
    } else {
      payload.addAll([
        (quantity >> 8) & 0xFF,
        quantity & 0xFF,
        values.length * 2,
      ]);
      for (final value in values) {
        payload.addAll([(value >> 8) & 0xFF, value & 0xFF]);
      }
    }
    return withModbusCrc(payload);
  }

  static void _checkU16(int value, String name) {
    if (value < 0 || value > 0xFFFF) {
      throw ArgumentError.value(value, name, '必须在 0-65535 范围内');
    }
  }
}

class ModbusResponse {
  const ModbusResponse({
    required this.slaveAddress,
    required this.functionCode,
    required this.payload,
    required this.raw,
    this.exceptionCode,
  });

  final int slaveAddress;
  final int functionCode;
  final List<int> payload;
  final List<int> raw;
  final int? exceptionCode;

  bool get isException => exceptionCode != null;

  List<int> get registers {
    if (functionCode != 0x03 || isException) return const [];
    if (payload.isEmpty ||
        payload.length != payload.first + 1 ||
        payload.first.isOdd) {
      throw const ModbusProtocolException('读寄存器响应 byte-count 无效');
    }
    final values = <int>[];
    for (var i = 1; i < payload.length; i += 2) {
      values.add((payload[i] << 8) | payload[i + 1]);
    }
    return values;
  }

  factory ModbusResponse.parse(List<int> bytes) {
    final raw = bytes.map((byte) => byte & 0xFF).toList(growable: false);
    if (raw.length < 5) {
      throw ModbusProtocolException('Modbus 响应长度不足', raw: raw);
    }
    final expectedCrc = raw[raw.length - 2] | (raw[raw.length - 1] << 8);
    final actualCrc = modbusCrc16(raw.sublist(0, raw.length - 2));
    if (expectedCrc != actualCrc) {
      throw ModbusProtocolException('Modbus CRC 校验失败', raw: raw);
    }
    final slave = raw[0];
    final function = raw[1];
    if ((function & 0x80) != 0) {
      if (raw.length != 5) {
        throw ModbusProtocolException('Modbus 异常响应长度无效', raw: raw);
      }
      return ModbusResponse(
        slaveAddress: slave,
        functionCode: function & 0x7F,
        payload: [raw[2]],
        raw: raw,
        exceptionCode: raw[2],
      );
    }
    final payload = raw.sublist(2, raw.length - 2);
    if (function == 0x03) {
      if (payload.isEmpty || payload.length != payload.first + 1) {
        throw ModbusProtocolException('读寄存器响应长度无效', raw: raw);
      }
    } else if (function == 0x06 && raw.length != 8) {
      throw ModbusProtocolException('写单寄存器响应长度无效', raw: raw);
    } else if (function == 0x10 && raw.length != 8) {
      throw ModbusProtocolException('写多寄存器响应长度无效', raw: raw);
    }
    return ModbusResponse(
      slaveAddress: slave,
      functionCode: function,
      payload: payload,
      raw: raw,
    );
  }
}

class ModbusStreamParser {
  final List<int> _buffer = <int>[];

  List<ModbusResponse> add(
    List<int> chunk, {
    int? expectedSlave,
    int? expectedFunction,
  }) {
    _buffer.addAll(chunk.map((byte) => byte & 0xFF));
    final responses = <ModbusResponse>[];
    while (true) {
      if (_buffer.length < 5) break;
      if (expectedSlave != null && _buffer.first != expectedSlave) {
        _buffer.removeAt(0);
        continue;
      }
      final function = _buffer[1];
      if (expectedFunction != null &&
          function != expectedFunction &&
          function != (expectedFunction | 0x80)) {
        _buffer.removeAt(0);
        continue;
      }
      final frameLength = _frameLength(function);
      if (frameLength == null) {
        _buffer.removeAt(0);
        continue;
      }
      if (_buffer.length < frameLength) break;
      final raw = _buffer.sublist(0, frameLength);
      _buffer.removeRange(0, frameLength);
      responses.add(ModbusResponse.parse(raw));
    }
    return responses;
  }

  int? _frameLength(int functionCode) {
    if ((functionCode & 0x80) != 0) return 5;
    if (functionCode == 0x06 || functionCode == 0x10) return 8;
    if (functionCode == 0x03) {
      if (_buffer.length < 3) return null;
      return 3 + _buffer[2] + 2;
    }
    return null;
  }

  void clear() => _buffer.clear();
  int get bufferedLength => _buffer.length;
}

AppError mapModbusException(ModbusResponse response) {
  if (response.exceptionCode == null) {
    return const AppError(code: ErrorCode.unknown, message: '未知 Modbus 错误');
  }
  return ModbusExceptionError(
    functionCode: response.functionCode,
    exceptionCode: response.exceptionCode!,
  );
}
