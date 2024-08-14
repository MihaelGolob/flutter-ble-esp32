part of 'bt_bloc.dart';

@immutable
sealed class BtState {}

final class BtInitial extends BtState {}

final class BtScanning extends BtState {}

final class BtConnected extends BtState {
  final BtDevice device;

  BtConnected({required this.device});
}

final class BtError extends BtState {
  final String message;

  BtError(this.message);
}
