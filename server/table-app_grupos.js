"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'app_grupos',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:false,
        },
        fields:[
            {name:'agrupacion'       , typeName:'text'    , nullable:false},
            {name:'grupo'            , typeName:'text'    , nullable:false},
            {name:'nombregrupo'      , typeName:'text'                    },
            {name:'nivel'            , typeName:'integer'                 },
            {name:'grupopadre'       , typeName:'text'                    },
        ],
        primaryKey:['agrupacion','grupo'],
        foreignKeys:[
            {references:'app_agrupaciones', fields:[
                {source:'agrupacion'       , target:'agrupacion'   },
            ]},
        ],
        detailTables:[
            {table:'app_calculo_grupos', abr:'CG', label:'calculo_grupos', fields:['agrupacion', 'grupo']},
        ],        
        sql:{
            from:`(
                select agrupacion, grupo, nombregrupo, nivel, grupopadre
                  from precios_app.grupos
                  )`
        }
    }, context);
}