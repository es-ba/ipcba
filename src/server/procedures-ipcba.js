"use strict";

const SOLO_PARA_DEMO_DM=false;

var likeAr = require('like-ar');
var pg = require('pg-promise-strict');
pg.easy=true;

var fs = require('fs-extra');

var MiniTools = require('mini-tools');
//var Comunes = require('./comunes');
//var Tedede = require('./tedede2');

var bestGlobals = require('best-globals');
var http = require('http');

var datetime = bestGlobals.datetime;
var timeInterval = bestGlobals.timeInterval;

var JSON4all = require('json4all');

const periodo_inicial = 'a2012m07';
const agrupacion = 'E';

const CALCULO_ACTION = 'fechacalculo_touch';
const PERIODO_BASE_CORRER_ACTION = 'periodobase_correr';

const ESPECIFICACION_COMPLETA=`
    CONCAT_WS(' ',
        trim(e.nombreespecificacion)|| '.',
        NULLIF(TRIM(
            COALESCE(trim(e.envase)||' ','')||
            CASE WHEN e.mostrar_cant_um='N' THEN ''
            ELSE COALESCE(e.cantidad::text||' ','')||COALESCE(e.UnidadDeMedida,'') END),'')|| '.',
        (SELECT string_agg(
                    CASE WHEN a.tipodato='N' AND a.visible = 'S' AND t.rangodesde IS NOT NULL AND t.rangohasta IS NOT NULL THEN 
                        CASE WHEN t.visiblenombreatributo = 'S' THEN a.nombreatributo||' ' ELSE '' END||
                            'de '||t.rangodesde||' a '||t.rangohasta||' '||COALESCE(a.unidaddemedida, a.nombreatributo, '')
                        ||CASE WHEN t.alterable = 'S' AND t.normalizable = 'S' AND NOT(t.rangodesde <= t.valornormal AND t.valornormal <= t.rangohasta) THEN ' ó '||t.valornormal||' '||a.unidaddemedida ELSE '' END||'. '
                    ELSE ''
                    END,
                    '' 
                    ORDER BY t.orden
                )
            FROM prodatr t INNER JOIN atributos a USING (atributo)
            WHERE t.producto=p.producto
        ),
        'Excluir ' || trim(e.excluir) || '.'
    ) AS EspecificacionCompleta
`

var ProceduresIpcba = {};
var cuadro = [];

function json(sql, orderby){
    return `COALESCE((SELECT jsonb_agg(to_jsonb(j.*) ORDER BY ${orderby}) from (${sql}) as j),'[]'::jsonb)`
}

function jsono(sql, indexedby){
    return `COALESCE((SELECT jsonb_object_agg(${indexedby},to_jsonb(j.*)) from (${sql}) as j),'{}'::jsonb)`
}

//----------------------FUNCIONES AUXILIARES-------------------------------------------------------------------------
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

/* PHP
$poner_parte=function($parte,$tipo) use ($fila,&$cuadro){
    $nodes=array();
    foreach(explode('|||',$fila->{$parte}) as $renglon){ //$fila->{$parte}: referencia la propiedad {$parte} del objeto $fila
        $renglon=trim($renglon);
        $nodes[]=array('tipox'=>'p', 'nodes'=>array(
            'tipox'=>strlen($renglon)<13?$tipo:'span',
            'nodes'=>$renglon
        ));
    }
    $cuadro[]=array('tipox'=>'div', 'className'=>'cuadro_'.$parte, 'nodes'=>$nodes);
};
*/
function poner_parte(parte,tipo,fila){
    var nodes=[];
    var renglones=fila.split('|||');
    renglones.forEach(function(renglon){
        renglon=renglon.trim();
        console.log('renglon: ', renglon);
        console.log('renglon.length: ', renglon.length);
        nodes.push({'tipox':'p', 'nodes':{"tipox":(renglon.length<13)?tipo:"span","nodes":renglon}});
    });
    cuadro.push({"tipox":"div", "className":"cuadro_"+parte, "nodes":nodes});
    return cuadro;
};

var simplificatedChars={
    "\u00a0":" ",
    "Á":"Á","Ă":"Á","Ắ":"Á","Ặ":"Á","Ằ":"Á","Ẳ":"Á","Ẵ":"Á","Ǎ":"Á","Â":"Á","Ấ":"Á","Ậ":"Á","Ầ":"Á","Ẩ":"Á","Ẫ":"Á","Ä":"Á","Ǟ":"Á","Ȧ":"Á","Ǡ":"Á","Ạ":"Á","Ȁ":"Á","À":"Á","Ả":"Á","Ȃ":"Á","Ā":"Á","Ą":"Á","Å":"Á","Ǻ":"Á","Ḁ":"Á","Ⱥ":"Á","Ã":"Á",
    "Ꜳ":"AA","Æ":"AE","Ǽ":"AE","Ǣ":"AE","Ꜵ":"AO","Ꜷ":"AU","Ꜹ":"AV","Ꜻ":"AV","Ꜽ":"AY",
    "Ḃ":"B","Ḅ":"B","Ɓ":"B","Ḇ":"B","Ƀ":"B","Ƃ":"B",
    "Ć":"C","Č":"C","Ç":"C","Ḉ":"C","Ĉ":"C","Ċ":"C","Ƈ":"C","Ȼ":"C",
    "Ď":"D","Ḑ":"D","Ḓ":"D","Ḋ":"D","Ḍ":"D","Ɗ":"D","Ḏ":"D","ǲ":"D","ǅ":"D","Đ":"D","Ƌ":"D","Ǳ":"DZ","Ǆ":"DZ",
    "É":"É","Ĕ":"É","Ě":"É","Ȩ":"É","Ḝ":"É","Ê":"É","Ế":"É","Ệ":"É","Ề":"É","Ể":"É","Ễ":"É","Ḙ":"É","Ë":"É","Ė":"É","Ẹ":"É","Ȅ":"É","È":"É","Ẻ":"É","Ȇ":"É","Ē":"É","Ḗ":"É","Ḕ":"É","Ę":"É","Ɇ":"É","Ẽ":"É","Ḛ":"É","Ꝫ":"ET",
    "Ḟ":"F","Ƒ":"F",
    "Ǵ":"G","Ğ":"G","Ǧ":"G","Ģ":"G","Ĝ":"G","Ġ":"G","Ɠ":"G","Ḡ":"G","Ǥ":"G",
    "Ḫ":"H","Ȟ":"H","Ḩ":"H","Ĥ":"H","Ⱨ":"H","Ḧ":"H","Ḣ":"H","Ḥ":"H","Ħ":"H",
    "Í":"Í","Ĭ":"Í","Ǐ":"Í","Î":"Í","Ï":"Í","Ḯ":"Í","İ":"Í","Ị":"Í","Ȉ":"Í","Ì":"Í","Ỉ":"Í","Ȋ":"Í","Ī":"Í","Į":"Í","Ɨ":"Í","Ĩ":"Í","Ḭ":"Í",
    "Ꝺ":"D","Ꝼ":"F","Ᵹ":"G","Ꞃ":"R","Ꞅ":"S","Ꞇ":"T","Ꝭ":"IS",
    "Ĵ":"J","Ɉ":"J",
    "Ḱ":"K","Ǩ":"K","Ķ":"K","Ⱪ":"K","Ꝃ":"K","Ḳ":"K","Ƙ":"K","Ḵ":"K","Ꝁ":"K","Ꝅ":"K",
    "Ĺ":"L","Ƚ":"L","Ľ":"L","Ļ":"L","Ḽ":"L","Ḷ":"L","Ḹ":"L","Ⱡ":"L","Ꝉ":"L","Ḻ":"L","Ŀ":"L","Ɫ":"L","ǈ":"L","Ł":"L","Ǉ":"LJ",
    "Ḿ":"M","Ṁ":"M","Ṃ":"M","Ɱ":"M",
    "Ń":"N","Ň":"N","Ņ":"N","Ṋ":"N","Ṅ":"N","Ṇ":"N","Ǹ":"N","Ɲ":"N","Ṉ":"N","Ƞ":"N","ǋ":"N","Ñ":"Ñ","Ǌ":"NJ",
    "Ó":"Ó","Ŏ":"Ó","Ǒ":"Ó","Ô":"Ó","Ố":"Ó","Ộ":"Ó","Ồ":"Ó","Ổ":"Ó","Ỗ":"Ó","Ö":"Ó","Ȫ":"Ó","Ȯ":"Ó","Ȱ":"Ó","Ọ":"Ó","Ő":"Ó","Ȍ":"Ó","Ò":"Ó","Ỏ":"Ó","Ơ":"Ó","Ớ":"Ó","Ợ":"Ó","Ờ":"Ó","Ở":"Ó","Ỡ":"Ó","Ȏ":"Ó","Ꝋ":"Ó","Ꝍ":"Ó","Ō":"Ó","Ṓ":"Ó","Ṑ":"Ó","Ɵ":"Ó","Ǫ":"Ó","Ǭ":"Ó","Ø":"Ó","Ǿ":"Ó","Õ":"Ó","Ṍ":"Ó","Ṏ":"Ó","Ȭ":"Ó","Ƣ":"OI","Ꝏ":"OO","Ɛ":"É","Ɔ":"Ó","Ȣ":"OU",
    "Ṕ":"P","Ṗ":"P","Ꝓ":"P","Ƥ":"P","Ꝕ":"P","Ᵽ":"P","Ꝑ":"P",
    "Ꝙ":"Q","Ꝗ":"Q",
    "Ŕ":"R","Ř":"R","Ŗ":"R","Ṙ":"R","Ṛ":"R","Ṝ":"R","Ȑ":"R","Ȓ":"R","Ṟ":"R","Ɍ":"R","Ɽ":"R",
    "Ꜿ":"C","Ǝ":"É",
    "Ś":"S","Ṥ":"S","Š":"S","Ṧ":"S","Ş":"S","Ŝ":"S","Ș":"S","Ṡ":"S","Ṣ":"S","Ṩ":"S",
    "Ť":"T","Ţ":"T","Ṱ":"T","Ț":"T","Ⱦ":"T","Ṫ":"T","Ṭ":"T","Ƭ":"T","Ṯ":"T","Ʈ":"T","Ŧ":"T",
    "Ɐ":"Á","Ꞁ":"L","Ɯ":"M","Ʌ":"V","Ꜩ":"TZ",
    "Ú":"Ú","Ŭ":"Ú","Ǔ":"Ú","Û":"Ú","Ṷ":"Ú","Ü":"Ü","Ǘ":"Ú","Ǚ":"Ú","Ǜ":"Ú","Ǖ":"Ú","Ṳ":"Ú","Ụ":"Ú","Ű":"Ú","Ȕ":"Ú","Ù":"Ú","Ủ":"Ú","Ư":"Ú","Ứ":"Ú","Ự":"Ú","Ừ":"Ú","Ử":"Ú","Ữ":"Ú","Ȗ":"Ú","Ū":"Ú","Ṻ":"Ú","Ų":"Ú","Ů":"Ú","Ũ":"Ú","Ṹ":"Ú","Ṵ":"Ú",
    "Ꝟ":"V","Ṿ":"V","Ʋ":"V","Ṽ":"V","Ꝡ":"VY",
    "Ẃ":"W","Ŵ":"W","Ẅ":"W","Ẇ":"W","Ẉ":"W","Ẁ":"W","Ⱳ":"W",
    "Ẍ":"X","Ẋ":"X","Ý":"Y","Ŷ":"Y","Ÿ":"Y","Ẏ":"Y","Ỵ":"Y","Ỳ":"Y","Ƴ":"Y","Ỷ":"Y","Ỿ":"Y","Ȳ":"Y","Ɏ":"Y","Ỹ":"Y"
    ,"Ź":"Z","Ž":"Z","Ẑ":"Z","Ⱬ":"Z","Ż":"Z","Ẓ":"Z","Ȥ":"Z","Ẕ":"Z","Ƶ":"Z","Ĳ":"IJ","Œ":"OE",
    "ᴀ":"Á","ᴁ":"AE","ʙ":"B","ᴃ":"B","ᴄ":"C","ᴅ":"D","ᴇ":"É","ꜰ":"F","ɢ":"G","ʛ":"G","ʜ":"H","ɪ":"Í","ʁ":"R","ᴊ":"J","ᴋ":"K","ʟ":"L","ᴌ":"L","ᴍ":"M","ɴ":"N","ᴏ":"Ó","ɶ":"OE","ᴐ":"Ó","ᴕ":"OU","ᴘ":"P","ʀ":"R","ᴎ":"N","ᴙ":"R","ꜱ":"S","ᴛ":"T","ⱻ":"É","ᴚ":"R","ᴜ":"Ú","ᴠ":"V","ᴡ":"W","ʏ":"Y","ᴢ":"Z",
    "á":"á","ă":"á","ắ":"á","ặ":"á","ằ":"á","ẳ":"á","ẵ":"á","ǎ":"á","â":"á","ấ":"á","ậ":"á","ầ":"á","ẩ":"á","ẫ":"á","ä":"á","ǟ":"á","ȧ":"á","ǡ":"á","ạ":"á","ȁ":"á","à":"á","ả":"á","ȃ":"á","ā":"á","ą":"á","ᶏ":"á","ẚ":"á","å":"á","ǻ":"á","ḁ":"á","ⱥ":"á","ã":"á","ꜳ":"aa","æ":"ae","ǽ":"ae","ǣ":"ae","ꜵ":"ao","ꜷ":"au","ꜹ":"av","ꜻ":"av","ꜽ":"ay",
    "ḃ":"b","ḅ":"b","ɓ":"b","ḇ":"b","ᵬ":"b","ᶀ":"b","ƀ":"b","ƃ":"b","ɵ":"ó",
    "ć":"c","č":"c","ç":"c","ḉ":"c","ĉ":"c","ɕ":"c","ċ":"c","ƈ":"c","ȼ":"c",
    "ď":"d","ḑ":"d","ḓ":"d","ȡ":"d","ḋ":"d","ḍ":"d","ɗ":"d","ᶑ":"d","ḏ":"d","ᵭ":"d","ᶁ":"d","đ":"d","ɖ":"d","ƌ":"d",
    "ı":"í","ȷ":"j","ɟ":"j","ʄ":"j","ǳ":"dz","ǆ":"dz",
    "é":"é","ĕ":"é","ě":"é","ȩ":"é","ḝ":"é","ê":"é","ế":"é","ệ":"é","ề":"é","ể":"é","ễ":"é","ḙ":"é","ë":"é","ė":"é","ẹ":"é","ȅ":"é","è":"é","ẻ":"é","ȇ":"é","ē":"é","ḗ":"é","ḕ":"é","ⱸ":"é","ę":"é","ᶒ":"é","ɇ":"é","ẽ":"é","ḛ":"é","ꝫ":"et",
    "ḟ":"f","ƒ":"f","ᵮ":"f","ᶂ":"f",
    "ǵ":"g","ğ":"g","ǧ":"g","ģ":"g","ĝ":"g","ġ":"g","ɠ":"g","ḡ":"g","ᶃ":"g","ǥ":"g",
    "ḫ":"h","ȟ":"h","ḩ":"h","ĥ":"h","ⱨ":"h","ḧ":"h","ḣ":"h","ḥ":"h","ɦ":"h","ẖ":"h","ħ":"h","ƕ":"hv",
    "í":"í","ĭ":"í","ǐ":"í","î":"í","ï":"í","ḯ":"í","ị":"í","ȉ":"í","ì":"í","ỉ":"í","ȋ":"í","ī":"í","į":"í","ᶖ":"í","ɨ":"í","ĩ":"í","ḭ":"í","ꝺ":"d","ꝼ":"f","ᵹ":"g","ꞃ":"r","ꞅ":"s","ꞇ":"t","ꝭ":"is",
    "ǰ":"j","ĵ":"j","ʝ":"j","ɉ":"j",
    "ḱ":"k","ǩ":"k","ķ":"k","ⱪ":"k","ꝃ":"k","ḳ":"k","ƙ":"k","ḵ":"k","ᶄ":"k","ꝁ":"k","ꝅ":"k",
    "ĺ":"l","ƚ":"l","ɬ":"l","ľ":"l","ļ":"l","ḽ":"l","ȴ":"l","ḷ":"l","ḹ":"l","ⱡ":"l","ꝉ":"l","ḻ":"l","ŀ":"l","ɫ":"l","ᶅ":"l","ɭ":"l","ł":"l","ǉ":"lj","ſ":"s","ẜ":"s","ẛ":"s","ẝ":"s",
    "ḿ":"m","ṁ":"m","ṃ":"m","ɱ":"m","ᵯ":"m","ᶆ":"m",
    "ń":"n","ň":"n","ņ":"n","ṋ":"n","ȵ":"n","ṅ":"n","ṇ":"n","ǹ":"n","ɲ":"n","ṉ":"n","ƞ":"n","ᵰ":"n","ᶇ":"n","ɳ":"n","ñ":"ñ","ǌ":"nj",
    "ó":"ó","ŏ":"ó","ǒ":"ó","ô":"ó","ố":"ó","ộ":"ó","ồ":"ó","ổ":"ó","ỗ":"ó","ö":"ó","ȫ":"ó","ȯ":"ó","ȱ":"ó","ọ":"ó","ő":"ó","ȍ":"ó","ò":"ó","ỏ":"ó","ơ":"ó","ớ":"ó","ợ":"ó","ờ":"ó","ở":"ó","ỡ":"ó","ȏ":"ó","ꝋ":"ó","ꝍ":"ó","ⱺ":"ó","ō":"ó","ṓ":"ó","ṑ":"ó","ǫ":"ó","ǭ":"ó","ø":"ó","ǿ":"ó","õ":"ó","ṍ":"ó","ṏ":"ó","ȭ":"ó","ƣ":"oi","ꝏ":"oo","ɛ":"é","ᶓ":"é","ɔ":"ó","ᶗ":"ó","ȣ":"ou",
    "ṕ":"p","ṗ":"p","ꝓ":"p","ƥ":"p","ᵱ":"p","ᶈ":"p","ꝕ":"p","ᵽ":"p","ꝑ":"p",
    "ꝙ":"q","ʠ":"q","ɋ":"q","ꝗ":"q",
    "ŕ":"r","ř":"r","ŗ":"r","ṙ":"r","ṛ":"r","ṝ":"r","ȑ":"r","ɾ":"r","ᵳ":"r","ȓ":"r","ṟ":"r","ɼ":"r","ᵲ":"r","ᶉ":"r","ɍ":"r","ɽ":"r","ↄ":"c","ꜿ":"c","ɘ":"é","ɿ":"r",
    "ś":"s","ṥ":"s","š":"s","ṧ":"s","ş":"s","ŝ":"s","ș":"s","ṡ":"s","ṣ":"s","ṩ":"s","ʂ":"s","ᵴ":"s","ᶊ":"s","ȿ":"s","ɡ":"g","ᴑ":"ó","ᴓ":"ó","ᴝ":"ú",
    "ť":"t","ţ":"t","ṱ":"t","ț":"t","ȶ":"t","ẗ":"t","ⱦ":"t","ṫ":"t","ṭ":"t","ƭ":"t","ṯ":"t","ᵵ":"t","ƫ":"t","ʈ":"t","ŧ":"t","ᵺ":"th",
    "ɐ":"á","ᴂ":"ae","ǝ":"é","ᵷ":"g","ɥ":"h","ʮ":"h","ʯ":"h","ᴉ":"í","ʞ":"k","ꞁ":"l","ɯ":"m","ɰ":"m","ᴔ":"oe","ɹ":"r","ɻ":"r","ɺ":"r","ⱹ":"r","ʇ":"t","ʌ":"v","ʍ":"w","ʎ":"y","ꜩ":"tz",
    "ú":"ú","ŭ":"ú","ǔ":"ú","û":"ú","ṷ":"ú","ü":"ü","ǘ":"ú","ǚ":"ú","ǜ":"ú","ǖ":"ú","ṳ":"ú","ụ":"ú","ű":"ú","ȕ":"ú","ù":"ú","ủ":"ú","ư":"ú","ứ":"ú","ự":"ú","ừ":"ú","ử":"ú","ữ":"ú","ȗ":"ú","ū":"ú","ṻ":"ú","ų":"ú","ᶙ":"ú","ů":"ú","ũ":"ú","ṹ":"ú","ṵ":"ú","ᵫ":"ue","ꝸ":"um",
    "ⱴ":"v","ꝟ":"v","ṿ":"v","ʋ":"v","ᶌ":"v","ⱱ":"v","ṽ":"v","ꝡ":"vy",
    "ẃ":"w","ŵ":"w","ẅ":"w","ẇ":"w","ẉ":"w","ẁ":"w","ⱳ":"w","ẘ":"w",
    "ẍ":"x","ẋ":"x","ᶍ":"x",
    "ý":"y","ŷ":"y","ÿ":"y","ẏ":"y","ỵ":"y","ỳ":"y","ƴ":"y","ỷ":"y","ỿ":"y","ȳ":"y","ẙ":"y","ɏ":"y","ỹ":"y",
    "ź":"z","ž":"z","ẑ":"z","ʑ":"z","ⱬ":"z","ż":"z","ẓ":"z","ȥ":"z","ẕ":"z","ᵶ":"z","ᶎ":"z","ʐ":"z","ƶ":"z","ɀ":"z",
    "ﬀ":"ff","ﬃ":"ffi","ﬄ":"ffl","ﬁ":"fi","ﬂ":"fl","ĳ":"ij","œ":"oe","ﬆ":"st",
    "ₐ":"á","ₑ":"é","ᵢ":"í","ⱼ":"j","ₒ":"ó","ᵣ":"r","ᵤ":"ú","ᵥ":"v","ₓ":"x",
    "\u0009":" ",
    "\u000d":" ",
    "\u000a":" ",
};

