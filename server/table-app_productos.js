"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'app_productos',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:false,
        },
        fields:[
            {name:'producto'       , typeName:'text'    , nullable:false},
            {name:'nombreproducto' , typeName:'text'    , nullable:false},
            {name:'grupo'          , typeName:'text'    , nullable:false},
            {name:'unidadmedida'   , typeName:'text'                    },
        ],
        primaryKey:['producto'],
        detailTables:[
            {table:'app_calculo_productos', abr:'CP', label:'calculo_productos', fields:['producto']},
        ],        
        foreignKeys:[
            {references:'app_grupos', fields:[
                {source:'grupo'     , target:'grupo'},
            ]},
        ],
        sql:{
            from:`(
                select producto, nombreproducto, grupo, unidadmedida
                  from precios_app.productos
                  )`
        }        
    }, context);
}