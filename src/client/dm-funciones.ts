"use strict";
import {RelPre, RelVis, RelAtr, Estructura} from "./dm-tipos";
import * as likeAr from "like-ar";

export function puedeCopiarTipoPrecio(estructura:Estructura, relPre:RelPre){
    return relPre.tipoprecio==null && relPre.tipoprecioanterior!=null && estructura.tipoPrecio[relPre.tipoprecioanterior].puedecopiar
}

export function puedeCopiarAtributos(estructura:Estructura, relPre:RelPre){
    return relPre.cambio==null && (!relPre.tipoprecio || estructura.tipoPrecio[relPre.tipoprecio].espositivo);
}

export function puedeCambiarPrecioYAtributos(estructura:Estructura, relPre:RelPre, relVis:RelVis){
    return (relPre.tipoprecio==null || estructura.tipoPrecio[relPre.tipoprecio].espositivo) && estructura.razones[relVis.razon].espositivoformulario;
}

export function puedeCambiarTP(estructura:Estructura, relVis:RelVis){
    return estructura.razones[relVis.razon].espositivoformulario;
}

export function tpNecesitaConfirmacion(estructura:Estructura, relPre:RelPre, tipoPrecioSeleccionado:string){
    return !estructura.tipoPrecio[tipoPrecioSeleccionado].espositivo && (relPre.precio != null || relPre.cambio != null)
}

export function razonNecesitaConfirmacion(estructura:Estructura, relVis:RelVis, razon:number){
    return !estructura.razones[razon].espositivoformulario
}

export function hayPreciosOAtributosCargadosEnFormulario(estructura:Estructura, relVis:RelVis){
    //Revisar
    //return likeAr(relVis.productos).map(function(producto:{observaciones:{[o:number]:RelPre}}){
    //    return likeAr(producto.observaciones).filter(function(relPre:RelPre){
    //        relPre.cambio != null || relPre.tipoprecio != null
    //    }).array();
    //}).array().length > 0
}