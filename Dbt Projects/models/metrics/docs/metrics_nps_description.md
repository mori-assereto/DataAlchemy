{% docs metrics_nps_description %}
## NPS

### Qué es?

Net Promoter Score propone medir la lealtad y satisfacción de los clientes de
una empresa basándose en las recomendaciones.

| Categoría                	| Puntaje 	|
|--------------------------	|---------	|
| Promotores o Promoters   	| 9 o 10  	|
| Neutrales o Neutrals     	| 7 u 8   	|
| Detractores o Detractors 	| <7      	|

Para más detalles, ver [el doc en Confluence](https://increase-app.atlassian.net/wiki/spaces/IN/pages/539852953/NPS+-+referencia).

### Cómo se calcula?

La fórmula del NPS es:

```
NPS = % promotores - % detractores
```

El puntaje va de -100 a 100.

El estándar de muestras va entre 50 a 200 encuestas respondidas.

### Cómo lo estamos midiendo en Increase?

Las fuentes del NPS son Appcues, Platform (para el histórico previo a Ene 2020)
y [un formulario](https://docs.google.com/forms/d/e/1FAIpQLSd4tsUFOJNvWIye74VuikYxApVrCBCld4v8KapuNAXMLt8rzw/viewform)
enviado on demand para las cuentas *enterprise* que no tengan acceso a nuestro
front.

Este último formulario todavía no se encuentra sincronizado con el warehouse,
por lo que sus resultados no se verán reflejados dentro de las respuestas de
NPS en Metabase.

A partir del 21 de Septiembre del 2020 la pregunta le aparecerá únicamente a aquellos usuarios que estando en Increase Match o Increase Card cuenten con una suscripcón usable a dicho producto. En cambio para Increase Pay esta puede generarse siempre y cuando el usuario tenga una suscripción.

#### Consideraciones de las fuentes

* Los días de las respuestas se están tomando en base a la fecha en UTC de la respuesta.
  Una respuesta que se envió a las 23 hs (ARST) de un 1ro de enero, por ejemplo,
  contabilizará para el 2do de enero ya que en UTC serían las 2 am del 2 de enero. 

Respuestas obtenidas entre **Enero 2020 y el 27 de Marzo del mismo año**:
* **No** cuentan con `user_id`
* Presentan `account_id`
* Se tomó la decisión de considerar que todos los registros correspondían al producto **Increase Card** y eran de **Argentina**


Respuestas obtenidas **posterior al 27 de Marzo del 2020**:
* Tienen `user_id`, `account_id` y `subscription_id`
* Considera el hostname para asignar el **producto**

Si se elimina un usuario de la base de platform, se pierden todas las dimensiones asociadas a esa respuesta.


{% enddocs %}
