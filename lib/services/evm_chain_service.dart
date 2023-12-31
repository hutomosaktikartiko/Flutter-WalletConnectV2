import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';

import '../models/chain_key_model.dart';
import '../models/ethereum_transaction_model.dart';
import '../models/connection_model.dart';
import '../presentations/widgets/connection_widget.dart';
import '../presentations/widgets/modals/web3_request_modal.dart';
import '../utils/string_parsing.dart';
import 'bottom_sheet_service.dart';
import 'chain_service.dart';
import 'key_service.dart';
import 'web3wallet_service.dart';

enum EVMChainId {
  ethereum,
  polygon,
  goerli,
  mumbai,
}

extension KadenaChainIdX on EVMChainId {
  String chain() {
    String name = '';

    switch (this) {
      case EVMChainId.ethereum:
        name = '1';
        break;
      case EVMChainId.polygon:
        name = '137';
        break;
      case EVMChainId.goerli:
        name = '5';
        break;
      case EVMChainId.mumbai:
        name = '80001';
        break;
    }

    return '${EvmChainServiceImpl.namespace}:$name';
  }
}

class EvmChainServiceImpl implements ChainService {
  static const namespace = 'eip155';
  static const pSign = 'personal_sign';
  static const eSign = 'eth_sign';
  static const eSignTransaction = 'eth_signTransaction';
  static const eSignTypedData = 'eth_signTypedData';
  static const eSendTransaction = 'eth_sendTransaction';

  final BottomSheetService _bottomSheetService =
      GetIt.I<BottomSheetService>();
  final Web3WalletService _web3WalletService = GetIt.I<Web3WalletService>();

  final EVMChainId reference;

  final Web3Client ethClient;

  EvmChainServiceImpl({
    required this.reference,
    Web3Client? ethClient,
  }) : ethClient = ethClient ??
            Web3Client(
                'https://mainnet.infura.io/v3/51716d2096df4e73bec298680a51f0c5',
                http.Client()) {
    final Web3Wallet wallet = _web3WalletService.getWeb3Wallet();
    for (final String event in getEvents()) {
      wallet.registerEventEmitter(chainId: getChainId(), event: event);
    }
    wallet.registerRequestHandler(
      chainId: getChainId(),
      method: pSign,
      handler: personalSign,
    );
    wallet.registerRequestHandler(
      chainId: getChainId(),
      method: eSign,
      handler: ethSign,
    );
    wallet.registerRequestHandler(
      chainId: getChainId(),
      method: eSignTransaction,
      handler: ethSignTransaction,
    );
    wallet.registerRequestHandler(
      chainId: getChainId(),
      method: eSendTransaction,
      handler: ethSignTransaction,
    );
    wallet.registerRequestHandler(
      chainId: getChainId(),
      method: eSignTypedData,
      handler: ethSignTypedData,
    );
  }

  @override
  String getNamespace() {
    return namespace;
  }

  @override
  String getChainId() {
    return reference.chain();
  }

  @override
  List<String> getEvents() {
    return ['chainChanged', 'accountsChanged'];
  }

  Future<String?> requestAuthorization(String text) async {
    // Show the bottom sheet
    final bool? isApproved = await _bottomSheetService.queueBottomSheet(
      widget: Web3RequestModal(
        child: ConnectionWidget(
          title: 'Sign Transaction',
          info: [
            ConnectionModel(
              text: text,
            ),
          ],
        ),
      ),
    );

    if (isApproved != null && isApproved == false) {
      return 'User rejected signature';
    }

    return null;
  }

  Future personalSign(String topic, dynamic parameters) async {
    log('received personal sign request: $parameters');

    final String message = (parameters[0] is String)
        ? (parameters[0] as String).utf8Message
        : parameters[0].toString().utf8Message;

    final String? authAcquired = await requestAuthorization(message);
    if (authAcquired != null) {
      return authAcquired;
    }

    try {
      // Load the private key
      final List<ChainKeyModel> keys = GetIt.I<KeyService>().getKeysForChain(
        getChainId(),
      );
      final Credentials credentials = EthPrivateKey.fromHex(keys[0].privateKey);

      final String signature = hex.encode(
        credentials.signPersonalMessageToUint8List(
          Uint8List.fromList(
            utf8.encode(message),
          ),
        ),
      );

      return '0x$signature';
    } catch (e) {
      log(e.toString());
      return 'Failed';
    }
  }

