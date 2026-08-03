# Codex 项目开发 Prompt：XY-SK120 Flutter 跨平台智能电源控制 App

你是一名资深 Flutter/Dart 跨平台应用开发工程师，同时具备 BLE、Modbus RTU、嵌入式设备通信和工业 IoT UI/UX 开发经验。

请从零开始实现一个名为 **XY-SK120 Control** 的跨平台智能电源控制 App。

目标平台：

- iOS
- Android
- macOS
- Windows
- Linux

使用 Flutter/Dart 尽可能共享 UI、业务逻辑、协议层和数据层代码；手机和桌面端采用响应式布局。

---

# 1. 产品定位

这是一个通过 BLE 与 XY-SK120 电源设备通信的专业电源控制和监控 App。

通信链路：

```text
Flutter App
    │
    │ BLE
    ▼
BLE Transport
    │
    │ Modbus Frame
    ▼
XY-SK120
```

App 不应只是 BLE 遥控器，而应成为完整的现代工业 IoT 电源控制/监控平台。

核心能力：

- BLE 扫描
- BLE 连接
- 自动重连
- Modbus 通信
- 读取设备参数
- 设置电压
- 设置电流
- 输出 ON/OFF
- 实时显示 V/A/W
- CV/CC 状态
- 保护状态
- 输入电压
- 温度显示
- M0-M9 数据组读取/写入
- 数据组名称
- 一键加载数据组
- 快捷预设
- 基础保护参数
- 恒功率模式
- 上电输出策略
- 蜂鸣器/背光/息屏设置
- 电压/电流/功率曲线
- AH/WH 统计
- 输出历史记录
- 通信日志

---

# 2. 协议来源与强约束

XY-SK120 Modbus 寄存器必须以项目提供的：

`XY-SK120-Modbus_Address.pdf`

为唯一协议依据。

同时，项目已明确 BLE UUID：

```text
BLE SERVICE UUID:
FFE0

NOTIFY / WRITE UUID:
FFE1

WRITE UUID:
FFE2
```

BLE 职责：

- `FFE0`：Service UUID
- `FFE1`：Notify / Write Characteristic
- `FFE2`：Write Characteristic，主动写入 Modbus 请求帧，控制指令优先使用该通道

BLE UUID 只允许存在于 `BleTransport` 层。

禁止出现在：

- UI
- Domain
- Repository
- ViewModel
- 业务逻辑

架构：

```text
UI
 ↓
PowerDeviceService
 ↓
ModbusClient
 ↓
BleTransport
     ├── Service UUID: FFE0
     ├── Notify UUID:  FFE1
     └── Write UUID:   FFE2
 ↓
BLE Stack
 ↓
XY-SK120
```

BLE 只负责 Byte Stream Transport。

Modbus 层负责：

- Frame
- Register
- CRC
- Parse

不要让 UI 知道 BLE UUID、Characteristic、Modbus Frame、CRC、Register Address。

---

# 3. 不允许猜测协议

PDF 或明确提供的 BLE 信息没有定义的内容，不允许凭经验补全。

包括：

- Modbus 功能码
- CRC 算法/字节顺序
- Modbus 从机默认地址
- PROTECT bit 定义
- CVCC 枚举
- ONOFF 编码
- S-INI 编码
- S-ETP 编码
- MPPT 编码
- AH/WH 高低 16 位组合规则
- 其他未明确的协议编码

如果缺少信息：

1. 保留清晰 TODO；
2. 建立扩展点；
3. 不伪造真实设备协议；
4. 使用 MockDevice 支持 UI 和业务开发；
5. 最终报告协议资料缺失项。

---

# 4. 技术栈

优先使用：

```text
Flutter
Dart
Riverpod
GoRouter
Drift + SQLite
BLE plugin
fl_chart
```

如果第三方 package 与当前 Flutter stable 版本不兼容，可以选择维护良好的等价替代方案，但保持整体架构不变。

推荐架构：

```text
Presentation
    │
    ▼
Application / State Management
    │
    ▼
Domain
    │
    ▼
Repository
    │
    ├── BLE Transport
    │
    └── Local Database
```

不要把 BLE、Modbus、数据库逻辑直接写进 Widget。

