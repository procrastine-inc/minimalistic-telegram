import { EventEmitter, Subscription } from "expo-modules-core";
import TdlibRnModule from "./src/TdlibRnModule";

type UpdateCallback = (update: any) => void;

export class TdClient {
  private static emitter = new EventEmitter(TdlibRnModule);
  private updateSubscription: Subscription | null = null;

  constructor(options: { onUpdate?: UpdateCallback } = {}) {
    if (options.onUpdate) {
      this.updateSubscription = TdClient.emitter.addListener(
        "tdLibUpdate",
        options.onUpdate
      );
    }
    TdlibRnModule.init();
  }

  async send(query: any): Promise<any> {
    return TdlibRnModule.send(JSON.stringify(query));
  }

  destroy() {
    if (this.updateSubscription) {
      this.updateSubscription.remove();
      this.updateSubscription = null;
    }
    TdlibRnModule.destroy();
  }
}

export default TdClient;
