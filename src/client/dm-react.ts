import { createStore } from "redux";
import { RelVis, RelPre, HojaDeRuta, Estructura } from "./dm-tipos";
import { puedeCopiarTipoPrecio, puedeCopiarAtributos, puedeCambiarPrecioYAtributos} from "./dm-funciones";
import { deepFreeze } from "best-globals";
import { mostrarHdr } from "./ejemplo-precios";
import * as JSON4all from "json4all";
import * as likeAr from "like-ar";
import * as bestGlobals from "best-globals";

var my=myOwn;

/* INICIO ACCIONES */
const SET_RAZON            = 'SET_RAZON';
const SET_COMENTARIO_RAZON = 'SET_COMENTARIO_RAZON';
const SET_TP               = 'SET_TP';
const COPIAR_TP            = 'COPIAR_TP';
const SET_PRECIO           = 'SET_PRECIO';
const COPIAR_ATRIBUTOS     = 'COPIAR_ATRIBUTOS';
const SET_ATRIBUTO         = 'SET_ATRIBUTO';

type ActionSetRAzon           = {type:'SET_RAZON'           , payload:{informante:number, formulario:number, valor:number}};
type ActionSetComentarioRazon = {type:'SET_COMENTARIO_RAZON', payload:{informante:number, formulario:number, valor:string}};
type ActionSetTp              = {type:'SET_TP'              , payload:{informante:number, formulario:number, producto:string, observacion:number, valor:string}};
type ActionCopiarTp           = {type:'COPIAR_TP'           , payload:{informante:number, formulario:number, producto:string, observacion:number}};
type ActionSetPrecio          = {type:'SET_PRECIO'          , payload:{informante:number, formulario:number, producto:string, observacion:number, valor:number}};
type ActionCopiarAtributos    = {type:'COPIAR_ATRIBUTOS'    , payload:{informante:number, formulario:number, producto:string, observacion:number}};
type ActionSetAtributo        = {type:'SET_ATRIBUTO'        , payload:{informante:number, formulario:number, producto:string, observacion:number, atributo:number, valor:string}};

/*
function <K extends string|number, U, T extends {K:U}>red(key:K, reduxer((previous:T)=>U)){
    return {

    }
}
*/

export type ActionHdr = ActionSetRAzon | ActionSetComentarioRazon | ActionSetTp | ActionCopiarTp | ActionSetPrecio | ActionCopiarAtributos | ActionSetAtributo;
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

export async function dmHojaDeRuta(_addrParams){
    var result = await my.ajax.dm_cargar({
        periodo: 'a2019m08',
        panel: 1,
        tarea: 1
    })
    /* DEFINICION CONTROLADOR */
    function hdrReducer(hdrState:HojaDeRuta = initialState, action:ActionHdr):HojaDeRuta {
        var defaultAction = function defaultAction(){return deepFreeze(hdrState)};

        const surfRelVis = (relVisReducer:(productoState:RelVis)=>RelVis)=>
            (surfStart(hdrState,
                surf('informantes', surf(action.payload.informante,
                    surf('formularios', surf(action.payload.formulario,relVisReducer))
                ))
            ));

        const surfRelPre = (relPreReducer:(productoState:RelPre)=>RelPre)=>
            surfRelVis(
                surf('productos', surf(action.payload.producto,
                    surf('observaciones', surf(action.payload.observacion,relPreReducer))
                ))
            );

            
        var setTP = function setTP(tipoPrecioRedux:(miRelPre:RelPre)=>string|null){
            return surfRelPre(miRelPre=>{
                var tipoPrecioNuevo = tipoPrecioRedux(miRelPre);
                var esNegativo = !tipoPrecioNuevo || !estructura.tipoPrecio[tipoPrecioNuevo].espositivo;
                var paraLimipar=esNegativo?{
                    precio: null,
                    cambio: null,
                    atributos: likeAr(miRelPre.atributos).map(relAtr=>({...relAtr, valor:null})).plain()
                }:{};
                return {
                    ...miRelPre,
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
                        razon: action.payload.valor
                    }
                });
            }
            case SET_COMENTARIO_RAZON: {
                return surfRelVis((miRelVis:RelVis)=>{
                    return {
                        ...miRelVis,
                        comentarios: action.payload.valor
                    }
                });
            }
            case SET_TP: {
                return setTP(_ => action.payload.valor);
            }
            case COPIAR_TP: {
                return setTP(relPre => puedeCopiarTipoPrecio(estructura, relPre)?relPre.tipoprecioanterior:relPre.tipoprecio)
            }
            case SET_PRECIO: {
                return surfRelPre((miRelPre:RelPre)=>{
                    var puedeCambiarPrecio = puedeCambiarPrecioYAtributos(estructura, miRelPre);
                    return {
                        ...miRelPre,
                        precio:puedeCambiarPrecio?action.payload.valor:miRelPre.precio,
                        tipoprecio:puedeCambiarPrecio && !miRelPre.tipoprecio?estructura.tipoPrecioPredeterminado.tipoprecio:miRelPre.tipoprecio
                    }
                });
            }
            case SET_ATRIBUTO: {
                return surfRelPre((miRelPre:RelPre)=>{
                    var puedeCambiarAttrs = puedeCambiarPrecioYAtributos(estructura, miRelPre);
                    return puedeCambiarAttrs?{
                        ...miRelPre,
                        cambio:'C',
                        atributos:{
                            ...miRelPre.atributos,
                            [action.payload.atributo]:{
                                ...miRelPre.atributos[action.payload.atributo],
                                valor: action.payload.valor
                            }
                        }
                    }:miRelPre
                });
            }
            case COPIAR_ATRIBUTOS: {
                return surfRelPre((miRelPre:RelPre)=>{
                    var puedeCopiarAttrs = puedeCopiarAtributos(estructura, miRelPre);
                    return puedeCopiarAttrs?{
                        ...miRelPre,
                        cambio:puedeCopiarAttrs?'=':miRelPre.cambio,
                        atributos:likeAr(miRelPre.atributos).map(relAtr=>({...relAtr, valor:relAtr.valoranterior})).plain()
                    }:miRelPre;
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
    /* FIN DEFINICION STATE */

    /* CARGA Y GUARDADO DE STATE */
    function loadState():HojaDeRuta{
        var contentJson = localStorage.getItem('dm-store-v3');
        if(contentJson){
            var content:HojaDeRuta = JSON4all.parse(contentJson);
            return content;
        }else{
            return initialState;
        }
    }
    function saveState(state:HojaDeRuta){
        localStorage.setItem('dm-store-v2', JSON4all.stringify(state));
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
    window.dmHojaDeRuta = dmHojaDeRuta;
}