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

const ESPECIFICACION_COMPLETA=`
        COALESCE(trim(e.nombreespecificacion)|| '. ', '')  
            ||COALESCE(
                NULLIF(TRIM(
                    COALESCE(trim(e.envase)||' ','')||
                    CASE WHEN e.mostrar_cant_um='N' THEN ''
                    ELSE COALESCE(e.cantidad::text||' ','')||COALESCE(e.UnidadDeMedida,'') END),'')|| '. '
            , '') 
            ||(SELECT 
              string_agg(
               CASE WHEN a.tipodato='N' AND a.visible = 'S' AND t.rangodesde IS NOT NULL AND t.rangohasta IS NOT NULL THEN 
                  CASE WHEN t.visiblenombreatributo = 'S' THEN a.nombreatributo||' ' ELSE '' END||
                  'de '||t.rangodesde||' a '||t.rangohasta||' '||COALESCE(a.unidaddemedida, a.nombreatributo, '')
                  ||CASE WHEN t.alterable = 'S' AND t.normalizable = 'S' AND NOT(t.rangodesde <= t.valornormal AND t.valornormal <= t.rangohasta) THEN ' ó '||t.valornormal||' '||a.unidaddemedida ELSE '' END||'. '
                ELSE ''
               END,'' ORDER BY t.orden)
               FROM prodatr t INNER JOIN atributos a USING (atributo)
               WHERE t.producto=p.producto
              )
            ||COALESCE('Excluir ' || trim(e.excluir) || '. ', '') AS EspecificacionCompleta`

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
    console.log("params ",params);
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
        action:'fechacalculo_touch',
        parameters:[
            {name:'periodo', typeName:'text', references:'periodos'},
            {name:'calculo', typeName:'integer'                    },
        ],
        roles:['programador','coordinador','analista'],
        coreFunction:function(context, parameters){
            //context.informProgress({message:'cálculo lanzado'});
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
                    `UPDATE relpre SET precio = precioblanqueado, tipoprecio = tipoprecioblanqueado, cambio = cambioblanqueado,
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
                `INSERT INTO calculos_def (calculo,definicion)
                 SELECT m.calculo,'Copia del Calculo' definicion from 
                    (select periodo,max(calculo)+1 calculo
                        from calculos 
                        where periodo=$1
                        group by periodo) m 
                    LEFT JOIN calculos_def d USING (calculo)
                    WHERE d.calculo is null`,
                    [parameters.periodo]).execute();
            var result = await context.client.query(
                `SELECT copiarcalculo(periodo,0,periodo,(
                          select max(calculo)+1
                            from calculos c2
                            where c2.periodo=c.periodo
                          ), $2 )
                   FROM calculos c
                   WHERE periodo=$1 AND calculo=0`,
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
            /*
            console.log('funcion_a_llamar ',funcion_a_llamar);
            console.log('parametros_funcion ', parametros_funcion);
            console.log('separador_decimal ',separador_decimal);
            console.log('encabezado ',encabezado);
            */
            return context.client.query(
                `SELECT * FROM ${funcion_a_llamar}(${parametros_funcion},$1) resultado`,
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
                    console.log(query.substr(0,70).replace(/\n.*$/,''));
                    var result = await ori.query(query).fetchAll();
                    return result.rows;
                }
                async function bulkInsert(tableName, esquema, onerror){
                    context.informProgress({message:'copiando '+tableName});
                    var rows=data[tableName];
                    console.log('INS:',tableName,(rows||{length:'ERROR, SIN DATOS'}).length)
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
                        where p.periodo >= '${periodo_inicial}' and abierto='N' and calculos.calculo = 0
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
                            -- inner join calgru g on d.producto=g.grupo and d.periodo=g.periodo and d.calculo=g.calculo
                        where d.calculo=0 and d.division='0'
                            and p.periodo >= '${periodo_inicial}' and abierto='N'
                        order by producto
                    `);
                    await bulkInsert('calculo_productos',esquema);
                    data.calculo_grupos = await oriquery(`
                        select periodo,agrupacion,grupo,indiceredondeado
                        from calgru g inner join calculos c using (periodo,calculo)
                        where agrupacion in ('Z', 'R', 'S') and nivel in (0,1) and g.calculo = 0  and periodo >= '${periodo_inicial}' 
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
            console.log('listo');
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
                console.log('ERROR',err.message);
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
        ],
        policy:'web',
        progress:true,
        roles:['programador','coordinador','analista','jefe_campo','recepcionista','supervisor'],
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
                    set razon = 0
                    where periodo = $1 and panel = $2 and tarea = $3 and razon is null /*and razon <> 0*/`
                ,
                [params.periodo, params.panel, params.tarea]
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
                console.log('ERROR',err.message);
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
                console.log('ERROR',err.message);
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
                console.log('ERROR',err.message);
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
                ,[idInstalacion.value]).fetchAll();
                if(result.rowCount){
                    var data = JSON.parse(params.data);
                    var promiseChain = Promise.resolve();
                    data.mobile_visita.forEach(function(row){
                        promiseChain = promiseChain.then(async function(){
                            try{
                                await context.client.query(`
                                    update relvis
                                    set razon = $1, comentarios = $6, fechaingreso = current_date, recepcionista = (select persona from personal where username = $7)
                                    where periodo = $2 and informante = $3 and visita = $4 and formulario = $5
                                    --pk verificada`
                                ,[row.razon, row.periodo, row.informante, row.visita, row.formulario, row.comentarios, context.user.usu_usu]).execute()
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
                console.log('ERROR',err.message);
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
        action:'periodobase_correr',
        parameters:[
            {name:'ejecutar', typeName:'boolean'},
        ],
        roles:['programador','migracion'],
        coreFunction:function(context, parameters){
            return context.client.query(
                `SELECT periodobase() where $1`,
                [parameters.ejecutar]
            ).onNotice(function(progressInfo){
                progressInfo.message=progressInfo.message.replace(/comenzo.*finalizo.*demoro.*$/g,'');
                context.informProgress(progressInfo);
            }).fetchUniqueRow().then(function(result){
                return 'periodo base calculado';
            }).catch(function(err){
                if(err.code=='54011!'){
                    throw new Error('El calculo no esta abierto');
                }
                console.log(err);
                console.log(err.code);
                throw err;
            });
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
            await context.client.query(
                `update reltar
                    set cargado = current_timestamp, descargado = null, id_instalacion = $4
                    where periodo = $1 and panel = $2 and tarea = $3`
                ,
                [parameters.periodo, parameters.panel, parameters.tarea, idInstalacion.value]
            ).execute();
            return "ok"
        }
    },
    {
        action:'dm2_archivospreparar',
        parameters:[
            {name:'periodo'           , typeName:'text'    , references:'periodos'},
            {name:'panel'             , typeName:'integer' },
            {name:'tarea'             , typeName:'integer' }
        ],
        policy:'web',
        unlogged: true,
        coreFunction: async function(context, parameters){
            var be = context.be;
            try{
                var sqlEstructura=`
                  SELECT 
                        ${jsono(`
                            SELECT moneda, valor_pesos
                                FROM relmon
                                WHERE periodo = rt.periodo`,
                                'moneda'
                        )} as relmon
                        , ${jsono(`
                            SELECT informante, direccion
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
                            SELECT p.producto, nombreproducto, ${ESPECIFICACION_COMPLETA}, e.destacada as destacado,
                                    ${json(
                                        `SELECT atributo, CASE WHEN mostrar_cant_um='S' THEN true ELSE false END as mostrar_cant_um, valornormal, orden, rangodesde, rangohasta, normalizable='S' as normalizable, prioridad, tiponormalizacion, opciones, 
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
                            SELECT razon, nombrerazon, espositivoformulario='S' as espositivoformulario, escierredefinitivoinf='S' as escierredefinitivoinf, escierredefinitivofor='S' as escierredefinitivofor
                                FROM razones
                                WHERE visibleparaencuestador='S'`, 
                            'razon'
                        )} as razones
                    FROM reltar rt
                    WHERE rt.periodo=$1 AND rt.panel=$2 AND rt.tarea=$3
                `;
                var sqlAtributos=`
                    SELECT ra.periodo, ra.visita, ra.informante, formulario, ra.producto, ra.observacion, ra.atributo, ra.valor, ra_1.valor as valoranterior, pa.orden
                        FROM relatr ra 
                            INNER JOIN relatr ra_1 
                                ON ra_1.periodo = rp.periodo_1
                                AND ra_1.visita = ra.visita
                                AND ra_1.informante = ra.informante
                                AND ra_1.producto=ra.producto
                                AND ra_1.observacion=ra.observacion
                                AND ra_1.atributo=ra.atributo
                            INNER JOIN prodatr pa on ra.producto=pa.producto and ra.atributo = pa.atributo
                        WHERE ra.periodo=rp.periodo 
                            AND ra.visita=rp.visita 
                            AND ra.informante=rp.informante 
                            AND ra.producto=rp.producto
                            AND ra.observacion=rp.observacion`
                var sqlObservaciones=`                
                    SELECT rp.periodo, visita, rp.informante, rp.formulario, rp.producto, rp.observacion, rp.precio, precio_1 as precioanterior, rp.tipoprecio,  tipoprecio_1 as tipoprecioanterior,
                            cambio, comentariosrelpre, comentariosrelpre_1, esvisiblecomentarioendm_1, precionormalizado, rp.precionormalizado_1, 
                            f.orden as orden_formulario,
                            fp.orden as orden_producto,
                            p.periodo is not null as repregunta,
                            false as adv,
                            ${json(sqlAtributos, 'orden, atributo')} as atributos,
                            c.promobs as promobs_1,
                            distanciaperiodos(rv.periodo,ultimoperiodoconprecio) cantidadperiodossinprecio,
                            split_part(split_part(re.ultimoperiodoconprecio,' ', 1),'/', 2) || '/' ||  split_part(split_part(re.ultimoperiodoconprecio,' ', 1),'/', 1) ultimoperiodoconprecio,
                            split_part(re.ultimoperiodoconprecio,' ', 2) ultimoprecioinformado,
                            r_his.sinpreciohace4meses = 'S' sinpreciohace4meses
                        FROM relvis rv inner join relpre_1 rp using(periodo, informante, visita, formulario)
                            inner join forprod fp using(formulario, producto)
                            inner join formularios f using (formulario)
                            left join calobs c on c.periodo = rp.periodo_1 and calculo = 0
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
                    SELECT periodo, visita, informante, formulario, CASE WHEN razon is null THEN 1 ELSE razon END as razon, comentarios, visita, orden
                        FROM relvis rv inner join formularios using (formulario)
                        WHERE periodo=rvi.periodo 
                            AND tarea=rvi.tarea
                            AND panel=rvi.panel
                            AND informante=rvi.informante
                    `;
                var sqlInformantes=`
                    SELECT periodo, informante, nombreinformante, direccion, 
                            ${json(sqlFormularios,'orden, formulario')} as formularios,
                            ${json(sqlObservaciones, 'orden_formulario, formulario, orden_producto, producto, observacion')} as observaciones,
                            distanciaperiodos(rvi.periodo, max_periodos.maxperiodoinformado) as cantidad_periodos_sin_informacion
                        FROM relvis rvi INNER JOIN informantes USING (informante),
                        lateral(
                            SELECT 
                                CASE WHEN COUNT(*) > 0 THEN max(periodo) ELSE null END AS maxperiodoinformado
                                    FROM relvis rvis
                                    WHERE razon = 1 and rvis.informante = rvi.informante
                                ) as max_periodos
                        WHERE periodo=rt.periodo 
                            AND panel=rt.panel 
                            AND tarea=rt.tarea
                        GROUP BY periodo, informante, nombreinformante, direccion, panel, tarea, maxperiodoinformado
                    `;
                var sqlHdR=`
                    SELECT encuestador, per.nombre as nombreencuestador, per.apellido as apellidoencuestador,
                            (select ipad from instalaciones where id_instalacion = rt.id_instalacion ) as dispositivo,
                            current_date as fecha_carga,
                            rt.panel, rt.tarea, rt.periodo,
                            ${json(sqlInformantes,'direccion, informante')} as informantes
                        FROM reltar rt INNER JOIN periodos p USING (periodo) inner join personal per on encuestador = per.persona
                        WHERE rt.periodo=$1 
                            AND rt.panel=$2 
                            AND rt.tarea=$3
                `;
                var estructura;
                var hdr;
                
                var resultEstructura = await context.client.query(
                    sqlEstructura,
                    [parameters.periodo, parameters.panel, parameters.tarea]
                ).fetchOneRowIfExists();
                var resultHdR = await context.client.query(
                    sqlHdR,
                    [parameters.periodo, parameters.panel, parameters.tarea]
                ).fetchOneRowIfExists();
                estructura = resultEstructura.row;
                hdr = resultHdR.row;
                if(estructura){
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
                }

                //genero archivos
                const PATH = 'dist/client/carga-dm/';
                const MANIFEST_FILENAME = `${parameters.periodo}p${parameters.panel}t${parameters.tarea}_manifest.manifest`;
                const ESTRUCTURA_FILENAME = `${parameters.periodo}p${parameters.panel}t${parameters.tarea}_estructura.js`;
                const HDR_FILENAME = `${parameters.periodo}p${parameters.panel}t${parameters.tarea}_hdr.json`;
                await fs.writeFile(PATH + ESTRUCTURA_FILENAME, "var structFromManifest=" + JSON.stringify(estructura));
                await fs.writeFile(PATH + HDR_FILENAME, JSON.stringify(hdr));
                var manifest = 
`CACHE MANIFEST
#${parameters.periodo}p${parameters.panel}t${parameters.tarea} ${datetime.now().toHms()}

CACHE:
#--------------------------- JS ------------------------------------
../lib/react.development.js
../lib/react-dom.development.js
../lib/material-ui.development.js
../lib/material-styles.development.js
../lib/clsx.min.js
../lib/redux.js
../lib/react-redux.js
../lib/require-bro.js
../lib/like-ar.js
../lib/best-globals.js
../lib/json4all.js
../lib/js-to-html.js
../lib/redux-typed-reducer.js
../adapt.js
../dm-tipos.js
../dm-funciones.js
../dm-react.js
../ejemplo-precios.js
../unlogged.js
../lib/js-yaml.js
../lib/xlsx.core.min.js
../lib/lazy-some.js
../lib/sql-tools.js
../dialog-promise/dialog-promise.js
../moment/min/moment.js
../pikaday/pikaday.js
../lib/polyfills-bro.js
../lib/big.js
../lib/type-store.js
../lib/typed-controls.js
../lib/ajax-best-promise.js
../my-ajax.js
../my-start.js
../lib/my-localdb.js
../lib/my-websqldb.js
../lib/my-localdb.js.map
../lib/my-websqldb.js.map
../lib/my-things.js
../lib/my-tables.js
../lib/my-inform-net-status.js
../lib/my-menu.js
../lib/my-skin.js
../lib/cliente-en-castellano.js
../client/client.js
../client/menu.js
../client/hoja-de-ruta.js
../client/hoja-de-ruta-react.js
${ESTRUCTURA_FILENAME}
${HDR_FILENAME}

#------------------------------ CSS ---------------------------------
../dialog-promise/dialog-promise.css
../pikaday/pikaday.css
../css/my-things.css
../css/my-tables.css
../css/my-menu.css
../css/menu.css
../css/offline-mode.css
../css/hoja-de-ruta.css
../default/css/my-things.css
../default/css/my-tables.css
../default/css/my-menu.css
../css/ejemplo-precios.css
../default/css/ejemplo-precios.css

#------------------------------ IMAGES ---------------------------------
../img/logo.png
../img/main-loading.gif

NETWORK:
*`
                await fs.writeFile(PATH + MANIFEST_FILENAME, manifest);

                //resultado
                return {status: 'ok', estructura, hdr}
            }catch(err){
                throw err
            }
        }
    },
    {
        action:'dm2_preparar',
        parameters:[
            {name:'periodo'           , typeName:'text'    , references:'periodos'},
            {name:'panel'             , typeName:'integer' },
            {name:'tarea'             , typeName:'integer' },
            {name:'encuestador'       , typeName:'text'    },
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
                await context.client.query(
                    `update relvis
                        set preciosgenerados = true
                        where periodo = $1 and panel = $2 and tarea = $3 and not preciosgenerados`
                    ,
                    [parameters.periodo, parameters.panel, parameters.tarea]
                ).execute();
                var hojaDeRutaConPrecios = await context.client.query(
                    `SELECT count(*) > 0 as tieneprecioscargados
                        FROM relvis
                        WHERE periodo = $1 AND panel = $2 AND tarea = $3 AND razon IS NOT NULL`
                    ,
                    [parameters.periodo, parameters.panel, parameters.tarea]
                ).fetchUniqueValue();
                //creo archivos y traigo hdr
                if(parameters.demo){
                    var {estructura, hdr} = await be.procedure.dm2_archivospreparar.coreFunction(context, parameters)
                }else{
                    var {estructura, hdr} = await be.procedure.dm2_archivospreparar.coreFunction(context, parameters);
                }
                //habilito sincronizacion
                var {vencimientoSincronizacion} = parameters.demo?{vencimientoSincronizacion:null}:await be.procedure.sincronizacion_habilitar.coreFunction(context,parameters);

                //resultado
                return {status: 'ok', vencimientoSincronizacion, estructura, hdr, tieneprecioscargados: hojaDeRutaConPrecios.value}
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
            var content = await fs.readFile(
                `dist/client/carga-dm/${parameters.periodo}p${parameters.panel}t${parameters.tarea}_hdr.json`,
                'utf8'
            );
            return JSON4all.parse(content);
        }
    },
    {
        action: 'dm2_descargar',
        parameters:[
            {name:'token_instalacion'  , typeName:'text' },
            {name:'hoja_de_ruta'       , typeName:'jsonb' },
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
                ,[idInstalacion.value]).fetchAll();
                var tiposDePrecio = await context.client.query(
                    `SELECT tipoprecio, espositivo='S' as espositivo FROM tipopre`
                ,[]).fetchAll();
                tiposDePrecio = likeAr.createIndex(tiposDePrecio.rows, 'tipoprecio');
                if(result.rowCount){
                    var hoja_de_ruta = params.hoja_de_ruta;
                    for(var informante of hoja_de_ruta.informantes){
                        for(var formulario of informante.formularios){
                            try{
                                await context.client.query(`
                                    update relvis
                                        set razon = $1, comentarios = $6, fechaingreso = current_date, recepcionista = (select persona from personal where username = $7)
                                        where periodo = $2 and informante = $3 and visita = $4 and formulario = $5 --pk verificada`
                                ,[formulario.razon, hoja_de_ruta.periodo, formulario.informante, formulario.visita, formulario.formulario, formulario.comentarios, context.user.usu_usu]).execute()
                            }catch(err){
                                throw new Error('Error al actualizar razón para el informante: ' + formulario.informante + ', formulario: ' + formulario.formulario + '. '+ err.message);
                            }
                        };
                        for(var observacion of informante.observaciones){
                            try{
                                observacion.cambio=observacion.cambio=='='?null:observacion.cambio;
                                await context.client.query(`
                                    update relpre
                                        set tipoprecio = $1, precio = $2, cambio = $3, comentariosrelpre = $9
                                        where periodo = $4 and informante = $5 and visita = $6 and producto = $7 and observacion = $8 --pk verificada`
                                ,[
                                    observacion.tipoprecio, 
                                    observacion.precio, 
                                    observacion.cambio,
                                    observacion.periodo, 
                                    observacion.informante, 
                                    observacion.visita, 
                                    observacion.producto, 
                                    observacion.observacion,
                                    observacion.comentariosrelpre
                                ]).execute()
                            }catch(err){
                                throw new Error('Error al actualizar precio para el informante: ' + observacion.informante + ', formulario: ' + observacion.formulario + ', producto: ' + observacion.producto + ', observacion: ' + observacion.observacion +  '. '+ err.message);
                            }
                            for(var atributo of observacion.atributos){
                                //solo actualizo atributo si el tipoprecio es positivo (si el valor es nulo, se guarda nulo)
                                if(observacion.tipoprecio && tiposDePrecio[observacion.tipoprecio].espositivo/* && atributo.valor*/){
                                    try{
                                        await context.client.query(`
                                            update relatr
                                                set valor = $1
                                                where periodo = $2 and informante = $3 and visita = $4 and  producto = $5 and observacion = $6 and atributo = $7 --pk verificada`
                                        ,[
                                            atributo.valor?atributo.valor.toString().trim().toUpperCase():null, 
                                            atributo.periodo, 
                                            atributo.informante, 
                                            atributo.visita, 
                                            atributo.producto, 
                                            atributo.observacion,
                                            atributo.atributo
                                        ]).execute()
                                    }catch(err){
                                        throw new Error('Error al actualizar atributo para el informante: ' + atributo.informante + ', formulario: ' + atributo.formulario + ', producto: ' + atributo.producto + ', observacion: ' + atributo.observacion + ', atributo: ' + atributo.atributo + ', valor: "' + atributo.valor + '". '+ err.message);
                                    }
                                }
                            }
                        }
                    };              
                    return 'descarga completa';
                }else{
                    return 'sincronizacion deshabilitada o vencida para el encuestador ' + params.encuestador
                }
            }catch(err){
                console.log('ERROR',err.message);
                throw err;
            }
        }
    },
];

module.exports = ProceduresIpcba;