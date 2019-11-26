import { createStore } from "redux";
import { RelInf, RelVis, RelPre, HojaDeRuta, Estructura } from "./dm-tipos";
import { puedeCopiarTipoPrecio, puedeCopiarAtributos, puedeCambiarPrecioYAtributos} from "./dm-funciones";
import { deepFreeze } from "best-globals";
import { createReducer, createDispatchers, ActionsFrom } from "redux-typed-reducer";
import * as JSON4all from "json4all";

var my=myOwn;

/* REDUCERS */

type NextID = string | false;

var estructura:Estructura|null = null;

var defaultAction = function defaultAction(
    hdrState:HojaDeRuta, 
    payload:{nextId:NextID}, 
){
    return deepFreeze({
        ...hdrState,
        idActual:payload.nextId==null?hdrState.idActual:(payload.nextId===false?null:payload.nextId)
    })
};
const surfRelInf = (
    hdrState:HojaDeRuta, 
    payload:{forPk:{informante:number}, nextId:NextID}, 
    relInfReducer:(relInfState:RelInf)=>RelInf
)=>(
    {
        ...hdrState,
        idActual:payload.nextId?payload.nextId:hdrState.idActual,
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
        var nuevasObservaciones = i != undefined?[
            ...relInf.observaciones.slice(0, i),
            relPreReducer(relInf.observaciones[i]),
            ...relInf.observaciones.slice(i+1)
        ]:relInf.observaciones.map(
            relPre=>relPre.formulario==payload.forPk.formulario && relPre.producto==payload.forPk.producto && relPre.observacion==payload.forPk.observacion?
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
                return {
                    ...miRelPre,
                    precio:puedeCambiarPrecio?payload.precio:miRelPre.precio,
                    tipoprecio:puedeCambiarPrecio && !miRelPre.tipoprecio?estructura!.tipoPrecioPredeterminado.tipoprecio:miRelPre.tipoprecio
                }
            });
        },
    COPIAR_ATRIBUTOS     :(payload: {nextId: NextID, forPk:{informante:number, formulario:number, producto:string, observacion:number}, iRelPre:number}) => 
        function(state: HojaDeRuta){
            return surfRelPre(state, payload, (relPre:RelPre)=>{
                var puedeCopiarAttrs = puedeCopiarAtributos(estructura!, relPre);
                return puedeCopiarAttrs?{
                    ...relPre,
                    cambio:puedeCopiarAttrs?'=':relPre.cambio,
                    atributos:relPre.atributos.map(relAtr=>({...relAtr, valor:relAtr.valoranterior}))
                }:relPre;
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
                nuevoRelPre.cambio=nuevoRelPre.atributos.some(relAtr=>relAtr.valor!=relAtr.valoranterior)?'C':'='
                return nuevoRelPre;
            });
        },
    SET_FOCUS            :(payload: {nextId: NextID}) => 
        function(state: HojaDeRuta){
            return defaultAction(state, payload)
        },    
    UNSET_FOCUS          :(payload: {unfocusing: string}) => 
        function(state: HojaDeRuta){
            return deepFreeze({
                ...state,
                idActual:state.idActual==payload.unfocusing?false:state.idActual
            })
        },    
    SET_FORMULARIO_ACTUAL:(payload: {informante:number, formulario:number}) => 
        function(state: HojaDeRuta){
            return deepFreeze({
                ...state,
                relVisPk:{informante:payload.informante, formulario:payload.formulario}
            })
        },
    UNSET_FORMULARIO_ACTUAL:(_payload: {}) => 
        function(state: HojaDeRuta){
            return deepFreeze({
                ...state,
                relVisPk:null
            })
        },
    SET_OPCION:(payload: {variable:string, valor:any}) => 
        function(state: HojaDeRuta){
            return deepFreeze({
                ...state,
                opciones:{...state.opciones, [payload.variable]:payload.valor}
            })
        },
    }
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
    var result = await my.ajax.dm_cargar({
        // periodo: 'a2019m02', panel: 1, tarea: 1
        periodo: 'a2019m08', panel: 3, tarea: 6
    })
    /* DEFINICION STATE */
    const initialState:HojaDeRuta = result.hdr;
    estructura = result.estructura;
    const LOCAL_STORAGE_STATE_NAME = 'dm-store-v8';
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
}
