/* UTF-8:Sí
   comunes.js
*/
"use strict";

function elemento_existente(id_elemento){
    "use strict";
    var elemento=document.getElementById(id_elemento);
    if(!elemento){
        throw new Error("no existe el elemento "+id_elemento);
    }
    return elemento;
}

function descripcionError(err){
"use strict";
    /* usado para mostrar el mensaje de error de cualquier excepción */
    if(typeof(err)=='string'){
        return err;
    }else{
        //var debugging=true;
        var debugging=false;
        return err.message+(debugging?' '+err.stack:'');
    }
}


function trim(esto) {
"use strict";
    if(esto==null || esto==undefined || typeof esto!="string"){
        return esto;
    }
    return esto.replace(/^\s+|\s+$/g, '');  
}

function ir_a_url(direccion,reemplazando){
    if(reemplazando){
        window.location.replace(direccion);
    }else{
        window.location.href=direccion;
    }
}
function ir_a_otra_url(direccion){
    window.open(direccion);
}

function descripciones_de_error(err){
"use strict";
    /* usado para mostrar el mensaje de error de cualquier excepción */
    var mensaje=' '+(err.description||'')+' '+(err.message||'')+' '+(err.type_error||'');
    if(!trim(mensaje)){
        mensaje=JSON.stringify(err);
    }
    return mensaje;
}

function cambiandole(destino,cambios,borrando,borrar_si_es_este_valor){
"use strict";
    if(destino instanceof Object && !(destino instanceof Date) && !(destino instanceof Function) && (!(cambios instanceof Array) || cambios.length>0)){
        var respuesta={};
        for(var campo in destino) if(destino.hasOwnProperty(campo)){
            var cambio=cambios[campo];
            if(!(campo in cambios)){
                respuesta[campo]=destino[campo];
            }else if(borrando && cambio===borrar_si_es_este_valor){
            }else{
                respuesta[campo]=cambiandole(destino[campo],cambio,borrando,borrar_si_es_este_valor);
            }
        }
        for(var campo in cambios) if(cambios.hasOwnProperty(campo)){
            var cambio=cambios[campo];
            if(!(campo in destino) && (!borrando || !(cambio===borrar_si_es_este_valor))){
                respuesta[campo]=cambio;
            }
        }
        return respuesta;
    }else{
        if(cambios==undefined){
            return destino;
        }else{
            return cambios;
        }
    }
}

function estoMismo(estoMismoDevuelvo){
    return estoMismoDevuelvo;
}

function borrar_localStorage(forzar){
"use strict";
    if(forzar || confirm('¿borrar localStorage?')){
        localStorage.clear();
        if(!forzar){
            alert('borrado');
        }
    }
}

function guardar_en_localStorage(clave, valor){
"use strict";
    localStorage.removeItem(clave);
    localStorage.setItem(clave, valor); 
}

function guardar_en_sessionStorage(clave, valor){
"use strict";
    sessionStorage.removeItem(clave);
    sessionStorage.setItem(clave, valor); 
}

function traer_de_sessionStorage(clave){
    return sessionStorage.getItem(clave);
}
function traer_de_localStorage(clave){
    return localStorage.getItem(clave);
}


function para_ordenar_numeros(texto_con_numeros){
"use strict";
    var rta='';
    var numero='';
    var despues_de_la_coma=false;
    texto_con_numeros+=' ';
    for(var i=0; i<texto_con_numeros.length; i++){
        var letra=texto_con_numeros[i];
        if(letra.match(/[0-9]/)){
            if(despues_de_la_coma){
                rta+=letra;
            }else{
                numero+=letra;
            }
        }else{
            despues_de_la_coma=letra=='.';
            if(numero){
                while(numero.length>0 && numero[0]=='0'){
                    numero=numero.substr(1);
                }
                rta+=String.fromCharCode(64+numero.length)+numero;
                numero='';
            }
            rta+=numero+letra;
        }
    }
    return rta.toLowerCase();
}

