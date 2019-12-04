"use strict";
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

export type LetraTipoOpciones = 'A'|'C'|'N'

export type ProdAtr = {
    atributo: number
    rangodesde: number | null
    rangohasta: number | null
    orden: number
    normalizable: boolean
    prioridad: number | null
    tiponormalizacion: string | null
    opciones: LetraTipoOpciones
    prodatrval:{
        [valor:string]:null
    }
    valornormal: number | null
    lista_prodatrval:string[]
    mostrar_cant_um: boolean
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

type TipoMoneda = 'ARS' | 'USD';

export type Relmon = {
    moneda: TipoMoneda,
    valor_pesos: number
}

export type Estructura={
    atributos  : {[atributo:number]: Atributo}
    productos  : {[producto:string]: Producto}
    formularios: {[formulario:number]: Formulario}
    tipoPrecio : {[tipoPrecio:string]: TipoPrecio}
    tiposPrecioDef: TipoPrecio[],
    tipoPrecioPredeterminado: TipoPrecio,
    razones    : {[razon:number]: Razon}
    relmon     : {[moneda:string]: Relmon}
}

export type RelAtr={
    informante: number
    formulario: number
    producto: string
    observacion: number
    atributo: number,
    valoranterior:string
    valor:string|null
}

export type Cambio = 'C'|'='

export type RelPre={
    informante: number
    formulario: number
    producto: string
    observacion: number
    precio:number | null
    precioanterior:number | null
    tipoprecio:string | null
    tipoprecioanterior:string | null
    atributos: RelAtr[]
    cambio: Cambio | null
    comentariosrelpre: string | null
    precionormalizado: number | null
    precionormalizado_1: number | null
    promobs_1?: number
    normsindato?:string
    fueraderango?:string
    sinpreciohace4meses?:string
    adv: boolean
}

export type RelVisPk = {
    informante:number,
    formulario:number
}

export type RelVis={
    informante: number
    formulario: number
    razon: number | null
    comentarios: string | null
};

export type RelInf={
    informante:number
    nombreinformante:string
    direccion:string
    formularios: RelVis[]
    observaciones: RelPre[]
}

export type OpcionesHojaDeRuta={
    letraGrandeFormulario?:boolean
}

export type HojaDeRuta={
    encuestador:string,
    dispositivo:string,
    fecha_carga:Date,
    informantes:RelInf[]
    idActual?:string|null
    relVisPk?:RelVisPk
    opciones?:OpcionesHojaDeRuta
}
