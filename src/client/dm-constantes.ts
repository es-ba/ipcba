"use strict";
import * as likeAr from "like-ar" ;
import {TipoPrecio, Producto, RelPre} from "./dm-tipos";

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