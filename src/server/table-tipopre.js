"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'tipopre',
        title:'Tipopre',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'tipoprecio'              , typeName:'text' , nullable:false                                      , allow:{update:puedeEditar}},
            {name:'nombretipoprecio'        , typeName:'text' , nullable:false                                      , allow:{update:puedeEditar}},
            {name:'espositivo'              , typeName:'text' , nullable:false, default:'N', defaultvalue:'N'       , allow:{update:puedeEditar}},
            {name:'visibleparaencuestador'  , typeName:'text' , nullable:false, default:'S', defaultvalue:'S'       , allow:{update:puedeEditar}},
            {name:'registrablanqueo'        , typeName:'boolean' , nullable:false, default:false, defaultValue:false, allow:{update:puedeEditar}},
            {name:'activo'                  , typeName:'text' , nullable:false, default:'S', defaultvalue:'S'       , allow:{update:puedeEditar}},
            {name:'puedecopiar'             , typeName:'text' , default:'N', defaultValue:'N'                       , allow:{update:puedeEditar}},
            {name:'orden'                   , typeName:'integer'                                                    , allow:{update:puedeEditar}},
        ],
        lookupFields:['nombretipoprecio'],
        primaryKey:['tipoprecio']
    });
}