---

# 5. 项目目录

建议：

```text
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── logging/
│   ├── result/
│   └── utils/
├── data/
│   ├── database/
│   ├── repositories/
│   └── datasources/
├── domain/
│   ├── models/
│   ├── entities/
│   ├── repositories/
│   └── services/
├── features/
│   ├── ble/
│   ├── device/
│   ├── control/
│   ├── monitoring/
│   ├── presets/
│   ├── protection/
│   ├── history/
│   ├── settings/
│   └── communication_log/
└── shared/
    ├── widgets/
    ├── charts/
    ├── glass/
    └── responsive/
```

---

# 6. Domain Model

建立统一：

```dart
PowerDevice
```

至少支持：

```text
id
name
model
firmwareVersion
bleDeviceId
connectionState
rssi

voltageSet
currentSet

outputVoltage
outputCurrent
outputPower
inputVoltage

outputAh
outputWh
outputDuration

internalTemperature
externalTemperature

cvccState
protectionState
outputEnabled

slaveAddress
baudRate

mpptEnabled
mpptCoefficient

constantPowerEnabled
constantPowerValue
```

实际字段必须以协议为准。

---

# 7. Register Model

不要在业务代码中散落：

```dart
0x0000
0x0001
0x0002
```

建立统一 Register 定义，例如：

```dart
enum PowerRegister {
  voltageSet(0x0000),
  currentSet(0x0001),
  outputVoltage(0x0002),
  outputCurrent(0x0003),
  outputPower(0x0004),
  inputVoltage(0x0005),
}
```

每个寄存器应包含：

```text
address
name
access
scale
unit
description
```

完整地址以 `XY-SK120-Modbus_Address.md` 为准。

---

# 8. 设备控制 API

业务层应提供类似：

```dart
await device.setVoltage(12.0);
await device.setCurrent(1.5);
await device.setOutput(true);

final status = await device.readStatus();

final group = await device.readDataGroup(3);
```

而不是：

```dart
ble.write([0x01, 0x06, ...]);
```

后者只能存在于通信层。

---

# 9. BLE Transport

实现独立：

```text
BleTransport
```

接口：

```text
scan()
connect()
disconnect()
reconnect()
discoverServices()
readCharacteristic()
writeCharacteristic()
subscribeCharacteristic()
```

固定：

```text
Service: FFE0
Notify/Write: FFE1
Write: FFE2
```

Transport 只负责字节传输，不解析业务寄存器。

提供：

```dart
BleTransport.write(frame)
BleTransport.subscribe()
```

---

# 10. Modbus Client

实现：

```text
ModbusClient
ModbusFrame
ModbusRequest
ModbusResponse
ModbusException
```

职责：

```text
readRegisters()
writeRegister()
writeRegisters()
parseResponse()
validateCrc()
```

具体 Modbus 功能码和 CRC，如果协议资料未提供，不得猜测。

---

# 11. 通信队列

BLE 通信必须串行化。

实现：

```text
ModbusRequestQueue
```

原则：

```text
one request
    ↓
one response
    ↓
next request
```

禁止多个 Widget 同时操作 BLE。

---

# 12. 自动重连

连接流程：

```text
Connected
    ↓
Disconnected
    ↓
Reconnecting...
    ↓
Connected
```

支持：

- 指数退避
- 最大重试次数
- 手动停止重连
- App 前后台状态处理
- 避免重复连接任务
- 避免并发 BLE connection

---

# 13. 轮询

建立：

```text
DevicePollingService
```

不要在 Widget 内创建独立 Timer。

建议初始策略：

```text
实时状态：约 500ms ~ 1s
低频状态：约 2s ~ 5s
历史采样：根据用户配置
```

实际频率需要通过真实设备测试调整。

---

# 14. 首页控制 Dashboard

UI 风格：

> Modern Industrial IoT + iOS 18 inspired Glassmorphism

要求：

- 深色背景
- 动态蓝/紫/青渐变
- 半透明毛玻璃
- 高斯模糊
- BackdropFilter
- 细腻阴影
- 柔和发光
- 大号数字
- 精细圆角
- 微妙边框高光
- 简洁图标
- 克制动画

避免：

