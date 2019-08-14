"use strict";
var likeAr = require('like-ar');
var pg = require('pg-promise-strict');
pg.easy=true;

var MiniTools = require('mini-tools');
//var Comunes = require('./comunes');
//var Tedede = require('./tedede2');

var bestGlobals = require('best-globals');
var datetime = bestGlobals.datetime;
var timeInterval = bestGlobals.timeInterval;

const periodo_inicial = 'a2012m07';
const agrupacion = 'E';

var ProceduresIpcba = {};
var cuadro = [];

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
                `UPDATE calculos SET fechacalculo = current_timestamp(0) 
                   WHERE periodo=$1 
                     AND calculo=$2 AND abierto='S'
                   RETURNING fechacalculo`,
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
        roles:['programador','coordinador','analista','jefe_campo','supervisor'],
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
        roles:['programador','coordinador','analista','jefe_campo','supervisor'],
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
        coreFunction:async function(context, parameters){
            var now = datetime.now();
            try{
                var persona = await context.client.query(
                    `select *
                        from personal 
                        where token_instalacion = $1`
                    ,
                    [parameters.token_instalacion]
                ).fetchUniqueRow();
                var result = await context.client.query(
                    `select * 
                        from reltar
                        where encuestador = $1 and 
                              vencimiento_sincronizacion is not null and 
                              vencimiento_sincronizacion > current_timestamp`
                    ,
                    [persona.row.persona]
                ).fetchAll();
                return result.rows[0]?result.rows[0]:null
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
        progress:true,
        roles:['programador','coordinador','analista','jefe_campo','recepcionista'],
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
            await context.client.query(
                `update reltar
                    set cargado = current_timestamp, descargado = null, token_instalacion = $4
                    where periodo = $1 and panel = $2 and tarea = $3`
                ,
                [params.periodo, params.panel, params.tarea, params.token_instalacion]
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
                await context.client.query(
                    `update reltar
                        set vencimiento_sincronizacion = $4
                        where periodo = $1 and panel = $2 and tarea = $3`
                    ,
                    [parameters.periodo, parameters.panel, parameters.tarea, tokenDueDate]
                ).execute();
                return 'ok'
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
                            join instalaciones i using (token_instalacion)
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
        coreFunction:async function(context, params){
            var now = datetime.now();
            var token = params.numero_encuestador + params.numero_ipad + now;
            try{
                var result = await context.client.query(
                    `insert into instalaciones (token_instalacion, fecha_hora, encuestador, ipad, version_sistema, token_original) 
                        values (md5($1), $2, $3, $4, $5, coalesce($6,md5($1)))
                        returning token_instalacion, encuestador, ipad`
                    ,
                    [token, now, params.numero_encuestador, params.numero_ipad,params.version_sistema, params.token_original]
                ).fetchUniqueRow();
                await context.client.query(
                    `update personal
                        set ipad = $1, token_instalacion = $2
                        where persona = $3`
                    ,
                    [result.row.ipad, result.row.token_instalacion, result.row.encuestador]
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
        coreFunction:async function(context, params){
            var token = params.token_instalacion;
            try{
                var result = await context.client.query(
                    `update reltar
                      set descargado = current_timestamp
                      where token_instalacion = $1 and vencimiento_sincronizacion > current_timestamp
                      returning *`
                ,[token]).fetchAll();
                if(result.rowCount){
                    var data = JSON.parse(params.data);
                    var promiseChain = Promise.resolve();
                    data.mobile_visita.forEach(function(row){
                        promiseChain = promiseChain.then(async function(){
                            try{
                                await context.client.query(`
                                    update relvis
                                    set razon = $1, comentarios = $6
                                    where periodo = $2 and informante = $3 and visita = $4 and formulario = $5
                                    --pk verificada`
                                ,[row.razon, row.periodo, row.informante, row.visita, row.formulario, row.comentarios]).execute()
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
];

module.exports = ProceduresIpcba;