import 'package:flutter/material.dart';
import 'package:test_wallet_connect_v2/wallet_service.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class DappsHomePage extends StatefulWidget {
  const DappsHomePage({super.key});

  @override
  State<DappsHomePage> createState() => _DappsHomePageState();
}

class _DappsHomePageState extends State<DappsHomePage> {
  late WalletService walletService;

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    Web3App web3App = await Web3App.createInstance(
      projectId: '8eaf78b8e19d71bfa435b5f34eef83e6',
      metadata: const PairingMetadata(
        name: 'dApp (Requester)',
        description: 'A dapp that can request that transactions be signed',
        url: 'https://walletconnect.com',
        icons: ['https://avatars.githubusercontent.com/u/37784886'],
      ),
    );

    walletService = WalletServiceImpl(
      web3App: web3App,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}