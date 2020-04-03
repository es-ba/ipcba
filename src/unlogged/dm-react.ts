import { createStore } from "redux";
import { RelInf, RelVis, RelPre, HojaDeRuta, Estructura, getDefaultOptions, AddrParamsHdr, QueVer } from "./dm-tipos";
import { puedeCopiarTipoPrecio, puedeCopiarAtributos, puedeCambiarPrecioYAtributos, calcularCambioAtributosEnPrecio, normalizarPrecio, controlarPrecio, getObservacionesFiltradas} from "./dm-funciones";
import { deepFreeze } from "best-globals";
import { createReducer, createDispatchers, ActionsFrom } from "redux-typed-reducer";
import * as JSON4all from "json4all";

var my=myOwn;

export const LOCAL_STORAGE_STATE_NAME = 'ipc2.0-store-r1';

/* REDUCERS */

type NextID = string | false;

//@ts-ignore no va a ser null porque está en la estructura del manifiesto
var estructura:Estructura = null;

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
    payload:{forPk:{informante:number}}, 
    relInfReducer:(relInfState:RelInf)=>RelInf
)=>(
    {
        ...hdrState,
        opciones:{
            ...hdrState.opciones,
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
    payload:{forPk:{informante:number, formulario:number}}, 
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
    payload:{forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number},
    relPreReducer:(productoState:RelPre)=>RelPre
)=>{
    /*
    if(action.type=="SET_RAZON"||action.type=="SET_COMENTARIO_RAZON"){
        throw new Error("internal error action.type in surfRelPre");
    }
    */
    var reducerPlus=(relPre:RelPre)=>{
        var nuevoRelPre = relPreReducer(relPre);
        var control = controlarPrecio(nuevoRelPre, estructura!)
        return {
            ...nuevoRelPre,
            adv: control.tieneAdv,
            err: control.tieneErr
        };
    }
    return surfRelInf(hdrState, payload, relInf=>{
        var i = payload.iRelPre;
        if(i != undefined && 
            (relInf.observaciones[i].producto != payload.forPk.producto || relInf.observaciones[i].observacion != payload.forPk.observacion )
        ){
            throw new Error('iRelPre en una posición no esperada');
        }
        var nuevasObservaciones = i != undefined?[
            ...relInf.observaciones.slice(0, i),
            reducerPlus(relInf.observaciones[i]),
            ...relInf.observaciones.slice(i+1)
        ]:relInf.observaciones.map(
            relPre=>relPre.producto==payload.forPk.producto && relPre.observacion==payload.forPk.observacion?
                reducerPlus(relPre)
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
    payload:{forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number},
    tipoPrecioRedux:(relPre:RelPre)=>string|null
){
    return surfRelPre(hdrState, payload, (relPre:RelPre)=>{
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

var calcularListas=function(observaciones: RelPre[], relVis: RelVis, allForms:boolean, searchString: string, queVer: QueVer){
    return getObservacionesFiltradas(observaciones, relVis, estructura, allForms, searchString, queVer);
}

var reducers={
    SET_RAZON            : (payload: {forPk:{informante:number, formulario:number}, razon:number|null}) => 
        function(state: HojaDeRuta){
            return surfRelVis(state, payload, (miRelVis:RelVis)=>{
                return {
                    ...miRelVis,
                    razon: payload.razon
                }
            });
        },
    SET_COMENTARIO_RAZON : (payload: {forPk:{informante:number, formulario:number}, comentarios:string|null}) => 
        function(state: HojaDeRuta){
            return surfRelVis(state, payload, (miRelVis:RelVis)=>{
                return {
                    ...miRelVis,
                    comentarios: payload.comentarios
                }
            });
        },
    SET_TP               : (payload: {forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number, tipoprecio:string|null}) => 
        function(state: HojaDeRuta){
            return setTP(state, payload, _ => payload.tipoprecio);
        },
    COPIAR_TP            :(payload: {forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number}) => 
        function(state: HojaDeRuta){
            return setTP(state, payload, relPre => puedeCopiarTipoPrecio(estructura!, relPre)?relPre.tipoprecioanterior:relPre.tipoprecio)
        },
    SET_PRECIO           :(payload: {forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number, precio:number|null}) => 
        function(state: HojaDeRuta){
            return surfRelPre(state, payload, (miRelPre:RelPre)=>{
                var puedeCambiarPrecio = puedeCambiarPrecioYAtributos(estructura!, miRelPre);
                var nuevoRelPre:RelPre = {
                    ...miRelPre,
                    precio:puedeCambiarPrecio?payload.precio:miRelPre.precio,
                    tipoprecio:puedeCambiarPrecio && !miRelPre.tipoprecio?estructura!.tipoPrecioPredeterminado.tipoprecio:miRelPre.tipoprecio
                };
                nuevoRelPre.precionormalizado = normalizarPrecio(nuevoRelPre, estructura!);
                return nuevoRelPre;
            });
        },
    SET_COMENTARIO_PRECIO:(payload: {forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number, comentario:string|null}) => 
        function(state: HojaDeRuta){
            return surfRelPre(state, payload, (miRelPre:RelPre)=>{
                var nuevoRelPre:RelPre = {
                    ...miRelPre,
                    comentariosrelpre: payload.comentario
                };
                return nuevoRelPre;
            });
        },
    COPIAR_ATRIBUTOS     :(payload: {forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number}) => 
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
                return nuevoRelPre;
            });
        },
    COPIAR_ATRIBUTOS_VACIOS:(payload: {forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number}) => 
        function(state: HojaDeRuta){
            return surfRelPre(state, payload, (relPre:RelPre)=>{
                var nuevoRelPre:RelPre = {
                    ...relPre,
                    atributos:relPre.atributos.map(relAtr=>({...relAtr, valor:relAtr.valor?relAtr.valor:relAtr.valoranterior}))
                };
                nuevoRelPre.cambio = calcularCambioAtributosEnPrecio(nuevoRelPre);
                nuevoRelPre.precionormalizado = normalizarPrecio(nuevoRelPre, estructura!);
                return nuevoRelPre;
            });
        },
    SET_ATRIBUTO         :(payload: {forPk:{informante:number, formulario:number, producto:string, observacion:number, atributo:number}, iRelPre:number, valor:string|null}) => 
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
            var {queVer} = state.opciones;
            var searchString = '';
            var allForms = false;
            var informante = state.informantes.find((informante)=>informante.informante == payload.informante)!;
            var observaciones=informante.observaciones;
            var relVis = informante!.formularios.find((formulario)=>formulario.formulario == payload.formulario)!;
            var {observacionesFiltradasIdx, observacionesFiltradasEnOtrosIdx}=calcularListas(observaciones, relVis, allForms, searchString, queVer);
            return deepFreeze({
                ...state,
                opciones:{
                    ...state.opciones,
                    relVisPk:{informante:payload.informante, formulario:payload.formulario},
                    observacionesFiltradasIdx,
                    observacionesFiltradasEnOtrosIdx,
                    searchString,
                    verRazon: true,
                    allForms
                }
            })
        },
    UNSET_FORMULARIO_ACTUAL:(_payload: {}) => 
        function(state: HojaDeRuta){
            return deepFreeze({
                ...state,
                opciones:{
                    ...state.opciones,
                    relVisPk:null,
                    observacionesFiltradasIdx: [],
                    observacionesFiltradasEnOtrosIdx: [],
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
    SET_QUE_VER:(payload: {queVer:QueVer, informante: number, formulario: number, searchString:string, allForms:boolean, compactar:boolean}) => 
        function(state: HojaDeRuta){
            var {queVer, searchString, allForms, compactar} = payload;
            var informante = state.informantes.find((informante)=>informante.informante == payload.informante)!;
            var observaciones=informante.observaciones;
            var relVis = informante!.formularios.find((formulario)=>formulario.formulario == payload.formulario)!;
            var {observacionesFiltradasIdx, observacionesFiltradasEnOtrosIdx}=calcularListas(observaciones, relVis, allForms, searchString, queVer);
            return deepFreeze({
                ...state,
                opciones:{
                    ...state.opciones, 
                    observacionesFiltradasIdx,
                    observacionesFiltradasEnOtrosIdx,
                    queVer,
                    searchString,
                    allForms,
                    verRazon: !allForms,
                    compactar
                }
            })
        },
    SET_FORM_POSITION:(payload: {formulario:number, position:number}) => 
        function(state: HojaDeRuta){
            var posiciones:{formulario: number, position: number}[] = [
                ...state.opciones.posFormularios,
            ];
            var pos = posiciones.findIndex((position)=>position.formulario==payload.formulario);
            if(pos==-1){
                posiciones.push({...payload});
            }else{
                posiciones[pos] = {...payload};
            }
            return deepFreeze({
                ...state,
                opciones:{
                    ...state.opciones,
                    posFormularios: posiciones,
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

/* NO SE USAN MÁS
function surf<T extends {}, K extends keyof T>(key:K, callback:(object:T[K])=>T[K]):((object:T)=>T){
    return (object:T)=>Object.freeze({
        ...object,
        [key]: callback(object[key])
    });
}

function surfStart<T extends {}>(object:T, callback:((object:T)=>T)):T{
    return callback(object);
}
*/

export const dispatchers = createDispatchers(reducers);

export async function dmTraerDatosHdr(addrParams:AddrParamsHdr){
    var result:any = {hdr:null,estructura:null};
    var initialState:HojaDeRuta;
    if(addrParams.periodo && addrParams.panel && addrParams.tarea){
        var content = localStorage.getItem(LOCAL_STORAGE_STATE_NAME);
        if(content){
            result.hdr = JSON4all.parse(content);
            //@ts-ignore structFromManifest existe gracias al manifiesto
            estructura=structFromManifest;
            initialState = result.hdr;
        }else{
            throw Error('no se cargó correctamente la hoja de ruta')
        }
    }else{
        //DEMO
        result = await my.ajax.dm2_preparar({
            //periodo: 'a2019m08', panel: 1, tarea: 1, sincronizar: false
            //periodo: 'a2019m08', panel: 3, tarea: 6, sincronizar: false
            periodo: 'a2019m12', panel: 3, tarea: 6, encuestador: null, demo: true
            //periodo: 'a2020m01', panel: 1, tarea: 1, encuestador: null, demo: true
        })
        estructura = result.estructura;
        if(result.hdr){
            initialState = result.hdr;
        }else{
            throw Error ('no hay datos para el periodo seleccionado')
        }
    }

    /* DEFINICION CONTROLADOR */
    const hdrReducer = createReducer(reducers, initialState);
    /* FIN DEFINICION CONTROLADOR */
    /* CARGA Y GUARDADO DE STATE */
    function completarOpcionesCambiosyAdvertencias(content:HojaDeRuta){
        content.opciones = content.opciones || getDefaultOptions();
        content.informantes.forEach(
            (informante:RelInf)=> informante.observaciones.forEach((observacion:RelPre)=> {
                observacion.adv = controlarPrecio(observacion, estructura).tieneAdv;
                observacion.err = controlarPrecio(observacion, estructura).tieneErr;
                observacion.cambio = calcularCambioAtributosEnPrecio(observacion);
            })
        )
    }

    function loadState():HojaDeRuta{
        var contentJson = localStorage.getItem(LOCAL_STORAGE_STATE_NAME);
        if(contentJson){
            var content:HojaDeRuta = JSON4all.parse(contentJson);
            completarOpcionesCambiosyAdvertencias(content);
            return content;
        }else{
            completarOpcionesCambiosyAdvertencias(initialState);
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
   
}
