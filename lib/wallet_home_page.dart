import 'package:flutter/material.dart';
import 'package:test_wallet_connect_v2/dapps_service.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key});

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  late DappsService dappsService;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() async {
    Web3Wallet web3Wallet = await Web3Wallet.createInstance(
      // relayUrl: '', // The relay websocket URL, leave blank to use the default
      projectId: '8eaf78b8e19d71bfa435b5f34eef83e6',
      metadata: const PairingMetadata(
        name: 'Wallet (Responder)',
        description: 'A wallet that can be requested to sign transactions',
        url: 'https://walletconnect.com',
        icons: ['https://avatars.githubusercontent.com/u/37784886'],
      ),
    );

    dappsService = DappsServiceImpl(
      web3Wallet: web3Wallet,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
