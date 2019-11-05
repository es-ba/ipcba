"use strict";


/* TODO: controlar los nombres y tipos de la base
 * atributo
 * producto
 * 
 */

export type Atributo = {
    atributo:number
    tipodato:string
    nombreatributo:string
    escantidad:boolean
}

export type ProdAtr = {
    orden: number
}&({
    rangodesde: number
    rangohasta: number
    normalizable:true
    prioridad: number 
    tiponormalizacion: string
}|{
    rangodesde: number
    rangohasta: number
    normalizable:false
    prioridad: null
    tiponormalizacion: null
}|{
    rangodesde: null
    rangohasta: null
    normalizable:false
    prioridad: null
    tiponormalizacion: null
})

export type Producto={
    producto:string
    nombreproducto:string
    especificacioncompleta: string
    _especificaciones__mostrar_cant_um?: string|null
    atributos:{
        [atributo:number]: ProdAtr
    }
    listaAtributos:number[]
}

export type ForProd = {
    observaciones: number
    orden: number
}

export type Formulario={
    formulario:number
    nombreformulario:string
    orden: number // esto va acá o en la hoja de ruta en ForInf?
    productos: {[producto:string]:ForProd}
    listaProductos:string[]
}

export type Razones={
    escierredefinitivoinf: boolean
    escierredefinitivofor: boolean
}

export type TipoPrecio = {
    tipoprecio: string
    positivo: boolean // CONFIRMAR NOMBRE
    descripcion:string
    predeterminado?:boolean
    copiable?:boolean
}

export type Estructura={
    atributos  : {[atributo:number]: Atributo}
    productos  : {[producto:string]: Producto}
    formularios: {[formulario:number]: Formulario}
    tipoPrecio : {[tipoPrecio:string]: TipoPrecio}
    razones    : {[razon:number]: Razones}
}

export type RelAtr={
    valoranterior:string
    valor:string|null
    _valornormal?: number
    _opciones?: string  
    _valor_pesos?: number //AGREGAR A CONSULTA (actualmente viene en PRECIOS MOBILE)
}

export type RelPre={
    precio:number|null,
    precioanterior:number|null,
    tipoprecio:string|null,
    tipoprecioanterior:string|null,
    atributos:{
        [atributo:number]:RelAtr
    }
    cambio: string|null
    comentariosrelpre?: string|null
    precionormalizado?: number|null
    precionormalizado_1?: number|null
    promobs_1?: number|null
    normsindato?:string|null
    fueraderango?:string|null
    sinpreciohace4meses?:string|null
    adv?: boolean|null
}

export type RelPreProd={
    observaciones:{
        [observacion:number]:RelPre
    }
}

export type RelVis={
    formulario: number
    razon: number|null
    comentarios: string|null
    productos:{
        [producto:string]:RelPreProd
    }
};

export type Informante={
    informante:number,
    informantenombre:string,
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