## Handlers

Basicaly, `Agala.Backbone` splits event handling into 2 stages:

* **receive->backbone** stage - on which events are getting inside our system,
  and are preparing to be pushed into backbone. This module will cover this stage.
* **backbone->handle** stage - on which events are pulling from the backbone,
  then somehow handled by the system.

You can handle events just inside **receive** stage - this will probably increase performance
of an app, because you will not need to put and then pull data from **Backbone**.
On the other hand, **Backbone** alows you to split incoming events stream
to be handled with pool of handlers that can be started all over the cluster.
Also, sometimes you will get events directly from the **Backbone**, because 
receiver is created in another language or technology.