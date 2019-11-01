import { createStore } from "redux";
import { RelVis, RelPre, HojaDeRuta } from "./dm-tipos";
import { tipoPrecioPredeterminado, tipoPrecio} from './dm-estructura';
import { puedeCopiarTipoPrecio, puedeCopiarAtributos, puedeCambiarPrecioYAtributos} from "./dm-funciones";
import { deepFreeze } from "best-globals";
import { mostrarHdr } from "./ejemplo-precios";
import * as likeAr from "like-ar";
import * as bestGlobals from "best-globals";

var my=myOwn;

/* INICIO ACCIONES */
const SET_TP            = 'SET_TP';
const COPIAR_TP         = 'COPIAR_TP';
const SET_PRECIO        = 'SET_PRECIO';
const COPIAR_ATRIBUTOS  = 'COPIAR_ATRIBUTOS';
const SET_ATRIBUTO      = 'SET_ATRIBUTO';

type ActionSetTp           = {type:'SET_TP'          , payload:{informante:number, formulario:number, producto:string, observacion:number, valor:string}};
type ActionCopiarTp        = {type:'COPIAR_TP'       , payload:{informante:number, formulario:number, producto:string, observacion:number}};
type ActionSetPrecio       = {type:'SET_PRECIO'      , payload:{informante:number, formulario:number, producto:string, observacion:number, valor:number}};
type ActionCopiarAtributos = {type:'COPIAR_ATRIBUTOS', payload:{informante:number, formulario:number, producto:string, observacion:number}};
type ActionSetAtributo     = {type:'SET_ATRIBUTO'    , payload:{informante:number, formulario:number, producto:string, observacion:number, atributo:number, valor:string}};

/*
function <K extends string|number, U, T extends {K:U}>red(key:K, reduxer((previous:T)=>U)){
    return {

    }
}
*/

export type ActionHdr = ActionSetTp | ActionCopiarTp | ActionSetPrecio | ActionCopiarAtributos | ActionSetAtributo;
/* FIN ACCIONES */

// function surf<T extends {[key:K]}>(object:T, key:keyof T, callback:(object:T[keyof T])=>T[keyof T]):T
//function surf<T extends {}>(object:T, key:keyof T, callback:(object:T[keyof T])=>T[keyof T]):T{
function surf<T extends {}, K extends keyof T>(object:T, key:K, callback:(object:T[K])=>T[K]):T{
    return {
        ...object,
        [key]: callback(object[key])
    };
}


