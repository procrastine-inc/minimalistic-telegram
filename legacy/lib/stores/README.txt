This folder contains stores based on 2 different event emitter implementations.

The first one is old EventEmitter class, very poor implementation, but it works. It contains a stream, but that stream is not used anywhere.
The second is EventBus, provided by flutter library. 

Stores, based on EventEmitter, when subscribed, have to be unsubscribed through .off() method.
Stores, based on EventBus, when subscribed, have their subsciptions to be stored and then disposed through .cancel() method in widget disposal.

Keep this in mind using any of these implementations in your components.