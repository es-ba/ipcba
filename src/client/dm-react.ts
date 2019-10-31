import { createStore } from "redux";
import { RelVis, ProductoState, HojaDeRuta } from "./dm-tipos";
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
type ActionSetPrecio       = {type:'SET_PRECIO'      , payload:{informante:number, formulario:number, producto:string, observacion:number, valor:string}};
type ActionCopiarAtributos = {type:'COPIAR_ATRIBUTOS', payload:{informante:number, formulario:number, producto:string, observacion:number}};
type ActionSetAtributo     = {type:'SET_ATRIBUTO'    , payload:{informante:number, formulario:number, producto:string, observacion:number, atributo:number, valor:string}};

export type ActionHdr = ActionSetTp | ActionCopiarTp | ActionSetPrecio | ActionCopiarAtributos | ActionSetAtributo;
/* FIN ACCIONES */

myOwn.wScreens.demo_dm = function(addrParams){
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
        var defaultAction = function defaultAction(){return deepFreeze(hdrState)};
        var enElFormulario = (productoState:RelPre)=>deepFreeze({
            ...hdrState,
            informantes:{
                [action.payload.informante]:{
                    ...hdrState.informantes[action.payload.informante], 
                    formularios:{
                        ...hdrState.informantes[action.payload.informante]
                            .formularios[action.payload.formulario], 
                        [action.payload.formulario]:{
                            productos: {
                                ...hdrState.informantes[action.payload.informante]
                                    .formularios[action.payload.formulario]
                                    .productos[action.payload.producto],
                                [action.payload.producto]:{
                                    ...hdrState.informantes[action.payload.informante]
                                        .formularios[action.payload.formulario]
                                        .productos[action.payload.producto]
                                        .observaciones[action.payload.observacion],
                                    observaciones: {
                                        [action.payload.observacion]: productoState
                                    }
                                }
                            }

                        }
                    }
                }
            }
            
        })
        var setTP = function setTP(producto:string, observacion:number, valor:string){
            var misObservaciones = hdrState.byIds[producto].observaciones;
            var miRelPre = hdrState.byIds[producto].observaciones[observacion];
            var atributos = {...miRelPre.atributos};
            var esNegativo = tipoPrecio[valor].espositivo == 'N';
            likeAr(miRelPre.atributos).forEach(function(attr,index){
                atributos[index]={...attr};
                atributos[index].valor=esNegativo?null:atributos[index].valor;
            })
            return enElFormulario({
                ...miRelPre,
                precio: esNegativo?null:miRelPre.precio,
                cambio: esNegativo?null:miRelPre.cambio,
                tipoprecio: valor,
                atributos:{
                    ...atributos
                }
            });
        }
        switch (action.type) {
            case SET_TP: {
                const { producto, observacion, valor } = action.payload;
                return setTP(producto, observacion, valor);
            }
            case COPIAR_TP: {
                const { producto, observacion } = action.payload;
                var misObservaciones = hdrState.byIds[producto].observaciones;
                var miRelPre = hdrState.byIds[producto].observaciones[observacion];
                var atributos = {...miRelPre.atributos};
                if(puedeCopiarTipoPrecio(miRelPre)){
                    return setTP(producto, observacion, miRelPre.tipoprecioanterior!)
                }else{
                    return defaultAction()
                }

            }
            case SET_PRECIO: {
                const { producto, observacion, valor } = action.payload;
                var misObservaciones = hdrState.byIds[producto].observaciones;
                var miRelPre = hdrState.byIds[producto].observaciones[observacion];
                var puedeCambiarPrecio = puedeCambiarPrecioYAtributos(miRelPre);
                return enElFormulario({
                    ...miRelPre,
                    precio:puedeCambiarPrecio?valor:miRelPre.precio,
                    tipoprecio:puedeCambiarPrecio && !miRelPre.tipoprecio?tipoPrecioPredeterminado.tipoprecio:miRelPre.tipoprecio
                });
            }
            case SET_ATRIBUTO: {
                const { producto, observacion, atributo, valor } = action.payload;
                var misObservaciones = hdrState.byIds[producto].observaciones;
                var miRelPre = hdrState.byIds[producto].observaciones[observacion];
                var miAtr = hdrState.byIds[producto].observaciones[observacion].atributos[atributo];
                var puedeCambiarAttrs = puedeCambiarPrecioYAtributos(miRelPre);
                return enElFormulario({
                    ...miRelPre,
                    cambio:puedeCambiarAttrs?'C':miRelPre.cambio,
                    atributos:{
                        ...miRelPre.atributos,
                        [atributo]:{
                            ...miAtr,
                            valor: puedeCambiarAttrs?valor:miAtr.valor
                        }
                    }
                });
            }
            case COPIAR_ATRIBUTOS: {
                const { producto, observacion } = action.payload;
                var misObservaciones = hdrState.byIds[producto].observaciones;
                var miRelPre = hdrState.byIds[producto].observaciones[observacion];
                var atributos = {...miRelPre.atributos};
                var puedeCopiarAttrs = puedeCopiarAtributos(miRelPre);
                likeAr(miRelPre.atributos).forEach(function(attr,index){
                    atributos[index]={...attr};
                    atributos[index].valor=puedeCopiarAttrs?atributos[index].valoranterior:atributos[index].valor;
                })
                return enElFormulario({
                    ...miRelPre,
                    cambio:puedeCopiarAttrs?'=':miRelPre.cambio,
                    atributos:{
                        ...atributos
                    }
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
        fechaCarga: bestGlobals.date(2019,11,1),
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
    function loadState():ProductoState{
        var content = localStorage.getItem('dm-store');
        if(content){
            return JSON.parse(content);
        }else{
            return initialState;
        }
    }
    function saveState(state:ProductoState){
        localStorage.setItem('dm-store', JSON.stringify(state));
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
