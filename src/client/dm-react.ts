import { createStore } from "redux";
import { RelInf, RelVis, RelPre, HojaDeRuta, Estructura } from "./dm-tipos";
import { puedeCopiarTipoPrecio, puedeCopiarAtributos, puedeCambiarPrecioYAtributos} from "./dm-funciones";
import { deepFreeze } from "best-globals";
import { mostrarHdr } from "./ejemplo-precios";
import * as JSON4all from "json4all";

var my=myOwn;

/* INICIO ACCIONES */
const SET_RAZON            = 'SET_RAZON';
const SET_COMENTARIO_RAZON = 'SET_COMENTARIO_RAZON';
const SET_TP               = 'SET_TP';
const COPIAR_TP            = 'COPIAR_TP';
const SET_PRECIO           = 'SET_PRECIO';
const COPIAR_ATRIBUTOS     = 'COPIAR_ATRIBUTOS';
const SET_ATRIBUTO         = 'SET_ATRIBUTO';

type ActionSetRazon           = {type:'SET_RAZON'           , payload:{forPk:{informante:number, formulario:number}, razon:number}};
type ActionSetComentarioRazon = {type:'SET_COMENTARIO_RAZON', payload:{forPk:{informante:number, formulario:number}, comentarios:string}};
type ActionSetTp              = {type:'SET_TP'              , payload:{forPk:{informante:number, formulario:number, producto:string, observacion:number}, tipoprecio:string}};
type ActionCopiarTp           = {type:'COPIAR_TP'           , payload:{forPk:{informante:number, formulario:number, producto:string, observacion:number}}};
type ActionSetPrecio          = {type:'SET_PRECIO'          , payload:{forPk:{informante:number, formulario:number, producto:string, observacion:number}, precio:number}};
type ActionCopiarAtributos    = {type:'COPIAR_ATRIBUTOS'    , payload:{forPk:{informante:number, formulario:number, producto:string, observacion:number}}};
type ActionSetAtributo        = {type:'SET_ATRIBUTO'        , payload:{forPk:{informante:number, formulario:number, producto:string, observacion:number, atributo:number}, valor:string}};

/*
function <K extends string|number, U, T extends {K:U}>red(key:K, reduxer((previous:T)=>U)){
    return {

    }
}
*/

export type ActionHdr = ActionSetRazon | ActionSetComentarioRazon | ActionSetTp | ActionCopiarTp | ActionSetPrecio | ActionCopiarAtributos | ActionSetAtributo;
/* FIN ACCIONES */

function surf<T extends {}, K extends keyof T>(key:K, callback:(object:T[K])=>T[K]):((object:T)=>T){
    return (object:T)=>Object.freeze({
        ...object,
        [key]: callback(object[key])
    });
}

function surfStart<T extends {}>(object:T, callback:((object:T)=>T)):T{
    return callback(object);
}

