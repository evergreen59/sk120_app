import 'dart:async';

import '../../core/errors/app_error.dart';
import '../../core/result/result.dart';
import '../models/device_models.dart';
import '../repositories/ble_transport.dart';
import 'modbus_frame.dart';
import 'modbus_request_queue.dart';

class ModbusClient {
  ModbusClient({
    required this.transport,
    this.deviceId = 'xy-sk120',
    this.onLog,
    this.slaveAddress = 1,
    this.timeout = const Duration(milliseconds: 900),
    this.readRetries = 1,
    ModbusRequestQueue? queue,
  }) : _queue = queue ?? ModbusRequestQueue();

  final BleTransport transport;
  final String deviceId;
  final void Function(CommunicationLogEntry entry)? onLog;
  int slaveAddress;
  final Duration timeout;
  final int readRetries;
  final ModbusRequestQueue _queue;

  Future<Result<List<int>>> readRegisters(int startAddress, int quantity) =>
      _queue.enqueue(() async {
        final request = ModbusRequest.readRegisters(
          slaveAddress: slaveAddress,
          startAddress: startAddress,
          quantity: quantity,
        );
        final response = await _execute(request, retry: readRetries);
        return response.fold(
          onSuccess: (value) => Success(value.registers),
          onFailure: Failure.new,
        );
      });

  Future<Result<void>> writeRegister(int address, int value) =>
      _queue.enqueue(() async {
        final request = ModbusRequest.writeRegister(
          slaveAddress: slaveAddress,
          address: address,
          value: value,
        );
        final response = await _execute(request, retry: 0);
        return response.fold(
          onSuccess: (_) => const Success(null),
          onFailure: Failure.new,
        );
      });

  Future<Result<void>> writeRegisters(int startAddress, List<int> values) =>
      _queue.enqueue(() async {
        final request = ModbusRequest.writeRegisters(
          slaveAddress: slaveAddress,
          startAddress: startAddress,
          values: values,
        );
        final response = await _execute(request, retry: 0);
        return response.fold(
          onSuccess: (_) => const Success(null),
          onFailure: Failure.new,
        );
      });

  Future<Result<ModbusResponse>> _execute(
    ModbusRequest request, {
    required int retry,
  }) async {
    AppError? lastError;
    for (var attempt = 0; attempt <= retry; attempt++) {
      final result = await _sendOnce(request);
      if (result.isSuccess) return result;
      lastError = result.error;
      if (lastError?.code != ErrorCode.modbusTimeout &&
          lastError?.code != ErrorCode.modbusCrcError) {
        break;
      }
    }
    return Failure(
      lastError ??
          const AppError(code: ErrorCode.unknown, message: 'Modbus 请求失败'),
    );
  }

  Future<Result<ModbusResponse>> _sendOnce(ModbusRequest request) async {
    final parser = ModbusStreamParser();
    final completer = Completer<ModbusResponse>();
    final requestBytes = request.toBytes();
    _emitLog(
      CommunicationLogEntry(
        deviceId: deviceId,
        timestamp: DateTime.now(),
        direction: CommunicationDirection.tx,
        rawBytes: requestBytes,
        parsedMessage:
            'FC 0x${request.functionCode.toRadixString(16).padLeft(2, '0')} address 0x${request.startAddress.toRadixString(16).padLeft(4, '0')}',
        success: true,
      ),
    );
    late final StreamSubscription<List<int>> subscription;
    subscription = transport.incomingBytes.listen((chunk) {
      _emitLog(
        CommunicationLogEntry(
          deviceId: deviceId,
          timestamp: DateTime.now(),
          direction: CommunicationDirection.rx,
          rawBytes: chunk,
          success: true,
        ),
      );
      try {
        for (final response in parser.add(
          chunk,
          expectedSlave: request.slaveAddress,
          expectedFunction: request.functionCode,
        )) {
          if (response.isException) {
            _emitLog(
              CommunicationLogEntry(
                deviceId: deviceId,
                timestamp: DateTime.now(),
                direction: CommunicationDirection.rx,
                rawBytes: response.raw,
                parsedMessage:
                    'Modbus exception 0x${response.exceptionCode!.toRadixString(16)}',
                success: false,
                error: mapModbusException(response).message,
              ),
            );
            if (!completer.isCompleted) {
              completer.completeError(mapModbusException(response));
            }
          } else if (!completer.isCompleted) {
            _emitLog(
              CommunicationLogEntry(
                deviceId: deviceId,
                timestamp: DateTime.now(),
                direction: CommunicationDirection.rx,
                rawBytes: response.raw,
                parsedMessage:
                    'FC 0x${response.functionCode.toRadixString(16).padLeft(2, '0')} parsed',
                success: true,
              ),
            );
            completer.complete(response);
          }
        }
      } catch (error) {
        if (!completer.isCompleted) completer.completeError(error);
      }
    });

    try {
      final writeResult = await transport.writeFrame(requestBytes);
      if (writeResult.isFailure) return Failure(writeResult.error!);
      final response = await completer.future.timeout(
        timeout,
        onTimeout: () => throw const AppError(
          code: ErrorCode.modbusTimeout,
          message: 'Modbus 响应超时',
        ),
      );
      if (response.slaveAddress != request.slaveAddress ||
          response.functionCode != request.functionCode) {
        return const Failure(
          AppError(code: ErrorCode.modbusException, message: 'Modbus 响应与请求不匹配'),
        );
      }
      return Success(response);
    } on AppError catch (error) {
      return Failure(error);
    } on ModbusProtocolException catch (error) {
      return Failure(
        AppError(
          code: ErrorCode.modbusCrcError,
          message: error.message,
          cause: error,
        ),
      );
    } on TimeoutException catch (error) {
      return Failure(
        AppError(
          code: ErrorCode.modbusTimeout,
          message: 'Modbus 响应超时',
          cause: error,
        ),
      );
    } catch (error) {
      return Failure(
        AppError(code: ErrorCode.bleError, message: 'BLE 传输失败', cause: error),
      );
    } finally {
      await subscription.cancel();
    }
  }

  void _emitLog(CommunicationLogEntry entry) {
    try {
      onLog?.call(entry);
    } catch (_) {
      // Logging must never interrupt a device request.
    }
  }
}
