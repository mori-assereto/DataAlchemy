{% docs zk_tickets_incoming_description %}
## Zk Tickets Incoming

Tabla que contiene la fecha de todas las veces que un ticket fue creado o paso
a ser una reapertura

### Cómo lo medimos?

Es la suma de todos los casos creados más cada reapertura de un ticket en el
período de tiempo seleccionado.

**Consideraciones**
Es la cantidad de tickets en estado `created` sin importar el estado en el cual
fueron creados más los contactos que estaban en estado `solved`y pasaron a
cualquier otro estado que no es `canceled`

{% enddocs %}