function iterable(indice, objeto_o_lista_o_arreglo){
    return objeto_o_lista_o_arreglo.hasOwnProperty(indice) &&
        (!(objeto_o_lista_o_arreglo instanceof HTMLCollection 
           || objeto_o_lista_o_arreglo instanceof NodeList
           || 'TouchList' in window && objeto_o_lista_o_arreglo instanceof TouchList
           ) || !isNaN(indice));
}

function obtener_top_global(elemento){
"use strict";
    var posicion_global = 0;
    while( elemento != null ) {
        posicion_global += elemento.offsetTop;
        elemento = elemento.offsetParent;
    }
    return posicion_global;
}

function obtener_left_global(elemento){
"use strict";
    var posicion_global = 0;
    while( elemento != null ) {
        posicion_global += elemento.offsetLeft;
        elemento = elemento.offsetParent;
    }
    return posicion_global;
}

function al_menos_uno_lleno_con_dato_uno(arreglo){
"use strict";
    var al_menos_uno=false;
    var cont=0;
    for(var fila in arreglo) if(iterable(fila,arreglo)){
        if (arreglo[fila]==1){
            cont++;
        }
    }
    if(cont>0){
        al_menos_uno=true;
    }  
    return al_menos_uno;
}

function centrar_en_vertical(elemento){
    var pos_v=obtener_top_global(elemento);
    window.scrollTo(0,pos_v-(window.innerHeight-elemento.offsetHeight)/2);
}

function empieza_con(frase,prefijo){
    return frase.indexOf(prefijo)==0;
}

function quitar_prefijo(frase,prefijo){
    if(!empieza_con(frase,prefijo)){
        throw new Error("No se pudo quitar el prefijo "+prefijo+" de "+frase);
    }
    return frase.substr(prefijo.length);
}

function cambiar_prefijo(dato, que, por_cual){
"use strict";
    if(es_objeto(dato)){
        var dato_completo={};
        for(var campo in dato) if(iterable(campo,dato)){
            var valor=dato[campo];
            var dato_cambiado=por_cual+quitar_prefijo(campo,que);
            dato_completo[dato_cambiado]=valor;
        }
    }else{
        var dato_completo=por_cual+quitar_prefijo(dato,que);          
    }
    return dato_completo;
}

function ponerle_claves(arreglo_valores_sin_claves,arreglo_de_claves_valores_por_defecto){
"use strict";
    // devuelve el arreglo de pares [claves=>valores o valores_por_defecto]
    var i=0;
    var devolvere={};
    for(var campo in arreglo_de_claves_valores_por_defecto){
        var valor_por_defecto=arreglo_de_claves_valores_por_defecto[campo];
        // if(valor_por_defecto instanceof Object && forzar_valor in valor_por_defecto){
        if(valor_por_defecto instanceof Object && 'forzar_valor' in valor_por_defecto){
            devolvere[campo]=valor_por_defecto.forzar_valor;
        }else if(arreglo_valores_sin_claves[i]!=undefined){
            devolvere[campo]=arreglo_valores_sin_claves[i];
        }else{
            devolvere[campo]=valor_por_defecto;
        }
        i++;
    }
    return devolvere;
}

function array_keys(objeto_asociativo) {
"use strict";
    var rta=[];
    for (var clave in objeto_asociativo) if(iterable(clave,objeto_asociativo)){
        rta.push(clave);
    }
    return rta;
}

function in_array(elemento, arreglo) {    
    for(var i = 0; i < arreglo.length; i++) {
        if(arreglo[i] == elemento) return true;
    }
    return false;
}

function si_no_es_nulo(dato){
    if (dato){
        return dato+' ';
    }else{
        return '';
    }
}

if (!Array.prototype.reduce)
{
  Array.prototype.reduce = function(fun /*, initial*/)
  {
    var len = this.length;
    if (typeof fun != "function")
      throw new TypeError();

    // no value to return if no initial value and an empty array
    if (len == 0 && arguments.length == 1)
      throw new TypeError();

    var i = 0;
    if (arguments.length >= 2)
    {
      var rv = arguments[1];
    }
    else
    {
      do
      {
        if (i in this)
        {
          rv = this[i++];
          break;
        }

        // if array contains no values, no initial value to return
        if (++i >= len)
          throw new TypeError();
      }
      while (true);
    }

    for (; i < len; i++)
    {
      if (i in this)
        rv = fun.call(null, rv, this[i], i, this);
    }

    return rv;
  };
}