myOwn.wScreens.demo_dm = async function(_addrParams){
    /* FORM EJEMPLO, LUEGO SE TRAE POR AJAX */
    var formularioCorto:RelVis = {
        formulario:99,
        razon:1,
        comentarios:null,
        productos:{
            P01:{
                observaciones:{
                    1:{
                        tipoprecioanterior:'P',
                        precioanterior:120,
                        tipoprecio:'O',
                        precio:130,
                        atributos:{
                            13:{valoranterior:'La campagnola', valor:null},
                            16:{valoranterior:'300', valor:null}
                        },
                        cambio: null
                    },
                    2:{
                        tipoprecioanterior:'P',
                        precioanterior:102,
                        tipoprecio:null,
                        precio:null,
                        atributos:{
                            13:{valoranterior:'Arcor', valor:null},
                            16:{valoranterior:'300', valor:null}
                        },
                        cambio: null
                    }
                }
            },
            P02:{
                observaciones:{
                    1:{
                        tipoprecioanterior:'P',
                        precioanterior:140,
                        tipoprecio:'N',
                        precio:null,
                        atributos:{
                            13:{valoranterior:'La campagnola', valor:null},
                            16:{valoranterior:'300', valor:null}
                        },
                        cambio: null
                    }
                }
            },
            P03:{
                observaciones:{
                    1:{
                        tipoprecioanterior:'N',
                        precioanterior:null,
                        tipoprecio:null,
                        precio:null,
                        atributos:{
                            13:{valoranterior:'Unión', valor:null},
                            16:{valoranterior:'500', valor:null},
                            55:{valoranterior:'Suave sin palo', valor:null},
                        },
                        cambio: null
                    }
                }
            },
        }
    };
    /* FIN FORM EJEMPLO, LUEGO SE TRAE POR AJAX */

    /* DEFINICION CONTROLADOR */
    function hdrReducer(hdrState:HojaDeRuta = initialState, action:ActionHdr):HojaDeRuta {
        action.payload = {
            ...action.payload,
            informante:3333,
            formulario:99
        }
        var defaultAction = function defaultAction(){return deepFreeze(hdrState)};

        /*
        var enRelPre3 = (relPreReducer:(productoState:RelPre)=>RelPre)=>surf(hdrState)
            .in('informantes').in(action.payload.informante)
            .in('formularios').in(action.payload.formulario)
            .in('productos').in(action.payload.producto)
            .in('observaciones').in(action.payload.observacion)
            .redux(relPreReducer)
            .freeze();

        var enRelPre3 = (relPreReducer:(productoState:RelPre)=>RelPre)=>
            surfRedux(relPreReducer,
                surfIn('observaciones',surfIn(action.payload.observacion,
                    surfIn('productos',surfIn(action.payload.producto,
                        surfIn('formularios',surfIn(action.payload.formulario,
                            surfIn('informantes',surfIn(action.payload.informante,
                                surfStart(hdrState)
                            ))
                        ))
                    ))
                ))
            );
        */

        var enRelPre = (relPreReducer:(productoState:RelPre)=>RelPre)=>
            surf(hdrState,'informantes', x=>surf(x,action.payload.informante,x=>
                surf(x,'formularios', x=>surf(x,action.payload.formulario,x=>
                    surf(x,'productos', x=>surf(x,action.payload.producto,x=>
                        surf(x,'observaciones', x=>surf(x,action.payload.observacion,relPreReducer))
                    ))
                ))
            ));

        var enRelPre1 = (relPreReducer:(productoState:RelPre)=>RelPre)=>deepFreeze({
            ...hdrState,
            informantes:{
                ...hdrState.informantes,
                [action.payload.informante]:{
                    ...hdrState.informantes[action.payload.informante], 
                    formularios:{
                        ...hdrState.informantes[action.payload.informante]
                            .formularios, 
                        [action.payload.formulario]:{
                            ...hdrState.informantes[action.payload.informante]
                                .formularios[action.payload.formulario], 
                            productos: {
                                ...hdrState.informantes[action.payload.informante]
                                    .formularios[action.payload.formulario]
                                    .productos,
                                [action.payload.producto]:{
                                    ...hdrState.informantes[action.payload.informante]
                                        .formularios[action.payload.formulario]
                                        .productos[action.payload.producto],
                                    observaciones: {
                                        ...hdrState.informantes[action.payload.informante]
                                            .formularios[action.payload.formulario]
                                            .productos[action.payload.producto]
                                            .observaciones,
                                        [action.payload.observacion]: relPreReducer(
                                            hdrState.informantes[action.payload.informante]
                                                .formularios[action.payload.formulario]
                                                .productos[action.payload.producto]
                                                .observaciones[action.payload.observacion]
                                        )
                                    }
                                }
                            }

                        }
                    }
                }
            }
            
        })
        var setTP = function setTP(tipoPrecioRedux:(miRelPre:RelPre)=>string|null){
            return enRelPre(miRelPre=>{
                var tipoPrecioNuevo = tipoPrecioRedux(miRelPre);
                var esNegativo = !tipoPrecioNuevo || tipoPrecio[tipoPrecioNuevo].espositivo == 'N';
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
            case SET_TP: {
                return setTP(_ => action.payload.valor);
            }
            case COPIAR_TP: {
                return setTP(relPre => puedeCopiarTipoPrecio(relPre)?relPre.tipoprecioanterior:relPre.tipoprecio)
            }
            case SET_PRECIO: {
                return enRelPre((miRelPre:RelPre)=>{
                    var puedeCambiarPrecio = puedeCambiarPrecioYAtributos(miRelPre);
                    return {
                        ...miRelPre,
                        precio:puedeCambiarPrecio?action.payload.valor:miRelPre.precio,
                        tipoprecio:puedeCambiarPrecio && !miRelPre.tipoprecio?tipoPrecioPredeterminado.tipoprecio:miRelPre.tipoprecio
                    }
                });
            }
            case SET_ATRIBUTO: {
                return enRelPre((miRelPre:RelPre)=>{
                    var puedeCambiarAttrs = puedeCambiarPrecioYAtributos(miRelPre);
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
                return enRelPre((miRelPre:RelPre)=>{
                    var puedeCopiarAttrs = puedeCopiarAtributos(miRelPre);
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
    const initialState:HojaDeRuta = {
        dispositivo: 'N33',
        encuestador: '13',
        fechaCarga: bestGlobals.date.ymd(2019,11,1),
        informantes:{
            3333:{
                informante: 3333,
                nombreinformante: "Ferretería X",
                domicilio: "San José 999",
                formularios:{
                    99:formularioCorto
                }
            }
        }
    };
    /* FIN DEFINICION STATE */

    /* CARGA Y GUARDADO DE STATE */
    function loadState():HojaDeRuta{
        var contentJson = localStorage.getItem('dm-store-v2');
        if(contentJson){
            var content = JSON.parse(contentJson);
            return {...content, fechaCarga:bestGlobals.date.iso(content.fechaCarga) }
        }else{
            return initialState;
        }
    }
    function saveState(state:HojaDeRuta){
        localStorage.setItem('dm-store-v2', JSON.stringify(state));
    }
    /* FIN CARGA Y GUARDADO DE STATE */

    /* CREACION STORE */
    const store = createStore(hdrReducer, loadState()); 
    store.subscribe(function(){
        saveState(store.getState());
    });
    /* FIN CREACION STORE */

    //HDR CON STORE CREADO
    mostrarHdr(store)
}
