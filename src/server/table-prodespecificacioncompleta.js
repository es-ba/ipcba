"use strict";

module.exports = function(context){
    var puedeEditar = context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'prodespecificacioncompleta',
        //title:'Prodespecificacioncompleta',
        dbOrigin:'view',
        //editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:false,
        },        
        fields:[
            {name:'producto'                    , typeName:'text'       },
            {name:'formulario'                  , typeName:'integer'    },
            {name:'observacion'                 , typeName:'integer'    },
            {name:'especificacioncompleta'      , typeName:'text'       },
        ],
        primaryKey:['producto','formulario','observacion'],
        sql:{
            from:`(select distinct producto, formulario, observacion, especificacioncompleta
                    from paraimpresionformulariosenblanco
                )`
        }       
        
    },context);
}