function simplificateText(text){
    if(text==null){
        return null;
    }
    return text.replace(
        /[^-A-Za-z0-9_\[\] ,/*+().$@!#:%ÁÉÍÓÚÜÑñáéíóúüçÇ¿¡?!<>={}"\\|&^~';º³]/g,
        function(a){
            return simplificatedChars[a]||`{&#${a.charCodeAt(0)};}`; // buscar en http://www.amp-what.com/
        }
    );
}

function dm2CrearQueries(parameters, context){
    var sqlEstructura=`
      SELECT 
            ${jsono(`
                SELECT moneda, valor_pesos
                    FROM relmon
                    WHERE periodo = rt.periodo`,
                    'moneda'
            )} as relmon
            , ${jsono(`
                SELECT informante, direccion, contacto, telcontacto, web, email
                    FROM informantes INNER JOIN (
                        SELECT informante
                            FROM relvis 
                            WHERE periodo=rt.periodo AND panel=rt.panel AND tarea=rt.tarea
                            GROUP BY informante
                    ) lista_informantes USING (informante)`, 
                    'informante'
            )} as informantes
            , ${jsono(`
                SELECT atributo, tipodato, nombreatributo, escantidad='S' as escantidad
                    FROM atributos INNER JOIN (
                        SELECT atributo
                            FROM relvis 
                                INNER JOIN forprod USING (formulario)
                                INNER JOIN prodatr USING (producto)
                            WHERE periodo=rt.periodo AND panel=rt.panel AND tarea=rt.tarea
                            GROUP BY atributo
                    ) lista_atributos USING (atributo)`, 
                    'atributo'
            )} as atributos
            , ${jsono(`
                SELECT p.producto, coalesce(nombreparaformulario,nombreproducto) as nombreproducto, ${ESPECIFICACION_COMPLETA}, e.destacada as destacado,
                        ${json(
                            `SELECT atributo, CASE WHEN mostrar_cant_um='S' THEN true ELSE false END as mostrar_cant_um, valornormal, orden, rangodesde, rangohasta, normalizable='S' as normalizable, prioridad, tiponormalizacion, opciones, validaropciones, alterable='S' as alterable, visible='S' as visible,
                                ${json(
                                    `SELECT atributo, valor, orden
                                        FROM prodatrval
                                        WHERE producto=pa.producto
                                        AND atributo=pa.atributo`, 
                                    'orden, valor'
                                )} as x_prodatrval
                                FROM prodatr pa inner join especificaciones e using(producto)
                                WHERE producto=p.producto`, 
                            'orden, atributo'
                        )} as x_atributos
                    FROM productos p INNER JOIN (
                        SELECT producto
                            FROM relvis 
                                INNER JOIN forprod USING (formulario)
                            WHERE periodo=rt.periodo AND panel=rt.panel AND tarea=rt.tarea
                            GROUP BY producto
                    ) lista_productos USING (producto)
                        INNER JOIN especificaciones e ON p.producto=e.producto AND e.especificacion=1
                    `, 
                'producto'
            )} as productos
            , ${jsono(`
                SELECT formulario, nombreformulario, orden, 
                        ${json(`SELECT producto, COALESCE(pr.cantobs,CASE WHEN despacho = 'A' THEN 2 ELSE 1 END) as observaciones, orden
                                    FROM forprod INNER JOIN productos pr using (producto) 
                                    WHERE formulario=f.formulario`, 'orden, producto')} as x_productos
                    FROM formularios f INNER JOIN (
                        SELECT formulario
                            FROM relvis
                            WHERE periodo=rt.periodo AND panel=rt.panel AND tarea=rt.tarea
                            GROUP BY formulario
                    ) lista_productos USING (formulario)`, 
                'formulario'
            )} as formularios
            , ${json(`
                SELECT tipoprecio, nombretipoprecio, espositivo='S' as espositivo, tipoprecio='P' as predeterminado, puedecopiar='S' as puedecopiar, orden, visibleparaencuestador = 'S' as visibleparaencuestador 
                    FROM tipopre`, 
                'orden'
            )} as "tiposPrecioDef"
            , ${jsono(`
                SELECT razon, nombrerazon, visibleparaencuestador='S' as visibleparaencuestador, espositivoformulario='S' as espositivoformulario, escierredefinitivoinf='S' as escierredefinitivoinf, escierredefinitivofor='S' as escierredefinitivofor
                    FROM razones
                `, 
                'razon'
            )} as razones
        FROM reltar rt
        WHERE rt.periodo=$1 AND rt.panel=$2 AND rt.tarea=$3
    `;
    var sqlAtributos=`
        SELECT ra.periodo, ra.visita, ra.informante, rp.formulario, ra.producto, ra.observacion, ra.atributo, 
                ra.valor, ra.valor_1 as valoranterior, pa.orden, ba.valor as valoranteriorblanqueado
            FROM relatr_1 ra
                INNER JOIN prodatr pa on ra.producto=pa.producto and ra.atributo = pa.atributo
                left join blaatr ba on ra.periodo_1 = ba.periodo and ra.informante = ba.informante and ra.visita = ba.visita and
                  ra.producto = ba.producto and ra.observacion = ba.observacion and ra.atributo = ba.atributo
            WHERE ra.periodo=rp.periodo 
                AND ra.visita=rp.visita 
                AND ra.informante=rp.informante 
                AND ra.producto=rp.producto
                AND ra.observacion=rp.observacion`
    var sqlObservaciones=`                
        SELECT rp.periodo, rp.visita, rp.informante, rp.formulario, rp.producto, rp.observacion, rp.precio, precio_1 as precioanterior, 
                case when rp.tipoprecio='L' then null else rp.tipoprecio end as tipoprecio, 
                tipoprecio_1 as tipoprecioanterior,
                rp.cambio, rp.comentariosrelpre, comentariosrelpre_1, esvisiblecomentarioendm_1, rp.precionormalizado, rp.precionormalizado_1, 
                f.orden as orden_formulario,
                fp.orden as orden_producto,
                p.periodo is not null as repregunta,
                false as adv,
                ${json(sqlAtributos, 'orden, atributo')} as atributos,
                c.promobs as promobs_1,
                distanciaperiodos(rp.periodo,ultimoperiodoconprecio)-1 cantidadperiodossinprecio,
                split_part(split_part(re.ultimoperiodoconprecio,' ', 1),'/', 2) || '/' ||  split_part(split_part(re.ultimoperiodoconprecio,' ', 1),'/', 1) ultimoperiodoconprecio,
                split_part(re.ultimoperiodoconprecio,' ', 2) ultimoprecioinformado,
                r_his.sinpreciohace4meses = 'S' sinpreciohace4meses,
                bp.precio as precioanteriorblanqueado,
                bp.tipoprecio as tipoprecioanteriorblanqueado
            FROM relvis rv inner join relpre_1 rp using(periodo, informante, visita, formulario)
                left join tipopre tp using(tipoprecio) 
                inner join forprod fp using(formulario, producto)
                inner join formularios f using (formulario)
                left join blapre bp on rp.periodo_1 = bp.periodo and rp.informante = bp.informante and rp.visita = bp.visita and
                    rp.producto = bp.producto and rp.observacion = bp.observacion
                left join (select * from calobs co join calculos_def cd on co.calculo = cd.calculo where cd.principal) c on c.periodo = rp.periodo_1
                    and c.informante = rp.informante and c.producto = rp.producto
                    and c.observacion = rp.observacion
                left join prerep p on rp.periodo = p.periodo and rp.producto = p.producto and rp.informante = p.informante,
                lateral (select max(periodo||' '||round(precio::decimal,2)::text) ultimoperiodoconprecio 
                    from relpre
                    where precio is not null and rp.informante = informante and rp.producto = producto and rp.observacion = observacion and rp.visita = visita 
                    and periodo < rp.periodo
                ) re,
                lateral(
                    select CASE WHEN count(*) = 4 THEN 'S' ELSE null END as sinpreciohace4meses
                    from relpre rp_2_3
                    where moverperiodos(rp.periodo,-1) >= rp_2_3.periodo and moverperiodos(rp.periodo,-4) <= rp_2_3.periodo and rp.producto = rp_2_3.producto and rp.observacion = rp_2_3.observacion and rp.informante = rp_2_3.informante and rp.visita = rp_2_3.visita and rp_2_3.tipoprecio in ('S',null)
                ) r_his
            WHERE rv.periodo=rvi.periodo 
                AND rv.panel=rvi.panel
                AND rv.tarea=rvi.tarea
                AND rv.informante=rvi.informante`;
    var sqlFormularios=`
        SELECT periodo, visita, informante, formulario, CASE WHEN razon is null or razon=0 THEN 1 ELSE razon END as razon, comentarios, visita, orden
            FROM relvis rv inner join formularios using (formulario)
            WHERE periodo=rvi.periodo 
                AND tarea=rvi.tarea
                AND panel=rvi.panel
                AND informante=rvi.informante
        `;
    var sqlInformantes=`
        SELECT periodo, informante, visita, nombreinformante, direccion,
                ${json(sqlFormularios,'orden, formulario')} as formularios,
                ${json(sqlObservaciones, 'orden_formulario, formulario, orden_producto, producto, observacion')} as observaciones,
                distanciaperiodos(rvi.periodo, max_periodos.maxperiodoinformado) as cantidad_periodos_sin_informacion,
                max_periodos.maxperiodoinformado,
                ri.observaciones as observacionesinformante,
                ri.observaciones_campo
            FROM relvis rvi INNER JOIN informantes USING (informante) LEFT JOIN relpantarinf ri USING (periodo, informante, visita, panel, tarea),
            lateral(
                SELECT 
                    CASE WHEN COUNT(*) > 0 THEN max(periodo) ELSE null END AS maxperiodoinformado
                        FROM relvis rvis
                        WHERE razon = 1 and rvis.informante = rvi.informante
                    ) as max_periodos
            WHERE periodo=rt.periodo 
                AND panel=rt.panel
                ${parameters.informante?`AND informante=${context.be.db.quoteLiteral(parameters.informante)} `:' '}
                 AND tarea=rt.tarea
            GROUP BY periodo, informante, visita, nombreinformante, direccion, panel, tarea, maxperiodoinformado, observaciones, observaciones_campo
        `;
    var sqlHdR=`
        SELECT encuestador, per.nombre as nombreencuestador, per.apellido as apellidoencuestador,
                (select ipad from instalaciones where id_instalacion = rt.id_instalacion ) as dispositivo,
                current_date as fecha_carga,
                rt.panel, rt.tarea, rt.periodo,
                rt.modalidad,
                ${json(sqlInformantes,'direccion, informante')} as informantes
            FROM reltar rt INNER JOIN periodos p USING (periodo) inner join personal per on encuestador = per.persona
            WHERE rt.periodo=$1 
                AND rt.panel=$2 
                AND rt.tarea=$3
    `;
    return {sqlEstructura, sqlHdR}
}

async function paneltarea_mover(context, parameters, intercambiar){
    var condicionExtra = '';
    var paramsArray = [parameters.periodo,parameters.panel,parameters.tarea,parameters.otropanel,parameters.otratarea];
    try{
        var firstResult = await context.client.query(
            `INSERT INTO cambiopantar_lote (fecha_lote, formulario) 
              VALUES (current_date, $1) returning id_lote`,
              [parameters.formulario]
        ).fetchUniqueRow();
        paramsArray.push(firstResult.row.id_lote); //posicion 6
        if(parameters.informante){
            paramsArray.push(parameters.informante);
            condicionExtra = ' AND informante= $7';
        }
        var secondResult = await context.client.query(
            `INSERT INTO cambiopantar_det
             (SELECT DISTINCT $6::integer id_lote, periodo, informante, panel, tarea, $4::integer panel_nuevo, $5::integer tarea_nueva 
                FROM relvis
                WHERE periodo = $1 AND panel = $2 AND tarea = $3 ${condicionExtra})`,
                paramsArray
        ).execute();
        if (intercambiar) {
           var secondOtherResult = await context.client.query(
            `INSERT INTO cambiopantar_det
             (SELECT DISTINCT $6::integer id_lote, periodo, informante, panel, tarea, $2::integer panel_nuevo, $3::integer tarea_nueva 
                FROM relvis
                WHERE periodo = $1 AND panel = $4 AND tarea = $5)`,
            [parameters.periodo,parameters.panel,parameters.tarea,parameters.otropanel,parameters.otratarea,firstResult.row.id_lote]
           ).execute();
        }
        var thirdResult =  await context.client.query(
            `UPDATE cambiopantar_lote SET fechaprocesado = current_timestamp 
             WHERE id_lote = $1
             RETURNING id_lote, fechaprocesado`,
             [firstResult.row.id_lote]
        ).fetchUniqueRow();
        return 'ok, id_lote ' + firstResult.row.id_lote + ' procesado en ' + thirdResult.row.fechaprocesado;
        }catch(err){
        if(err.code=='54011!'){
            throw new Error('El periodo no esta abierto para ingreso');
        }
        console.log(err);
        console.log(err.code);
        throw err;
        };
    }
//----------------------fin FUNCIONES AUXILIARES-----------------------------------------------------------------------

ProceduresIpcba = [
    {
        action:'fechageneracionperiodo_touch',
        parameters:[
            {name:'periodo', typeName:'text', references:'periodos'},
        ],
        roles:['programador','coordinador','analista','jefe_campo'],
        coreFunction:function(context, parameters){
            return context.client.query(
                `UPDATE periodos SET fechageneracionperiodo = current_timestamp(0) 
                   WHERE periodo=$1 
                     AND ingresando='S'
                   RETURNING fechageneracionperiodo`,
                [parameters.periodo]
            ).fetchUniqueRow().then(function(result){
                return 'generado '+result.row.fechageneracionperiodo.toHms();
            }).catch(function(err){
                if(err.code=='54011!'){
                    throw new Error('El periodo no esta abierto para ingreso');
                }
                console.log(err);
                console.log(err.code);
                throw err;
            });
        }
    },
    {
        action:'fechageneracionpanel_touch',
        parameters:[
            {name:'periodo', typeName:'text', references:'periodos'},
            {name:'panel'  , typeName:'integer'                    },
        ],
        roles:['programador','coordinador','analista','jefe_campo'],
        coreFunction:function(context, parameters){
            return context.client.query(
                `UPDATE relpan SET fechageneracionpanel = current_timestamp(0) 
                   WHERE periodo=$1 
                     AND panel=$2
                   RETURNING fechageneracionpanel`,
                [parameters.periodo,parameters.panel]
            ).fetchUniqueRow().then(function(result){
                return 'generado '+result.row.fechageneracionpanel.toHms();
            }).catch(function(err){
                if(err.code=='54011!'){
                    throw new Error('El panel no esta abierto para ingreso');
                }
                console.log(err);
                console.log(err.code);
                throw err;
            });
        }
    },
    {
        action:CALCULO_ACTION,
        parameters:[
            {name:'periodo', typeName:'text', references:'periodos'},
            {name:'calculo', typeName:'integer'                    },
        ],
        bitacora:{error:true, always:true},
        roles:['programador','coordinador','analista'],
        progress:true,
        coreFunction:async function(context, parameters){
            //context.informProgress({message:'cálculo lanzado'});
            const BITACORA_TABLENAME = context.be.config.server.bitacoraTableName || 'bitacora';
            //preguntar si hay alguien corriendo 'periodobase_correr' o mismo periodo dentro del calculo actual
            var result = await context.client.query(
                `select * 
                    from ${context.be.db.quoteIdent(BITACORA_TABLENAME)} 
                    where procedure_name = $1 and end_date is null or
                        procedure_name = $2 and parameters = $3 and end_date is null`,
                [PERIODO_BASE_CORRER_ACTION, CALCULO_ACTION,JSON.stringify(parameters)]
            ).fetchAll();
            if(result.rowCount > 1){
                throw Error('Hay otra persona ejecutando el calculo, por favor aguarde un momento y vuelva a intentarlo')
            }else{
                return context.client.query(
                    `UPDATE calculos SET fechageneracionexternos = COALESCE(fechageneracionexternos,current_timestamp), fechacalculo = current_timestamp
                    WHERE periodo=$1 
                        AND calculo=$2 AND abierto='S'
                    RETURNING fechageneracionexternos, fechacalculo`,
                    [parameters.periodo,parameters.calculo]
                ).onNotice(function(progressInfo){
                    progressInfo.message=progressInfo.message.replace(/comenzo.*finalizo.*demoro.*$/g,'');
                    context.informProgress(progressInfo);
                }).fetchUniqueRow().then(function(result){
                    return 'calculado '+result.row.fechacalculo.toHms();
                }).catch(function(err){
                    if(err.code=='54011!'){
                        throw new Error('El calculo no esta abierto');
                    }
                    console.log(err);
                    console.log(err.code);
                    throw err;
                });
            }
        }
    },
    {
        action:'precio_recuperar',
        parameters:[
            {name:'periodo'    , typeName:'text', references:'periodos'},
            {name:'producto'   , typeName:'text', references:'productos'},
            {name:'observacion', typeName:'integer'},
            {name:'informante' , typeName:'integer'},
            {name:'visita'     , typeName:'integer'},
        ],
        roles:['programador','coordinador','analista','recepcionista'],
        coreFunction: async function(context, parameters){
            try{
                var result = await context.client.query(
                    `UPDATE relpre SET precio = precioblanqueado, tipoprecio = tipoprecioblanqueado,
                       comentariosrelpre = comentariosrelpreblanqueado
                       FROM (SELECT precio precioblanqueado, tipoprecio tipoprecioblanqueado, cambio cambioblanqueado,
                            comentariosrelpre comentariosrelpreblanqueado
                            FROM blapre
                            WHERE periodo=$1 AND producto=$2 AND observacion=$3 AND informante=$4 AND visita=$5
                            ) b 
                       WHERE periodo=$1 AND producto=$2 AND observacion=$3 AND informante=$4 AND visita=$5
                       RETURNING producto, precio`,
                    [parameters.periodo,parameters.producto,parameters.observacion,parameters.informante,parameters.visita]
                ).fetchUniqueRow();
                /*
                var otherResult = context.client.query(
                    `DELETE FROM blapre WHERE periodo=$1 AND producto=$2 AND observacion=$3 AND informante=$4 AND visita=$5 RETURNING producto`,
                    [parameters.periodo,parameters.producto,parameters.observacion,parameters.informante,parameters.visita]
                ).execute();
                var otherResult = context.client.query(
                    `DELETE FROM blaatr WHERE periodo=$1 AND producto=$2 AND observacion=$3 AND informante=$4 AND visita=$5 RETURNING producto`,
                    [parameters.periodo,parameters.producto,parameters.observacion,parameters.informante,parameters.visita]
                ).execute();
                */
                return 'ok'
            }catch(err){
                console.log(err);
                console.log(err.code);
                throw err;
            }
        }
    },
    {
        action:'visita_agregar',
        parameters:[
            {name:'periodo'    , typeName:'text', references:'periodos'},
            {name:'producto'   , typeName:'text', references:'productos'},
            {name:'observacion', typeName:'integer'},
            {name:'informante' , typeName:'integer'},
            {name:'visita'     , typeName:'integer'},
        ],
        roles:['programador','coordinador','analista'],
        coreFunction: async function(context, parameters){
            try{
                var result = await context.client.query(
                    `UPDATE relpre p SET ultima_visita = null
                       FROM (SELECT ra.periodo, ra.producto, ra.observacion, ra.informante, ra.visita, 
                                string_agg(distinct CASE WHEN es_vigencia THEN 'S' ELSE 'N' END,'') as puedeagregarvisita   
                                FROM cvp.relatr ra join cvp.atributos at on ra.atributo = at.atributo 
                                GROUP BY ra.periodo, ra.producto, ra.observacion, ra.informante, ra.visita) aa					
                       WHERE aa.periodo = p.periodo and aa.producto = p.producto and aa.observacion = p.observacion	and aa.informante = p.informante 
                       and aa.visita = p.visita and p.periodo=$1 AND p.producto=$2 AND p.observacion=$3 AND p.informante=$4 AND p.visita=$5 
                       and p.ultima_visita and aa.puedeagregarvisita like '%S%'
                       RETURNING p.producto, precio`,
                    [parameters.periodo,parameters.producto,parameters.observacion,parameters.informante,parameters.visita]
                ).fetchUniqueRow();
                return 'ok'
            }catch(err){
                console.log(err);
                console.log(err.code);
                throw err;
            }
        }
    },
    {
        action:'visita_agregar_por_visita',
        parameters:[
            {name:'periodo'    , typeName:'text', references:'periodos'},
            {name:'informante' , typeName:'integer'},
            {name:'visita'     , typeName:'integer'},
            {name:'formulario' , typeName:'integer', references:'formularios'},
        ],
        roles:['programador','coordinador','analista'],
        coreFunction: async function(context, parameters){
            try{
                var result = await context.client.query(
                    `UPDATE relpre p SET ultima_visita = null
                       FROM parametros par					
                       WHERE par.unicoregistro AND p.periodo=$1 AND p.informante=$2 AND p.visita=$3 AND p.formulario=$4 
                       AND p.ultima_visita AND par.puedeagregarvisita='S'`,
                    [parameters.periodo,parameters.informante,parameters.visita,parameters.formulario]
                ).execute();
                return 'ok'
            }catch(err){
                console.log(err);
                console.log(err.code);
                throw err;
            }
        }
    },
    {
        action:'calculo_copiar',
        parameters:[
            {name:'periodo'    , typeName:'text', references:'periodos'},
            {name:'motivocopia', typeName:'text'                       },
        ],
        roles:['programador','coordinador','analista'],
        coreFunction: async function(context, parameters){
            try{
            var previusResult = await context.client.query(
                `INSERT INTO calculos_def (calculo,definicion, agrupacionprincipal, para_rellenado_de_base, grupo_raiz)
                 SELECT m.calculo,'Copia del Calculo' definicion, dp.agrupacionprincipal, dp.para_rellenado_de_base, dp.grupo_raiz 
                   from 
                    (select periodo,max(calculo)+1 calculo
                        from calculos 
                        where periodo=$1
                        group by periodo) m 
                    LEFT JOIN calculos_def d USING (calculo)
                    CROSS JOIN (SELECT * FROM calculos_def WHERE principal) dp
                    WHERE d.calculo is null`,
                    [parameters.periodo]).execute();
            var result = await context.client.query(
                `SELECT copiarcalculo(periodo,cd.calculo,periodo,(
                          select max(calculo)+1
                            from calculos c2
                            where c2.periodo=c.periodo
                          ), $2 )
                   FROM calculos c join calculos_def cd on c.calculo = cd.calculo
                   WHERE periodo=$1 AND cd.principal`,
                [parameters.periodo,parameters.motivocopia]
            ).fetchUniqueValue();
            return 'copiado '+result.value;
            }catch(err){
                console.log(err);
                console.log(err.code);
                throw err;
            };
        }
    },
    {
        action:'cuadros_mostrar',
        parameters:[
            {name:'tra_periodo'             , typeName:'text', references:'periodos', defaultValue:'a2018m07'},
            {name:'tra_cuadro'              , typeName:'text', references:'cuadros', defaultValue:'1'        },
            {name:'tra_separador_decimal'   , typeName:'text', defaultValue:','                              },
            {name:'tra_periodo_desde'       , typeName:'text', references:'periodos', defaultValue:'a2018m07'},
            {name:'tra_hogar'               , typeName:'text', references:'hogares', defaultValue:'Hogar 1'  },
            {name:'tra_agrupacion'          , typeName:'text', references:'agrupaciones', defaultValue:'A'   },
        ],
        roles:['programador','coordinador','analista'],
        coreFunction: async function(context, parameters){
            try{
            var previusResult = await context.client.query(
                `select c.funcion as funcion_a_llamar, CASE WHEN f.usa_parametro1    THEN ''''||c.parametro1|| '''' ELSE '' END 
                || CASE WHEN f.usa_periodo       THEN  ', '''||$1||'''' ELSE '' END 
                || CASE WHEN f.usa_nivel         THEN ','||c.nivel::text ELSE '' END 
                || CASE WHEN f.usa_grupo         THEN ','''||c.grupo|| '''' ELSE '' END 
                || CASE WHEN f.usa_agrupacion    THEN ','||CASE WHEN $2 in ('HC','H1','HH','HC_var','HH_var','X1','X2','LH','LH_var') THEN ''''||$6||'''' ELSE ''''||c.agrupacion|| '''' END ELSE '' END 
                || CASE WHEN f.usa_ponercodigos  THEN ','||c.ponercodigos::text ELSE '' END 
                || CASE WHEN f.usa_agrupacion2   THEN ','''||c.agrupacion2|| '''' ELSE '' END 
                || CASE WHEN f.usa_cuadro        THEN ','''||c.cuadro|| '''' ELSE '' END 
                || CASE WHEN f.usa_hogares       THEN ','||CASE WHEN $2 in ('HC','HC_var','I') THEN ''''||$5||'''' ELSE c.hogares::text END ELSE '' END 
                || CASE WHEN f.usa_cantdecimales THEN ','||c.cantdecimales::text ELSE '' END 
                || CASE WHEN f.usa_desde         THEN ','''||CASE WHEN $2 in ('X1','X2','HC','HC_var','HH_var','5','10','P','LH_var','9b','CC','I') OR $2 like '%h%' THEN $4 ELSE '' END|| '''' ELSE '' END 
                || CASE WHEN f.usa_orden         THEN ','''||c.orden|| '''' ELSE '' END
                as str_paramfun 
                , f.usa_periodo
                , $3::text as separador_decimal
                , CASE WHEN $6 = 'D' THEN c.encabezado2 ELSE c.encabezado END 
                || CASE WHEN $2 = '6' OR $2 = '7' THEN '. '||cvp.devolver_mes_anio($1) 
                WHEN $2 like 'HC%' THEN '. '|| cvp.devolver_mes_anio($4)||CASE WHEN $4 <> $1 THEN '/'||cvp.devolver_mes_anio($1) ELSE '' END||'. Evolución de su valor en '||CASE WHEN $2 like '%var' THEN '%. ' ELSE 'pesos. ' END || $5 ||'*'
                WHEN $2 like 'I%' THEN  '. '|| cvp.devolver_mes_anio($4)||CASE WHEN $4 <> $1 THEN '/'||cvp.devolver_mes_anio($1) ELSE '' END||'. En pesos. '|| $5 ||'*'
                ELSE '' END 
                as encabezado
                , c.pie1, c.pie, '(*)'||h.nombrehogar as piehogar 
                from cvp.cuadros c join cvp.cuadros_funciones f on c.funcion= f.funcion  
               , (SELECT nombrehogar FROM cvp.hogares WHERE hogar = $5) h WHERE cuadro=$2`,
                [parameters.tra_periodo, parameters.tra_cuadro, parameters.tra_separador_decimal, parameters.tra_periodo_desde, parameters.tra_hogar, parameters.tra_agrupacion]
            ).fetchUniqueRow();
            var funcion_a_llamar = previusResult.row.funcion_a_llamar;
            var parametros_funcion = previusResult.row.str_paramfun;
            var separador_decimal = previusResult.row.separador_decimal;
            var encabezado = previusResult.row.encabezado;
            var piehogar = previusResult.row.piehogar;
            var pie = previusResult.row.pie;
            var pie1 = previusResult.row.pie1;
            return context.client.query(
                `SELECT * FROM ${context.be.db.quoteIdent(funcion_a_llamar)}(${context.be.db.quoteLiteral(parametros_funcion)},$1) resultado`,
                [separador_decimal]
            ).fetchAll().then(function(result){
                //las filas resultado de la funcion_a_llamar
                var parte1 = poner_parte('encabezado','b',encabezado);
                var tipox=(funcion_a_llamar=='res_cuadro_matriz_hogar_var'||funcion_a_llamar=='res_cuadro_matriz_hogar'||funcion_a_llamar=='res_cuadro_matriz_linea'||funcion_a_llamar=='res_cuadro_matriz_up'||funcion_a_llamar=='res_cuadro_matriz_canasta'||funcion_a_llamar=='res_cuadro_matriz_canasta_var'||funcion_a_llamar=='res_cuadro_matriz_i'||funcion_a_llamar=='res_cuadro_vc'||funcion_a_llamar=='res_cuadro_pp'||funcion_a_llamar=='res_cuadro_matriz_linea_var'||funcion_a_llamar=='res_cuadro_matriz_hogar_per'||funcion_a_llamar=='res_cuadro_matriz_ingreso')?'cuadro_cpm':'cuadro_cp';
                cuadro.push({'tipox':tipox,'className':'cuadro','filas':result.rows});                
                if (parameters.tra_cuadro == 'HC'||parameters.tra_cuadro == 'HC_var'||parameters.tra_cuadro == 'I'){
                  var parte2 = poner_parte('piehogar','span', piehogar);
                }
                var parte3 = poner_parte('pie1','span',pie1);
                var parte4 = poner_parte('pie','span',pie);
                var cuadroFinal = {'tipox':'div','className':'cuadro','nodes':cuadro};
                proceso_formulario_boton_ejecutar('cuadros_resultados','boton_ver',["tra_periodo","tra_cuadro","tra_separador_decimal","tra_periodo_desde","tra_hogar","tra_agrupacion"],null,null,false);
                return cuadroFinal;
            });
            }catch(err){
                console.log(err);
                console.log(err.code);
                throw err;
            };
        }
    },
    {
        action:'caldiv_filtrarvarios',
        parameters:[
            {name:'periododesde'    , typeName:'text', references:'periodos'},
            {name:'periodohasta'    , typeName:'text', references:'periodos'},
        ],
        roles:['programador','coordinador','analista'],
        coreFunction: async function(context, parameters){
            try{
            var result = 'listo ';
            return 'listo '+result.value;
            }catch(err){
                console.log(err);
                console.log(err.code);
                throw err;
            };
        }
    },
    {
        action:'supervision_preparar',
        parameters:[
            {name:'periodo'    , typeName:'text', references:'periodos'},
            {name:'panel'      , typeName:'integer'                    },
        ],
        roles:['programador','coordinador','analista','jefe_campo','supervisor','recepcionista'],
        coreFunction:function(context, parameters){
            return context.client.query(
                //`SELECT generar_para_supervisiones($1,$2);`,
                `SELECT CASE WHEN generacionsupervisiones is not null then generacionsupervisiones::text ELSE generar_para_supervisiones(periodo,panel)::text END
                FROM relpan WHERE periodo = $1 and panel = $2;`,
                [parameters.periodo,parameters.panel]
            ).fetchUniqueValue().then(function(result){
                return /*'preparado '+ */ result.value;
            }).catch(function(err){
                console.log(err);
                console.log(err.code);
                throw err;
            });
        }
    },
    {
        action:'supervision_seleccionar',
        parameters:[
            {name:'periodo'    , typeName:'text', references:'periodos'},
            {name:'panel'      , typeName:'integer'                    },
        ],
        roles:['programador','coordinador','analista','jefe_campo','supervisor','recepcionista'],
        coreFunction:function(context, parameters){
            return context.client.query(
                `select CASE WHEN max(disponible) is null THEN 'Debe especificar al menos un supervisor disponible'::text 
                        ELSE seleccionar_supervisiones_aleatorias($1,$2)::text END
                 FROM relsup WHERE periodo = $1 and panel = $2 and disponible = 'S';`,
                [parameters.periodo,parameters.panel]
            ).fetchUniqueValue().then(function(result){
                return /*'seleccionado '*/ result.value;
            }).catch(function(err){
                console.log(err);
                console.log(err.code);
                throw err;
            });
        }
    },
    {
        action:'precios_exportarapp',
        parameters:[
            {name:'ocasion'    , typeName:'text'},
        ],
        roles:['programador','coordinador','analista'],
        progress:true,
        coreFunction: async function procesar(context,parameters){
            context.informProgress({message:'comienzo'});
            var config=context.be.config;
            // context.informProgress({message:'config '+JSON.stringify(config)});
            async function connect(configuracion){
                var connector = await pg.connect(configuracion);
                if(configuracion.search_path){
                    await connector.query('set search_path to '+configuracion.search_path).execute();
                };
                if(configuracion.setRole){
                    await connector.query('set role = '+configuracion.setRole).execute();
                };
                return connector;
            };
            async function pasaje(esquema, configDb){
                async function oriquery(query){
                    var result = await ori.query(query).fetchAll();
                    return result.rows;
                }
                async function bulkInsert(tableName, esquema, onerror){
                    context.informProgress({message:'copiando '+tableName});
                    var rows=data[tableName];
                    return des.bulkInsert({
                        schema:esquema,
                        table:tableName,
                        columns:likeAr(rows[0]).keys(),
                        rows:rows.map(function(row){
                            return likeAr(row).array();
                        }),
                        onerror
                    })
                }
                var des;
                try{
                    var ori = context.client;
                    // var ori = await connect(config.origen);
                    context.informProgress({message:'conectando al servidor de destino'});
                    des = await connect(configDb);
                    var cadenaPromesas = ['periodos','grupos_producto','productos','calculo_productos','agrupaciones','grupos','calculo_grupos'].reduceRight(function(cadenaPromesas, nombre_tabla){
                        return cadenaPromesas.then(function(){
                            console.log('borrando',nombre_tabla);
                            return des.query('delete from '+esquema+'.'+nombre_tabla).execute();
                        })
                    }, Promise.resolve());
                    await cadenaPromesas; 
                    var data={};
                    data.periodos = await oriquery(`
                        select p.periodo, ano as annio,mes from periodos p inner join calculos using (periodo)
                        inner join calculos_def using(calculo) 
                        where p.periodo >= '${periodo_inicial}' and abierto='N' and calculos_def.principal
                        order by periodo;
                    `);                   
                    await bulkInsert('periodos',esquema);
                    data.agrupaciones = await oriquery(`
                    select agrupacion, CASE WHEN agrupacion= 'Z' THEN 'Agrupación 12 divisiones' ELSE nombreagrupacion END AS nombreagrupacion
                        from agrupaciones 
                        where agrupacion in ('Z', 'R', 'S')
                        order by agrupacion;
                    `);
                    await bulkInsert('agrupaciones',esquema);
                    data.grupos = await oriquery(`
                    select agrupacion, grupo, nombregrupo, nivel, grupopadre
                        from grupos
                        where agrupacion in ('Z', 'R', 'S') and nivel in (0,1)
                        order by agrupacion, grupo; 
                    `);
                    await bulkInsert('grupos',esquema);
                    data.grupos_producto = await oriquery(`
                        select grupo, nombregrupo
                        from grupos
                        where nivel=2
                            and agrupacion = '${agrupacion}'
                        order by grupo;
                    `);
                    await bulkInsert('grupos_producto',esquema);
                    data.productos = await oriquery(`
                        select producto, coalesce(nombreparapublicar::character varying(250),nombreproducto) as nombreproducto, grupopadre as grupo, unidadmedidaabreviada as unidadmedida
                        from productos inner join grupos on agrupacion = '${agrupacion}' and grupo=producto
                        order by producto
                    `);
                    await bulkInsert('productos',esquema);
                    data.calculo_productos = await oriquery(`
                        select d.producto, d.periodo, promedioredondeado as preciopromedio
                        from caldiv d
                            inner join productos using(producto) inner join grupos on agrupacion = '${agrupacion}' and grupo=producto
                            inner join periodos p using(periodo) inner join calculos using (periodo,calculo)
                            inner join calculos_def cd on d.calculo = cd.calculo
                            -- inner join calgru g on d.producto=g.grupo and d.periodo=g.periodo and d.calculo=g.calculo
                        where cd.principal and d.division='0'
                            and p.periodo >= '${periodo_inicial}' and abierto='N'
                        order by producto
                    `);
                    await bulkInsert('calculo_productos',esquema);
                    data.calculo_grupos = await oriquery(`
                        select periodo,agrupacion,grupo,indiceredondeado
                        from calgru g inner join calculos c using (periodo,calculo)
                        inner join calculos_def cd using (calculo)
                        where agrupacion in ('Z', 'R', 'S') and nivel in (0,1) and cd.principal  and periodo >= '${periodo_inicial}' 
                        and abierto='N'
                        order by periodo, agrupacion, grupo;
                    `);
                    await bulkInsert('calculo_grupos',esquema);
                }catch(err){
                    context.informProgress({message:'error '+err.message});
                    console.log(err);
                    throw err;
                }finally{
                    context.informProgress({message:'cerrando las conecciones'});
                    des.done()
                }
            }
            await pasaje('precios_app',config.db); // LOCAL
            if(parameters.ocasion=='final'){
                context.informProgress({message:'PASAJE A LA APP'});
                await pasaje('public', config.precios_app.destino); // OTRO SERVIDOR
            }
            return 'listo';
        }
    },
    {
        action: 'hojaderuta_traer',
        parameters:[
            {name:'token_instalacion'   , typeName:'text'},
        ],
        policy:'web',
        coreFunction:async function(context, parameters){
            var now = datetime.now();
            try{
                var persona = await context.client.query(
                    `select *
                        from personal 
                        where id_instalacion = (select id_instalacion from instalaciones where token_instalacion = $1)`
                    ,
                    [parameters.token_instalacion]
                ).fetchUniqueRow();
                var result = await context.client.query(
                    `select r.*, i.id_instalacion, i.ipad, i.encuestador as encuestador_instalacion, p.nombre, p.apellido
                        from reltar r
                        left join instalaciones i using (id_instalacion)
                        left join personal p on p.persona = i.encuestador
                        where r.encuestador = $1 and 
                              vencimiento_sincronizacion is not null and 
                              vencimiento_sincronizacion > current_timestamp`
                    ,
                    [persona.row.persona]
                ).fetchUniqueRow();
                return result.row;
            }catch(err){
                console.log('ERROR',err);
                throw err;
            }
        }
    },
    {
        action: 'hojaderuta_traer2',
        parameters:[
            {name:'token_instalacion'   , typeName:'text'},
        ],
        policy:'web',
        coreFunction:async function(context, parameters){
            var now = datetime.now();
            try{
                var persona = await context.client.query(
                    `select *
                        from personal 
                        where id_instalacion = (select id_instalacion from instalaciones where token_instalacion = $1)`
                    ,
                    [parameters.token_instalacion]
                ).fetchUniqueRow();
                var result = await context.client.query(
                    `select r.*, i.id_instalacion, i.ipad, i.encuestador as encuestador_instalacion, p.nombre, p.apellido
                        from reltar r
                        left join instalaciones i using (id_instalacion)
                        left join personal p on p.persona = i.encuestador
                        where r.encuestador = $1 and 
                              vencimiento_sincronizacion2 is not null and 
                              vencimiento_sincronizacion2 > current_timestamp
                        order by vencimiento_sincronizacion2 desc 
                        limit 1`
                    ,
                    [persona.row.persona]
                ).fetchUniqueRow();
                return result.row;
            }catch(err){
                console.log('ERROR',err);
                throw err;
            }
        }
    },
    {
        action:'tareamodoavion_crear',
        parameters:[
            {name:'periodo'             , typeName:'text', references:'periodos'},
            {name:'panel'               , typeName:'integer'                    },
            {name:'tarea'               , typeName:'integer'                    },
            {name:'token_instalacion'   , typeName:'text'                       },
            {name:'encuestador'         , typeName:'text'                       },
        ],
        policy:'web',
        progress:true,
        roles:['programador','coordinador','analista','jefe_campo','recepcionista','supervisor', 'encuestador', 'recep_gabinete'],
        coreFunction:async function(context, params){
            var be = context.be;
            var informantesArray = await context.client.query(
                `select distinct informante 
                    from relvis 
                    where periodo = $1 and panel = $2 and tarea = $3`
                ,
                [params.periodo, params.panel, params.tarea]
            ).fetchAll();
            await context.client.query(
                `update relvis
                    set razon = 0, encuestador = $4
                    where periodo = $1 and panel = $2 and tarea = $3 and razon is null /*and razon <> 0*/`
                ,
                [params.periodo, params.panel, params.tarea, params.encuestador]
            ).execute();
            var idInstalacion = await context.client.query(
                `select id_instalacion from instalaciones where token_instalacion = $1`,
                [params.token_instalacion]
            ).fetchUniqueValue();
            await context.client.query(
                `update reltar
                    set cargado = current_timestamp, descargado = null, id_instalacion = $4
                    where periodo = $1 and panel = $2 and tarea = $3`
                ,
                [params.periodo, params.panel, params.tarea, idInstalacion.value]
            ).execute();
            informantesArray = informantesArray.rows;
            var fixedFields = [
                {fieldName: 'periodo', value: params.periodo},
                {fieldName: 'panel', value: params.panel},
                {fieldName: 'tarea', value: params.tarea},
            ];
            var mobileTables = ['mobile_hoja_de_ruta', 'mobile_visita', 'mobile_precios', 'mobile_atributos' ];
            var promiseChain = Promise.resolve();
            mobileTables.forEach(function(tableName){
                informantesArray.forEach(function(informante){
                    var results = {data: [], tableName: tableName}
                    promiseChain = promiseChain.then(async function(){
                        var result = await be.procedure.table_data.coreFunction(
                            context,{
                                table: tableName, 
                                fixedFields:fixedFields.concat({fieldName: 'informante', value: informante.informante})
                            }
                        )
                        results.data = result;
                        context.informProgress(results);
                    })
                });
            });
            promiseChain = promiseChain.then(async function(){
                var result = await context.client.query(
                    `select pa.* 
                      from relvis v join relpre p using(periodo, informante, visita, formulario) 
                        join prodatrval pa on p.producto = pa.producto
                      where periodo = $1 and panel = $2 and tarea = $3`
                    ,
                    [params.periodo, params.panel, params.tarea]
                ).fetchAll();
                var results = {data: result.rows, tableName: 'prodatrval'};
                context.informProgress(results);
            })
            await promiseChain;
            return 'ok';
        },
    },
    {
        action: 'sincronizacion_habilitar',
        parameters:[
            {name:'periodo'      , typeName:'text', references:'periodos'},
            {name:'panel'        , typeName:'integer'                    },
            {name:'tarea'        , typeName:'integer'                    },
            {name:'encuestador'  , typeName:'text'                       },
        ],
        coreFunction:async function(context, parameters){
            var now = datetime.now();
            var tokenDueDate = now.add({hours:1});
            try{
                await context.client.query(
                    `update reltar
                        set vencimiento_sincronizacion = null
                        where encuestador = $1 and vencimiento_sincronizacion is not null`
                    ,
                    [parameters.encuestador]
                ).execute();
                var dueDate = await context.client.query(
                    `update reltar
                        set vencimiento_sincronizacion = $4
                        where periodo = $1 and panel = $2 and tarea = $3`
                    ,
                    [parameters.periodo, parameters.panel, parameters.tarea, tokenDueDate]
                ).execute();
                return {status: 'ok', vencimientoSincronizacion: tokenDueDate}
            }catch(err){
                console.log('ERROR',err);
                throw err;
            }
        }
    },
    {
        action: 'sincronizacion_habilitar2',
        parameters:[
            {name:'periodo'      , typeName:'text', references:'periodos'},
            {name:'panel'        , typeName:'integer'                    },
            {name:'tarea'        , typeName:'integer'                    },
            {name:'encuestador'  , typeName:'text'                       },
        ],
        coreFunction:async function(context, parameters){
            var now = datetime.now();
            var tokenDueDate = now.add({hours:3});
            try{
                await context.client.query(
                    `update reltar
                        set vencimiento_sincronizacion2 = null
                        where encuestador = $1 and vencimiento_sincronizacion2 is not null`
                    ,
                    [parameters.encuestador]
                ).execute();
                await context.client.query(
                    `update reltar
                        set vencimiento_sincronizacion2 = $4
                        where periodo = $1 and panel = $2 and tarea = $3`
                    ,
                    [parameters.periodo, parameters.panel, parameters.tarea, tokenDueDate]
                ).execute();
                return {status: 'ok', vencimientoSincronizacion2: tokenDueDate}
            }catch(err){
                console.log('ERROR',err);
                throw err;
            }
        }
    },
    {
        action: 'instalacion_preparar',
        parameters:[
            {name:'numero_encuestador', typeName:'text' },
            {name:'numero_ipad'       , typeName:'text' },
            {name:'fecha_ipad'        , typeName:'timestamp' }
        ],
        policy:'web',
        coreFunction:async function(context, params){
            var clientDatetime = params.fecha_ipad;
            var serverDatetime = datetime.now();
            var diff = serverDatetime>clientDatetime?serverDatetime.sub(clientDatetime):clientDatetime.sub(serverDatetime);
            diff = diff.toHms();
            try{
                var result = {};
                var tiene_otro_ipad = await context.client.query(
                    `select nombre as nombre_encuestador, apellido as apellido_encuestador, ipad
                        from personal
                        where persona = $1 and ipad <> $2`
                    ,
                    [params.numero_encuestador, params.numero_ipad]
                ).fetchAll();
                result.tiene_otro_ipad = tiene_otro_ipad.rows;
                var tiene_ipad_sin_descargar = await context.client.query(
                    `select rt.panel, rt.tarea, rt.cargado, p.nombre as nombre_encuestador, 
                            p.apellido as apellido_encuestador, i.ipad
                        from reltar rt 
                            join instalaciones i using (id_instalacion)
                            join personal p on rt.encuestador = p.persona 
                        where rt.encuestador = $1 and rt.cargado is not null and rt.descargado is null`
                    ,
                    [params.numero_encuestador]
                ).fetchAll();
                result.tiene_ipad_sin_descargar = tiene_ipad_sin_descargar.rows;
                var intervalLimit = await context.client.query(
                    `select diferencia_horaria_tolerancia_ipad, diferencia_horaria_advertencia_ipad
                        from parametros`
                    ,[]
                ).fetchUniqueRow();
                result.supera_tolerancia  = diff > intervalLimit.row.diferencia_horaria_tolerancia_ipad;
                result.supera_advertencia = diff > intervalLimit.row.diferencia_horaria_advertencia_ipad;
                return result;
            }catch(err){
                console.log('ERROR',err);
                throw err;
            }
        }
    },
    {
        action: 'instalacion_crear',
        parameters:[
            {name:'numero_encuestador', typeName:'text' },
            {name:'numero_ipad'       , typeName:'text' },
            {name:'token_original'    , typeName:'text' },
            {name:'version_sistema'   , typeName:'text' },
        ],
        policy:'web',
        coreFunction:async function(context, params){
            var now = datetime.now();
            var token = params.numero_encuestador + params.numero_ipad + now;
            try{
                var result = await context.client.query(
                    `insert into instalaciones (token_instalacion, fecha_hora, encuestador, ipad, version_sistema, token_original) 
                        values (md5($1), $2, $3, $4, $5, coalesce($6,md5($1)))
                        returning id_instalacion, token_instalacion, fecha_hora, encuestador, ipad`
                    ,
                    [token, now, params.numero_encuestador, params.numero_ipad,params.version_sistema, params.token_original]
                ).fetchUniqueRow();
                var idInstalacion = await context.client.query(
                    `select id_instalacion from instalaciones where token_instalacion = $1`,
                    [result.row.token_instalacion]
                ).fetchUniqueValue();
                await context.client.query(
                    `update personal
                        set ipad = $1, id_instalacion = $2
                        where persona = $3`
                    ,
                    [result.row.ipad, idInstalacion.value, result.row.encuestador]
                ).execute();
                return result.row
            }catch(err){
                console.log('ERROR',err);
                throw err;
            }
        }
    },
    {
        action: 'dm_descargar',
        parameters:[
            {name:'token_instalacion'  , typeName:'text' },
            {name:'data'               , typeName:'jsonb' },
            {name:'encuestador'        , typeName:'text' },
        ],
        policy:'web',
        coreFunction:async function(context, params){
            var token = params.token_instalacion;
            try{
                var idInstalacion = await context.client.query(
                    `select id_instalacion from instalaciones where token_instalacion = $1`,
                    [token]
                ).fetchUniqueValue();
                var result = await context.client.query(
                    `update reltar
                      set descargado = current_timestamp, vencimiento_sincronizacion = null
                      where id_instalacion = $1 and vencimiento_sincronizacion > current_timestamp
                      returning *`
                ,[idInstalacion.value]).fetchOneRowIfExists();
                if(result.rowCount){
                    try{
                        try{
                            var persona = await context.client.query(`
                                select persona, labor from personal where username = $1`,
                                [context.user.usu_usu]
                            ).fetchUniqueRow();
                        }catch(err){
                            throw new Error('No se encontró el nombre de usuario en personal');
                        }
                        if(persona.row.labor == 'E'){
                            try{
                                persona = await context.client.query(`
                                    select recepcionista as persona from tareas where tarea = $1 and activa = 'S'`,
                                    [result.row.tarea]
                                ).fetchUniqueRow();
                            }catch(err){
                                throw new Error('No se encontró la tarea o la misma no está activa');
                            }
                            if(!persona.row.persona){
                                throw new Error('La tarea no tiene recepcionista asignado');
                            }
                        }
                    }catch(err){
                        console.log('entra al catch: ', err.message)
                        throw new Error('Error al buscar recepcionista. ' + err.message);
                    }
                    var data = JSON.parse(params.data);
                    var promiseChain = Promise.resolve();
                    data.mobile_visita.forEach(function(row){
                        promiseChain = promiseChain.then(async function(){
                            try{
                                await context.client.query(`
                                    update relvis
                                    set razon = $1, comentarios = $6, fechaingreso = current_date, recepcionista = $7
                                    where periodo = $2 and informante = $3 and visita = $4 and formulario = $5
                                    --pk verificada`
                                ,[row.razon, row.periodo, row.informante, row.visita, row.formulario, row.comentarios, persona.row.persona]).execute()
                            }catch(err){
                                throw new Error('Error al actualizar razón para el informante: ' + row.informante + ', formulario: ' + row.formulario + '. '+ err.message);
                            }
                        })
                    });
                    data.mobile_precios.forEach(function(row){
                        promiseChain = promiseChain.then(async function(){
                            //Solucionado en cliente, pero lo dejo por las dudas
                            if(row.tipopre__espositivo =='N' && row.cambio=='C'){
                                row.cambio=null;
                            }
                            try{
                                await context.client.query(`
                                    update relpre
                                    set tipoprecio = $1, precio = $2, cambio = $3, comentariosrelpre = $9
                                    where periodo = $4 and informante = $5 and visita = $6 and 
                                            producto = $7 and observacion = $8
                                            --pk verificada`
                                ,[
                                    row.tipoprecio, 
                                    row.precio, 
                                    row.cambio,
                                    row.periodo, 
                                    row.informante, 
                                    row.visita, 
                                    row.producto, 
                                    row.observacion,
                                    row.comentariosrelpre
                                ]).execute()
                            }catch(err){
                                throw new Error('Error al actualizar precio para el informante: ' + row.informante + ', formulario: ' + row.formulario + ', producto: ' + row.productocompleto['nombreproducto'] + ', observacion: ' + row.observacion +  '. '+ err.message);
                            }
                        })
                    });
                    data.mobile_atributos.forEach(function(row){
                        var precioDeAtributo = data.mobile_precios.find(function(price){
                            return row.periodo == price.periodo && 
                                   row.informante == price.informante && 
                                   row.visita == price.visita && 
                                   row.formulario == price.formulario && 
                                   row.producto == price.producto && 
                                   row.observacion == price.observacion
                        })
                        //solo actualizo atributo si el tipoprecio es positivo
                        if(precioDeAtributo.tipopre__espositivo == 'S' && row.valor){
                            promiseChain = promiseChain.then(async function(){
                                try{
                                    await context.client.query(`
                                        update relatr
                                        set valor = $1
                                        where periodo = $2 and informante = $3 and visita = $4 and 
                                            producto = $5 and observacion = $6 and atributo = $7
                                            --pk verificada`
                                    ,[
                                        row.valor.trim(), 
                                        row.periodo, 
                                        row.informante, 
                                        row.visita, 
                                        row.producto, 
                                        row.observacion,
                                        row.atributo
                                    ]).execute()
                                }catch(err){
                                    throw new Error('Error al actualizar atributo para el informante: ' + row.informante + ', formulario: ' + row.formulario + ', producto: ' + precioDeAtributo.productocompleto['nombreproducto'] + ', observacion: ' + row.observacion + ', atributo: ' + row.nombreatributo + ', valor: "' + row.valor + '". '+ err.message);
                                }
                            })
                        }
                    });              
                    await promiseChain;
                    return 'descarga completa';
                }else{
                    return 'sincronizacion deshabilitada o vencida para el encuestador ' + params.encuestador
                }
            }catch(err){
                console.log('ERROR',err);
                throw err;
            }
        }
    },
    {
        action: 'para_formulario_imprimir',
        parameters:[
            {name:'periodo'           , typeName:'text'    , defaultValue:'a2019m07', references:'periodos'},
            {name:'panel'             , typeName:'integer' , defaultValue:1},
            {name:'tarea'             , typeName:'integer' , defaultValue:3},
            {name:'informante'        , typeName:'integer' , defaultValue:4737},
        ],
        resultOk:'imprimir_formulario_con_precios',
        coreFunction:async function(context, params){
            var result = await context.client.query(
                `select * 
                    from paraImpresionFormulariosPrecios 
                    where periodo = $1 and panel = $2 and tarea = $3`,
                [params.periodo, params.panel, params.tarea]
            ).fetchAll();
            return result.rows;
        }
    },
    {
        action:'informante_buscar',
        parameters:[
            {name:'periodo'    , typeName:'text'   , references:'periodos'   },
            {name:'informante' , typeName:'integer', references:'informantes'},
        ],
        roles:['programador','coordinador','analista','jefe_campo','supervisor','ingresador','recep_gabinete','recepcionista'],
        coreFunction:function(context, parameters){
            return context.client.query(
                `SELECT *
                FROM relvis WHERE periodo = $1 and informante = $2;`,
                [parameters.periodo,parameters.informante]
            ).fetchAll().then(function(result){
                return result.rows;
            }).catch(function(err){
                console.log(err);
                console.log(err.code);
                throw err;
            });
        }
    },
    {
        action:PERIODO_BASE_CORRER_ACTION,
        parameters:[
            {name:'periodo' , typeName:'text'   , references:'periodos'},
            {name:'calculo' , typeName:'integer', defaultValue:20      },
            {name:'ejecutar', typeName:'boolean'                       },
        ],
        bitacora:{error:true, always:true},
        roles:['programador','migracion','analista','coordinador'],
        coreFunction:async function(context, parameters){
            const BITACORA_TABLENAME = context.be.config.server.bitacoraTableName || 'bitacora';
            //preguntar si hay alguien corriendo 'periodobase_correr' o fechacalculo_touch
            var result = await context.client.query(
                `select * 
                    from ${context.be.db.quoteIdent(BITACORA_TABLENAME)} 
                    where procedure_name in ($1,$2) and end_date is null`,
                [PERIODO_BASE_CORRER_ACTION, CALCULO_ACTION]
            ).fetchAll();
            if(result.rowCount > 1){
                throw Error('Hay otra persona ejecutando el calculo, por favor aguarde un momento y vuelva a intentarlo')
            }else{
                try{
                    await context.client.query(
                        `SELECT periodobase($1, $2) where $3;`,
                        [parameters.periodo, parameters.calculo, parameters.ejecutar]
                    ).onNotice((progressInfo)=>{
                    progressInfo.message=progressInfo.message.replace(/comenzo.*finalizo.*demoro.*$/g,'');
                    context.informProgress(progressInfo);
                    }).fetchUniqueRow();
                    return 'periodo base calculado';
                }catch(err){
                    if(err.code=='54011!'){
                        throw new Error('El calculo no esta abierto, o el perido base no está habilitado');
                    }
                    console.log(err);
                    console.log(err.code);
                    throw err;
                }            
            }
        }
    },
    {
        action:'dm2_cargar',
        parameters:[
            {name:'periodo'           , typeName:'text'    , references:'periodos'},
            {name:'panel'             , typeName:'integer' },
            {name:'tarea'             , typeName:'integer' },
            {name:'token_instalacion'   , typeName:'text'  },
        ],
        unlogged:SOLO_PARA_DEMO_DM,
        policy:'web',
        coreFunction: async function(context, parameters){
            var idInstalacion = await context.client.query(
                `select id_instalacion from instalaciones where token_instalacion = $1`,
                [parameters.token_instalacion]
            ).fetchUniqueValue();
            //blanqueamos instalaciones, fecha de carga, sincro
            //de cargas sin descargar para esa instalación en ese periodo por si descartó una hdr
            await context.client.query(
                `update reltar
                    set cargado = null, id_instalacion = null, vencimiento_sincronizacion2 = null
                    where periodo = $1 and id_instalacion = $2 and descargado is null and cargado is not null`
                ,
                [parameters.periodo, idInstalacion.value]
            ).execute();
            await context.client.query(
                `update reltar
                    set cargado = current_timestamp, descargado = null, id_instalacion = $4
                    where periodo = $1 and panel = $2 and tarea = $3 --PK verificada
                    returning true`
                ,
                [parameters.periodo, parameters.panel, parameters.tarea, idInstalacion.value]
            ).fetchUniqueRow();
            return "ok"
        }
    },
    {
        action:'dm2_estructura_hdr_preparar',
        parameters:[
            {name:'periodo'           , typeName:'text'    , references:'periodos'},
            {name:'panel'             , typeName:'integer' },
            {name:'tarea'             , typeName:'integer' },
            {name:'informante'        , typeName:'integer' }
        ],
        coreFunction: async function(context, parameters){
            var {be, client} = context;
            try{
                var {sqlEstructura, sqlHdR} = dm2CrearQueries(parameters, context);
                try{
                    var resultEstructura = await context.client.query(
                        sqlEstructura,
                        [parameters.periodo, parameters.panel, parameters.tarea]
                    ).fetchUniqueRow();
                }catch(err){
                    throw Error('error al buscar estructura. ' + err.message)
                }
                try{
                    var resultHdR = await context.client.query(
                        sqlHdR,
                        [parameters.periodo, parameters.panel, parameters.tarea]
                    ).fetchUniqueRow();
                }catch(err){
                    throw Error('error al crear hoja de ruta, verifique que haya un encuestador asignado en reltar. ' + err.message);
                }
                var estructura = resultEstructura.row;
                var hdr = resultHdR.row;
                likeAr(estructura.productos).forEach(p=>{
                    p.lista_atributos = p.x_atributos.map(a=>a.atributo);
                    p.atributos = likeAr.createIndex(p.x_atributos, 'atributo');
                    likeAr(p.atributos).forEach(a=>{
                        // if(a.x_prodatrval==null){
                        //     a.x_prodatrval=[];
                        // }
                        a.lista_prodatrval = a.x_prodatrval.map(v=>v.valor);
                        a.prodatrval = likeAr.createIndex(a.x_prodatrval, 'valor');
                        delete p.x_prodatrval;
                    });
                    delete p.x_atributos;
                });
                likeAr(estructura.formularios).forEach(f=>{
                    f.lista_productos = f.x_productos.map(p=>p.producto);
                    f.productos = likeAr.createIndex(f.x_productos, 'producto');
                    delete f.x_productos;
                });
                estructura.tipoPrecio=likeAr.createIndex(estructura.tiposPrecioDef, 'tipoprecio');
                estructura.tipoPrecioPredeterminado = estructura.tipoPrecio['P'];
                return {status: 'ok', estructura, hdr}
            }catch(err){
                throw err
            }
        }
    },
    {
        action:'dm2_archivospreparar',
        parameters:[
            {name:'periodo'           , typeName:'text'    , references:'periodos'},
            {name:'panel'             , typeName:'integer' },
            {name:'tarea'             , typeName:'integer' },
            {name:'informante'        , typeName:'integer' }
        ],
        coreFunction: async function(context, parameters){
            var {be, client} = context;
            try{
                //obtengo estructura y hdr
                var {estructura, hdr} = await be.procedure.dm2_estructura_hdr_preparar.coreFunction(context, parameters)
                var resourcesForCache = be.createResourcesForCacheJson(parameters);
                await client.query(`
                    UPDATE reltar 
                        SET archivo_estructura = $1, archivo_hdr = $2, archivo_cache = $3
                        WHERE periodo = $4 AND panel=$5 AND tarea = $6`,
                    [
                        "var structFromManifest=" + JSON.stringify(estructura),
                        JSON4all.stringify(hdr),
                        JSON4all.stringify(resourcesForCache),
                        parameters.periodo,
                        parameters.panel,
                        parameters.tarea,
                    ]
                ).execute();
                //resultado
                return {status: 'ok', estructura, hdr}
            }catch(err){
                throw err
            }
        }
    },
    {
        action:'dm2_relevamiento_unlock',
        parameters:[
            {name:'token'             , typeName:'text'    },
        ],
        policy:'web',
        coreFunction: async function(context, parameters){
            await context.client.query(
                `update relvis
                    set token_relevamiento = null
                    where token_relevamiento = $1`
                ,
                [parameters.token]
            ).execute();
            return "ok";
        }
    },
    {
        action:'dm2_relevamiento_chequear_informante_abierto',
        parameters:[
            {name:'periodo'           , typeName:'text'    , references:'periodos'},
            {name:'panel'             , typeName:'integer' },
            {name:'tarea'             , typeName:'integer' },
            {name:'informante'        , typeName:'integer' },
            {name:'visita'            , typeName:'integer' },
        ],
        policy:'web',
        coreFunction: async function(context, parameters){
            var result = await context.client.query(
                `select t.username, t.useragent
                    from relvis r
                    left join tokens t on r.token_relevamiento = t.token
                    WHERE periodo = $1 AND panel = $2 AND tarea = $3 AND informante = $4 and visita = $5 and token_relevamiento is not null
                    group by t.username, t.useragent`
                ,
                [parameters.periodo, parameters.panel, parameters.tarea, parameters.informante, parameters.visita]
            ).fetchAll();
            return {informanteAbierto: result.rowCount > 0, dispositivosAbiertos: result.rows}
        }
    },
    {
        action:'dm2_preparar',
        parameters:[
            {name:'periodo'           , typeName:'text'    , references:'periodos'},
            {name:'panel'             , typeName:'integer' },
            {name:'tarea'             , typeName:'integer' },
            {name:'informante'        , typeName:'integer' },
            {name:'visita'            , typeName:'integer' },
            {name:'demo'              , typeName:'boolean' },
        ],
        policy:'web',
        coreFunction: async function(context, parameters){
            var be = context.be;
            var fileResult;
            if(SOLO_PARA_DEMO_DM){
                fileResult =JSON4all.parse(await fs.readFile('c:/temp/dm_cargar.txt','utf8'));
            }
            try{
                if(!parameters.demo){
                    //entro por pantalla de relevamiento
                    if(parameters.informante && parameters.visita){
                        await context.client.query(
                            `update relvis
                                set preciosgenerados = true , token_relevamiento = null
                                where periodo = $1 and panel = $2 and tarea = $3 and informante = $4 and visita = $5 /*and not preciosgenerados*/`
                            ,
                            [parameters.periodo, parameters.panel, parameters.tarea, parameters.informante, parameters.visita]
                        ).execute();
                    }else{
                        //entro por aplicacion dm (carga habitual)
                        await context.client.query(
                            `update relvis
                                set preciosgenerados = true
                                where periodo = $1 and panel = $2 and tarea = $3`
                            ,
                            [parameters.periodo, parameters.panel, parameters.tarea]
                        ).execute();
                    }
                }
                var hojaDeRutaConPrecios = await context.client.query(
                    `SELECT count(*) > 0 as tieneprecioscargados
                        FROM relvis
                        WHERE periodo = $1 AND panel = $2 AND tarea = $3 AND razon IS NOT NULL`
                    ,
                    [parameters.periodo, parameters.panel, parameters.tarea]
                ).fetchUniqueValue();
                
                var vencimientoSincronizacion2 = null;
                var result;
                var token;
                //si tiene informante viene de pantalla relevamiento
                //o es demo
                //solo necesita preparar la estructura y hdr
                if(parameters.informante || parameters.demo){
                    //vengo de relevamiento
                    if(parameters.informante){
                        //pido token
                        var myToken = await be.procedure.token_get.coreFunction(context, {
                            useragent: context.session.req.useragent, 
                            username: context.user.usu_usu
                        });
                        token = myToken.token;
                        //seteo token en relvis
                        await context.client.query(
                            `UPDATE relvis
                                SET token_relevamiento = $5
                                WHERE periodo = $1 AND panel = $2 AND tarea = $3 AND informante = $4 and visita = $6`
                            ,
                            [parameters.periodo, parameters.panel, parameters.tarea, parameters.informante, token, parameters.visita]
                        ).execute();
                    }
                    result = await be.procedure.dm2_estructura_hdr_preparar.coreFunction(context, parameters);
                //sino tambien prepara archivos y calculo sincronizacion
                }else{
                    result = await be.procedure.dm2_archivospreparar.coreFunction(context, parameters);
                    vencimientoSincronizacion2 = (await be.procedure.sincronizacion_habilitar2.coreFunction(context,{...parameters,encuestador:result.hdr.encuestador})).vencimientoSincronizacion2;
                }
                var {estructura, hdr} = result;
                //resultado
                return {status: 'ok', vencimientoSincronizacion2, estructura, hdr, tieneprecioscargados: hojaDeRutaConPrecios.value, token}
            }catch(err){
                throw err
            }
        }
    },
    {
        action:'hdr_json_leer',
        policy:'web',
        parameters:[
            {name:'periodo'           , typeName:'text'    , references:'periodos'},
            {name:'panel'             , typeName:'integer' },
            {name:'tarea'             , typeName:'integer' },
        ],
        coreFunction: async function(context, parameters){
            var {value: content} = await context.client.query(
                `SELECT archivo_hdr
                    FROM reltar
                    WHERE periodo = $1 AND panel = $2 AND tarea = $3`,
                [parameters.periodo, parameters.panel, parameters.tarea]
            ).fetchUniqueValue();
            return JSON4all.parse(content);
        }
    },
    {
        action: 'dm2_descargar',
        parameters:[
            {name:'token_instalacion'  , typeName:'text' },
            {name:'hoja_de_ruta'       , typeName:'jsonb'},
            {name:'custom_data'        , typeName:'boolean' },
            {name:'current_token'      , typeName:'text' },
        ],
        policy:'web',
        coreFunction:async function(context, params){
            var token = params.token_instalacion;
            try{
                var habilitado = params.custom_data;
                var tarea=params.hoja_de_ruta.tarea;
                if(params.custom_data){
                    //saco token antes de actualizar
                    var result = await context.client.query(`
                        update relvis 
                            set token_relevamiento = null
                            where token_relevamiento = $1
                            returning 1 as ok`
                        ,[params.current_token]
                    ).fetchAll()
                    if(result.rowCount < params.hoja_de_ruta.informantes[0].formularios.length){
                        let err = new Error(`Su token (${params.current_token}) ha expirado. Es probable que alguien alguien haya abierto la hoja de ruta desde otro dispositivo.`)
                        err.code = 403;
                        throw err;
                    }
                }else{
                    try{
                        var idInstalacion = await context.client.query(
                            `select id_instalacion from instalaciones where token_instalacion = $1`,
                            [token]
                        ).fetchUniqueValue();
                    }catch(err){
                        if(err.code=='54011!'){
                            throw new Error(`No se encuentra el token_instalacion ${token}. Quizas la persona tiene otro dipopsitivo activo`);
                        }
                    }
                    var result = await context.client.query(
                        `update reltar
                            set descargado = current_timestamp, vencimiento_sincronizacion2 = null, 
                                datos_descarga = $2
                            where id_instalacion = $1 and descargado is null
                            returning *`
                    ,[idInstalacion.value, params.hoja_de_ruta]).fetchOneRowIfExists();
                    habilitado = result.rowCount;
                    tarea=result.rowCount?result.row.tarea:null;
                }
                if(habilitado){
                    var tiposDePrecio = await context.client.query(
                        `SELECT tipoprecio, espositivo='S' as espositivo, puedecambiaratributos FROM tipopre`
                    ,[]).fetchAll();
                    tiposDePrecio = likeAr.createIndex(tiposDePrecio.rows, 'tipoprecio');
                    var productos = await context.client.query(
                        `SELECT * from productos`
                    ,[]).fetchAll();
                    productos = likeAr.createIndex(productos.rows, 'producto');
                    var atributos = await context.client.query(
                        `SELECT * from atributos`
                    ,[]).fetchAll();
                    atributos = likeAr.createIndex(atributos.rows, 'atributo');
                    var razones = await context.client.query(
                        `SELECT * from razones`
                    ,[]).fetchAll();
                    razones = likeAr.createIndex(razones.rows, 'razon');
                    try{
                        try{
                            var persona = await context.client.query(`
                                select persona, labor from personal where username = $1`,
                                [context.user.usu_usu]
                            ).fetchUniqueRow();
                        }catch(err){
                            throw new Error('No se encontró el nombre de usuario en personal');
                        }
                        if(persona.row.labor == 'E'){
                            try{
                                persona = await context.client.query(`
                                    select recepcionista as persona from tareas where tarea = $1 and activa = 'S'`,
                                    [tarea]
                                ).fetchUniqueRow();
                            }catch(err){
                                throw new Error('No se encontró la tarea o la misma no está activa');
                            }
                            if(!persona.row.persona){
                                throw new Error('La tarea no tiene recepcionista asignado');
                            }
                        }
                    }catch(err){
                        console.log('entra al catch: ', err.message)
                        throw new Error('Error al buscar recepcionista. ' + err.message);
                    }
                    var hoja_de_ruta = params.hoja_de_ruta;
                    for(var informante of hoja_de_ruta.informantes){
                        try{
                            console.log("informante", informante)
                            await context.client.query(`
                                update relpantarinf 
                                    set observaciones_campo = $1
                                    where periodo = $2 and informante = $3 and visita = $4 and panel = $5 and tarea= $6 --pk verificada
                                    returning true`
                                ,[informante.observaciones_campo, hoja_de_ruta.periodo, informante.informante, informante.visita, hoja_de_ruta.panel, hoja_de_ruta.tarea]
                            ).fetchUniqueRow()
                        }catch(err){
                            throw new Error('Error al actualizar las observaciones para el informante: ' + informante.informante + ". " + err.message);
                        }
                        for(var formulario of informante.formularios){
                            var filtroValoresPrecioAtributo;
                            var razonNegativa = razones[formulario.razon].espositivoformulario=="N";
                            var actualizarRelVis=async function(){
                                try{
                                    await context.client.query(`
                                        update relvis 
                                            set razon = $1, comentarios = $6, fechaingreso = current_date, recepcionista = $7, encuestador = $8
                                            where periodo = $2 and informante = $3 and visita = $4 and formulario = $5 --pk verificada
                                            returning true`
                                        ,[formulario.razon, hoja_de_ruta.periodo, formulario.informante, formulario.visita, formulario.formulario, 
                                            simplificateText(formulario.comentarios), 
                                            persona.row.persona, hoja_de_ruta.encuestador
                                        ]
                                    ).fetchUniqueRow()
                                }catch(err){
                                    throw new Error('Error al actualizar razon para el informante: ' + formulario.informante + ', formulario: ' + formulario.formulario + '. '+ err.message);
                                }
                            }
                            try{
                                var result = await context.client.query(`
                                    select r_a.espositivoformulario = 'S' and r_nueva.espositivoformulario is distinct from 'S' as limpiar_precios,
                                           case when r_nueva.espositivoformulario = 'S' then true else null end as filtro_valores
                                        from relvis rv left join razones r_a using (razon) left join razones r_nueva on r_nueva.razon = $1
                                        where periodo = $2 and informante = $3 and visita = $4 and formulario = $5 --pk verificada
                                        `
                                    ,[formulario.razon, hoja_de_ruta.periodo, formulario.informante, formulario.visita, formulario.formulario]
                                ).fetchUniqueRow()
                                filtroValoresPrecioAtributo = result.row.filtro_valores;
                            }catch(err){
                                throw new Error('Error al caracterizar la visita para el informante: ' + formulario.informante + ', formulario: ' + formulario.formulario + '. '+ err.message);
                            }
                            var actualizarObservacionesYAtributos=async function(observaciones){
                                var actualizarObservacion=async function(observacion){
                                    try{
                                        await context.client.query(`
                                            update relpre
                                                set tipoprecio = $1, precio = $2, comentariosrelpre = $8
                                                where periodo = $3 and informante = $4 and visita = $5 and producto = $6 and observacion = $7 --pk verificada
                                                returning true`
                                        ,[
                                            filtroValoresPrecioAtributo && observacion.tipoprecio && (tiposDePrecio[observacion.tipoprecio].espositivo && !observacion.precio?null:observacion.tipoprecio),
                                            filtroValoresPrecioAtributo && observacion.tipoprecio && (tiposDePrecio[observacion.tipoprecio].espositivo?observacion.precio:null), 
                                            observacion.periodo, 
                                            observacion.informante, 
                                            observacion.visita, 
                                            observacion.producto, 
                                            observacion.observacion,
                                            simplificateText(filtroValoresPrecioAtributo && observacion.comentariosrelpre),
                                        ]).fetchUniqueRow()
                                    }catch(err){
                                        throw new Error('Error al actualizar precio para el informante: ' + observacion.informante + ', formulario: ' + observacion.formulario + ', producto: ' + observacion.producto + ' ' + productos[observacion.producto].nombreproducto + ', observacion: ' + observacion.observacion +  '. '+ err.message);
                                    }
                                };
                                for(var observacion of observaciones){
                                    observacion.cambio=observacion.cambio=='='?null:observacion.cambio;
                                    var tpEsNegativo = !!(observacion.tipoprecio && !tiposDePrecio[observacion.tipoprecio].espositivo);
                                    if(observacion.cambio &&!observacion.precio && !tpEsNegativo && !razonNegativa){
                                        observacion.tipoprecio="L";
                                    }
                                    var blanquearAtributosAntes = razonNegativa;
                                    if(!blanquearAtributosAntes){
                                        await actualizarObservacion(observacion);
                                    }
                                    for(var atributo of observacion.atributos){
                                        if(!tpEsNegativo){
                                            try{
                                                //razon positiva (no hay null nunca) y hay cambio, a veces hay problemas con los numeros
                                                var valor = !razonNegativa && atributo.valor != atributo.valoranterior?
                                                    atributo.valor?simplificateText(atributo.valor.toString().trim().toUpperCase()):null
                                                :
                                                    atributo.valoranterior?atributo.valoranterior:null    
                                                await context.client.query(`
                                                    update relatr
                                                        set valor = $1
                                                        where periodo = $2 and informante = $3 and visita = $4 and  producto = $5 and observacion = $6 and atributo = $7 --pk verificada
                                                          and upper(trim(valor)) is distinct from $8
                                                        returning true`
                                                ,[
                                                    valor, 
                                                    atributo.periodo, 
                                                    atributo.informante, 
                                                    atributo.visita, 
                                                    atributo.producto, 
                                                    atributo.observacion,
                                                    atributo.atributo,
                                                    valor // para solo hacer update si hubo cambio
                                                ]).fetchOneRowIfExists()
                                            }catch(err){
                                                throw new Error('Error al actualizar atributo para el informante: ' + atributo.informante + ', formulario: ' + atributo.formulario + ', producto: ' + atributo.producto+' '+productos[atributo.producto].nombreproducto + ', observacion: ' + atributo.observacion + ', atributo: ' + atributo.atributo +' '+ atributos[atributo.atributo].nombreatributo + ', valor: "' + valor + '". '+ err.message);
                                            }
                                        }
                                    }
                                    if(blanquearAtributosAntes){
                                        await actualizarObservacion(observacion);
                                    }
                                }
                            }
                            var observaciones = informante.observaciones.filter((observacion)=>observacion.formulario==formulario.formulario)
                            if(razonNegativa){
                                await actualizarObservacionesYAtributos(observaciones);
                                await actualizarRelVis();
                            }else{
                                await actualizarRelVis();
                                await actualizarObservacionesYAtributos(observaciones);
                            }
                        };
                    };              
                    return 'descarga completa';
                }else{
                    return `No se pudo descargar. 
                        Quizás haya sido descargado anteriormente o se le haya cargado otro dispositivo. 
                        ${params.custom_data?'Token: ' + params.current_token:'ID instalacion: ' + idInstalacion.value}`
                }
            }catch(err){
                console.log('ERROR',err);
                throw err;
            }
        }
    },
    {
        action: 'dm2_backup_hacer',
        parameters:[
            {name:'token_instalacion'  , typeName:'text' },
            {name:'hoja_de_ruta'       , typeName:'jsonb'},
        ],
        policy:'web',
        unlogged:true,
        coreFunction:async function(context, params){
            var token = params.token_instalacion;
            try{
                try{
                    var idInstalacion = (await context.client.query(
                        `select id_instalacion from instalaciones where token_instalacion = $1`,
                        [token]
                    ).fetchUniqueValue()).value;
                }catch(err){
                    if(err.code=='54011!'){
                        throw new Error(`No se encuentra el token_instalacion ${token}. Quizas la persona tiene otro dipopsitivo activo`);
                    }
                }
                try{
                    await context.client.query(
                        `update reltar
                            set fecha_backup = current_timestamp, backup = $2
                            where id_instalacion = $1 and cargado is not null and descargado is null
                            returning 'ok'`
                    ,[idInstalacion, params.hoja_de_ruta]).fetchUniqueValue();
                }catch(err){
                    if(err.code=='54011!'){
                        throw new Error(`No se encuentra el la instalación ${idInstalacion} en reltar`);
                    }
                }   
                return 'backup completado';
            }catch(err){
                console.log('ERROR',err);
                throw err;
            }
        }
    },   
    {
        action: 'dm2_backup_pre_recuperar',
        parameters:[
            {name:'periodo'  , typeName:'text', references:'periodos' },
            {name:'panel'    , typeName:'integer'},
            {name:'tarea'    , typeName:'integer' },
        ],
        resultOk:'mostrar_datos_backup',
        roles:['programador'],
        coreFunction:async function(context, params){
            try{
                var reltarRecord = (await context.client.query(
                    `select * from reltar where periodo = $1 and panel = $2 and tarea = $3`,
                    [params.periodo, params.panel, params.tarea]
                ).fetchUniqueRow()).row;
                return reltarRecord;
            }catch(err){
                throw Error("No se encuentra registro en reltar para ese periodo, panel, tarea. " + err.message)
            }
        }
    },
    {
        action: 'dm2_backup_recuperar',
        parameters:[
            {name:'id_instalacion'  , typeName:'integer' },
            {name:'hoja_de_ruta'    , typeName:'jsonb'},
        ],
        roles:['programador'],
        coreFunction:async function(context, params){
            var be = context.be;
            var {hoja_de_ruta, id_instalacion} = params;
            try{
                var token_instalacion = (await context.client.query(
                    `select token_instalacion from instalaciones where id_instalacion = $1`,
                    [id_instalacion]
                ).fetchUniqueValue()).value;
            }catch(err){
                if(err.code=='54011!'){
                    throw new Error(`No se encuentra el token_instalacion para el id de instalación ${id_instalacion}.`);
                }
            }
            var parameters = {
                token_instalacion,
                hoja_de_ruta,
                custom_data: false,
                current_token: null
            }
            return await be.procedure.dm2_descargar.coreFunction(context, parameters)
        }
    },
    {
        action: 'dm2_rescatar',
        parameters:[
            {name:'localStorageItem'       , typeName:'jsonb'},
            {name:'localStorageItemKey'    , typeName:'text'},
        ],
        unlogged:true,
        coreFunction:async function(context, params){
            var {localStorageItemKey, localStorageItem} = params;
            try{
                console.log(localStorageItem);
                await fs.appendFile('local-rescate.txt', JSON.stringify({now:new Date(),user:context.username, itemKey: localStorageItemKey, itemData: localStorageItem})+'\n\n', 'utf8');
                return 'ok';
            }catch(err){
                console.log('ERROR',err);
                throw err;
            }
        }
    },
    {
        action:'dm2_carga_blanquear',
        parameters:[
            {name:'periodo'           , typeName:'text'    , references:'periodos'},
            {name:'panel'             , typeName:'integer' },
            {name:'tarea'             , typeName:'integer' },
        ],
        coreFunction: async function(context, parameters){
            try{
                await context.client.query(
                    `update reltar
                        set cargado = null, id_instalacion = null, vencimiento_sincronizacion2 = null
                        where periodo = $1 and panel = $2 and tarea = $3 and cargado is not null and descargado is null
                        returning true`
                    ,
                    [parameters.periodo, parameters.panel, parameters.tarea]
                ).fetchUniqueRow();
            }catch(err){
                throw new Error("Solo se permiten blanquear DMs con fecha de carga y sin fecha de descarga. " + err.message);
            }
            return "ok"
        }
    },
    {
        action:'paneltarea_buscar',
        parameters:[
            {name:'periodo'    , typeName:'text'   , references:'periodos'   },
            {name:'panel'      , typeName:'integer'                          },
            {name:'tarea'      , typeName:'integer'                          },
            {name:'otropanel'  , typeName:'integer'                          },
            {name:'otratarea'  , typeName:'integer'                          },
        ],
        roles:['programador', 'coordinador', 'analista'],
        coreFunction:function(context, parameters){
            return context.client.query(
                `SELECT rv.periodo, rv.informante, rv.visita, rv.formulario, rv.panel, rv.tarea, rt.panel otropanel, rt.tarea otratarea
                FROM relvis rv
                JOIN reltar rt ON rv.periodo = rt.periodo
                WHERE rv.periodo = $1 and rv.panel = $2 and rv.tarea = $3 and rt.panel = $4 and rt.tarea = $5;`,
                [parameters.periodo,parameters.panel,parameters.tarea,parameters.otropanel,parameters.otratarea]
            ).fetchAll().then(function(result){
                return result.rows;
            }).catch(function(err){
                console.log(err);
                console.log(err.code);
                throw err;
            });
        }
    },
    {
        action:'paneltarea_cambiar',
        //mover todo un panel-tarea a otro
        parameters:[
            {name:'periodo'     , typeName:'text'   , references:'periodos'   },
            {name:'panel'       , typeName:'integer'                          },
            {name:'tarea'       , typeName:'integer', references:'tareas'     },
            {name:'otropanel'   , typeName:'integer'                          },
            {name:'otratarea'   , typeName:'integer', references:'tareas'     },
        ],
        roles:['programador', 'coordinador', 'analista'],
        coreFunction: async function(context, parameters){
            var be=context.be;
            var esIntercambiar = false;
            let result = await paneltarea_mover(context, parameters, esIntercambiar);
            return result;
        }
    },
    {
        action:'paneltarea_intercambiar',
        //intercambiar entre dos paneles-tarea
        parameters:[
            {name:'periodo'     , typeName:'text'   , references:'periodos'   },
            {name:'panel'       , typeName:'integer'                          },
            {name:'tarea'       , typeName:'integer', references:'tareas'     },
            {name:'otropanel'   , typeName:'integer'                          },
            {name:'otratarea'   , typeName:'integer', references:'tareas'     },
        ],
        roles:['programador','coordinador', 'analista'],
        coreFunction: async function(context, parameters){
            var be=context.be;
            var esIntercambiar = true;
            let result = await paneltarea_mover(context, parameters, esIntercambiar);
            return result;
        }
    },
    {
        action:'paneltarea_cambiaruninf',
        // mover un informante-formulario particular de un panel-tarea a otro
        parameters:[
            {name:'periodo'     , typeName:'text'   , references:'periodos'   },
            {name:'informante'  , typeName:'integer', references:'informantes'},
            {name:'visita'      , typeName:'integer'                          },
            {name:'formulario'  , typeName:'integer', references:'formularios'},
            {name:'otropanel'   , typeName:'integer'                          },
            {name:'otratarea'   , typeName:'integer'                          },
            {name:'panel'       , typeName:'integer'                          },
            {name:'tarea'       , typeName:'integer'                          },
        ],
        roles:['programador','coordinador', 'analista'],
        coreFunction: async function(context, parameters){
            var be=context.be;
            var esIntercambiar = false;
            let result = await paneltarea_mover(context, parameters, esIntercambiar);
            return result;
        }
    },
    {
        action:'altamanualconfirmar_touch',
        parameters:[
            {name:'informante', typeName:'integer', references:'informantes'},
        ],
        roles:['programador','analista','coordinador'],
        coreFunction:function(context, parameters){
            return context.client.query(
                `UPDATE informantes SET altamanualconfirmar = current_timestamp 
                   WHERE informante = $1
                   RETURNING altamanualperiodo,altamanualpanel,altamanualtarea, altamanualconfirmar`,
                [parameters.informante]
            ).fetchUniqueRow().then(function(result){
                return 'generado Periodo: '+result.row.altamanualperiodo+' Panel: '+result.row.altamanualpanel+ ' Tarea: '+result.row.altamanualtarea +' '+result.row.altamanualconfirmar.toHms();
            }).catch(function(err){
                if(err.code=='54011!'){
                    throw new Error('El perido no esta abierto para ingreso');
                }
                console.log(err);
                console.log(err.code);
                throw err;
            });
        }
    },
    {
        action:'fechaprocesado_touch',
        parameters:[
            {name:'id_lote'       , typeName:'integer'  , references:'cambiopantar_lote'}
        ],
        roles:['programador','coordinador','analista'],
        coreFunction:function(context, parameters){
            return context.client.query(
                `UPDATE cambiopantar_lote SET fechaprocesado = current_timestamp 
                   WHERE id_lote = $1 and fechaprocesado is null
                   RETURNING fechaprocesado`,
                [parameters.id_lote]
            ).fetchUniqueRow().then(function(result){
            return 'procesado: ' + result.row.fechaprocesado;
            }).catch(function(err){
                if(err.code=='54011!'){
                    throw new Error('El lote ya ha sido procesado');
                }
                console.log(err);
                console.log(err.code);
                throw err;
            });
        }
    },
    {
        action:'unificar_valores_atributos_exportar',
        parameters:[
            {name:'periodo'     , typeName:'text'   , references:'periodos'   },
        ],
        roles:['programador','coordinador','analista'],
        forExport:{
        },
        coreFunction:async function(context/*:ProcedureContext*/, parameters/*:CoreFunctionParameters*/){
                var nombre = 'unificacionDeMarcas_' + parameters.periodo + '_' + datetime.now().toYmdHms().replace(/[: -/]/g,'');
                return [
                /*{
                    title:'agrupaciones',
                    rows: (
                        await context.client.query(`select * from agrupaciones order by agrupacion`).fetchAll()
                    ).rows.map(r=>{return r; })
                },
                {
                    title:'divisiones',
                    rows: (
                        await context.client.query(`select * from divisiones order by division`).fetchAll()
                    ).rows
                }*/
                {   title:'unificacionDeMarcasTitle',
                    fileName: nombre + '.xlsx',
                    csvFileName: nombre + '.csv',
                    rows:(
                        await context.client.query(`select rm.periodo, v.panel, v.tarea, rm.producto, p.nombreproducto, 
                        rm.informante, rm.visita, rm.observacion, rm.formulario,
                        rm.atributo, rm.nombreatributo, rm.valor, 
                        r.atributo as atributo_2, r.nombreatributo as nombreatributo_2, r.valor as valor_2, 
                        rn.atributo as atributo_3, rn.nombreatributo as nombreatributo_3, rn.valor as valor_3,
                        rs.atributo as atributo_4, rs.nombreatributo as nombreatributo_4, rs.valor as valor_4,
                        rm.comentariosrelpre as comentarios
                        from (select rp.formulario, ra.*, rp.comentariosrelpre, a2.nombreatributo 
                                from cvp.relpre rp 
                                join cvp.tipopre t on rp.tipoprecio = t.tipoprecio
                                join cvp.relatr ra on rp.periodo = ra.periodo and rp.informante = ra.informante and rp.producto = ra.producto 
                                        and rp.visita = ra.visita and rp.observacion = ra.observacion 
                                join cvp.atributos a2 on ra.atributo = a2.atributo 
                                where a2.nombreatributo = 'Marca' and rp.periodo = $1 and t.espositivo = 'S') rm
                             join cvp.relvis v on v.periodo = rm.periodo and v.informante = rm.informante and v.visita = rm.visita and v.formulario = rm.formulario  
                             join cvp.productos p on rm.producto = p.producto
                             left join 
                             (select rp.formulario, ra.* , a1.nombreatributo
                                from cvp.relpre rp 
                                join cvp.tipopre t on rp.tipoprecio = t.tipoprecio
                                join cvp.relatr ra on rp.periodo = ra.periodo and rp.informante = ra.informante and rp.producto = ra.producto 
                                                  and rp.visita = ra.visita and rp.observacion = ra.observacion
                                join cvp.atributos a1 on ra.atributo = a1.atributo
                                join cvp.prodatr pa on rp.producto = pa.producto and ra.atributo = pa.atributo
                                where pa.normalizable = 'S' and rp.periodo = $1 and t.espositivo = 'S') r 
                                on r.periodo = rm.periodo and r.informante = rm.informante and r.producto = rm.producto 
                                and r.observacion = rm.observacion and r.visita = rm.visita
                            left join 
                            (select rp.formulario, ra.* , a2.nombreatributo
                                from cvp.relpre rp 
                                join cvp.tipopre t on rp.tipoprecio = t.tipoprecio
                                join cvp.relatr ra on rp.periodo = ra.periodo and rp.informante = ra.informante and rp.producto = ra.producto 
                                                  and rp.visita = ra.visita and rp.observacion = ra.observacion
                                join cvp.atributos a2 on ra.atributo = a2.atributo
                                where a2.nombreatributo = 'Nombre' and rp.periodo = $1 and t.espositivo = 'S') rn 
                                   on rm.periodo = rn.periodo and rm.informante = rn.informante and rm.producto = rn.producto 
                                   and rm.observacion = rn.observacion and rm.visita = rn.visita
                            left join 
                            (select rp.formulario, ra.* , a3.nombreatributo
                               from cvp.relpre rp 
                               join cvp.tipopre t on rp.tipoprecio = t.tipoprecio
                               join cvp.relatr ra on rp.periodo = ra.periodo and rp.informante = ra.informante and rp.producto = ra.producto 
                                                  and rp.visita = ra.visita and rp.observacion = ra.observacion
                               join cvp.atributos a3 on ra.atributo = a3.atributo
                               where a3.nombreatributo = 'Sabor' and rp.periodo = $1 and t.espositivo = 'S') rs 
                                  on rm.periodo = rs.periodo and rm.informante = rs.informante and rm.producto = rs.producto 
                                  and rm.observacion = rs.observacion and rm.visita = rs.visita`, [parameters.periodo]).fetchAll()
                    ).rows
                }
            ]
        }
    },
    {
        action:'calobs_ampliado_exportar',
        parameters:[
            {name:'periododesde'     , typeName:'text'   , references:'periodos'   },
            {name:'periodohasta'     , typeName:'text'   , references:'periodos'   },
        ],
        roles:['programador','coordinador','analista'],
        forExport:{
        },
        coreFunction:async function(context/*:ProcedureContext*/, parameters/*:CoreFunctionParameters*/){
            var nombre = 'calobsAmpliado_' + parameters.periododesde + '_' + parameters.periodohasta + '_'+ datetime.now().toYmdHms().replace(/[: -/]/g,'');
            return [
                {   title:'calobsAmpliadoTitle',
                    fileName: nombre + '.xlsx',
                    csvFileName: nombre + '.csv',
                    rows:(
                        await context.client.query(`select c.periodo, c.calculo, c.producto, p.cluster, c.informante, i.nombreinformante, i.tipoinformante,c.observacion, c.division, c.promobs, 
                        c.impobs, c.antiguedadconprecio, c.antiguedadsinprecio, c.antiguedadexcluido, c.antiguedadincluido, c.sindatosestacional, v.panel, v.encuestador
                        , r.visita, r.precio, r.tipoprecio, r.cambio, case when c.antiguedadexcluido>0 then 'X' else null end as excluido
                        , case when ((z.escierredefinitivoinf = 'S' or z.escierredefinitivofor = 'S') or v.informante is null and c.promobs is not null and vv.informante is null) then 'Inactivo ' else null end as inactivo
                        , v.razon, ra.valor as marca, r.comentariosrelpre, rt.modalidad
                        from calobs c
                        join calculos_def cd on c.calculo = cd.calculo
                        join productos p on c.producto = p.producto
                        join informantes i on c.informante = i.informante
                        LEFT join relpre r on c.periodo = r.periodo and c.informante = r.informante and c.producto = r.producto and c.observacion = r.observacion
                        LEFT join relvis v on r.periodo = v.periodo and r.informante = v.informante and r.formulario = v.formulario and r.visita = v.visita
                        LEFT join reltar rt on v.periodo = rt.periodo and v.panel = rt.panel and v.tarea = rt.tarea 
                        LEFT JOIN razones z ON v.razon = z.razon 
                        LEFT JOIN forprod fp ON c.producto = fp.producto 
                        LEFT JOIN formularios formu ON formu.formulario = fp.formulario 
                        JOIN cvp.forinf fi ON fp.formulario = fi.formulario and c.informante = fi.informante 
                        LEFT JOIN cvp.relvis vv on c.periodo = vv.periodo and fi.informante = vv.informante and fi.formulario = vv.formulario and vv.ultima_visita
                        LEFT JOIN (SELECT * from relatr r join atributos a using(atributo) where nombreatributo = 'Marca') ra 
                        on r.periodo = ra.periodo and r.informante = ra.informante and r.visita = ra.visita and r.observacion = ra.observacion and r.producto = ra.producto
                        where cd.principal and c.periodo >= $1 and c.periodo <= $2 and p.cluster is distinct from 3 and formu.activo = 'S'
                        order by c.periodo, c.calculo, c.producto, c.informante, c.observacion, r.visita`, [parameters.periododesde, parameters.periodohasta]).fetchAll()
                    ).rows
                }
            ]
        }
    },
    {
        action:'relpre_exportar',
        parameters:[
            {name:'periodo'     , typeName:'text'      , references:'periodos'   },
        ],
        roles:['programador','coordinador','analista'],
        forExport:{
        },
        coreFunction:async function(context/*:ProcedureContext*/, parameters/*:CoreFunctionParameters*/){
            var nombre = 'relpre_' + parameters.periodo + '_' + datetime.now().toYmdHms().replace(/[: -/]/g,'');
            return [
                {   title:'relpreExportarTitle',
                    fileName: nombre + '.xlsx',
                    csvFileName: nombre + '.csv',
                    rows:(
                        await context.client.query(`select r.periodo, 
                        r.producto,
                        o.nombreproducto as productos__nombreproducto,
                        o.cluster as productos__cluster,
                        r.informante,
                        i.nombreinformante as informantes__nombreinformante,
                        i.tipoinformante as informantes__tipoinformante,
                        i.cluster as informantes__cluster,
                        r.formulario, 
                        r.visita, 
                        r.observacion, 
                        r.precio, 
                        r.tipoprecio, 
                        r.cambio, 
                        CASE WHEN p.periodo is not null THEN 'R' ELSE null END as repregunta,
                        CASE WHEN c.antiguedadexcluido>0 and r.precio>0 THEN 'x' ELSE null END as excluido, 
                        CASE WHEN distanciaperiodos(r.periodo,re.ultimoperiodoconprecio)-1>0 
                             THEN distanciaperiodos(r.periodo,re.ultimoperiodoconprecio)-1 
                             ELSE NULL 
                        END as cantidadperiodossinprecio,	   
                        r_1.precio_1 as precioanterior, 
                        r_1.tipoprecio_1 as tipoprecioanterior, 
                        CASE WHEN r_1.precio_1 > 0 and r_1.precio_1 <> r.precio 
                             THEN round((r.precio/r_1.precio_1*100-100)::decimal,1)::TEXT||'%' 
                             ELSE CASE WHEN c_1.promobs > 0 and c_1.promobs <> r.precionormalizado and r_1.precio_1 is null 
                                       THEN round((r.precionormalizado/c_1.promobs*100-100)::decimal,1)::TEXT||'%' 
                                       ELSE NULL 
                                  END 
                        END AS masdatos,
                        r.comentariosrelpre, 
                        r.esvisiblecomentarioendm,
                        r_1.comentariosrelpre_1 as comentariosanterior,                  
                        r.precionormalizado,
                        case when r.ultima_visita is true then null else true end as agregarvisita,
                        v.panel
                 from relpre r
                      inner join productos o on r.producto = o.producto
                      inner join informantes i on r.informante = i.informante
                      inner join relvis v on r.periodo = v.periodo and r.informante = v.informante and r.formulario = v.formulario and r.visita = v.visita
                      inner join forprod fp on r.producto = fp.producto and r.formulario = fp.formulario                      left join relpre_1 r_1 on r.periodo=r_1.periodo and r.producto = r_1.producto and r.informante=r_1.informante and r.visita = r_1.visita and r.observacion = r_1.observacion
                      left join prerep p on r.periodo = p.periodo and r.producto = p.producto and r.informante = p.informante
                      left join (select cobs.* from calobs cobs join calculos_def cdef on cobs.calculo = cdef.calculo where cdef.principal) c on r.periodo = c.periodo and r.producto = c.producto and r.informante = c.informante and r.observacion = c.observacion
                      left join calobs c_1 on r_1.periodo_1 = c_1.periodo and r.producto = c_1.producto and r.informante = c_1.informante and r.observacion = c_1.observacion and c_1.calculo = c.calculo
                      , lateral (select max(periodo) ultimoperiodoconprecio 
                               from relpre
                               where precio is not null and r.informante = informante and r.producto = producto and r.observacion = observacion and r.visita = visita 
                               and periodo < r.periodo) re
                        where r.periodo = $1 order by fp.orden, r.observacion`, [parameters.periodo]).fetchAll()
                    ).rows
                }
            ]
        }
    },    
    {
        action:'control_ajustes_exportar',
        parameters:[
            {name:'periodo'     , typeName:'text'   , references:'periodos'   },
        ],
        roles:['programador','coordinador','analista'],
        forExport:{
        },
        coreFunction:async function(context/*:ProcedureContext*/, parameters/*:CoreFunctionParameters*/){
            var nombre = 'controlAjustes_' + parameters.periodo + '_' + datetime.now().toYmdHms().replace(/[: -/]/g,'');
            return [
                {   title:'controlAjustesExportarTitle',
                    fileName: nombre  + '.xlsx',
                    csvFileName: nombre  + '.csv',
                    rows:(
                        await context.client.query(`select periodo, panel, tarea, informante, tipoinformante, visita, formulario, grupo_padre_1, 
                        nombregrupo_1, grupo_padre_2, nombregrupo_2, grupo_padre_3, nombregrupo_3, c.producto, p.nombreproducto, p.cluster, observacion, 
                        precionormalizado, tipoprecio, cambio, variacion_1, varia_1, precionormalizado_1, 
                        tipoprecio_1, cambio_1, variacion_2, varia_2, precionormalizado_2, tipoprecio_2, cambio_2, varia_ambos 
                        from control_ajustes c 
                        join productos p on c.producto = p.producto
                        where c.periodo = $1`, [parameters.periodo]).fetchAll()
                    ).rows
                }
            ]
        }
    },
    {
        action:'revisor_exportar',
        parameters:[
            {name:'periododesde'     , typeName:'text'   , references:'periodos'   },
            {name:'periodohasta'     , typeName:'text'   , references:'periodos'   },
            {name:'producto'         , typeName:'text'   , references:'productos'  },
            {name:'proceso'          , typeName:'text'   , defaultValue: 'MatrizVPT' /*['MatrizVPT','Matriz','MatrizV']*/ },
        ],
        //roles:['programador','coordinador','analista'],
        roles:['programador'],
        forExport:{
        },
        coreFunction:async function(context/*:ProcedureContext*/, parameters/*:CoreFunctionParameters*/){
            var nombre = 'revisor_' + parameters.periododesde + '_'+ parameters.periodohasta + '_' + parameters.producto + '_'+ datetime.now().toYmdHms().replace(/[: -/]/g,'');
            try{
                var previusResult = await context.client.query(
                    `select * from revisorFilasPreparar($1,$2,$3,$4)`, [parameters.periododesde, parameters.periodohasta, parameters.producto, parameters.proceso]
                ).execute(); 
                var result = await context.client.query(
                    `select * from revisorResumenPreparar($1,$2,$3,$4)`, [parameters.periododesde, parameters.periodohasta, parameters.producto, parameters.proceso]
                ).execute(); 
                return [
                    {
                        title:'revisorResumen '+parameters.producto,
                        fileName: nombre + '.xlsx',
                        csvFileName: nombre + '.csv',
                        rows: (
                            await context.client.query(`select * from revisorResumenCrear()`).fetchAll()
                        ).rows
                    },
                    {
                        title:'revisorFilas '+parameters.producto,
                        fileName: nombre + '.xlsx',
                        csvFileName: nombre + '.csv',
                        rows: (
                            await context.client.query(`select * from revisorFilasCrear()`).fetchAll()
                        ).rows
                    }
    
                ]
                }catch(err){
                    console.log(err);
                    console.log(err.code);
                    throw err;
                };
        }
    },
    {
        action:'controlvigencias_exportar',
        parameters:[
            {name:'periodo'     , typeName:'text'      , references:'periodos'   },
        ],
        roles:['programador','coordinador','analista'],
        forExport:{
        },
        coreFunction:async function(context/*:ProcedureContext*/, parameters/*:CoreFunctionParameters*/){
            var nombre = 'controlvigencias_' + parameters.periodo + '_' + datetime.now().toYmdHms().replace(/[: -/]/g,'');
            return [
                {   title:'vigenciasExportarTitle',
                    fileName: nombre + '.xlsx',
                    csvFileName: nombre + '.csv',
                    rows:(
                        await context.client.query(`select periodo, informante, producto, nombreproducto, observacion, valor,
                        cantdias, ultimodiadelmes, visitas, vigencias, comentarios, tipoprecio, cantnegativos, cantpositivos 
                        FROM controlvigencias
                        WHERE periodo =  $1`, [parameters.periodo]).fetchAll()
                    ).rows
                }
            ]
        }
    },
    {
        action:'relpre_control_atr2_diccionario_atributos_exportar',
        parameters:[
            {name:'periodo'     , typeName:'text'      , references:'periodos'   },
        ],
        roles:['programador','coordinador','analista','recepcionista','jefeCampo'],
        forExport:{
        },
        coreFunction:async function(context/*:ProcedureContext*/, parameters/*:CoreFunctionParameters*/){
            var nombre = 'relpre_control_atr2_diccionario_atributos_' + parameters.periodo + '_' + datetime.now().toYmdHms().replace(/[: -/]/g,'');
            return [
                {   title:'relpre_control_atr2_dicatrTitle',
                    fileName: nombre + '.xlsx',
                    csvFileName: nombre + '.csv',
                    rows:(
                        await context.client.query(`select a.periodo, vis.panel, vis.tarea, a.producto, 
                        o.nombreproducto productos__nombreproducto, o.cluster productos__cluster,
                        a.informante, i.nombreinformante informantes__nombreinformante, i.tipoinformante informantes__tipoinformante,
                        i.cluster informantes__cluster, pre.formulario, a.visita, a.observacion, 
                        a.atributo, a1.nombreatributo atributos__nombreatributo, a.valor, aa.atributo atributo_2, a2.nombreatributo atr__nombreatributo,
                        aa.valor valor_2, p.valor_2 valido_2, pre.comentariosrelpre, pre.esvisiblecomentarioendm  
                              from relpre pre
                              join informantes i on pre.informante = i.informante
                              join relatr a on a.periodo = pre.periodo and a.informante = pre.informante and a.producto = pre.producto and a.visita = pre.visita and a.observacion = pre.observacion
                              join atributos a1 on a.atributo = a1.atributo
                              join prodatr pa on a.producto = pa.producto and a.atributo = pa.atributo 
                              join productos o on a.producto = o.producto
                              join relvis vis on pre.periodo = vis.periodo and pre.informante = vis.informante and pre.visita = vis.visita and pre.formulario = vis.formulario   
                              left join prodatrval p on a.producto = p.producto and a.atributo = p.atributo and a.valor = p.valor
                              left join tipopre t on pre.tipoprecio = t.tipoprecio
                              left join relatr aa on a.periodo = aa.periodo and a.informante = aa.informante and a.producto = aa.producto and a.observacion = aa.observacion 
                                                 and a.visita = aa.visita and aa.atributo = p.atributo_2  
                              left join atributos a2 on aa.atributo = a2.atributo
                              where coalesce(pa.validaropciones, true) and p.valor is not null and t.activo ='S' and t.espositivo = 'S' and p.atributo_2 is not null and aa.periodo is not null
                              and case when p.valor_2 ~ aa.valor then 1 else 0 end = 0
                              and pre.periodo =  $1`, [parameters.periodo]).fetchAll()
                    ).rows
                }
            ]
        }
    },
];

module.exports = ProceduresIpcba;