- 传统 Android 表单
- 粗糙工业软件
- 过度 Cyberpunk
- 过度霓虹
- 过度动画

---

# 15. 手机首页

参考：

```text
XY-SK120
● 已连接

        OUTPUT POWER

          15.00 W

┌────────────┐ ┌────────────┐
│ 12.000 V   │ │ 1.250 A    │
│ 电压设定    │ │ 电流设定    │
└────────────┘ └────────────┘

       [ 输出开启 ]

CV
24.10 V
32.5 °C

实时输出
12.000 V
1.250 A
15.00 W
```

---

# 16. 桌面 Dashboard

桌面不要简单放大手机界面。

使用三栏或多栏：

```text
┌────────┬──────────────────────┬─────────────┐
│ 控制   │      12.000 V        │ 设备状态    │
│        │       1.250 A        │ CV          │
│ 监控   │       15.00 W        │ 32.5 °C     │
│        │                      │ 24.1 V      │
│ 数据组 │   OUTPUT ON          │ 保护正常     │
│        │                      │             │
│ 保护   │    Power Curve       │             │
│        │                      │             │
│ 设置   │                      │             │
└────────┴──────────────────────┴─────────────┘
```

---

# 17. 电压/电流设置

支持：

- 点击数值输入
- +/- 微调
- 长按连续调节
- 快捷预设

例如：

```text
12.000 V
1.250 A
```

必须：

- 范围验证
- 格式验证
- 通信状态验证
- 非法值禁止发送

---

# 18. 输出控制

实现明显的：

```text
OUTPUT ON/OFF
```

状态：

```text
OFF
ON
UNKNOWN
```

通信异常时禁止错误显示为 OFF。

高风险操作提供确认：

```text
确认开启输出？

电压：24.000 V
电流：2.000 A

[取消] [开启输出]
```

---

# 19. 实时监控

显示：

```text
VOUT
IOUT
POWER
UIN
T_IN
T_EX
CV/CC
PROTECT
AH
WH
OUTPUT TIME
```

实时曲线：

```text
Voltage
Current
Power
Temperature
```

时间范围：

```text
实时
1 min
5 min
30 min
1 hour
```

---

# 20. 曲线

使用 `fl_chart` 或等价方案。

支持：

- 平滑曲线
- 当前值
- 时间轴
- 单位
- Tooltip
- 缩放
- 滑动
- 实时滚动
- 暂停
- 清空

工业仪表盘风格优先，不要过度装饰。

---

# 21. AH / WH

设备提供：

```text
AH-LOW
AH-HIGH
WH-LOW
WH-HIGH
```

组合规则必须根据协议资料或真实设备测试确认。

如果资料未定义组合方式，不得自行猜测。

---

# 22. 历史记录

SQLite 保存：

```text
device
startTime
endTime
outputDuration
averageVoltage
averageCurrent
maxPower
totalAh
totalWh
```

提供：

```text
历史记录
详情
曲线
删除
导出
```

---

# 23. M0-M9 数据组

设备提供 M0-M9 共 10 组数据。

起始地址：

```text
0x0050 + groupIndex * 0x0010
```

例如：

```text
M0 = 0x0050
M1 = 0x0060
M2 = 0x0070
M3 = 0x0080
...
M9 = 0x00E0
```

每组包含：

```text
V-SET
I-SET
S-LVP
S-OVP
S-OCP
S-OPP
S-OHP_H
S-OHP_M
S-OAH_L
S-OAH_H
S-OWH_L
S-OWH_H
S-OTP
S-INI
S-ETP
```

支持：

- 读取 M0-M9
- 写入 M0-M9
- 编辑
- 数据组名称
- 本地保存名称
- 一键加载
- 设备数据组与本地数据组区分

加载数据组时：

```text
读取
 ↓
预览
 ↓
用户确认
 ↓
写入参数
 ↓
不要自动打开输出
```

除非协议明确规定，否则禁止隐式开启输出。

---

# 24. 快捷预设

允许用户建立：

```text
名称
电压
电流
```

示例仅作为 UI：

```text
5V / 1A
9V / 1A
12V / 2A
24V / 1A
36V / 1A
48V / 0.5A
```

实际可用范围必须由设备能力和协议确定。

