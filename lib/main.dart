import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:test_wallet_connect_v2/presentations/pages/apps_page.dart';
import 'package:test_wallet_connect_v2/utils/constants.dart';

import 'dependencies/bottom_sheet/bottom_sheet_listener.dart';
import 'dependencies/bottom_sheet/bottom_sheet_service.dart';
import 'dependencies/bottom_sheet/i_bottom_sheet_service.dart';
import 'dependencies/chains/evm_service.dart';
import 'dependencies/chains/i_chain.dart';
import 'dependencies/i_web3wallet_service.dart';
import 'dependencies/key_service/i_key_service.dart';
import 'dependencies/key_service/key_service.dart';
import 'dependencies/web3wallet_service.dart';
import 'models/page_data.dart';
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

  List<PageData> _pageDatas = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    initialize();

    super.initState();
  }

  Future<void> initialize() async {
    GetIt.I.registerSingleton<IBottomSheetService>(BottomSheetService());
    GetIt.I.registerSingleton<IKeyService>(KeyService());

    final IWeb3WalletService web3WalletService = Web3WalletService();
    web3WalletService.create();
    GetIt.I.registerSingleton<IWeb3WalletService>(web3WalletService);

    // for (final cId in KadenaChainId.values) {
    //   GetIt.I.registerSingleton<IChain>(
    //     KadenaService(reference: cId),
    //     instanceName: cId.chain,
    //   );
    // }

    for (final cId in EVMChainId.values) {
      GetIt.I.registerSingleton<IChain>(
        EVMService(reference: cId),
        instanceName: cId.chain(),
      );
    }

    await web3WalletService.init();

    setState(() {
      _pageDatas = [
        PageData(
          page: AppsPage(),
          title: StringConstants.connectPageTitle,
          icon: Icons.home,
        ),
        PageData(
          page: const Center(
            child: Text(
              'Notifications (Not Implemented)',
              style: StyleConstants.bodyText,
            ),
          ),
          title: StringConstants.pairingsPageTitle,
          icon: Icons.notifications,
        ),
      ];

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

    final List<Widget> navRail = [];
    if (MediaQuery.of(context).size.width >= Constants.smallScreen) {
      navRail.add(_buildNavigationRail());
    }
    navRail.add(
      Expanded(
        child: _pageDatas[_selectedIndex].page,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageDatas[_selectedIndex].title),
      ),
      bottomNavigationBar:
          MediaQuery.of(context).size.width < Constants.smallScreen
              ? _buildBottomNavBar()
              : null,
      body: BottomSheetListener(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: navRail,
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.indigoAccent,
      // called when one tab is selected
      onTap: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      // bottom tab items
      items: _pageDatas
          .map(
            (e) => BottomNavigationBarItem(
              icon: Icon(e.icon),
              label: e.title,
            ),
          )
          .toList(),
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      labelType: NavigationRailLabelType.selected,
      destinations: _pageDatas
          .map(
            (e) => NavigationRailDestination(
              icon: Icon(e.icon),
              label: Text(e.title),
            ),
          )
          .toList(),
    );
  }
}
