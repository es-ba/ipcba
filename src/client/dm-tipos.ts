"use strict";
import * as likeAr from "like-ar" ;
/* TODO: controlar los nombres y tipos de la base
 * atributo
 * producto
 * 
 */

export type AtributoDataTypes = 'N'|'C';

export type Atributo = {
    atributo:string
    tipodato:AtributoDataTypes
    nombreatributo:string
    escantidad: boolean
}

export type ProdAtr = {
    rangodesde: number | null
    rangohasta: number | null
    orden: number
    normalizable: boolean
    prioridad: number | null
    tiponormalizacion: string | null
}

export type Producto={
    producto:string
    nombreproducto:string
    especificacioncompleta: string
    _especificaciones__mostrar_cant_um?: string
    atributos:{
        [atributo:string]: ProdAtr
    }
    lista_atributos:number[]
}

export type ForProd = {
    observaciones: number
    orden: number
}

export type Formulario={
    formulario:number
    nombreformulario:string
    orden: number // esto va acá o en la hoja de ruta en ForInf?
    productos: {[p:string]:ForProd}
    lista_productos:string[]
}

export type Razon={
    nombrerazon: string
    espositivoformulario: boolean
    escierredefinitivoinf: boolean
    escierredefinitivofor: boolean
}

export type TipoPrecio = {
    tipoprecio: string
    nombretipoprecio: string
    puedecopiar: boolean
    espositivo: boolean
    predeterminado?:boolean

}

export type Estructura={
    atributos  : {[atributo:number]: Atributo}
    productos  : {[producto:string]: Producto}
    formularios: {[formulario:number]: Formulario}
    tipoPrecio : {[tipoPrecio:string]: TipoPrecio}
    razones    : {[razon:number]: Razon}
}

export type RelAtr={
    valoranterior:string
    valor:string|null
    _valornormal?: number
    _opciones?: string  
    _valor_pesos?: number //AGREGAR A CONSULTA (actualmente viene en PRECIOS MOBILE)
}

export type RelPre={
    precio:number | null,
    precioanterior:number | null,
    tipoprecio:string | null,
    tipoprecioanterior:string | null,
    atributos:{
        [atributo:number]:RelAtr
    }
    cambio: string | null
    comentariosrelpre?: string
    precionormalizado?: number
    precionormalizado_1?: number
    promobs_1?: number
    normsindato?:string
    fueraderango?:string
    sinpreciohace4meses?:string
    adv?: boolean
}

export type RelVis={
    formulario: number
    razon: number
    comentarios: string | null
    productos:{
        [producto:string]:{
            observaciones:{
                [observacion:number]:RelPre
            }
        }
    }
};

export type Informante={
    informante:number,
    nombreinformante:string,
    direccion:string,
    formularios:{
        [formulario:number]:RelVis
    }
}

export type HojaDeRuta={
    encuestador:string,
    dispositivo:string,
    fecha_carga:Date,
    informantes:{[informante:number]:Informante}
}
