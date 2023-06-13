import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:test_wallet_connect_v2/services/chain_service.dart';

import 'presentations/pages/home_page.dart';
import 'presentations/widgets/modals/bottom_sheet_listener.dart';
import 'services/bottom_sheet_service.dart';
import 'services/evm_chain_service.dart';
import 'services/key_service.dart';
import 'services/web3wallet_service.dart';
import 'utils/constants.dart';
import 'utils/string_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: StringConstants.appTitle,
      theme: _buildDarkTheme(),
      home: MyHomePage(),
    );
  }

  ThemeData _buildDarkTheme() {
    final baseTheme = ThemeData.dark();
    const nearWhite = Color(0xFFE0E0E0);

    return baseTheme.copyWith(
      scaffoldBackgroundColor: Colors.black,
      textTheme: baseTheme.textTheme.apply(
        bodyColor: nearWhite,
        displayColor: nearWhite,
      ),
      colorScheme: baseTheme.colorScheme.copyWith(
        background: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: nearWhite.withOpacity(0.5)),
        labelStyle: const TextStyle(color: nearWhite),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: nearWhite.withOpacity(0.5)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: nearWhite),
        ),
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: nearWhite),
        contentTextStyle: TextStyle(color: nearWhite),
      ),
      appBarTheme: const AppBarTheme(
        color: Colors.black,
        iconTheme: IconThemeData(color: nearWhite),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: nearWhite,
        unselectedItemColor: nearWhite.withOpacity(0.5),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.black,
        selectedIconTheme: const IconThemeData(color: nearWhite),
        unselectedIconTheme: IconThemeData(color: nearWhite.withOpacity(0.5)),
        selectedLabelTextStyle: const TextStyle(color: nearWhite),
        unselectedLabelTextStyle: TextStyle(color: nearWhite.withOpacity(0.5)),
      ),
      cardColor: const Color(0xFF1A1A1A),
      cardTheme: const CardTheme(
        color: Color(0xFF1A1A1A),
      ),
      dividerColor: nearWhite.withOpacity(0.2),
    );
  }
}

class MyHomePage extends StatefulWidget with GetItStatefulWidgetMixin {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with GetItStateMixin {
  bool _initializing = true;

  @override
  void initState() {
    initialize();

    super.initState();
  }

  Future<void> initialize() async {
    GetIt.I.registerSingleton<BottomSheetService>(BottomSheetServiceImpl());
    GetIt.I.registerSingleton<KeyService>(KeyServiceImpl());

    final Web3WalletService web3WalletService = Web3WalletServiceImpl();
    web3WalletService.create();
    GetIt.I.registerSingleton<Web3WalletService>(web3WalletService);

    for (final cId in EVMChainId.values) {
      GetIt.I.registerSingleton<ChainService>(
        EvmChainServiceImpl(reference: cId),
        instanceName: cId.chain(),
      );
    }

    await web3WalletService.init();

    setState(() {
      _initializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Center(
        child: CircularProgressIndicator(
          color: StyleConstants.primaryColor,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(StringConstants.connectPageTitle),
      ),
      body: BottomSheetListener(
        child: HomePage(),
      ),
    );
  }
}
