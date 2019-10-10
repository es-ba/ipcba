# Altas y bajas del cálculo

## Análisis

En el cálculo del IPC los precios faltantes se imputan ([ver imputacion](imputacion.md)). 
cuando un negocio cierra o deja de vender un cierto producto sería un problema imputarlo por siempre. 

Si bien los encuestadores anotan cuando un negocio cierra en forma definitiva o se deja de vender un producto, 
puede ocurrir que en una supervisión o en una visita posterior el cierre no fuera definitivo o el producto
no se había dejado de vender. 

Se necesita un mecanismo flexible que permita seguir imputando un producto mientras se busca un reemplazo
o que deje de imputarlo inmediatamente cuando de decida no reemplazarlo 
o que espere (imputándolo) un tiempo prudencial por si vuelve a aparecer el producto en el mismo negocio. 

## Altas y bajas de la muestra vs entradas y salidas del cálculo

Hay que diferencias dos conceptos:
   * las altas y bajas de la muestra, que implican que se salga a relevar a campo cierto precio
   * las entradas y salidas del cálculo, si se considera ese precio para el cálculo o se lo imputa cuando falta. 

Cuando se incorpora un negocio a la muestra los precios que traen podrían no incorporarse al cálculo en forma inmediata, esperar para incorporarlos permite supervisar los precios y
analizar el comportamiento del informante en las siguientes visitas. 
En el parámetro *cantperaltaauto* se indica cuántos meses se esperará antes de que los precios nuevos de ese producto entren al cálculo. Manualmente se puede hacer que los precios entren antes o después. 

Cuando un negocio cierra o el producto se deja de vender el sistema puede seguir imputándolo
automáticamente la cantidad de períodos indicada en el parámetro *cantperbajaauto*. 
(La cantidad de períodos en que un precio se impute podría ser mayor si el producto entra en un período estacional). 
Manualmente se le puede indicar al sistema que se deje de imputar o considerar en el cálculo o 
que se exitenda el período de imputación más allá del parámetro *cantperbajaauto*. 

Las altas y bajas del cálculo son a nivel de la tabla *calobs*.

## Altas y bajas manuales del cálculo

Para indicar un alta o una baja manual del cálculo, el usuario autorizado debe agregar un registro en la tabla *novobs* indicando si es un *'Alta'* o *'Baja'*. El registro debe indicar en qué período se produce la novedad. 

Las altas y bajas manuales tienen prioridad sobre los criterios automáticos de altas y bajas. 

## Altas y bajas automáticas del cálculo

Las altas y bajas automáticas están reguladas por 4 parámetros de la tabla *productos* y *calculo* y 5 campos de la tabla *calobs*
   * parámetros de altas y bajas:
      * *cantperaltaauto*: Cantidad de períodos consecutivos con precio a esperar para un alta automática
      * *cantperbajaauto*: Cantidad de perídoos consecutivos sin precio a esperar (y seguir imputando) antes de una baja automática
      * *umbralbajaauto*: Cantidad de precios bajo el cual un producto se considera en período estacional (o especial). Este parámetro es uno por cada tipo de informante en que se relevan precios del prodcuto (se encuentra en la tabla *proddiv*)
      * *esperiodobase*: Indica si un período se considera *periodo base* en cuyo caso tampoco se realizan altas y bajas automáticas.
   * campos de control en la tabla *calobs*
      * *antiguedadconprecio*: cantidad de períodos consecutivos con precio (o null si no tiene precio)
      * *antiguedadsinprecio*: cantidad de períodos consecutivos sin precio (o null si tiene precios)
      * *sindatosestacional*: cantidad de períodos dentro de los períodos consecutivos sin precio que se consideran estacionales (o especiales). 
      * *antiguedadexcluido*: cantidad de períodos en que el renglón de *calobs* no se excluye del cálculo
      * *antiguedadincluido*: cantidad de períodos en que el renglon de *calobs* está incluido en el cálculo

## Valores de los parámetros

   * *cantperaltaauto*:
      * Con **2** el sistema espera a tener dos períodos consecutivos con precio para incluirlo. Esto le da tiempo al supervisor a ver qué tan estable es un informante nuevo al ver cómo se comportan sus variaciones en el segundo período.
      * Un valor más alto para *cantperaltaauto* permite, en ciertos productos (con poca muestra o heterogéneos con alta disperción en los precios), un análisis más profundo o tener la oportunidad de tener el precio en reserva para en forma manual para los productos 
   * *cantperbajaauto*:
      * Con **3** el sistema espera al tercer período sin precio para darlo de baja, esto permite buscar un reemplazante al informante que cierra dentro de un tiempo prudencial. 
      * Un valor más alto permite, en ciertos productos de baja muestra o de precios heterogéneos buscar un reemplazante hasta encontrarlo. 
   * *umbralbajaauto* 
      * podría tener un número que sea entre un 10 y un 25% de la cantidad de precios que habitualmente hay para ese producto y tipo de informante. Este umbral debe actualizarse cuando cambien los tamaños reales de la muestra (ya sea cuando se refuerce y se agrande la muestra o cuando se achique por desgaste de la misma)
      * el riesgo de poner un número muy alto es que podría estar 12 meses por debajo del umbral dejando de activarse el mecanismo de altas y bajas automáticas y si no se hace el mantenimiento manual de altas y bajas se podrían estar imputando precios innecesariamente. 


