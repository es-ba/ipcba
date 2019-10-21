"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador'||context.user.usu_rol ==='jefe_campo'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'magnitudes',
        editable:puedeEditar,
		allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },
        fields:[
            {name:'magnitud'                  , typeName:'text'    , nullable:false, allow:{update:puedeEditar}},
            {name:'nombremagnitud'            , typeName:'text'    , isName:true   , allow:{update:puedeEditar}},
            {name:'unidadprincipalsingular'   , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'unidadprincipalplural'     , typeName:'text'                    , allow:{update:puedeEditar}},
        ],
        primaryKey:['magnitud'],

    },context);
}