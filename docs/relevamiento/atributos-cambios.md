# Atributos y cambios en sus valores

En los valores de atributos se encuentra el valor correspondiente al útimo precio ingresado.
O sea:
   * si en el mes actual hay precio observado los valores corresponden a ese,
   * si en el mes actual no hay precio (ya sea por un tipo de precio negativo o una razón de visita negativa) el valor atributo corresponde al último visto.

Los atributos pueden tener algunas de las siguientes caracerísticas:
   * obligatorios: por ejemplo los que corresponden a atributos que normalizan el precio
   * no modificables: por ejemplo ponderadores internos del producto
   * numéricos: solo aceptan números

## objetivo

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




