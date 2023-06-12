import 'package:walletconnect_flutter_v2/apis/web3wallet/web3wallet.dart';

abstract class DappsService {
  Future<void> connect();
}

class DappsServiceImpl implements DappsService {
  final Web3Wallet web3Wallet;

  const DappsServiceImpl({
    required this.web3Wallet,
  });

  Future<void> connect() async {}
}
