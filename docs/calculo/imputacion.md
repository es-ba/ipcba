# imputación

En el cálculo del IPC los precios se imputan, 
si no se imputaran los precios faltantes habría un movimiento artificial del índice del producto. 

La imputación se realiza a nivel de [observación](observacion.md). 

> La imputación consiste en multiplicar el precio observado (o imputado) el mes anterior
  por el factor de imputación que le corresponda.

## marcas de imputación

Cuando un precio es imputado se lo marca en la base de datos con su señal de imputado. 
Esa marca indica en qué fase se imputó el precio. 
Cuando los precios se promedian la marca de imputación sube, 
el promedio se marca con la última señal de imputación que se haya recibido en el grupo promediado. 

Las marcas de imputación están ordenadas alfabéticamente en orden inverso, 
se ponen primero las marcas más cerca de la Z (empezando por **IP** imputación por los pares) 
y luego se sigue avanzando hacia la A (por ejemplo, **IG5** es imputación por grupo de nivel 5). 
Entonces si en un promedio se tienen precios **IP** y precios **IG5** la marca que lleva el promedio es **IG5**. 

Los promedios no se marcan ninguno de los precios promediados fue imputado. 

## **división** de los precios de un producto por tipo de informante

Una gran cantidad de productos se releva tanto en supermercados como en negocios tradicionales. 
Los precios se promedian dividiéndolos en estos dos grupos. 

> Dentro del Sistema Informático llamamos **división** a la división que se usa para hacer el primer promedio de precios de los productos

A los efectos definir la imputación **división** se puede usar como sinónimo de tipo de negocio. 
En casos especiales el sistema podría usarse en otra situación para productos que tengan más de dos **divisiones**.

Atención:
   1. no debe confundirse la **división** de los promedios de los productos según su tipo de informante
      con el nombre que se le dio a la primera clasificación de productos en 12 divisiones según la COICOP
      (dentro del sistema a esa división se la llama grupo de nivel 1).
   2. una vez establecidas las **divisiones** internas a los productos (según su tipo de negocio) 
      los ponderadores quedan fijo para toda la vida del índice. 

# fases de la imputación

## primera imputación (imputación por los pares)

Si la cantidad de precios relevados de un producto es _suficiente_ (para cierta división)
los precios faltantes se imputan por el promedio de la variación observada de los otros precios
de ese producto en esa división. **IP**: `imputación por los pares`.

Precisando, si hay precios faltantes se cuenta la cantidad de precios relevados que tengan
en el período anterior un precio informado o imputado. 
Si esa cantidad supera el _umbral de primera imputación_ definido para ese producto y división
se utiliza como factor de imputación el promedio geométrico simpe de los cocientes entre los precios del mes actual y del anterior
para los precios que sean positivos tanto en el mes actual como en el anterior. 

Si a cantidad de precios relevados es _suficiente_ en una división del producto y no en otra
los precios de la división no _suficiente_ se imputan con el promedio de la división _suficiente_. **IOD**: `imputación por otra división`. 

## segunda imputación (imputación por nivel superior)

Cuando las observaciones no pueden imputarse por los pares (por no haber precios suficientes) 
se utiliza como factor de imputación la variación del grupo al que pertenece el producto en cuestión. 
Por ejemplo, si no hay sufciente cantidad de precios de _yogurt_ 
este podría imputarse con la variación de los _lácteos_. 

Para ello es necesario conocer la variación de los grupos, 
pero aún no se pueden calcular los índices de todos los productos (porque faltan las imputaciones). 
Entonces lo que se hace es calcular un **índice preliminar** para todos los productos y grupos que se puedan
(o sea los que no necesitan imputar o se hayan podido imputar con sus pares).

### cálculo del índice preliminar
   1. Para cada producto se calcula promedios preliminares del mes actual y del anterior con las observaciones positivas en ambos meses.
   2. Se calculan los índices preliminares del producto multiplicando por el cociente de los promedios preliminares. 
   3. Se agregan hacia los grupos superiores excluyendo los productos y grupos que no tengan datos de primera fase.
   4. Se seleccionan los factores de imputación del grupo superior correspondiente.

### imputación según _umbral de descarte_

Si se llegó a la segunda imputación es porque la cantidad de precios no es suficiente 
para obtener una _variación de precios_ representativa del producto (y por lo tanto para imputar los restantes). 
Todavía falta decidir si los precios relevados son _suficientes_ para representarse a sí mismos. 
Si no lo son, los precios observados del producto se imputan; en cambio si son suficientes solo se imputan los precios faltantes.

Precisando, cuando la cantidad de precios de una división de un producto esté por debajo del _umbral de descarte_
todos los precios de esa división se imputarán, tanto los faltantes como los observados (que se consideran descartados).
Cuando la cantidad de precios observados esté por arriba del _umbral de descarte_ solo se imputarán los precios faltantes. 

El factor de imputación usado es el cociente de los índices preliminares del nivel superior. 

# Cálculo definitivo

Finalizadas las imputaciones se procede a calcular los promedios y los índices definitivos. 