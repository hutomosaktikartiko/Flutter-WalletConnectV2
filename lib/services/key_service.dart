
import '../models/chain_key_model.dart';
import '../utils/dart_defines.dart';

abstract class KeyService {
  /// Returns a list of all the keys.
  List<ChainKeyModel> getKeys();

  /// Returns a list of all the chain ids.
  List<String> getChains();

  /// Returns a list of all the keys for a given chain id.
  /// If the chain is not found, returns an empty list.
  ///  - [chain]: The chain to get the keys for.
  List<ChainKeyModel> getKeysForChain(String chain);

  /// Returns a list of all the accounts in namespace:chainId:address format.
  List<String> getAllAccounts();
}

class KeyServiceImpl implements KeyService {
  final List<ChainKeyModel> keys = [
    ChainKeyModel(
      chains: [
        'eip155:1',
        'eip155:5',
        'eip155:137',
        'eip155:80001',
      ],
      privateKey: DartDefines.ethereumPrivateKey,
      publicKey: DartDefines.ethereumPublicKey,
    )
  ];

  @override
  List<String> getChains() {
    final List<String> chainIds = [];
    for (final ChainKeyModel key in keys) {
      chainIds.addAll(key.chains);
    }
    return chainIds;
  }

  @override
  List<ChainKeyModel> getKeys() {
    return keys;
  }

  @override
  List<ChainKeyModel> getKeysForChain(String chain) {
    return keys.where((e) => e.chains.contains(chain)).toList();
  }

  @override
  List<String> getAllAccounts() {
    final List<String> accounts = [];
    for (final ChainKeyModel key in keys) {
      for (final String chain in key.chains) {
        accounts.add('$chain:${key.publicKey}');
      }
    }
    return accounts;
  }
}
