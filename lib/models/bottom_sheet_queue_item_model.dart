
import 'dart:async';

import 'package:flutter/cupertino.dart';

class BottomSheetQueueItemModel {
  final Widget widget;
  final Completer<dynamic> completer;

  BottomSheetQueueItemModel({
    required this.widget,
    required this.completer,
  });
}