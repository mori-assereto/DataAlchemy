{% docs metrics_ltv_description %}
## Metrics LTV

Esta tabla contiene las variables necesarias para poder construir el
LTV.

Para facilitar los cálculos, la tabla agrupa las variables en las
distintas dimensiones de interés.

A modo ilustrativo, tenemos el siguiente ejemplo
con dos dimensiones y una métrica:

| Enterprise 	| Product 	| Subscriptions Lost 	|
|------------	|---------	|--------------------	|
| TRUE       	| Card    	| 2                  	|
| FALSE      	| Card    	| 20                 	|
| TRUE       	| Pay     	| 2                  	|

En este ejemplo, tenemos que dentro de las suscripciones de cuentas
enterprise, para Card, tuvimos 2 bajas. Para cuentas no enterprise,
tuvimos 20. Y para Pay, tuvimos 2 bajas únicamente de cuentas enterprise.

## LTV

### Qué es?

Lifetime Value (LTV) estima el revenue generado por un cliente durante
toda su vida dentro de Increase.

### Cómo se calcula?

El LTV se estima de la siguiente manera, utilizando ARPS y Churn de los últimos 6 meses para ser menos propensos a cambios bruscos (p.ej churn elevado en un mes en particular):

```
LTV = AVG(ARPS últimos 6 meses) * (1 / AVG(Churn últimos 6 meses))
```

Teniendo en cuenta que la inversa del churn mensual intenta aproximar la
cantidad de meses que en promedio se van a quedar los clientes.

El cálculo entonces refleja el revenue promedio (`ARPS`) durante los meses
de vida estimados (`1 / Churn`).

Dentro de Metabase, para calcular el LTV agrupado de una manera en
particular (por país y producto por ejemplo), se deben agregar las
métricas de la siguiente manera:

```
ARPS = SUM(revenue_usd últimos 6 meses) / SUM(paying_subscriptions_on_current_month últimos 6 meses)
Churn = SUM(subscriptions_lost últimos 6 meses) / SUM(paying_subscriptions_on_previous_month últimos 6 meses)
LTV = ARPS / Churn
```

Agrupando por país y producto.

{% enddocs %}
