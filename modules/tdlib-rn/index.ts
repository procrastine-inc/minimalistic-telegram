// import {
//   NativeModulesProxy,
//   EventEmitter,
//   Subscription,
// } from "expo-modules-core";

// Import the native module. On web, it will be resolved to tdlib.web.ts
// and on native platforms to tdlib.ts
import tdlibModule from "./src/TdlibRnModule";

export function createClientId(): number {
  return tdlibModule.createClientId();
}

export function receive(timeout: number): string {
  return tdlibModule.receive(timeout);
}

export function send(clientId: number, request: string): void {
  tdlibModule.send(clientId, request);
}

export function execute(request: string): string {
  return tdlibModule.execute(request);
}

export function setLogMessageCallback(
  verbosityLevel: number,
  callback: (verbosityLevel: number, message: string) => void
): void {
  tdlibModule.setLogMessageCallback(verbosityLevel, callback);
}
