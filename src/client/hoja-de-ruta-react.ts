import {html}  from 'js-to-html';
import * as JSON4all from "json4all";
import {LOCAL_STORAGE_STATE_NAME} from "../unlogged/dm-react";

var my=myOwn;

function getVersionSistema(){
    return document.body.getAttribute('app-version');
}

async function cargarDispositivo2(tokenInstalacion:string, encuestador:string){
    var mainLayout = document.getElementById('main_layout')!;
    try{
        var reltarHabilitada = await my.ajax.hojaderuta_traer({
            token_instalacion: tokenInstalacion
        })
    }catch(err){
        var message = 'La sincronización se encuentra deshabilitada o vencida para el encuestador '+ encuestador + '. ' + err.message;
        mainLayout.appendChild(html.p(message).create());
        throw new Error(message)
    }
    var periodo = reltarHabilitada.periodo;
    var panel = reltarHabilitada.panel;
    var tarea = reltarHabilitada.tarea;
    var cargado = reltarHabilitada.cargado;
    var descargado = reltarHabilitada.descargado;
    var id_instalacion = reltarHabilitada.id_instalacion;
    var ipad = reltarHabilitada.ipad;
    var encuestador_instalacion = reltarHabilitada.encuestador_instalacion;
    var nombre = reltarHabilitada.nombre;
    var apellido = reltarHabilitada.apellido;
    var hojaDeRutaEnOtroDispositivo = cargado && !descargado && id_instalacion;
    var cargarFun = async function cargarFun(){
        mainLayout.appendChild(html.img({src:'img/loading16.gif'}).create());
        await my.ajax.dm2_cargar({
            periodo: periodo,
            panel: panel,
            tarea: tarea,
            token_instalacion: tokenInstalacion
        });
        var hdr = await my.ajax.hdr_json_leer({
            periodo: periodo,
            panel: panel,
            tarea: tarea
        });
        localStorage.setItem(LOCAL_STORAGE_STATE_NAME, JSON4all.stringify(hdr));
        mainLayout.appendChild(html.p('Carga completa!, pasando a modo avion...').create());
        localStorage.setItem('descargado',JSON.stringify(false));
        localStorage.setItem('vaciado',JSON.stringify(false));
        history.replaceState(null, null, `${location.origin}/ipcba/hdr?per=${periodo}&pan=${panel}&tar=${tarea}`);
        location.reload();
    }
    if(hojaDeRutaEnOtroDispositivo){
        mainLayout.appendChild(html.div({},[
            html.div({class:'danger'}, `El panel ${panel}, tarea ${tarea} se encuentra cargado en el  dispositivo ${ipad}, 
                en poder de ${nombre} ${apellido} (${encuestador_instalacion}). Si continua no se podrá descargar
                el dispositivo.`
            )
        ]).create());
        var inputForzar = html.input({class:'input-forzar'}).create();
        mainLayout.appendChild(html.div([
            html.div(['Se puede forzar la carga ',inputForzar])
        ]).create());
        var clearButton = html.button({class:'load-ipad-button'},'forzar carga').create();
        mainLayout.appendChild(clearButton);
        clearButton.onclick = async function(){
            if(inputForzar.value=='forzar'){
                await confirmPromise('¿confirma carga de D.M.?',{underElement:clearButton});
                clearButton.disabled=true;
                cargarFun()
            }else{
                alertPromise('si necesita cargar el D.M. escriba forzar.',{underElement:clearButton})
            }
        }
    }else{
        try{
            await confirmPromise(`confirma carga del período ${periodo}, panel ${panel}, tarea ${tarea}`);
            cargarFun();
        }catch(err){
            mainLayout.appendChild(html.p('carga cancelada').create());    
        }
    }
}

function descargarDispositivo2(tokenInstalacion: string, encuestador: string){
    var mainLayout = document.getElementById('main_layout')!;
    var waitGif = mainLayout.appendChild(html.img({src:'img/loading16.gif'}).create());
    mainLayout.appendChild(html.p([
        'descargando, por favor espere',
        waitGif
    ]).create());
    var promiseChain = Promise.resolve();
    var data = {};
    var mobileTables = ['mobile_hoja_de_ruta', 'mobile_visita', 'mobile_precios', 'mobile_atributos'];
    mobileTables.forEach(function(tableName){
        promiseChain = promiseChain.then(function(){
            return my.ldb.getAll(tableName).then(function(results){
                data[tableName] = results;
            });
        })
    });
    promiseChain = promiseChain.then(function(){
        return my.ajax.dm_descargar({
            token_instalacion: tokenInstalacion,
            data: JSON.stringify(data),
            encuestador: encuestador
        }).then(function(message){
            waitGif.style.display = 'none';
            if(message=='descarga completa'){
                localStorage.setItem('descargado',JSON.stringify(true));
            }
            mainLayout.appendChild(html.p(message).create());
        });
    });
    return promiseChain;
}

