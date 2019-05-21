"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador'||context.user.usu_rol ==='jefe_campo'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'parametros',
        //title:'Parametros',
        editable:puedeEditar,
		allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'unicoregistro'                       , typeName:'boolean' , nullable:false , default:true, defaultValue:true, allow:{update:puedeEditar}},
            {name:'nombreaplicacion'                    , typeName:'text'              , allow:{update:puedeEditar}},
            {name:'titulo'                              , typeName:'text'              , allow:{update:puedeEditar}},
            {name:'archivologo'                         , typeName:'text'              , allow:{update:puedeEditar}},
            {name:'tamannodesvpre'                      , typeName:'decimal' , nullable:false , default:2.5, defaultValue:2.5, allow:{update:puedeEditar}},
            {name:'tamannodesvvar'                      , typeName:'decimal' , nullable:false , default:2.5, defaultValue:2.5, allow:{update:puedeEditar}},
            {name:'codigo'                              , typeName:'text'              , allow:{update:puedeEditar}},
            {name:'formularionumeracionglobal'          , typeName:'text'              , allow:{update:puedeEditar}},
            //{name:'estructuraversioncommit'             , typeName:'decimal'            },
            {name:'soloingresaingresador'               , typeName:'text' , default:'S', defaultValue:'S', allow:{update:puedeEditar}},
            {name:'pb_desde'                            , typeName:'text'              , allow:{update:puedeEditar}},
            {name:'pb_hasta'                            , typeName:'text'              , allow:{update:puedeEditar}},
            {name:'ph_desde'                            , typeName:'text'              , allow:{update:puedeEditar}},
            //{name:'diferencia_horaria_tolerancia_ipad'  , typeName:'interval', nullable:false, defaultValue:'01:15:00'       , allow:{update:puedeEditar}},
            //{name:'diferencia_horaria_advertencia_ipad' , typeName:'interval', nullable:false, defaultValue:'00:15:00'       , allow:{update:puedeEditar}},
        ],
        primaryKey:['unicoregistro'],
    },context);
}