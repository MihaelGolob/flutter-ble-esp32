import 'package:ble_demo/ble/data/bt_repository.dart';
import 'package:ble_demo/ble/models/bt_device_model.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bt_event.dart';
part 'bt_state.dart';

class BtBloc extends Bloc<BtEvent, BtState> {
  final BtRepository _btRepository;

  BtBloc(this._btRepository) : super(BtInitial()) {
    on<BtFindAndConnectToDevice>((event, emit) => _handleConnectToDevice(event, emit));
    on<BtDisconnect>((event, emit) => _handleDisconnect(emit));

    _btRepository.onDisconnect(() {
      add(BtDisconnect());
    });
  }

  void _handleConnectToDevice(BtFindAndConnectToDevice event, Emitter<BtState> emit) async {
    emit(BtScanning());
    try {
      var device = await _btRepository.connectToDevice(event.deviceName);
      emit(BtConnected(device: device));
    } on BtExceptionTimeout {
      emit(BtError('Device not found, please try again'));
    } on Exception catch (e) {
      emit(BtError('Error connecting to device: $e'));
    }
  }

  void _handleDisconnect(Emitter<BtState> emit) {
    _btRepository.disconnectFromDevice();
    emit(BtInitial());
  }

  void setVolume(int value) {
    _btRepository.setVolume(value);
  }
}
