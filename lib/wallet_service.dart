import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

abstract class WalletService {
  Future<void> connect();
}

class WalletServiceImpl implements WalletService {
  final Web3App web3App;

  const WalletServiceImpl({
    required this.web3App,
  });

  Future<void> connect() async {}
}