  Future ethSign(String topic, dynamic parameters) async {
    log('received eth sign request: $parameters');

    final String message = (parameters[1] is String)
        ? (parameters[1] as String).utf8Message
        : parameters[1].toString().utf8Message;

    final String? authAcquired = await requestAuthorization(message);
    if (authAcquired != null) {
      return authAcquired;
    }

    try {
      // Load the private key
      final List<ChainKeyModel> keys = GetIt.I<KeyService>().getKeysForChain(
        getChainId(),
      );
      final EthPrivateKey credentials = EthPrivateKey.fromHex(
        keys[0].privateKey,
      );
      final String signature = hex.encode(
        credentials.signPersonalMessageToUint8List(
          Uint8List.fromList(
            utf8.encode(message),
          ),
        ),
      );
      log(signature);

      return '0x$signature';
    } catch (e) {
      log('error:');
      log(e.toString());
      return 'Failed';
    }
  }

  Future ethSignTransaction(String topic, dynamic parameters) async {
    log('received eth sign transaction request: $parameters');
    final String? authAcquired = await requestAuthorization(
      jsonEncode(
        parameters[0],
      ),
    );
    if (authAcquired != null) {
      return authAcquired;
    }

    // Load the private key
    final List<ChainKeyModel> keys = GetIt.I<KeyService>().getKeysForChain(
      getChainId(),
    );
    final Credentials credentials = EthPrivateKey.fromHex(
      '0x${keys[0].privateKey}',
    );

    EthereumTransactionModel ethTransaction = EthereumTransactionModel.fromJson(
      parameters[0],
    );

    // Construct a transaction from the EthereumTransactionModel object
    final transaction = Transaction(
      from: EthereumAddress.fromHex(ethTransaction.from),
      to: EthereumAddress.fromHex(ethTransaction.to),
      value: EtherAmount.fromUnitAndValue(
        EtherUnit.wei,
        BigInt.tryParse(ethTransaction.value) ?? BigInt.zero,
      ),
      gasPrice: ethTransaction.gasPrice != null
          ? EtherAmount.fromUnitAndValue(
              EtherUnit.gwei,
              BigInt.tryParse(ethTransaction.gasPrice!) ?? BigInt.zero,
            )
          : null,
      maxFeePerGas: ethTransaction.maxFeePerGas != null
          ? EtherAmount.fromUnitAndValue(
              EtherUnit.gwei,
              BigInt.tryParse(ethTransaction.maxFeePerGas!) ?? BigInt.zero,
            )
          : null,
      maxPriorityFeePerGas: ethTransaction.maxPriorityFeePerGas != null
          ? EtherAmount.fromUnitAndValue(
              EtherUnit.gwei,
              BigInt.tryParse(ethTransaction.maxPriorityFeePerGas!) ??
                  BigInt.zero,
            )
          : null,
      maxGas: int.tryParse(ethTransaction.gasLimit ?? ''),
      nonce: int.tryParse(ethTransaction.nonce ?? ''),
      data: (ethTransaction.data != null && ethTransaction.data != '0x')
          ? Uint8List.fromList(hex.decode(ethTransaction.data!))
          : null,
    );

    try {
      final Uint8List sig = await ethClient.signTransaction(
        credentials,
        transaction,
      );

      // Sign the transaction
      final String signedTx = hex.encode(sig);

      // Return the signed transaction as a hexadecimal string
      return '0x$signedTx';
    } catch (e) {
      log(e.toString());
      return 'Failed';
    }
  }

  Future ethSignTypedData(String topic, dynamic parameters) async {
    log('received eth sign typed data request: $parameters');
    final String data = parameters[1];
    final String? authAcquired = await requestAuthorization(data);
    if (authAcquired != null) {
      return authAcquired;
    }

    final List<ChainKeyModel> keys = GetIt.I<KeyService>().getKeysForChain(
      getChainId(),
    );

    return EthSigUtil.signTypedData(
      privateKey: keys[0].privateKey,
      jsonData: data,
      version: TypedDataVersion.V4,
    );
  }
}
