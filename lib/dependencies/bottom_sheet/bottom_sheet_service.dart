import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import 'i_bottom_sheet_service.dart';

class BottomSheetService extends IBottomSheetService {
  Queue queue = Queue<BottomSheetQueueItem>();

  @override
  final ValueNotifier<BottomSheetQueueItem?> currentSheet = ValueNotifier(null);

  @override
  Future<dynamic> queueBottomSheet({
    required Widget widget,
  }) async {
    // Create the bottom sheet queue item
    final completer = Completer<dynamic>();
    final queueItem = BottomSheetQueueItem(
      widget: widget,
      completer: completer,
    );

    // If the current sheet it null, set it to the queue item
    if (currentSheet.value == null) {
      currentSheet.value = queueItem;
    } else {
      // Otherwise, add it to the queue
      queue.add(queueItem);
    }

    // Return the future
    return await completer.future;
  }

  @override
  void showNext() {
    if (queue.isEmpty) {
      currentSheet.value = null;
    } else {
      currentSheet.value = queue.removeFirst();
    }
  }
}