/*
var las_cookies=document.cookie.split(';').reduce(function(acumular,elemento){ var partes=elemento.split('='); acumular[partes[0]]=unescape(partes[1]); return acumular;   },{});

if(!"quiere ver siempre las cookies en el primer renglon para debuguear"){
    window.addEventListener('load',function(){
        setTimeout(function(){
            document.body.insertBefore(document.createTextNode(JSON.stringify(las_cookies)),document.body.childNodes[0]);
        },1000);
    });
}
*/
function buscarPadre(elemento,caracterizador){
    var funcionDetencion=is_function(caracterizador)?caracterizador:function(elemento){ return elemento.tagName==caracterizador};
    while(elemento.parentNode && !funcionDetencion(elemento.parentNode)){ 
        elemento=elemento.parentNode;
    }
    return elemento.parentNode;
}

function fechaAmd(cadenaAnnoMesDia){
    return new Date(cadenaAnnoMesDia);
}

function is_object (mixed_var) {
  // http://kevin.vanzonneveld.net
  // +   original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  // +   improved by: Legaev Andrey
  // +   improved by: Michael White (http://getsprink.com)
  // *     example 1: is_object('23');
  // *     returns 1: false
  // *     example 2: is_object({foo: 'bar'});
  // *     returns 2: true
  // *     example 3: is_object(null);
  // *     returns 3: false
  if (Object.prototype.toString.call(mixed_var) === '[object Array]') {
    return false;
  }
  return mixed_var !== null && typeof mixed_var === 'object';
}

function is_array(x){
    return x instanceof Array;
}

function is_string(x){
    return typeof x=='string';
}

function is_bool(x){
    return typeof x=='boolean';
}

function is_function(x){
    return x instanceof Function;
}

function is_dom_element(x){
    return x instanceof HTMLElement;
}

function is_dom_element_or_id(x){
    return x instanceof HTMLElement?x:(typeof x=='string'?document.getElementById(x):null);
}

//if(window.rutaImagenes===undefined) window.rutaImagenes='../imagenes/'; // !QApred

function seleccionar_campos(objeto,campos_copiar){
    var rta={};
    for(var i=0; i<campos_copiar.length; i++){
        rta[campos_copiar[i]]=objeto[campos_copiar[i]];
    }
    return rta;
}

function seleccionar_campos_array(objeto,campos_copiar){
    var rta=[];
    for(var i=0; i<campos_copiar.length; i++){
        var valor=objeto[campos_copiar[i]];
        rta.push(trim(valor)===''?null:valor);
    }
    return rta;
}

function boolint(expresion_booleana){
    return expresion_booleana?1:0;
}

function dosCifras(i){
    if(i<10){
        return '0'+i;
    }else{
        return ''+i;
    }
}

var TIME_ZONE_STR=function(){
    var dtz=new Date(); // para averiguar el TIME-ZONE
    var tzo=dtz.getTimezoneOffset(); // 180
    if(tzo<0){
        var signo='+';
        tzo=-tzo;
    }else{  
        var signo='-';
    }
    var min=tzo%60;
    var horas=Math.floor(tzo/60);
    return signo+dosCifras(horas)+dosCifras(min);
}();

function CrearFechaDesdeTextoISO(texto){
    if(texto.length!=10) throw new Error('Preparado solo para una fecha ISO sin hora');
    var partes=texto.split(/[/-]/g);
    return new Date(Number(partes[0]),partes[1]-1,Number(partes[2]));
}

function interpretarTrue(valor){
    return !!valor && valor!=="0";
}

// para expres habilita:   boolint(sn1a=1)+boolint(sn1b=1)+boolint(sn1c=1)+boolint(sn1d=1)+boolint(sn1e=1)+boolint(sn1f=1)>1

function fecha_amd_hora_hms(){
    var vdate= new Date();
    return  formatearFecha(vdate) +' '+vdate.getHours()+":"+vdate.getMinutes()+":"+vdate.getSeconds() ; 
}