# Atributos y cambios en sus valores en el DM 2.0

En vistas de la inmminente implementación de la versión 2.0 del desarrollo en Dispositivo Móvil del relevamiento del IPCBA
es oportuno revisar la cuestión de los cambios en los valores de atributos. 

En los valores de atributos se encuentra el valor correspondiente al útimo precio ingresado.
O sea:
   * si en el mes actual hay precio observado los valores corresponden a ese,
   * si en el mes actual no hay precio (ya sea por un tipo de precio negativo o una razón de visita negativa) el valor atributo corresponde al último visto.

Los atributos pueden tener algunas de las siguientes caracerísticas:
   * obligatorios: por ejemplo los que corresponden a atributos que normalizan el precio
   * no modificables: por ejemplo ponderadores internos del producto
   * numéricos: solo aceptan números

# Antecedentes

## relevamiento en papel

El relevamiento en el IPCBA se hizo en papel desde 2008 (empezando por su antecedente el relvamiento de precios para canstas de consumo), 
en 2010 se comienza con un relevamiento continuo de precios con formularios
que mostraban al encuestador el valor anterior de los atributos del producto 
(de modo que pudiera, si había buscar el precio de exactamente el mismo artículo). 

El encuestador debía colocar junto al precio una "C" de cambio si cambiaba alguno de los atributos. 
Y colocaba una comilla en caso de que no cambiara ninguno.

El ingresado de datos en el sistema informático colocaba una "C" en el casillero correspondiente,
de ese modo el sistema habilitaba los campos para el cambio de valores de atributos. 
Cuando no hubiera cambio dejaba el casillero de cambio en blanco y cursor saltaba al siguiente producto/observación. 
En este caso el sistema informático copiaba los valores de los atributos del mes anterior 
(lo mismo hacía si se indicaba un tipo de precio negativo o si el formulario no se había podido relevar en el período). 

## relevamiento en dispositivo móvil

En 2019 se comienza con el relevamiento de precios en dispositivo móvil para el IPCBA con un desarrollo propio. 
El uso del dispositivo móvil fue un avance en la calidad y oportunidad de la información gracias a los controles digitales en el punto de captura
y a la consolidación inmediata de la información en la base de datos centralizada. 

Respecto a los cambios de atributos el encuestador debe ingresar primero el precio y
luego debe indicar si los atributos son los mismos o si tiene que cambiarlos (para luego proceder a cargar los valores que hayan cambiado).

Respecto a las primeras visitas a informantes (negocios nuevos en la muestra), 
el encuestador debe relevar una cantidad mucho mayor de atributos que en relevamiento normal (donde la tasa de cambio es del orden del 10%). 
Entonces para las primeras visitas se le da la opción al encuestador de hacer el relevamiento en formularios en papel. 

## mejoras al DM 1.0

Para el desarrollo del DM 1.0 se eligieron una serie de características funcionales 
para obtener lo antes posible una primera versión del sistema que fuera una mejora sustancial respecto al relevamiento en papel. 

Entre las mejoras planificadas para el DM 2.0 se incluye:
   1. la posibilidad de que el encuestador consigue los valores de los atributos antes de cargar el precio. 
   2. el uso de la misma pantalla del DM 2.0 en el sistema de escritorio para el ingreso eventual de formulario en papel
      y para los roles de recepción y análisis (con los agregados en la pantalla que se necesitan para esas tareas).

# Plan para el DM 2.0

## objetivos

Ordenados por prioridad. 
   1. En la base de datos debe almacenarse información consistente. 
   2. El encuestado debe poder interrumir su trabajo y guardar en cualquier parte de su tarea. 
      Las excepciones deben ser mínimas y puntuales (por ejemplo no debe poder almacenarse tipo de precio positivo sin precio); 
      estas excepciones no deben ser un obstáculo durante el trabajo del encuestador o ingresador. 
   3. Cuando el encuestador releve un precio cuyos atributos no cambien 
      debe marcar explícitamente que los atributos no cambiaron. 
      El objetivo de esto es diferenciarlo de un olvido, omisión 
      o error en el posicionamiento debida a la interrupción del trabajo y posterior continuación

## situaciones particulares
   1. El mes anterior algún atributo con valor
      1. No ingresó el precio. Ve la flecha de copiar activa
      2. Pone un precio positivo. Ve la flecha de copiar activa
      3. Indica que los atributos son los mismo. Ve un signo igual
      4. Cambia un atributo. Ve una *C* que puede desplegar el menú de completar atributos
   2. Igual pero poniendo los atributos antes que el precio
      1. Copia los atributos con la flecha antes de ingresar el precio. Ve un "="
      2. Cambia un atributo. Ve una *C* que puede desplegar el menú de completar atributos
      3. Ingresa el precio.
   3. El mes anterior no hay atributos con valor
      1. No ingresó el precio. No hay flecha
      2. Ingresó el precio. No hay flecha
      3. Ingresa un atributo. Ve una *C*




