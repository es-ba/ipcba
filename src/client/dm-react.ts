import { createStore } from "redux";
import { Provider, useSelector, useDispatch } from "react-redux";
import {TipoPrecio, Atributo, Producto, ProdAtr, Formulario, Estructura, RelVis, RelAtr, RelPre} from "./dm-tipos";
import {puedeCopiarTipoPrecio} from './dm-constantes';
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
type ActionCopiarTp = {type:'COPIAR_TP', payload:{producto:string, observacion:number}};
type ActionCopiarAtributos = {type:'COPIAR_ATRIBUTOS', payload:{producto:string, observacion:number}};
export type ActionFormulario = ActionCopiarTp | ActionCopiarAtributos;

myOwn.wScreens.demo_dm = function(addrParams){
    var atributos:{[a:string]:Atributo}={
        '13':{
            atributo:'13',
            nombreatributo:'Marca',
            escantidad:'N',
            tipodato:'C'
        },
        '16':{
            atributo:'16',
            nombreatributo:'Gramaje',
            escantidad:'S',
            tipodato:'N'
        },
        '55':{
            atributo:'55',
            nombreatributo:'Variante',
            escantidad:'N',
            tipodato:'C'
        }
    }
   
    var formularios:{[f:number]:Formulario}={
        99:{
            formulario:99,
            nombreformulario:'Prueba',
            orden:99,
            productos:{
                P01:{
                    orden:2,
                    observaciones:2
                },
                P02:{
                    orden:3,
                    observaciones:1
                },
                P03:{
                    orden:1,
                    observaciones:1
                },
            },
            listaProductos:['P03','P01','P02']
        }
    }
    
    var razones={
        1:{escierredefinitivoinf:'N', escierredefinitivofor:'N'}
    }
    
    //var estructura:Estructura={
    //    tipoPrecio,
    //    razones,
    //    atributos,
    //    productos,
    //    formularios,
    //}
    
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
                        tipoprecio:null,
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
        default:
            return deepFreeze(productoState);
        }
    }
    const store = createStore(preciosReducer, initialState); 
    mostrarHdr(store)
}
