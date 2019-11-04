"use strict";
import {RelPre, RelVis, RelAtr} from "./dm-tipos";
import {estructura} from "./dm-estructura";
import * as likeAr from "like-ar";

export function puedeCopiarTipoPrecio(relPre:RelPre){
    return relPre.tipoprecio==null && relPre.tipoprecioanterior!=null && estructura.tipoPrecio[relPre.tipoprecioanterior].puedecopiar=='S'
}

export function puedeCopiarAtributos(relPre:RelPre){
    return relPre.cambio==null && (!relPre.tipoprecio || estructura.tipoPrecio[relPre.tipoprecio].espositivo == 'S');
}

export function puedeCambiarPrecioYAtributos(relPre:RelPre){
    return relPre.tipoprecio==null || estructura.tipoPrecio[relPre.tipoprecio].espositivo != 'N';
}

export function tpNecesitaConfirmacion(relPre:RelPre, tipoPrecioSeleccionado:string){
    return estructura.tipoPrecio[tipoPrecioSeleccionado].espositivo == 'N' && (relPre.precio != null || relPre.cambio != null)
}

export function razonNecesitaConfirmacion(relVis:RelVis, razon:number){
    return estructura.razones[razon].espositivoformulario == "N"
}

export function hayPreciosOAtributosCargadosEnFormulario(relVis:RelVis){
    //Revisar
    //return likeAr(relVis.productos).map(function(producto:{observaciones:{[o:number]:RelPre}}){
    //    return likeAr(producto.observaciones).filter(function(relPre:RelPre){
    //        relPre.cambio != null || relPre.tipoprecio != null
    //    }).array();
    //}).array().length > 0
}