myOwn.wScreens.sincronizar_dm2=function(){
    var mainLayout = document.getElementById('main_layout')!;
    var tokenInstalacion = localStorage.getItem('token_instalacion') || null;
    var ipad = localStorage.getItem('ipad') || null;
    var encuestador = localStorage.getItem('encuestador') || null;
    if(tokenInstalacion && ipad && encuestador){
        if(localStorage.getItem(LOCAL_STORAGE_STATE_NAME)){
            mainLayout.appendChild(html.p('El dispositivo tiene información cargada').create());
            var downloadButton = html.button({class:'download-ipad-button'},'descargar').create();
            mainLayout.appendChild(downloadButton);
            downloadButton.onclick = function(){
                confirmPromise('¿confirma descarga de D.M.?').then(function(){
                    downloadButton.disabled=true;
                    descargarDispositivo2(tokenInstalacion, encuestador).then(function(){
                        downloadButton.disabled=false;
                    },function(err){
                        alertPromise(err.message);
                        downloadButton.disabled=false;
                    })
                })
            }
        }else{
            mainLayout.appendChild(html.p('El dispositivo no tiene hoja de ruta cargada').create());
            var loadButton = html.button({class:'load-ipad-button'},'cargar').create();
            mainLayout.appendChild(loadButton);
            loadButton.onclick = async function(){
                try{
                    loadButton.disabled=true;
                    await cargarDispositivo2(tokenInstalacion, encuestador);
                    loadButton.disabled=false;
                }catch(err){
                    alertPromise(err.message);
                    loadButton.disabled=false;
                }
            }  
        }
    }else{
        mainLayout.appendChild(html.p('No hay token de instalación, por favor instale el dispositivo').create());
    }
};

myOwn.wScreens.hoja_ruta_2=function(){
    var mainLayout = document.getElementById('main_layout')!;
    try{
        if(localStorage.getItem(LOCAL_STORAGE_STATE_NAME)){
            var {periodo, panel, tarea} = JSON4all.parse(localStorage.getItem(LOCAL_STORAGE_STATE_NAME)!);
            mainLayout.appendChild(html.p('Carga completa!, pasando a modo avion...').create());
            localStorage.setItem('descargado',JSON.stringify(false));
            localStorage.setItem('vaciado',JSON.stringify(false));
            history.replaceState(null, null, `${location.origin}/ipcba/hdr?per=${periodo}&pan=${panel}&tar=${tarea}`);
            location.reload();
        }else{
            throw Error("No hay hoja de ruta cargada")
        }
    }catch(err){
        mainLayout.appendChild(html.p('Error al cargar hoja de ruta. ' + err.message).create());
    }
};

myOwn.wScreens.vaciar_dm2=function(){
    //var mainLayout = document.getElementById('main_layout');
    //var tokenInstalacion = localStorage.getItem('token_instalacion') || null;
    //var ipad = localStorage.getItem('ipad') || null;
    //var encuestador = localStorage.getItem('encuestador') || null;
    //if(tokenInstalacion && ipad && encuestador){
    //    return my.ldb.existsStructure('mobile_hoja_de_ruta').then(function(existsStructure){
    //        if(existsStructure){
    //            return my.ldb.isEmpty('mobile_hoja_de_ruta').then(function(isEmptyLocalDatabase){
    //                var vaciado = JSON.parse(localStorage.getItem('vaciado')||'false');
    //                if(isEmptyLocalDatabase || vaciado){
    //                    mainLayout.appendChild(html.p('El D.M. está vacío.').create());
    //                }else{
    //                    var clearButton = html.button({class:'load-ipad-button'},'vaciar D.M.').create();
    //                    var fueDescargadoAntes = JSON.parse(localStorage.getItem('descargado')||'false');
    //                    var inputForzar = html.input({class:'input-forzar'}).create();
    //                    if(!fueDescargadoAntes){
    //                        mainLayout.appendChild(html.div([
    //                            html.div({class:'danger'},'El dispositivo todavía no fue descargado'),
    //                            html.div(['Se puede forzar el vaciado ',inputForzar])
    //                        ]).create());
    //                    }
    //                    mainLayout.appendChild(clearButton);
    //                    clearButton.onclick = function(){
    //                        if(fueDescargadoAntes || inputForzar.value=='forzar'){
    //                            confirmPromise('¿confirma vaciado de D.M.?',{underElement:clearButton}).then(function(){
    //                                clearButton.disabled=true;
    //                                localStorage.setItem('vaciado',JSON.stringify(true));
    //                            }).then(function(){
    //                                mainLayout.appendChild(html.p('D.M. vaciado correctamente!').create());
    //                            });
    //                        }else{
    //                            alertPromise('si necesita vaciar el D.M. puede forzar.',{underElement:clearButton})
    //                        }
    //                    }
    //                }
    //            });
    //        }else{
    //            mainLayout.appendChild(html.p('No existe la tabla mobile_hoja_de_ruta. Por favor reinstale el dispositivo').create());
    //        }
    //    })
    //}else{
    //    mainLayout.appendChild(html.p('No hay token de instalación, por favor instale el dispositivo').create());
    //}
};

