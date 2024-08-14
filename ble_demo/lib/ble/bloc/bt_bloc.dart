import 'package:ble_demo/ble/data/bt_repository.dart';
import 'package:ble_demo/ble/models/bt_device_model.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bt_event.dart';
part 'bt_state.dart';

class BtBloc extends Bloc<BtEvent, BtState> {
  final BtRepository _btRepository;

  BtBloc(this._btRepository) : super(BtInitial()) {
    on<BtInit>((event, emit) => _handleInitBt(event, emit));
    on<BtFindAndConnectToDevice>((event, emit) => _handleConnectToDevice(event, emit));
  }

  void _handleInitBt(BtInit event, Emitter<BtState> emit) {
    _btRepository.initBt();
  }

  void _handleConnectToDevice(BtFindAndConnectToDevice event, Emitter<BtState> emit) {
    emit(BtScanning());
  }
}
