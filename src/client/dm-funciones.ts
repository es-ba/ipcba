"use strict";
import {RelPre} from "./dm-tipos";
import {estructura} from "./dm-estructura";

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