import { createStore } from "redux";
import { RelInf, RelVis, RelPre, HojaDeRuta, Estructura, getDefaultOptions } from "./dm-tipos";
import { puedeCopiarTipoPrecio, puedeCopiarAtributos, puedeCambiarPrecioYAtributos, calcularCambioAtributosEnPrecio, normalizarPrecio, controlarPrecio} from "./dm-funciones";
import { deepFreeze } from "best-globals";
import { createReducer, createDispatchers, ActionsFrom } from "redux-typed-reducer";
import * as JSON4all from "json4all";
import {html} from "js-to-html";

var my=myOwn;

const LOCAL_STORAGE_STATE_NAME = 'dm-store-v11';

async function cargarDispositivo2(tokenInstalacion:string, encuestador:string){
    var mainLayout = document.getElementById('main_layout')!;
    try{
        var reltarHabilitada = await my.ajax.hojaderuta_traer({
            token_instalacion: tokenInstalacion
        })
    }catch(err){
        mainLayout.appendChild(html.p('La sincronización se encuentra deshabilitada o vencida para el encuestador '+ encuestador).create());
        throw err
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
        // una vez que confirmo debe deshabilitarse el boton cargar (para no confundir al usuario)
        // el boton debe habilitarse al final (tanto por error como por exito)
        if(my.offline.mode){
            throw new Error('No se puede asignar una tarea en modo avion');
        }
        mainLayout.appendChild(html.img({src:'img/loading16.gif'}).create());
        var hdr = await my.ajax.hdr_json_leer({
            periodo: periodo,
            panel: panel,
            tarea: tarea
        });
        localStorage.setItem(LOCAL_STORAGE_STATE_NAME, JSON4all.stringify(hdr));
        await my.ajax.dm2_cargar({
            periodo: periodo,
            panel: panel,
            tarea: tarea,
            token_instalacion: tokenInstalacion
        });
        mainLayout.appendChild(html.p('Carga completa!, pasando a modo avion...').create());
        localStorage.setItem('descargado',JSON.stringify(false));
        localStorage.setItem('vaciado',JSON.stringify(false));
        history.replaceState(null, null, location.origin+location.pathname+my.menuSeparator+'w=hoja_ruta');
        my.changeOfflineMode();
        return 'ok'
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

function descargarDispositivo2(tokenInstalacion, encuestador){
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
                        downloadButton.disabled=true;
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
                    loadButton.disabled=true;
                }
            }  
        }
    }else{
        mainLayout.appendChild(html.p('No hay token de instalación, por favor instale el dispositivo').create());
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

/* REDUCERS */

type NextID = string | false;

var estructura:Estructura|null = null;

var defaultAction = function defaultAction(
    hdrState:HojaDeRuta, 
    payload:{nextId:NextID}, 
){
    return deepFreeze({
        ...hdrState,
        opciones:{
            ...hdrState.opciones,
            idActual:payload.nextId==null?hdrState.opciones.idActual:(payload.nextId===false?null:payload.nextId)
        }
    })
};
const surfRelInf = (
    hdrState:HojaDeRuta, 
    payload:{forPk:{informante:number}, nextId:NextID}, 
    relInfReducer:(relInfState:RelInf)=>RelInf
)=>(
    {
        ...hdrState,
        opciones:{
            ...hdrState.opciones,
            idActual:payload.nextId?payload.nextId:hdrState.opciones.idActual,
        },
        informantes:hdrState.informantes.map(
            relInf=>relInf.informante==payload.forPk.informante?
                relInfReducer(relInf)
            :relInf
        )
    }
);
const surfRelVis = (
    hdrState:HojaDeRuta, 
    payload:{nextId:NextID, forPk:{informante:number, formulario:number}}, 
    relVisReducer:(productoState:RelVis)=>RelVis
)=>(
    surfRelInf(hdrState, payload, relInf=>({
        ...relInf,
        formularios:relInf.formularios.map(
            relVis=>relVis.formulario==payload.forPk.formulario?
                relVisReducer(relVis)
            :relVis
        )
    }))
);
const surfRelPre = (
    hdrState:HojaDeRuta, 
    payload:{nextId:NextID, forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number},
    relPreReducer:(productoState:RelPre)=>RelPre
)=>{
    /*
    if(action.type=="SET_RAZON"||action.type=="SET_COMENTARIO_RAZON"){
        throw new Error("internal error action.type in surfRelPre");
    }
    */
    return surfRelInf(hdrState, payload, relInf=>{
        var i = payload.iRelPre;
        if(i != undefined && 
            (relInf.observaciones[i].producto != payload.forPk.producto || relInf.observaciones[i].observacion != payload.forPk.observacion )
        ){
            throw new Error('iRelPre en una posición no esperada');
        }
        var nuevasObservaciones = i != undefined?[
            ...relInf.observaciones.slice(0, i),
            relPreReducer(relInf.observaciones[i]),
            ...relInf.observaciones.slice(i+1)
        ]:relInf.observaciones.map(
            relPre=>relPre.producto==payload.forPk.producto && relPre.observacion==payload.forPk.observacion?
                relPreReducer(relPre)
            :relPre
        )
        return {
            ...relInf,
            observaciones:nuevasObservaciones
        }
    })
};
var setTP = function setTP(
    hdrState:HojaDeRuta, 
    payload:{nextId:NextID, forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number},
    tipoPrecioRedux:(relPre:RelPre)=>string|null
){
    return surfRelPre(hdrState, payload, relPre=>{
        var tipoPrecioNuevo = tipoPrecioRedux(relPre);
        var esNegativo = !tipoPrecioNuevo || !estructura!.tipoPrecio[tipoPrecioNuevo].espositivo;
        var paraLimipar=esNegativo?{
            precio: null,
            cambio: null,
            atributos: relPre.atributos.map(relAtr=>({...relAtr, valor:null}))
        }:{};
        return {
            ...relPre,
            ...paraLimipar,
            tipoprecio: tipoPrecioNuevo
        };
    });
}

var reducers={
    SET_RAZON            : (payload: {nextId: NextID, forPk:{informante:number, formulario:number}, razon:number|null}) => 
        function(state: HojaDeRuta){
            return surfRelVis(state, payload, (miRelVis:RelVis)=>{
                return {
                    ...miRelVis,
                    razon: payload.razon
                }
            });
        },
    SET_COMENTARIO_RAZON : (payload: {nextId: NextID, forPk:{informante:number, formulario:number}, comentarios:string|null}) => 
        function(state: HojaDeRuta){
            return surfRelVis(state, payload, (miRelVis:RelVis)=>{
                return {
                    ...miRelVis,
                    comentarios: payload.comentarios
                }
            });
        },
    SET_TP               : (payload: {nextId: NextID, forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number, tipoprecio:string|null}) => 
        function(state: HojaDeRuta){
            return setTP(state, payload, _ => payload.tipoprecio);
        },
    COPIAR_TP            :(payload: {nextId: NextID, forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number}) => 
        function(state: HojaDeRuta){
            return setTP(state, payload, relPre => puedeCopiarTipoPrecio(estructura!, relPre)?relPre.tipoprecioanterior:relPre.tipoprecio)
        },
    SET_PRECIO           :(payload: {nextId: NextID, forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number, precio:number|null}) => 
        function(state: HojaDeRuta){
            return surfRelPre(state, payload, (miRelPre:RelPre)=>{
                var puedeCambiarPrecio = puedeCambiarPrecioYAtributos(estructura!, miRelPre);
                var nuevoRelPre:RelPre = {
                    ...miRelPre,
                    precio:puedeCambiarPrecio?payload.precio:miRelPre.precio,
                    tipoprecio:puedeCambiarPrecio && !miRelPre.tipoprecio?estructura!.tipoPrecioPredeterminado.tipoprecio:miRelPre.tipoprecio
                };
                nuevoRelPre.precionormalizado = normalizarPrecio(nuevoRelPre, estructura!);
                nuevoRelPre.adv=controlarPrecio(nuevoRelPre, estructura!).tieneAdv;
                return nuevoRelPre;
            });
        },
    SET_COMENTARIO_PRECIO:(payload: {nextId: NextID, forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number, comentario:string|null}) => 
        function(state: HojaDeRuta){
            return surfRelPre(state, payload, (miRelPre:RelPre)=>{
                var nuevoRelPre:RelPre = {
                    ...miRelPre,
                    comentariosrelpre: payload.comentario
                };
                nuevoRelPre.adv=controlarPrecio(nuevoRelPre, estructura!).tieneAdv;
                return nuevoRelPre;
            });
        },
    COPIAR_ATRIBUTOS     :(payload: {nextId: NextID, forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number}) => 
        function(state: HojaDeRuta){
            return surfRelPre(state, payload, (relPre:RelPre)=>{
                var puedeCopiarAttrs = puedeCopiarAtributos(estructura!, relPre);
                if(!puedeCopiarAttrs){
                    return relPre
                }
                var nuevoRelPre:RelPre = {
                    ...relPre,
                    atributos:relPre.atributos.map(relAtr=>({...relAtr, valor:relAtr.valoranterior}))
                };
                nuevoRelPre.cambio = calcularCambioAtributosEnPrecio(nuevoRelPre);
                nuevoRelPre.precionormalizado = normalizarPrecio(nuevoRelPre, estructura!);
                nuevoRelPre.adv=controlarPrecio(nuevoRelPre, estructura!).tieneAdv;
                return nuevoRelPre;
            });
        },
    COPIAR_ATRIBUTOS_VACIOS     :(payload: {nextId: NextID, forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number}) => 
        function(state: HojaDeRuta){
            return surfRelPre(state, payload, (relPre:RelPre)=>{
                var nuevoRelPre:RelPre = {
                    ...relPre,
                    atributos:relPre.atributos.map(relAtr=>({...relAtr, valor:relAtr.valor?relAtr.valor:relAtr.valoranterior}))
                };
                nuevoRelPre.cambio = calcularCambioAtributosEnPrecio(nuevoRelPre);
                nuevoRelPre.precionormalizado = normalizarPrecio(nuevoRelPre, estructura!);
                nuevoRelPre.adv=controlarPrecio(nuevoRelPre, estructura!).tieneAdv;
                return nuevoRelPre;
            });
        },
    SET_ATRIBUTO         :(payload: {nextId: NextID, forPk:{informante:number, formulario:number, producto:string, observacion:number, atributo:number}, iRelPre:number, valor:string|null}) => 
        function(state: HojaDeRuta){
            return surfRelPre(state, payload, (relPre:RelPre)=>{
                if(!puedeCambiarPrecioYAtributos(estructura!, relPre)){
                    return relPre;
                }
                var nuevoRelPre:RelPre = {
                    ...relPre,
                    atributos:relPre.atributos.map(relAtr=>relAtr.atributo==payload.forPk.atributo?
                        {...relAtr, valor:payload.valor}:
                        relAtr
                    )
                };
                nuevoRelPre.cambio=calcularCambioAtributosEnPrecio(nuevoRelPre)
                nuevoRelPre.precionormalizado = normalizarPrecio(nuevoRelPre, estructura!);
                nuevoRelPre.adv=controlarPrecio(nuevoRelPre, estructura!).tieneAdv;
                return nuevoRelPre;
            });
        },
    SET_FOCUS            :(payload: {nextId: NextID}) => 
        function(state: HojaDeRuta){
            return defaultAction(state, payload)
        },    
    SET_ZOOMIN           :(payload: {nextId: NextID}) => 
        function(state: HojaDeRuta){
            return defaultAction(state, payload)
        },    
    UNSET_FOCUS          :(payload: {unfocusing: string}) => 
        function(state: HojaDeRuta){
            return deepFreeze({
                ...state,
                opciones:{
                    ...state.opciones,
                    idActual:state.opciones.idActual==payload.unfocusing?false:state.opciones.idActual
                }
            })
        },    
    SET_FORMULARIO_ACTUAL:(payload: {informante:number, formulario:number}) => 
        function(state: HojaDeRuta){
            return deepFreeze({
                ...state,
                opciones:{
                    ...state.opciones,
                    relVisPk:{informante:payload.informante, formulario:payload.formulario}
                }
            })
        },
    UNSET_FORMULARIO_ACTUAL:(_payload: {}) => 
        function(state: HojaDeRuta){
            return deepFreeze({
                ...state,
                opciones:{
                    ...state.opciones,
                    relVisPk:null
                }
            })
        },
    SET_OPCION:(payload: {variable:string, valor:any}) => 
        function(state: HojaDeRuta){
            return deepFreeze({
                ...state,
                opciones:{...state.opciones, [payload.variable]:payload.valor}
            })
        },
    RESET_SEARCH:(_payload: {}) => 
        function(state: HojaDeRuta){
            return deepFreeze({
                ...state,
                opciones:{...state.opciones,
                    searchString: '',
                    verRazon: true,
                    allForms: false
                }
            })
        },
    RESET_OPCIONES:(_payload: {}) => 
        function(state: HojaDeRuta){
            return deepFreeze({
                ...state,
                opciones: getDefaultOptions()
            })
        },
}

export type ActionHdr = ActionsFrom<typeof reducers>;
/* FIN ACCIONES */

function surf<T extends {}, K extends keyof T>(key:K, callback:(object:T[K])=>T[K]):((object:T)=>T){
    return (object:T)=>Object.freeze({
        ...object,
        [key]: callback(object[key])
    });
}

export const dispatchers = createDispatchers(reducers);

function surfStart<T extends {}>(object:T, callback:((object:T)=>T)):T{
    return callback(object);
}

// @ts-ignore provisoriamente no me preocupa que falte _addrParams
export async function dmTraerDatosHdr(){
    var result = await my.ajax.dm2_preparar({
        periodo: 'a2019m08', panel: 1, tarea: 1, sincronizar: false
        //periodo: 'a2019m08', panel: 3, tarea: 6
        //periodo: 'a2019m11', panel: 3, tarea: 6
    })
    if(result.estructura && result.hdr){
        /* DEFINICION STATE */
        const initialState:HojaDeRuta = result.hdr;
        initialState.opciones = getDefaultOptions();
        estructura = result.estructura;
        /* FIN DEFINICION STATE */
        /* DEFINICION CONTROLADOR */
        const hdrReducer = createReducer(reducers, initialState);
        /* FIN DEFINICION CONTROLADOR */
        /* CARGA Y GUARDADO DE STATE */
        function loadState():HojaDeRuta{
            var contentJson = localStorage.getItem(LOCAL_STORAGE_STATE_NAME);
            if(contentJson){
                var content:HojaDeRuta = JSON4all.parse(contentJson);
                return content;
            }else{
                return initialState;
            }
        }
        
        function saveState(state:HojaDeRuta){
            localStorage.setItem(LOCAL_STORAGE_STATE_NAME, JSON4all.stringify(state));
        }
        /* FIN CARGA Y GUARDADO DE STATE */

        /* CREACION STORE */
        const store = createStore(hdrReducer, loadState()); 
        store.subscribe(function(){
            saveState(store.getState());
        });
        /* FIN CREACION STORE */

        //HDR CON STORE CREADO
        return {store, estructura:estructura!};
    }else{
        throw Error ('no hay datos para el periodo seleccionado')
    }
}
