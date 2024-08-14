import 'package:ble_demo/ble/bloc/bt_bloc.dart';
import 'package:ble_demo/ble/data/bt_impl.dart';
import 'package:ble_demo/ble/data/bt_repository.dart';
import 'package:ble_demo/global/AppBlocObserver.dart';
import 'package:ble_demo/pages/home_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

void main() {
  Bloc.observer = AppBlocObserver();

  final BtRepository btRepository = BtImpl();

  runApp(MyApp(
    btRepository: btRepository,
  ));
}

class MyApp extends StatelessWidget {
  final BtRepository btRepository;

  const MyApp({super.key, required this.btRepository});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BtRepository>(create: (context) => btRepository),
      ],
      child: MultiBlocProvider(
        providers: [BlocProvider<BtBloc>(create: (context) => BtBloc(context.read<BtRepository>()))],
        child: MaterialApp(
          title: 'BLE demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
            useMaterial3: true,
          ),
          home: const HomePage(),
        ),
      ),
    );
  }
}
