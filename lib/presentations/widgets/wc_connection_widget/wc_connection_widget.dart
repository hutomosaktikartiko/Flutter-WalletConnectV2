import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'wc_connection_model.dart';
import 'wc_connection_widget_info.dart';

class WCConnectionWidget extends StatelessWidget {
  const WCConnectionWidget({
    super.key,
    required this.title,
    required this.info,
  });

  final String title;
  final List<WCConnectionModel> info;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StyleConstants.layerColor2,
        borderRadius: BorderRadius.circular(
          StyleConstants.linear16,
        ),
      ),
      padding: const EdgeInsets.all(
        StyleConstants.linear8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(title),
          const SizedBox(height: StyleConstants.linear8),
          ...info.map(
            (e) => WCConnectionWidgetInfo(
              model: e,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Container(
      decoration: BoxDecoration(
        color: StyleConstants.layerBubbleColor2,
        borderRadius: BorderRadius.circular(
          StyleConstants.linear16,
        ),
      ),
      padding: StyleConstants.bubblePadding,
      child: Text(
        text,
        style: StyleConstants.layerTextStyle2,
      ),
    );
  }
}
