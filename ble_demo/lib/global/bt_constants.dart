// a helper class that will contain logic & rules for
// transforming data into bytes and writing it to the BLE device
import 'package:equatable/equatable.dart';

class BtConstants {
  static String unitBleName = 'Algorhythmo';

  static BtService mainService = const BtService(uuid: '00ff');
  static BtCharacteristic volumeChar = BtCharacteristic(uuid: 'ff04', parentService: mainService);
}

class BtService extends Equatable {
  final String uuid;

  const BtService({required this.uuid});

  @override
  List<Object?> get props => [uuid];
}

class BtCharacteristic extends Equatable {
  final String uuid;
  final BtService parentService;

  const BtCharacteristic({required this.uuid, required this.parentService});

  @override
  List<Object?> get props => [uuid, parentService];
}
