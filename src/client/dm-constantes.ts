"use strict";
import * as likeAr from "like-ar" ;
import {TipoPrecio, Producto, RelPre, Estructura, Atributo} from "./dm-tipos";

export const tiposPrecioDef:TipoPrecio[]=[
    {tipoprecio:'P', nombretipoprecio:'Precio normal'   , espositivo:'S', puedecopiar:'N' , predeterminado:true},
    {tipoprecio:'O', nombretipoprecio:'Oferta'          , espositivo:'S', puedecopiar:'N' },
    {tipoprecio:'B', nombretipoprecio:'Bonificado'      , espositivo:'S', puedecopiar:'N' },
    {tipoprecio:'S', nombretipoprecio:'Sin existencia'  , espositivo:'N', puedecopiar:'N' },
    {tipoprecio:'N', nombretipoprecio:'No vende'        , espositivo:'N', puedecopiar:'S'},
    {tipoprecio:'E', nombretipoprecio:'Falta estacional', espositivo:'N', puedecopiar:'S'},
];

export const tipoPrecio=likeAr.createIndex(tiposPrecioDef, 'tipoprecio');

export const tipoPrecioPredeterminado = tiposPrecioDef.find(tp=>tp.predeterminado)!;

export function puedeCopiarTipoPrecio(relPre:RelPre){
    return relPre.tipoprecio==null && relPre.tipoprecioanterior!=null && tipoPrecio[relPre.tipoprecioanterior].puedecopiar=='S'
}

export function puedeCopiarAtributos(relPre:RelPre){
    return relPre.cambio==null && (!relPre.tipoprecio || tipoPrecio[relPre.tipoprecio].espositivo == 'S');
}

export function puedeCambiarPrecioYAtributos(relPre:RelPre){
    return relPre.tipoprecio==null || tipoPrecio[relPre.tipoprecio].espositivo != 'N';
}

export function tpNecesitaConfirmacion(relPre:RelPre, tipoPrecioSeleccionado:string){
    return tipoPrecio[tipoPrecioSeleccionado].espositivo == 'N' && (relPre.precio != null || relPre.cambio != null)
}

export const productos:{[p:string]:Producto} = {
    P01:{
        producto:'P01',
        nombreproducto:'Lata de tomate',
        especificacioncompleta:'Lata de tomate perita enteros pelado de 120 a 140g neto',
        atributos:{
            13:{
                orden:1,
                normalizable:'N',
                prioridad:null,
                rangodesde:null,
                rangohasta:null,
                tiponormalizacion:null
            },
            16:{
                orden:2,
                normalizable:'N',
                prioridad:1,
                rangodesde:120,
                rangohasta:140,
                tiponormalizacion:'normal'
            }
        },
        listaAtributos:[13,16]
    },
    P02:{
        producto:'P02',
        nombreproducto:'Lata de arvejas',
        especificacioncompleta:'Lata de arvejas peladas de 120 a 140g neto',
        atributos:{
            13:{
                orden:1,
                normalizable:'N',
                prioridad:null,
                rangodesde:null,
                rangohasta:null,
                tiponormalizacion:null
            },
            16:{
                orden:2,
                normalizable:'S',
                prioridad:1,
                rangodesde:120,
                rangohasta:140,
                tiponormalizacion:'normal'
            }
        },
        listaAtributos:[13,16]
    },
    P03:{
        producto:'P02',
        nombreproducto:'Yerba',
        especificacioncompleta:'Paquete de yerba con palo en envase de papel de 500g',
        atributos:{
            13:{
                orden:1,
                normalizable:'N',
                prioridad:null,
                rangodesde:null,
                rangohasta:null,
                tiponormalizacion:null
            },
            16:{
                orden:3,
                normalizable:'S',
                prioridad:1,
                rangodesde:120,
                rangohasta:140,
                tiponormalizacion:'normal'
            },
            55:{
                orden:2,
                normalizable:'S',
                prioridad:1,
                rangodesde:120,
                rangohasta:140,
                tiponormalizacion:'normal'
            }
        },
        listaAtributos:[13,55,16]
    }
}

var razones={
    1:{escierredefinitivoinf:'N', escierredefinitivofor:'N'}
}

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

export const estructura:Estructura={
    tipoPrecio,
    razones,
    atributos,
    productos,
    formularios,
}