---

# 25. 恒功率模式

对应：

```text
CW-SW 0x0022
CW    0x0023
```

UI：

```text
恒功率模式
[OFF / ON]

目标功率
50.0 W

当前
12.00 V
4.167 A
50.0 W
```

具体编码严格遵循协议。

---

# 26. 上电输出策略

对应：

```text
S-INI
```

提供：

```text
上电输出
○ 保持关闭
○ 上电开启
```

具体枚举值必须根据协议确定。

---

# 27. 设备设置

包括：

```text
背光亮度
息屏时间
温度单位
蜂鸣器
Modbus 从机地址
波特率
内部温度修正
外部温度修正
```

---

# 28. 保护设置

包括：

```text
低压保护 LVP
过压保护 OVP
过流保护 OCP
过功率保护 OPP
过温保护 OTP
最大输出时间
最大 AH
最大 WH
外部过温保护
上电输出
```

使用 Glass Card + iOS 风格设置行。

---

# 29. 保护状态

`PROTECT` 是 R/W 寄存器，但如果资料没有完整 bit 定义：

- 保存原始值；
- UI 显示原始/未知状态；
- 不自行猜测每个 bit；
- 为未来 bit mapping 留扩展接口。

---

# 30. CV/CC

`CVCC` 是只读寄存器。

UI 支持：

```text
CV
CC
Unknown
```

具体数值映射如果资料没有定义，不得猜测。

---

# 31. BLE 扫描页面

提供：

```text
扫描
停止
连接
断开
自动重连
刷新
收藏设备
```

示例：

```text
● XY-SK120
  RSSI -48 dBm
                  [连接]

● XY-SK120
  RSSI -72 dBm
                  [连接]
```

---

# 32. 通信日志

工程调试页面：

```text
TIME
TX/RX
HEX
PARSED
RESULT
```

例如：

```text
22:31:01
TX
01 03 00 02 00 05 ...

22:31:01
RX
01 03 ...

Parsed:
VOUT = ...
IOUT = ...
```

支持：

- 暂停
- 继续
- 清空
- 搜索
- TX/RX 过滤
- Hex
- 解析
- 导出

每条日志至少包含：

```text
timestamp
direction
raw bytes
parsed message
success/failure
error
```

---

# 33. 数据库

使用：

```text
Drift + SQLite
```

至少包含：

```text
devices
presets
measurement_samples
output_sessions
device_groups
communication_logs
app_settings
```

Widget 不直接访问数据库。

---

# 34. 响应式布局

断点：

```text
< 600px
Mobile

600 ~ 1000px
Tablet

> 1000px
Desktop
```

手机：

```text
NavigationBar
```

桌面：

```text
NavigationRail / Sidebar
```

---

# 35. Design System

建立：

```text
AppColors
AppSpacing
AppRadius
AppShadows
AppTypography
GlassCard
GlassButton
GlassPanel
GlowIndicator
MetricCard
StatusBadge
```

主题：

```text
Dark Industrial IoT
```

主色：

```text
Electric Blue
Cyan
```

状态：

```text
Success
Warning
Danger
```

颜色必须克制，确保读数清晰。

---

# 36. 动画

实现适量：

- BLE 连接状态
- 输出 ON/OFF
- 数值变化
- Power Gauge
- CV/CC
- 页面切换
- 桌面 hover
- 按钮反馈
- 曲线更新

不要影响工程软件可读性。

---

# 37. MockDevice

必须实现：

```text
MockPowerDevice
```

模拟：

```text
12.000 V
1.250 A
15.000 W
24.1 V
32.5 °C
CV
```

并模拟：

- 输出
- 保护
- 数据组
- 曲线
- 历史
- 通信日志

真实模式：

```text
RealPowerDevice
```

Mock 不得混入真实通信逻辑。

---

# 38. 错误处理

统一定义：

```text
BleError
ConnectionTimeout
ModbusTimeout
ModbusCrcError
ModbusException
InvalidRegisterValue
DeviceNotReady
DatabaseError
```

用户看到：

```text
通信超时

设备没有响应。

[重试]
```

原始错误进入日志。

---

# 39. 工程模式

提供隐藏的：

