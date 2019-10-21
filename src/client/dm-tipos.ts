"use strict";


/* TODO: controlar los nombres y tipos de la base
 * atributo
 * producto
 * 
 */

export type Atributo = {
    atributo:string
    tipodato:string
    nombreatributo:string
    escantidad: string
}

export type ProdAtr = {
    rangodesde: number
    rangohasta: number
    orden: number
    normalizable: string
    prioridad: number 
    tiponormalizacion: string
}

export type Producto={
    producto:string
    nombreproducto:string
    especificacioncompleta: string
    _especificaciones__mostrar_cant_um: string
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
    productos: ForProd
    listaProductos:number[]
}

export type Razones={
    escierredefinitivoinf: string
    escierredefinitivofor: string
}

export type TipoPrecio = {
    tipoprecio: string
    positivo: string // CONFIRMAR NOMBRE

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
    valor:string
    _valornormal: number
    _opciones: string  
    _valor_pesos: number //AGREGAR A CONSULTA (actualmente viene en PRECIOS MOBILE)
}

export type RelPre={
    precio:number,
    precioanterior:number,
    tipopecio:string,
    tipoprecioanterior:string,
    atributos:{
        [atributo:number]:RelAtr
    }
    cambio: string
    comentariosrelpre: string
    precionormalizado: number
    precionormalizado_1: number
    promobs_1: number
    normsindato:string
    fueraderango:string
    sinpreciohace4meses:string
    adv: boolean
}

export type RelVis={
    formulario: number
    razon: number
    comentarios: string
    productos:{
        [producto:number]:{
            observaciones:{
                [observacion:number]:RelPre
            }
        }
    }
};

export type Informante={
    informante:number,
    informantenombre:string,
    domicilio:string,
    formularios:{
        [formulario:number]:RelVis
    }
}

export type HojaDeRuta={
    encuestador:string,
    dispositivo:string,
    fechaCarga:Date,
    informantes:{[informante:number]:Informante}
}