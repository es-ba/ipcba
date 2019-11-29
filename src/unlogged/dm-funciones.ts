"use strict";
import {RelPre, RelVis, RelAtr, Estructura} from "./dm-tipos";
import * as likeAr from "like-ar";

export function puedeCopiarTipoPrecio(estructura:Estructura, relPre:RelPre){
    return relPre.tipoprecio==null && relPre.tipoprecioanterior!=null && estructura.tipoPrecio[relPre.tipoprecioanterior].puedecopiar
}

export function puedeCopiarAtributos(estructura:Estructura, relPre:RelPre){
    return !relPre.atributos.every(relAtr=>relAtr.valoranterior == null) && (!relPre.tipoprecio || estructura.tipoPrecio[relPre.tipoprecio].espositivo);
}

export function muestraFlechaCopiarAtributos(estructura:Estructura, relPre:RelPre){
    return relPre.cambio==null && puedeCopiarAtributos(estructura, relPre);
}

export function puedeCambiarPrecioYAtributos(estructura:Estructura, relPre:RelPre){
    return relPre.tipoprecio==null || estructura.tipoPrecio[relPre.tipoprecio].espositivo;
}

export function puedeCambiarTP(estructura:Estructura, relVis:RelVis){
    return relVis.razon && estructura.razones[relVis.razon].espositivoformulario;
}

export function tpNecesitaConfirmacion(estructura:Estructura, relPre:RelPre, tipoPrecioSeleccionado:string){
    return !estructura.tipoPrecio[tipoPrecioSeleccionado].espositivo && (relPre.precio != null || relPre.cambio != null)
}

export function calcularCambioAtributosEnPrecio(relPre:RelPre){
    var hayAtributosActuales = relPre.atributos.some(relAtr=>relAtr.valor != null);
    var hayDiferenciasEntreAtributos = relPre.atributos.some(relAtr=>relAtr.valor!=relAtr.valoranterior);
    return !hayAtributosActuales?null:(!hayDiferenciasEntreAtributos?'=':'C')
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