import 'dart:developer';

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

import '../../dependencies/i_web3wallet_service.dart';
import '../../utils/constants.dart';
import '../../utils/string_constants.dart';
import '../widgets/pairing_item.dart';
import '../widgets/qr_scan_sheet.dart';
import '../widgets/uri_input_popup.dart';
import 'app_detail_page.dart';

class AppsPage extends StatefulWidget with GetItStatefulWidgetMixin {
  AppsPage({
    Key? key,
  }) : super(key: key);

  @override
  AppsPageState createState() => AppsPageState();
}

class AppsPageState extends State<AppsPage> with GetItStateMixin {
  List<PairingInfo> _pairings = [];

  final Web3Wallet web3Wallet = GetIt.I<IWeb3WalletService>().getWeb3Wallet();

  @override
  void initState() {
    _pairings = web3Wallet.pairings.getAll();
    // web3wallet.onSessionDelete.subscribe(_onSessionDelete);
    web3Wallet.core.pairing.onPairingDelete.subscribe(_onPairingDelete);
    web3Wallet.core.pairing.onPairingExpire.subscribe(_onPairingDelete);
    super.initState();
  }

  @override
  void dispose() {
    // web3wallet.onSessionDelete.unsubscribe(_onSessionDelete);
    web3Wallet.core.pairing.onPairingDelete.unsubscribe(_onPairingDelete);
    web3Wallet.core.pairing.onPairingExpire.unsubscribe(_onPairingDelete);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pairings = watch(
      target: GetIt.I<IWeb3WalletService>().pairings,
    );

    return Stack(
      children: [
        _pairings.isEmpty ? _buildNoPairingMessage() : _buildPairingList(),
        Positioned(
          bottom: StyleConstants.magic20,
          right: StyleConstants.magic20,
          child: Row(
            children: [
              // Disconnect buttons for testing
              _buildIconButton(
                Icons.discord,
                () {
                  web3Wallet.core.relayClient.disconnect();
                },
              ),
              const SizedBox(
                width: StyleConstants.magic20,
              ),
              _buildIconButton(
                Icons.connect_without_contact,
                () {
                  web3Wallet.core.relayClient.connect();
                },
              ),
              const SizedBox(
                width: StyleConstants.magic20,
              ),
              _buildIconButton(
                Icons.copy,
                _onCopyQrCode,
              ),
              const SizedBox(
                width: StyleConstants.magic20,
              ),
              _buildIconButton(
                Icons.qr_code_rounded,
                _onScanQrCode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoPairingMessage() {
    return const Center(
      child: Text(
        StringConstants.noApps,
        textAlign: TextAlign.center,
        style: StyleConstants.bodyText,
      ),
    );
  }

  Widget _buildPairingList() {
    final List<PairingItem> pairingItems = _pairings
        .map(
          (PairingInfo pairing) => PairingItem(
            key: ValueKey(pairing.topic),
            pairing: pairing,
            onTap: () => _onListItemTap(pairing),
          ),
        )
        .toList();

    return ListView.builder(
      itemCount: pairingItems.length,
      itemBuilder: (BuildContext context, int index) {
        return pairingItems[index];
      },
    );
  }

  Widget _buildIconButton(IconData icon, void Function()? onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: StyleConstants.primaryColor,
        borderRadius: BorderRadius.circular(
          StyleConstants.linear48,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: StyleConstants.titleTextColor,
        ),
        iconSize: StyleConstants.linear24,
        onPressed: onPressed,
      ),
    );
  }

  Future _onCopyQrCode() async {
    final String? uri = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return UriInputPopup();
      },
    );

    // print(uri);

    _onFoundUri(uri);
  }

  Future _onScanQrCode() async {
    final String? s = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext modalContext) {
        return QRScanSheet(
          title: StringConstants.scanPairing,
        );
      },
    );

    _onFoundUri(s);
  }

  Future _onFoundUri(String? uri) async {
    if (uri != null) {
      try {
        log('uri: $uri');
        final Uri uriData = Uri.parse(uri);
        await web3Wallet.pair(
          uri: uriData,
        );
      } catch (e) {
        _invalidUriToast();
      }
    } else {
      _invalidUriToast();
    }
  }

  void _invalidUriToast() {
    showToast(
      child: Container(
        padding: const EdgeInsets.all(StyleConstants.linear8),
        margin: const EdgeInsets.only(
          bottom: StyleConstants.magic40,
        ),
        decoration: BoxDecoration(
          color: StyleConstants.errorColor,
          borderRadius: BorderRadius.circular(
            StyleConstants.linear16,
          ),
        ),
        child: const Text(
          StringConstants.invalidUri,
          style: StyleConstants.bodyTextBold,
        ),
      ),
      context: context,
    );
  }

  void _onPairingDelete(PairingEvent? event) {
    setState(() {
      _pairings = web3Wallet.pairings.getAll();
    });
  }

  void _onListItemTap(PairingInfo pairing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppDetailPage(
          pairing: pairing,
        ),
      ),
    );
  }
}
