"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'paraimpresionformulariosenblanco',
        //title:'Paraimpresionformulariosenblanco',
        dbOrigin:'view',
        //editable:false,
        fields:[
            {name:'formulario'              , typeName:'integer' },
            {name:'producto'                , typeName:'text'    },
            {name:'orden'                   , typeName:'integer' , allow:{select:false}},
            {name:'observacion'             , typeName:'integer' },
            {name:'nombreformulario'        , typeName:'text'    , allow:{select:false}},
            {name:'tamanonormal'            , typeName:'decimal'  , allow:{select:false}},
            {name:'nombreproducto'          , typeName:'text'    , allow:{select:false}},
            {name:'codigo_producto'         , typeName:'text'    , allow:{select:false}},
            {name:'cantobs'                 , typeName:'integer' , allow:{select:false}},
            {name:'soloparatipo'            , typeName:'text'    , allow:{select:false}},
            {name:'despacho'                , typeName:'text'    , allow:{select:false}},
            {name:'especificacioncompleta'  , typeName:'text'    },
            {name:'dependedeldespacho'      , typeName:'text'    , allow:{select:false}},
        ],
        primaryKey:['formulario','producto','observacion']
    });
}