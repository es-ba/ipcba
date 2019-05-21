"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'calculos',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name: "calcular"                    , typeName: "bigint"  , editable:false, clientSide:'calcular'},
            {name:'periodo'                      , typeName:'text'     , nullable:false, allow:{update:false}},
            {name:'calculo'                      , typeName:'integer'  , nullable:false, allow:{update:false}},
            {name:'estimacion'                   , typeName:'integer'  , nullable:false, default:0 , allow:{update:puedeEditar} },
            {name:'abierto'                      , typeName:'text'     , nullable:false, default:'N', allow:{update:puedeEditar}},
            {name:'esperiodobase'                , typeName:'text'     , default:'N', visible:false},
            {name:'fechacalculo'                 , typeName:'timestamp', allow:{update:false}},
            {name:'fechageneracionexternos'      , typeName:'timestamp', allow:{update:false}},
            {name:'periodoanterior'              , typeName:'text'     , allow:{update:false}},
            {name:'calculoanterior'              , typeName:'integer'  , allow:{update:false}},
            {name:'agrupacionprincipal'          , typeName:'text'     , nullable:false, default:'A', visible:false},
            {name:'valido'                       , typeName:'text'     , nullable:false, default:'N', visible:false},
            {name:'pb_calculobase'               , typeName:'integer'  , visible:false},
            {name:'motivocopia'                  , typeName:'text'     },
            {name:'transmitir_canastas'          , typeName:'text'     , nullable:false, default:'N', allow:{update:puedeEditar}},
            {name:'fechatransmitircanastas'      , typeName:'timestamp', allow:{update:false}},
            {name:'hasta_panel'                  , typeName:'integer'  , allow:{update:puedeEditar}},
        ],
        primaryKey:['periodo','calculo'],
        foreignKeys:[
            {references:'periodos', fields:['periodo']},
            {references:'calculos_def', fields:['calculo']},
            {references:'calculos_def', fields:[
                {source:'pb_calculobase'  , target:'calculo'     },
            ], alias: 'cal_def'},
            {references:'calculos', fields:[
                {source:'periodoanterior'  , target:'periodo'     },
                {source:'calculoanterior'  , target:'calculo'     },
            ], alias: 'cal'},            
        ],
        detailTables:[
            {table:'calgru', fields:['periodo','calculo'], abr:'G'},
            {table:'caldiv', fields:['periodo','calculo'], abr:'D'},
            {table:'calgru_vw', fields:['periodo','calculo'], abr:'VG'},
            {table:'caldiv_vw', fields:['periodo','calculo'], abr:'VD'},
            {table:'novobs' , fields:['periodo','calculo'], abr:'AB'},
            {table:'novprod' , fields:['periodo','calculo'], abr:'EX'},
        ],
        sortColumns:[{column:'periodo', order:-1}, {column:'calculo'}],
        filterColumns:[
            {column:'periodo', operator:'>=', value:context.be.internalData.filterUltimoPeriodo.replace(/\d\d\d\d/,function(annio){ return annio-1;})},
            {column:'calculo', operator:'=' ,value:context.be.internalData.filterUltimoCalculo}
        ],    
        hiddenColumns:[
            'motivocopia'
        ]    
    }, context);
}