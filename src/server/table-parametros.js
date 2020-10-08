"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador'||context.user.usu_rol ==='migracion';
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
            {name:'unicoregistro'                       , typeName:'boolean' , nullable:false , default:true, defaultValue:true, allow:{update:false}},
            {name:'nombreaplicacion'                    , typeName:'text'              , allow:{update:false}},
            {name:'titulo'                              , typeName:'text'              , allow:{update:false}},
            {name:'archivologo'                         , typeName:'text'              , allow:{update:false}},
            {name:'tamannodesvpre'                      , typeName:'decimal' , nullable:false , default:2.5, defaultValue:2.5, allow:{update:false}},
            {name:'tamannodesvvar'                      , typeName:'decimal' , nullable:false , default:2.5, defaultValue:2.5, allow:{update:false}},
            {name:'codigo'                              , typeName:'text'              , allow:{update:false}},
            {name:'formularionumeracionglobal'          , typeName:'text'              , allow:{update:false}, visible:false},
            //{name:'estructuraversioncommit'             , typeName:'decimal'            },
            {name:'soloingresaingresador'               , typeName:'text' , default:'S', defaultValue:'S', allow:{update:false}, visible:false},
            {name:'pb_desde'                            , typeName:'text'              , allow:{update:false}},
            {name:'pb_hasta'                            , typeName:'text'              , allow:{update:false}},
            {name:'ph_desde'                            , typeName:'text'              , allow:{update:false}},
            {name:'sup_aleat_prob1'                     , typeName:'decimal'           , allow:{update:false}},
            {name:'sup_aleat_prob2'                     , typeName:'decimal'           , allow:{update:false}},
            {name:'sup_aleat_prob_per'                  , typeName:'decimal'           , allow:{update:false}},
            {name:'sup_aleat_prob_pantar'               , typeName:'decimal'           , allow:{update:false}},
            //{name:'diferencia_horaria_tolerancia_ipad'  , typeName:'interval', nullable:false, defaultValue:'01:15:00'       , allow:{update:false}},
            //{name:'diferencia_horaria_advertencia_ipad' , typeName:'interval', nullable:false, defaultValue:'00:15:00'       , allow:{update:false}},
            {name:'puedeagregarvisita'                  , typeName:'text'              , allow:{update:false}},
            {name:'permitir_cualquier_cambio_panel_tarea', typeName:'boolean'          , default:false, defaultValue:false, allow:{update:false}, visible:false},
            {name:'periodoreferenciaparapaneltarea'      , typeName:'text'              , allow:{update:false}, visible:false},
            {name:'periodoreferenciaparapreciospositivos', typeName:'text'              , allow:{update:false}, title:'PerReferencia'},
            {name:'solo_cluster'                         , typeName:'integer'           , allow:{update:puedeEditar}},
        ],
        primaryKey:['unicoregistro'],
    },context);
}