```text
工程模式
```

包含：

```text
原始寄存器
Modbus 通信日志
BLE 信息
设备信息
协议诊断
```

校准相关寄存器默认禁止普通用户访问。

特别注意：

```text
0x1000 ~ 0x100E
0x1500 ~ 0x1506
0x0400 ~ 0x040B
```

涉及校准/相关参数，必须单独封装，不得暴露为普通控制功能。

---

# 40. 测试

Unit Test：

```text
Modbus CRC
Register parser
Scale conversion
AH/WH conversion
Data group address
Parameter validation
```

Repository Test：

```text
Database CRUD
Preset
History
Communication Log
```

Widget Test：

```text
Control
Monitoring
Data Groups
Protection
Settings
```

---

# 41. Logger

统一：

```text
debug
info
warning
error
```

开发阶段可以记录 BLE Raw Packet / Modbus Frame。

生产模式默认关闭详细 HEX，但工程模式可开启。

---

# 42. README

创建完整 README：

```text
项目介绍
技术栈
架构
目录
运行方法
iOS 配置
Android 配置
macOS 配置
Windows 配置
Linux 配置
BLE 权限
数据库
Mock 模式
Real 模式
Modbus 协议
测试
构建
发布
```

---

# 43. 开发顺序

## Phase 1

先创建：

```text
Theme
Router
Responsive Layout
Glass UI
Mock Device
```

先完成 UI。

## Phase 2

实现：

```text
PowerDevice
Register Model
Modbus Model
Mock Modbus
```

## Phase 3

实现：

```text
BLE Scan
BLE Connect
BLE Disconnect
BLE Reconnect
```

## Phase 4

实现：

```text
Real Modbus over BLE
```

## Phase 5

实现：

```text
Real-time polling
Voltage
Current
Output
V/A/W
CV/CC
Protection
Temperature
```

## Phase 6

实现：

```text
M0-M9
Presets
Protection
Device Settings
```

## Phase 7

实现：

```text
Charts
AH/WH
History
SQLite
```

## Phase 8

实现：

```text
Communication Log
Engineering Mode
Export
Diagnostics
```

---

# 44. 开发执行规则

开始开发前：

1. 检查当前目录是否已有 Flutter 项目。
2. 如果已有项目，先分析，不要无条件覆盖。
3. 检查 Flutter/Dart 版本。
4. 检查平台支持。
5. 检查已有依赖。
6. 创建合理目录。
7. 优先完成 MockDevice + UI。
8. 再接入通信。
9. 每完成一个 Phase 执行：

```bash
flutter analyze
flutter test
```

10. 修复 analyzer error。
11. 不把未实现功能伪装成已实现。
12. 协议不明确的地方保留 TODO。
13. 不伪造真实设备协议。
14. 最终报告实现状态。

---

# 45. 平台构建

尽可能验证：

```bash
flutter build apk
flutter build ios
flutter build macos
flutter build windows
flutter build linux
```

无法在当前环境验证的平台必须明确说明：

```text
平台
无法验证原因
用户需要的验证环境
```

不得伪造构建成功。

---

# 46. 最终架构

必须保持：

```text
UI
 ↓
State Management
 ↓
Domain Service
 ↓
Repository
 ↓
Protocol
 ↓
Transport
 ↓
Hardware
```

最终：

```text
                 Flutter
                    │
        ┌───────────┴────────────┐
        │                        │
   Mobile UI                 Desktop UI
 iOS / Android          macOS / Windows / Linux
        │                        │
        └───────────┬────────────┘
                    │
               Application
                    │
             PowerDevice API
                    │
              Modbus Protocol
                    │
                BLE Transport
                    │
                    ▼
                 XY-SK120
```

核心优先级：

> 架构正确 > 协议准确 > 功能完整 > UI 美观 > 额外功能

不要为了快速完成 Demo 而破坏分层架构。

---

# 47. 完成后的最终报告

完成后输出：

```text
实现完成的功能
未实现功能
协议资料缺失项
Mock 模式说明
真实设备模式说明
运行方法
测试结果
各平台构建结果
需要真实设备验证的项目
后续建议
```

尤其需要明确列出任何因为协议文档缺失而无法安全实现的内容。
