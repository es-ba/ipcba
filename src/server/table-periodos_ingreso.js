"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo';
    return context.be.tableDefAdapt({
        name:'periodos_ingreso',
        tableName:'periodos',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },        
        fields:[
            {name:'periodo'                     , typeName:'text'     , nullable:false                             },
            {name:'ano'                         , typeName:'integer'                                               },
            {name:'mes'                         , typeName:'integer'                                               },
            {name:'ingresando'                  , typeName:'text'                                                  },
            {name: "generar"                    , typeName: "bigint"  , editable:false, clientSide:'generarPeriodo'},
            {name:'fechageneracionperiodo'      , typeName:'timestamp'                                             },                
            {name:'habilitado'                  , typeName:'text'                                                  },
        ],
        primaryKey:['periodo'],
        filterColumns:[
            {column:'ingresando', operator:'=', value:'S'},
        ],        
        sortColumns:[{column:'periodo', order:-1}],
        detailTables:[
            {table:'relpan', abr:'PAN', label:'paneles', fields:['periodo']},
        ],
        sql:{
            from:`(select periodo, ano, mes, ingresando, fechageneracionperiodo, habilitado
                    from periodos
                  )`,
        }        
    },context);
}