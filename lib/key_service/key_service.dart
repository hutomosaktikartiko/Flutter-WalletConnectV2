
import '../utils/dart_defines.dart';
import 'chain_key.dart';
import 'i_key_service.dart';

class KeyService extends IKeyService {
  final List<ChainKey> keys = [
    // ChainKey(
    //   chains: [
    //     'kadena:mainnet01',
    //     'kadena:testnet04',
    //     'kadena:development',
    //   ],
    //   privateKey: DartDefines.kadenaPrivateKey,
    //   publicKey: DartDefines.kadenaPublicKey,
    // ),
    ChainKey(
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
    for (final ChainKey key in keys) {
      chainIds.addAll(key.chains);
    }
    return chainIds;
  }

  @override
  List<ChainKey> getKeys() {
    return keys;
  }

  @override
  List<ChainKey> getKeysForChain(String chain) {
    return keys.where((e) => e.chains.contains(chain)).toList();
  }

  @override
  List<String> getAllAccounts() {
    final List<String> accounts = [];
    for (final ChainKey key in keys) {
      for (final String chain in key.chains) {
        accounts.add('$chain:${key.publicKey}');
      }
    }
    return accounts;
  }
}
