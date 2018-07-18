## Providers

Provider is one of the main concepts of **Agala** framework. Different providers 
*provide* different incoming event sources for your application.

All providers share same concepts of construction, but can have absolutely different
underline logic. One can create his own provider and plug it into Agala platform or share
between community. Or, you can use prepared provider in order to forget about
event source protocols and deal only with business logic of incoming events.

### Propvider structure

Basically, **provider package** can contain everything is needed to perform communication
with third-parties. It doesn't have any *upper border*, it is limited only by common sence.

At the same time, provider should follow some convention, and have some modules that implement
special behaviours:

* **Main module**: provider entry point. Should implement `Agala.Provider` behaviour.
* 1 to 3 retreiving modules:
  * **Plug**, that follows `Agala.Bot.Plug` conventions
  * **Poller**, that follows `Agala.Bot.Poller` conventions
  * **Handler**. that follows `Agala.Bot.Handler` conventions
* Optional **Helper** or **API** modules, that provide mechanisms to send response back to provider.

### Provider implimentation

TODO