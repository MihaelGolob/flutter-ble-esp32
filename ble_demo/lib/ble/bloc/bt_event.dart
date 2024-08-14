part of 'bt_bloc.dart';

@immutable
sealed class BtEvent {}

final class BtInit extends BtEvent {}

final class BtFindAndConnectToDevice extends BtEvent {
  final String deviceName;

  BtFindAndConnectToDevice({required this.deviceName});
}
