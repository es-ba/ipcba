import { createStore } from "redux";
import { Provider, useSelector, useDispatch } from "react-redux";
import {TipoPrecio, Atributo, Producto, ProdAtr, Formulario, Estructura, RelVis, RelAtr, RelPre} from "./dm-tipos";
import {puedeCopiarTipoPrecio, puedeCopiarAtributos, puedeCambiarPrecioYAtributos} from './dm-constantes';
import { deepFreeze } from "best-globals";
import { mostrarHdr } from "./ejemplo-precios";
import * as likeAr from "like-ar";

var my=myOwn;

export type ProductoState={
    allIds:string[],
    byIds:{[producto:string]:{observaciones:{[obs:number]:RelPre}}},
};

const COPIAR_TP         ='COPIAR_TP';
const COPIAR_ATRIBUTOS  ='COPIAR_ATRIBUTOS';
const SET_ATRIBUTO      ='SET_ATRIBUTO';
type ActionCopiarTp = {type:'COPIAR_TP', payload:{producto:string, observacion:number}};
type ActionCopiarAtributos = {type:'COPIAR_ATRIBUTOS', payload:{producto:string, observacion:number}};
type ActionSetAtributo = {type:'SET_ATRIBUTO', payload:{producto:string, observacion:number, atributo:number, valor:string}};
export type ActionFormulario = ActionCopiarTp | ActionCopiarAtributos | ActionSetAtributo;

myOwn.wScreens.demo_dm = function(addrParams){
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
    ///////// ESTADO:
    const initialState:ProductoState = {
        allIds: Object.keys(formularioCorto.productos),
        byIds: formularioCorto.productos,
    };

    /////////// CONTROLADOR
    function preciosReducer(productoState:ProductoState = initialState, action:ActionFormulario):ProductoState {
        switch (action.type) {
        case COPIAR_TP: {
            const { producto, observacion } = action.payload;
            var misObservaciones = productoState.byIds[producto].observaciones;
            var miRelPre = productoState.byIds[producto].observaciones[observacion];
            //var miTipoPrecio = miObservacion.tipoprecio==null && miObservacion.tipoprecioanterior!=null && tipoPrecio[miObservacion.tipoprecioanterior].puedecopiar=='S'
            return deepFreeze({
                ...productoState,
                byIds:{
                    ...productoState.byIds,
                    [producto]:{
                        observaciones:{
                            ...misObservaciones,
                            [observacion]: {
                                ...miRelPre,
                                tipoprecio: puedeCopiarTipoPrecio(miRelPre)?miRelPre.tipoprecioanterior:miRelPre.tipoprecio
                            }
                        }
                    }
                }
            });
        }
        case SET_ATRIBUTO: {
            const { producto, observacion, atributo, valor } = action.payload;
            var misObservaciones = productoState.byIds[producto].observaciones;
            var miRelPre = productoState.byIds[producto].observaciones[observacion];
            var miAtr = productoState.byIds[producto].observaciones[observacion].atributos[atributo];
            var puedeCambiarAttrs = puedeCambiarPrecioYAtributos(miRelPre);
            return deepFreeze({
                ...productoState,
                byIds:{
                    ...productoState.byIds,
                    [producto]:{
                        observaciones:{
                            ...misObservaciones,
                            [observacion]: {
                                ...miRelPre,
                                cambio:puedeCambiarAttrs?'C':miRelPre.cambio,
                                atributos:{
                                    ...miRelPre.atributos,
                                    [atributo]:{
                                        ...miAtr,
                                        valor: puedeCambiarAttrs?valor:miAtr.valor
                                    }
                                }
                            }
                        }
                    }
                }
            });
        }
        case COPIAR_ATRIBUTOS: {
            const { producto, observacion } = action.payload;
            var misObservaciones = productoState.byIds[producto].observaciones;
            var miRelPre = productoState.byIds[producto].observaciones[observacion];
            var atributos = {...miRelPre.atributos};
            var puedeCopiarAttrs = puedeCopiarAtributos(miRelPre);
            likeAr(miRelPre.atributos).forEach(function(attr,index){
                atributos[index]={...attr};
                atributos[index].valor=puedeCopiarAttrs?atributos[index].valoranterior:atributos[index].valor;
            })
            return deepFreeze({
                ...productoState,
                byIds:{
                    ...productoState.byIds,
                    [producto]:{
                        observaciones:{
                            ...misObservaciones,
                            [observacion]: {
                                ...miRelPre,
                                cambio:puedeCopiarAttrs?'=':miRelPre.cambio,
                                atributos:{
                                    ...atributos
                                }
                            }
                        }
                    }
                }
            });
        }
        default:
            return deepFreeze(productoState);
        }
    }
    const store = createStore(preciosReducer, initialState); 
    mostrarHdr(store)
}
