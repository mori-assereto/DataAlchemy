{% docs metrics_churn_description %}

Esta tabla posee históricos de:

* La cantidad de suscripciones mes a mes
* Las altas de suscripciones mes a mes
* Las bajas de suscripciones mes a mes
* Las altas acumuladas de suscripciones mes a mes, desde el primer cliente
* Las bajas acumuladas de suscripciones mes a mes, desde el primer cliente

Para más detalles sobre suscripciones ganadas (altas) y perdidas (bajas)
consultar el [diccionario de métricas](https://docs.google.com/spreadsheets/d/1BsqLaEl-fUXqJ1Gp-Ix2MQF9LktgKOXmFUefQGYDsoM/edit#gid=0).

## Churn

### Qué es?

El churn nos indica cuántos clientes se dieron de baja en un período
(puede ser semanal, mensual, anual, etc.) con respecto a los
clientes al comienzo de ese período.

En Increase, tomamos el Churn como métrica mensual, por lo que
se toman bajas en un mes y se las compara con la cantidad de
clientes al comienzo de ese mes.

### Cómo se calcula?

Conceptualmente, el Churn se calcula como:

```
Churn Mensual = Bajas en el mes / Clientes a principio de mes
```


### Cómo lo estamos midiendo en Increase?

Dentro de esta tabla, deberíamos realizar la siguiente operación:

```
Churn Mensual = SUM(subscriptions_lost) / SUM(paying_subscriptions_on_previous_month)
```

La **única** fuente de verdad dentro de Increase para el Churn es
Platform; estamos tomando todas las suscripciones de Platform para
poder alimentar esta tabla.

Dentro de Metabase, para agilizar el cálculo, está predefinida [la métrica
*Churn*](https://metabase.increase.app/question#eyJkYXRhc2V0X3F1ZXJ5Ijp7ImRhdGFiYXNlIjoyLCJxdWVyeSI6eyJzb3VyY2UtdGFibGUiOjI2MTAsImFnZ3JlZ2F0aW9uIjpbWyJtZXRyaWMiLDIxXV0sImJyZWFrb3V0IjpbWyJkYXRldGltZS1maWVsZCIsWyJmaWVsZC1pZCIsNDM3OTldLCJtb250aCJdXX0sInR5cGUiOiJxdWVyeSJ9LCJkaXNwbGF5IjoibGluZSIsInZpc3VhbGl6YXRpb25fc2V0dGluZ3MiOnt9fQ==) como agregación.

{% enddocs %}
