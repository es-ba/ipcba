import {html}  from 'js-to-html';
import * as JSON4all from "json4all";
import {LOCAL_STORAGE_STATE_NAME, ESTRUCTURA_LOCALSTORAGE_NAME, TOKEN_LOCALSTORAGE_NAME,
       registrarRelevamientoAbiertoLocalStorage, borrarDatosRelevamientoLocalStorage,
       hayHdrRelevando } from "../unlogged/dm-react";
import {dmHojaDeRuta} from "../unlogged/ejemplo-precios";
import { HojaDeRuta, Estructura } from '../unlogged/dm-tipos';

var my=myOwn;

function getVersionSistema(){
    return document.body.getAttribute('app-version');
}

function hayHojaDeRuta(){
    var vaciadoStr:string|null=localStorage.getItem('ipc2.0-vaciado')
    var storageStr:string|null=localStorage.getItem(LOCAL_STORAGE_STATE_NAME)
    return storageStr && vaciadoStr !==null && !(JSON.parse(vaciadoStr)) ||
        storageStr && vaciadoStr===null;
}

async function cargarDispositivo2(tokenInstalacion:string, encuestador:string){
    var mainLayout = document.getElementById('main_layout')!;
    try{
        var reltarHabilitada = await my.ajax.hojaderuta_traer2({
            token_instalacion: tokenInstalacion
        })
    }catch(err){
        var m=html.p('La sincronización se encuentra deshabilitada o vencida para el encuestador '+ encuestador+ '. E:'+err.message).create();
        mainLayout.appendChild(m);
        m.onclick=function(){
            mainLayout.appendChild(html.pre(err instanceof Error?(err.stack||err.message).toString():err.toString()).create());
        }
        throw new Error(err)
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
        localStorage.setItem('ipc2.0-descargado',JSON.stringify(false));
        localStorage.setItem('ipc2.0-vaciado',JSON.stringify(false));
        // @ts-ignore sabemos que hoja_ruta_2 es función
        myOwn.wScreens.hoja_ruta_2({});
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

async function descargarDispositivo2(tokenInstalacion: string, encuestador: string){
    var mainLayout = document.getElementById('main_layout')!;
    var waitGif = mainLayout.appendChild(html.img({src:'img/loading16.gif'}).create());
    mainLayout.appendChild(html.p([
        'descargando, por favor espere',
        waitGif
    ]).create());
    var message = await my.ajax.dm2_descargar({
        token_instalacion: tokenInstalacion,
        hoja_de_ruta: JSON4all.parse(localStorage.getItem(LOCAL_STORAGE_STATE_NAME)!),
        encuestador: encuestador,
        custom_data: false,
        current_token: null
    });
    waitGif.style.display = 'none';
    if(message=='descarga completa'){
        localStorage.setItem('ipc2.0-descargado',JSON.stringify(true));
    }
    mainLayout.appendChild(html.p(message).create());
}

myOwn.wScreens.sincronizar_dm2=async function(){
    var mainLayout = document.getElementById('main_layout')!;
    var tokenInstalacion = localStorage.getItem('ipc2.0-token_instalacion') || null;
    var ipad = localStorage.getItem('ipc2.0-ipad') || null;
    var encuestador = localStorage.getItem('ipc2.0-encuestador') || null;
    if(tokenInstalacion != null && ipad && encuestador){
        if(hayHojaDeRuta() && (localStorage.getItem('ipc2.0-descargado') == null || localStorage.getItem('ipc2.0-descargado') == 'false')){
            mainLayout.appendChild(html.p('El dispositivo tiene información cargada').create());
            var downloadButton = html.button({class:'download-ipad-button'},'descargar').create();
            mainLayout.appendChild(downloadButton);
            downloadButton.onclick = function(){
                confirmPromise('¿confirma descarga de D.M.?').then(async function(){
                    downloadButton.disabled=true;
                    try{
                        await descargarDispositivo2(tokenInstalacion||'no debería perderse el TOKEN si está el botón aún', encuestador!);
                    }catch(err){
                        alertPromise(err.message);
                    }finally{
                        downloadButton.disabled=false;
                    }
                })
            }
        }else{
            mainLayout.appendChild(html.p(
                hayHojaDeRuta()
                ?'el dispositivo tiene su hoja de ruta ya descargada'
                :'El dispositivo no tiene hoja de ruta cargada'
            ).create());
            var loadButton = html.button({class:'load-ipad-button'},'cargar').create();
            mainLayout.appendChild(loadButton);
            loadButton.onclick = async function(){
                try{
                    loadButton.disabled=true;
                    await cargarDispositivo2(tokenInstalacion!, encuestador!);
                    loadButton.disabled=false;
                }catch(err){
                    loadButton.disabled=false;
                }
            }  
        }
    }else{
        mainLayout.appendChild(html.p('No hay token de instalación, por favor instale el dispositivo').create());
    }
};

myOwn.wScreens.hoja_ruta_2=async function(){
    var mainLayout = document.getElementById('main_layout')!;
    try{
        if(hayHojaDeRuta()){
            var {periodo, panel, tarea} = JSON4all.parse(localStorage.getItem(LOCAL_STORAGE_STATE_NAME)!);
            history.replaceState(null, '', `${location.origin+location.pathname}/../hdr?periodo=${periodo}&panel=${panel}&tarea=${tarea}`);
            location.reload();
        }else if(!location.pathname.endsWith('/dm')){
            history.replaceState(null, '', `./dm`);
            location.reload();
        }else{
            mainLayout.appendChild(html.div([html.p('Dispositivo sin carga'), html.p('Sitio seguro para sacar el ícono'), html.img({src:'img/logo-dm.png'})]).create());        
        }
    }catch(err){
        mainLayout.appendChild(html.p('Error al cargar hoja de ruta. ' + err.message).create());
    }
};

myOwn.wScreens.vaciar_dm2=async function(){
    var mainLayout = document.getElementById('main_layout')!;
    var tokenInstalacion = localStorage.getItem('ipc2.0-token_instalacion') || null;
    var ipad = localStorage.getItem('ipc2.0-ipad') || null;
    var encuestador = localStorage.getItem('ipc2.0-encuestador') || null;
    if(tokenInstalacion && ipad && encuestador){
        var vaciado = JSON.parse(localStorage.getItem('ipc2.0-vaciado')||'false');
        if(vaciado){
            mainLayout.appendChild(html.p('El D.M. está vacío.').create());
        }else{
            var clearButton = html.button({class:'load-ipad-button'},'vaciar D.M.').create();
            var fueDescargadoAntes = JSON.parse(localStorage.getItem('ipc2.0-descargado')||'false');
            var inputForzar = html.input({class:'input-forzar'}).create();
            if(!fueDescargadoAntes){
                mainLayout.appendChild(html.div([
                    html.div({class:'danger'},'El dispositivo todavía no fue descargado'),
                    html.div(['Se puede forzar el vaciado ',inputForzar])
                ]).create());
            }
            mainLayout.appendChild(clearButton);
            clearButton.onclick = async function(){
                if(fueDescargadoAntes || inputForzar.value=='forzar'){
                    var confirma = await confirmPromise('¿confirma vaciado de D.M.?',{underElement:clearButton});
                    if(confirma){
                        clearButton.disabled=true;
                        localStorage.setItem('ipc2.0-vaciado',JSON.stringify(true));
                        mainLayout.appendChild(html.p('D.M. vaciado correctamente!').create());
                    };
                }else{
                    alertPromise('si necesita vaciar el D.M. puede forzar.',{underElement:clearButton})
                }
            }
        }
    }else{
        mainLayout.appendChild(html.p('No hay token de instalación, por favor instale el dispositivo').create());
    }
};

var { datetime } = require('best-globals');

myOwn.wScreens.preparar_instalacion2={
    parameters:[
        {name:'numero_encuestador'       , typeName:'text'   },
        {name:'numero_ipad'              , typeName:'text'   }
    ],
    mainAction:function(params:{numero_encuestador:string, numero_ipad:string},divResult:HTMLDivElement){
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

function install2(numeroEncuestador:string, numeroIpad:string, divResult:HTMLDivElement){
    var waitGif=html.img({src:'img/loading16.gif'}).create()
    divResult.appendChild(waitGif);
    divResult.appendChild(html.p('instalando dispositivo...').create());
    return my.ajax.instalacion_crear({
        numero_encuestador: numeroEncuestador,
        numero_ipad: numeroIpad,
        token_original: localStorage.getItem('ipc2.0-token_instalacion'),
        version_sistema: getVersionSistema()
    }).then(function(token){
        localStorage.setItem('ipc2.0-id_instalacion', token.id_instalacion);
        localStorage.setItem('ipc2.0-token_instalacion', token.token_instalacion);
        localStorage.setItem('ipc2.0-fecha_hora_instalacion', token.fecha_hora.toYmdHms());
        localStorage.setItem('ipc2.0-encuestador', token.encuestador);
        localStorage.setItem('ipc2.0-ipad', token.ipad);
        localStorage.removeItem('ipc2.0-descargado');
        localStorage.removeItem('ipc2.0-vaciado');
        localStorage.removeItem(LOCAL_STORAGE_STATE_NAME);
        divResult.appendChild(html.p('instalacion finalizada! Ya puede sincronizar el dispositivo.').create());
        waitGif.style.display = 'none';
    }).catch(function(err){
        divResult.appendChild(html.p('no se pudo instalar el dispositivo. ' + err.message).create());
        return 'ok'
    })
}

//relevamiento directo

myOwn.wScreens.relevamiento=function(_addrParams){
    if(hayHdrRelevando()){
        var estructura:Estructura = JSON4all.parse(localStorage.getItem(ESTRUCTURA_LOCALSTORAGE_NAME)!);
        var hdr:HojaDeRuta = JSON4all.parse(localStorage.getItem(LOCAL_STORAGE_STATE_NAME)!);
        dmHojaDeRuta({customData: {estructura, hdr}});
    }else{
        var mainLayout = document.getElementById('main_layout')!;
        return my.tableGrid('relevamiento',mainLayout,{});
    }
};

myOwn.clientSides.abrir={
    update: undefined,
    prepare: function(depot, fieldName){
        var mainLayout = document.getElementById('main_layout')!;
        var {periodo, panel, tarea, informante, visita, encuestador} = depot.row;
        var openButton = html.button({},'abrir').create();
        depot.rowControls[fieldName].appendChild(openButton);
        openButton.onclick=async function(){
            openButton.disabled=true;
            try{
                var relevarFun = async function(){
                    var result = await my.ajax.dm2_preparar({
                        periodo: periodo,
                        panel: panel,
                        tarea: tarea,
                        informante: informante,
                        visita: visita,
                        encuestador: encuestador,
                        demo: false,
                        useragent: my.config.useragent,
                        current_token: localStorage.getItem(TOKEN_LOCALSTORAGE_NAME) || null
                    });
                    if(result.hdr && result.estructura && result.token){
                        registrarRelevamientoAbiertoLocalStorage(periodo, panel, tarea, informante, result.hdr, result.estructura, result.token)
                        dmHojaDeRuta({customData: {estructura:result.estructura, hdr:result.hdr}});
                    }else{
                        throw new Error('no se pudo cargar la hoja de ruta');
                    }
                    openButton.disabled=false;
                }
                depot.rowControls[fieldName].appendChild(html.img({src:'img/loading16.gif'}).create());
                var abierto = await my.ajax.dm2_relevamiento_chequear_informante_abierto({
                    periodo: periodo,
                    panel: panel,
                    tarea: tarea,
                    informante: informante,
                    visita: visita,
                });
                if(abierto.hayFormulariosAbiertos){
                    var formulariosAbiertos = abierto.formulariosAbiertos;
                    var mainDiv = html.div().create()
                    mainDiv.appendChild(html.div({},[
                        html.div({class:'danger'}, [`Existen formularios del panel ${panel}, tarea ${tarea}, informante ${informante} cargados en otro 
                        dispositivo. Si continua no se podrá descargar el dispositivo.`].concat(
                            formulariosAbiertos.map((openedForm:any)=>
                                html.div(`usuario: ${openedForm.username}, formulario: ${openedForm.formulario}, SO: ${openedForm.useragent.os}, navegador: ${openedForm.useragent.browser+ ' ' + openedForm.useragent.version}`).create()
                            )
                        ))
                    ]).create());
                    var inputForzar = html.input({class:'input-forzar'}).create();
                    mainDiv.appendChild(html.div([
                        html.div(['Se puede forzar la carga ',inputForzar])
                    ]).create());
                    var clearButton = html.button({class:'load-ipad-button'},'forzar carga').create();
                    var cancelButton = html.button('cancelar carga').create();
                    cancelButton.onclick=function(){
                        location.reload();
                    }
                    mainDiv.appendChild(clearButton);
                    mainDiv.appendChild(cancelButton);
                    mainLayout.prepend(mainDiv);
                    clearButton.onclick = async function(){
                        if(inputForzar.value=='forzar'){
                            await confirmPromise('¿confirma carga de D.M.?',{underElement:clearButton});
                            clearButton.disabled=true;
                            relevarFun();
                        }else{
                            alertPromise('si necesita cargar el D.M. escriba forzar.',{underElement:clearButton})
                        }
                    }
                }else{
                    relevarFun();
                }
            }catch(err){
                openButton.disabled=false;
                borrarDatosRelevamientoLocalStorage()
                alertPromise(err.message);
                depot.rowControls[fieldName].innerHTML = '';
                depot.rowControls[fieldName].appendChild(openButton);
                throw err;
            }
            
        }
   }
}
//fin relevamiento directo

myOwn.wScreens.demo_dm = async function(){
    dmHojaDeRuta({addrParamsHdr:{periodo:null, panel:null,tarea:null}});
};