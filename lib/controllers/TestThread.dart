@JS()

import 'dart:html';
import 'dart:js_interop';
import 'custom_thread.dart';

@JS('self')
external DedicatedWorkerGlobalScope get self;

void main() async {
  self.importScripts('tdlib.js');
  await TestThread().main(self);
}