// @ts-ignore provisoriamente no me preocupa que falte _addrParams
export async function dmHojaDeRuta(_addrParams){
    var result = await my.ajax.dm_cargar({
        periodo: 'a2019m02',
        panel: 1,
        tarea: 1
    })
    /* DEFINICION CONTROLADOR */
    function hdrReducer(hdrState:HojaDeRuta = initialState, action:ActionHdr):HojaDeRuta {
        var defaultAction = function defaultAction(){return deepFreeze(hdrState)};
        
        const surfRelInf = (relInfReducer:(relInfState:RelInf)=>RelInf)=>(
            {
                ...hdrState,
                informantes:hdrState.informantes.map(
                    relInf=>relInf.informante==action.payload.forPk.informante?
                        relInfReducer(relInf)
                    :relInf
                )
            }
        );
        const surfRelVis = (relVisReducer:(productoState:RelVis)=>RelVis)=>(
            surfRelInf(relInf=>({
                ...relInf,
                formularios:relInf.formularios.map(
                    relVis=>relVis.formulario==action.payload.forPk.formulario?
                        relVisReducer(relVis)
                    :relVis
                )
            }))
        );
        const surfRelPre = (relPreReducer:(productoState:RelPre)=>RelPre)=>{
            if(action.type=="SET_RAZON"||action.type=="SET_COMENTARIO_RAZON"){
                throw new Error("internal error action.type in surfRelPre");
            }
            return surfRelVis(relVis=>({
                ...relVis,
                observaciones:relVis.observaciones.map(
                    relPre=>relPre.producto==action.payload.forPk.producto && relPre.observacion==action.payload.forPk.observacion?
                        relPreReducer(relPre)
                    :relPre
                )
            }))
        };
        var setTP = function setTP(tipoPrecioRedux:(relPre:RelPre)=>string|null){
            return surfRelPre(relPre=>{
                var tipoPrecioNuevo = tipoPrecioRedux(relPre);
                var esNegativo = !tipoPrecioNuevo || !estructura.tipoPrecio[tipoPrecioNuevo].espositivo;
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
        switch (action.type) {
            case SET_RAZON: {
                return surfRelVis((miRelVis:RelVis)=>{
                    return {
                        ...miRelVis,
                        razon: action.payload.razon
                    }
                });
            }
            case SET_COMENTARIO_RAZON: {
                return surfRelVis((miRelVis:RelVis)=>{
                    return {
                        ...miRelVis,
                        comentarios: action.payload.comentarios
                    }
                });
            }
            case SET_TP: {
                return setTP(_ => action.payload.tipoprecio);
            }
            case COPIAR_TP: {
                return setTP(relPre => puedeCopiarTipoPrecio(estructura, relPre)?relPre.tipoprecioanterior:relPre.tipoprecio)
            }
            case SET_PRECIO: {
                return surfRelPre((miRelPre:RelPre)=>{
                    var puedeCambiarPrecio = puedeCambiarPrecioYAtributos(estructura, miRelPre);
                    return {
                        ...miRelPre,
                        precio:puedeCambiarPrecio?action.payload.precio:miRelPre.precio,
                        tipoprecio:puedeCambiarPrecio && !miRelPre.tipoprecio?estructura.tipoPrecioPredeterminado.tipoprecio:miRelPre.tipoprecio
                    }
                });
            }
            case SET_ATRIBUTO: {
                return surfRelPre((relPre:RelPre)=>{
                    if(!puedeCambiarPrecioYAtributos(estructura, relPre)){
                        return relPre;
                    }
                    var nuevoRelPre:RelPre = {
                        ...relPre,
                        cambio:'C',
                        atributos:relPre.atributos.map(relAtr=>relAtr.atributo==action.payload.forPk.atributo?
                            {...relAtr, valor:action.payload.valor}:
                            relAtr
                        )
                    };
                    nuevoRelPre.cambio=nuevoRelPre.atributos.some(relAtr=>relAtr.valor!=relAtr.valoranterior)?'C':'='
                    return nuevoRelPre;
                });
            }
            case COPIAR_ATRIBUTOS: {
                return surfRelPre((relPre:RelPre)=>{
                    var puedeCopiarAttrs = puedeCopiarAtributos(estructura, relPre);
                    return puedeCopiarAttrs?{
                        ...relPre,
                        cambio:puedeCopiarAttrs?'=':relPre.cambio,
                        atributos:relPre.atributos.map(relAtr=>({...relAtr, valor:relAtr.valoranterior}))
                    }:relPre;
                });
            }
            default: {
                return defaultAction();
            }
        }
    }
    /* FIN DEFINICION CONTROLADOR */

    /* DEFINICION STATE */
    const initialState:HojaDeRuta = result.hdr;
    const estructura:Estructura = result.estructura;
    const LOCAL_STORAGE_STATE_NAME = 'dm-store-v4'
    /* FIN DEFINICION STATE */

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
    mostrarHdr(store, estructura)
}

if(typeof window !== 'undefined'){
    // @ts-ignore para hacerlo
    window.dmHojaDeRuta = dmHojaDeRuta;
}