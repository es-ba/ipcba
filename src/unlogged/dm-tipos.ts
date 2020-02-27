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
    destacado: boolean
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

export type Informante={
    informante :number
    direccion :string
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
    visibleparaencuestador: boolean
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
    informantes: {[informante:number]: Informante}
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
    comentariosrelpre_1: string | null
    esvisiblecomentarioendm_1: boolean
    precionormalizado: number | null
    precionormalizado_1: number | null
    promobs_1: number
    sinpreciohace4meses:boolean
    ultimoperiodoconprecio: string | null
    cantidadperiodossinprecio: number | null
    ultimoprecioinformado: number | null
    repregunta: boolean
    adv: boolean
    err: boolean
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
    cantidad_periodos_sin_informacion: number
}

export type QueVer = 'todos'|'pendientes'|'advertencias';

export type OpcionesHojaDeRuta={
    pantallaOpciones: boolean
    queVer: QueVer
    idActual:string|null
    relVisPk:RelVisPk | null
    letraGrandeFormulario:boolean
    mostrarColumnasFaltantesYAdvertencias: boolean
    allForms: boolean
    searchString: string
    verRazon: boolean
    compactar: false
    posHdr: number
    cargando: boolean
    posFormularios: {formulario: number, position: number}[]
    observacionesFiltradasIdx: {iRelPre:number}[]
    observacionesFiltradasEnOtrosIdx: {iRelPre:number}[]
}

export function getDefaultOptions():OpcionesHojaDeRuta{
    return {
        pantallaOpciones: false,
        queVer: 'todos',
        idActual: null,
        relVisPk: null,
        letraGrandeFormulario: false,
        mostrarColumnasFaltantesYAdvertencias: false,
        allForms: false,
        searchString: '',
        verRazon: true,
        compactar: false,
        posHdr: 0,
        cargando: false,
        posFormularios: [],
        observacionesFiltradasIdx: [],
        observacionesFiltradasEnOtrosIdx: []
    }
}

export type HojaDeRuta={
    encuestador:string,
    nombreencuestador:string,
    apellidoencuestador:string,
    panel: number,
    tarea: number,
    dispositivo:string,
    fecha_carga:Date,
    informantes:RelInf[]
    opciones: OpcionesHojaDeRuta
}

export type AddrParamsHdr={
    periodo: string | null
    panel: number | null
    tarea: number | null
}