myOwn.wScreens.preparar_instalacion2={
    parameters:[
        {name:'numero_encuestador'       , typeName:'text'   },
        {name:'numero_ipad'              , typeName:'text'   }
    ],
    mainAction:function(params,divResult){
        return my.ajax.instalacion_preparar({
            numero_encuestador: params.numero_encuestador,
            numero_ipad: params.numero_ipad,
            fecha_ipad: datetime.now()
        }).then(function(result){
            console.log(result)
            var ok = true;
            if(result.tiene_ipad_sin_descargar.length){
                ok = false;
                var ipadSinDescargar = result.tiene_ipad_sin_descargar[0];
                if(ipadSinDescargar){
                    divResult.appendChild(
                        html.p({},[
                            html.span({class:'danger'},'El encuestador ' + ipadSinDescargar.nombre_encuestador + 
                            ' ' + ipadSinDescargar.apellido_encuestador + ' tiene el ipad ' + 
                                ipadSinDescargar.ipad + ' sin descargar, se perderán los datos del dispositivo!'
                            )
                        ])
                    .create());
                }
            }
            if(result.tiene_otro_ipad.length){
                ok = false;
                var ipadAnteriorAsignado = result.tiene_otro_ipad[0];
                if(ipadAnteriorAsignado){
                    divResult.appendChild(
                        html.p({},[
                            html.span({class:'warning'},'El encuestador ' + ipadAnteriorAsignado.nombre_encuestador + 
                                ' ' + ipadAnteriorAsignado.apellido_encuestador + ' ya tiene el ipad ' + 
                                ipadAnteriorAsignado.ipad + ' asignado.'
                            )
                        ]).create()
                    );
                }
            }
            if(result.supera_tolerancia){
                ok = false;
                divResult.appendChild(
                    html.p({},[
                        html.span({class:'danger'},'Configurar correctamente fecha y hora del dispositivo para continuar la instalación.'
                        )
                    ]).create()
                );
            }else{
                if(result.supera_advertencia){
                    ok = false;
                    divResult.appendChild(
                        html.p({},[
                            html.span({class:'warning'},'Revisar fecha y hora del dispositivo.'
                            )
                        ]).create()
                    );
                }
                if(ok){
                    divResult.appendChild(
                        html.p({},[
                            html.span({class:'all-ok'},'No hay advertencias, presione instalar para confirmar instalacion.'
                            )
                        ]).create()
                    );
                }
                var installButton = html.button({class:'load-ipad-button'},'instalar').create();
                divResult.appendChild(installButton);
                installButton.onclick=function(){
                    var message = 'confirma instalación para encuestador ' + params.numero_encuestador + ', ipad ' + params.numero_ipad + '?';
                    confirmPromise(message).then(function(){
                        installButton.disabled=true;
                        return install2(params.numero_encuestador, params.numero_ipad, divResult);
                    });
                }
            }
            return 'ok'
        }).catch(function(err){
            divResult.appendChild(html.p('no se pudo instalar el dispositivo. ' + err.message).create());
            return 'ok'
        })
    }
};

function install2(numeroEncuestador, numeroIpad, divResult){
    var waitGif=html.img({src:'img/loading16.gif'}).create()
    divResult.appendChild(waitGif);
    divResult.appendChild(html.p('instalando dispositivo...').create());
    return my.ajax.instalacion_crear({
        numero_encuestador: numeroEncuestador,
        numero_ipad: numeroIpad,
        token_original: localStorage.getItem('token_instalacion'),
        version_sistema: getVersionSistema()
    }).then(function(token){
        localStorage.setItem('id_instalacion', token.id_instalacion);
        localStorage.setItem('token_instalacion', token.token_instalacion);
        localStorage.setItem('fecha_hora_instalacion', token.fecha_hora.toYmdHms());
        localStorage.setItem('encuestador', token.encuestador);
        localStorage.setItem('ipad', token.ipad);
        localStorage.removeItem('descargado');
        localStorage.removeItem('vaciado');
        localStorage.removeItem(LOCAL_STORAGE_STATE_NAME);
        divResult.appendChild(html.p('instalacion finalizada! Ya puede sincronizar el dispositivo.').create());
        waitGif.style.display = 'none';
    }).catch(function(err){
        divResult.appendChild(html.p('no se pudo instalar el dispositivo. ' + err.message).create());
        return 'ok'
    })
}

myOwn.wScreens.demo_dm = dmHojaDeRuta;