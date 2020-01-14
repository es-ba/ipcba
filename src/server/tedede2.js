"use strict";

function elemento_existente(id_elemento){
    "use strict";
    var elemento=document.getElementById(id_elemento);
    if(!elemento){
        throw new Error("no existe el elemento "+id_elemento);
    }
    return elemento;
}

function validar_un_parametro(parametros_recibidos_en_la_funcion, nombre, definicion){
"use strict";
/* auxiliar de controlar_parametros */
    if(definicion instanceof Object && definicion.validar && parametros_recibidos_en_la_funcion.hasOwnProperty(nombre) && parametros_recibidos_en_la_funcion.nombre!=undefined){
        var opciones_de_validacion=definicion.validar;
        /*
        if(is_array($opciones_de_validacion)){
            $funcion_validadora=@$opciones_de_validacion['funcion'];
            if($opciones_de_validacion['instanceof'] && !is_a($parametros_recibidos_en_la_funcion[$param],$opciones_de_validacion['instanceof'])){
                throw new Exception_Parametro_con_nombre_invalido(
                    " es ".
                    (@get_class($parametros_recibidos_en_la_funcion[$param])?:gettype($parametros_recibidos_en_la_funcion[$param])).
                    ", no es  ".$opciones_de_validacion['instanceof']);
            }
        }else*/{
            var funcion_validadora=opciones_de_validacion;
        }
        if(!funcion_validadora(parametros_recibidos_en_la_funcion[nombre])){
            throw new Error(JSON.stringify(parametros_recibidos_en_la_funcion[nombre])+" no es valido para "+nombre);
        }
    }
    if(!parametros_recibidos_en_la_funcion.hasOwnProperty(nombre)){
        var valor_por_defecto=definicion instanceof Object?definicion.def:definicion;
        parametros_recibidos_en_la_funcion[nombre]=valor_por_defecto;
    }
}

function controlar_parametros(parametros_recibidos_en_la_funcion, definicion_de_parametros){
"use strict";
    for(var nombre_definido in definicion_de_parametros){ if(definicion_de_parametros.hasOwnProperty(nombre_definido)){
        if(!definicion_de_parametros.hasOwnProperty(nombre_recibido)){
            validar_un_parametro(parametros_recibidos_en_la_funcion,nombre_definido,definicion_de_parametros[nombre_definido]);
        }
    }}
    for(var nombre_recibido in parametros_recibidos_en_la_funcion){ if(parametros_recibidos_en_la_funcion.hasOwnProperty(nombre_recibido)){
        if(!definicion_de_parametros.hasOwnProperty(nombre_recibido)){
            throw new Error("falta el parametro "+nombre_recibido+" en la definicion de parametros de "+JSON.stringify(controlar_parametros));
        }
    }}
}

function enviar_a_procesar(params){
"use strict";
    controlar_parametros(params,{
        proceso:null,
        campos:{validar:es_objeto},
        cuando_ok:{validar:es_funcion},
        cuando_error:{validar:es_funcion},
        cuando_un_paso:{validar:es_funcion},
        elemento_boton:{validar:es_elemento},
        voy_por:null,
        estado:null,
        impresion:{validar:es_booleano}
    });
    /*
    var elemento_rta=elemento_existente('proceso_formulario_respuesta');
    if(!params.voy_por){
        proceso_comenzo=new Date();
    }
    var frase_procesando='procesando desde '+proceso_comenzo.getHours()+':'+proceso_comenzo.getMinutes()+':'+proceso_comenzo.getSeconds();
    if(!params.voy_por){
        elemento_rta.innerHTML=frase_procesando;
        elemento_rta.style.backgroundColor='cyan';
    }
    var poner_mensaje=function(mensaje,en_vez_de_poner_hacer_esto,color,cuando_un_paso){
        if(cuando_un_paso){
            cuando_un_paso(mensaje);
        }
        if(en_vez_de_poner_hacer_esto && (!mensaje || !mensaje.parcial)){
            en_vez_de_poner_hacer_esto(mensaje);
        }else{
            elemento_rta.style.backgroundColor=color;
            if(es_objeto(mensaje)){
                if(mensaje.tipo=='html'){
                    elemento_rta.innerHTML=mensaje.html;
                    if(mensaje.js_indirecto){
                        setTimeout(mensaje.js_indirecto,500);
                    }
                }else if(mensaje.parcial){
                    elemento_rta.innerHTML=frase_procesando+'<BR>'+JSON.stringify(mensaje.parcial).small()+'<BR>'+JSON.stringify(mensaje.estado).small();
                    elemento_rta.style.backgroundColor='cyan';
                    params.voy_por=mensaje.parcial;
                    params.estado=mensaje.estado;
                    enviar_a_procesar(params);
                }else if(mensaje.tipo=='tedede_cm'){
                    elemento_rta.innerHTML='';
                    //elemento_rta.style.backgroundColor='';
                    var contenido;
                    domCreator.show_exceptions=proceso_encuesta_respuesta;
                    if('pre_procesar' in mensaje){
                        contenido=window[mensaje.pre_procesar](mensaje.tedede_cm);
                    }else{
                        contenido=mensaje.tedede_cm;
                    }
                    domCreator.grab(elemento_rta,contenido);
                }else{
                    elemento_rta.textContent=JSON.stringify(mensaje);
                }
                if(document.getElementById('boton_exportar')){
                    boton_exportar.style.visibility='visible';
                   // boton_exportar.href="data:text/csv;base64," + btoa(html.begin+elemento_rta.innerHTML+html.end);
                    boton_exportar.href="data:application/vnd.ms-excel;base64," + btoa(html.begin+elemento_rta.innerHTML+html.end);
                    boton_exportar.download="exportar.xls";
                }
            }else{
                elemento_rta.textContent=mensaje;
            }
        }
        if(!es_objeto(mensaje) || !mensaje.parcial){
            params.elemento_boton.disabled=false;
        }
    }
    var parametros_para_el_paquete=params.campos.valores||obtener_arreglo_asociativo_con_valores_de_elementos(params.campos);
    if(params.impresion){
        ir_a_url(location.pathname+'?imprimir='+params.proceso+'&todo='+encodeURIComponent(JSON.stringify(parametros_para_el_paquete)));
    }else{
        params.elemento_boton.disabled=true;
        enviar_paquete({
            proceso:params.proceso,
            paquete:parametros_para_el_paquete,
            cuando_ok:function(mensaje){ poner_mensaje(mensaje,params.cuando_ok,'lightGreen',params.cuando_un_paso); },
            cuando_error:function(mensaje){ poner_mensaje(mensaje,params.cuando_error,'yellow'); },
            usar_fondo_de:params.elemento_boton,
            voy_por:params.voy_por,
            estado:params.estado,
            asincronico:true
        });
    }*/
}

function proceso_formulario_boton_ejecutar(proceso,id_boton,campos,cuando_ok,cuando_error,impresion,cuando_un_paso){
    enviar_a_procesar({
        proceso:proceso, 
        elemento_boton:elemento_existente(id_boton), 
        campos:campos, 
        cuando_ok:cuando_ok, 
        cuando_error:cuando_error, 
        cuando_un_paso:cuando_un_paso, 
        impresion:impresion 
    });
}
