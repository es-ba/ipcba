"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'informantes_altamanual',
        tableName:'informantes',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },

        fields:[
            {name:'informante'                , typeName:'integer' , editable:false},
            {name:'nombreinformante'          , typeName:'text'    , editable:false},
            {name:'estado'                    , typeName:'text'    , editable:false},
            {name:'tipoinformante'            , typeName:'text'    , editable:false, title:'TI'},
            {name:'direccion'                 , typeName:'text'    , editable:false},
            {name:'rubro'                     , typeName:'integer' , editable:false},
            {name:'altamanualperiodo'         , typeName:'text'     , allow:{update:puedeEditar}},
            {name:'altamanualpanel'           , typeName:'integer'  , allow:{update:puedeEditar}},
            {name:'altamanualtarea'           , typeName:'integer'  , allow:{update:puedeEditar}},
            {name:'altamanualconfirmar'       , typeName:'timestamp', allow:{update:puedeEditar}},
            {name:'periodo'                   , typeName:'text'     , editable:false, title:'ultimoPeriodo'},
            {name: "generar"                  , typeName: "bigint"  , editable:false, clientSide:'altamanualgenerar'},
        ],
        primaryKey:['informante'],
        hiddenColumns:['altamanualconfirmar'],
        detailTables:[
            {table:'forinf', abr:'FOR', label:'formularios', fields:['informante']},
            {table:'relvis', abr:'VIS', label:'visitas', fields:['periodo','informante']},
        ],
        foreignKeys:[
            {references:'rubros'          , fields:['rubro']           },
            {references:'tipoinf'         , fields:['tipoinformante']  }
        ],
        sql:{
            from:`(select i.informante, nombreinformante, estado, tipoinformante, direccion, rubro, altamanualperiodo, altamanualpanel, altamanualtarea, 
                   altamanualconfirmar, r.periodo
                     from informantes i 
                     left join (select distinct periodo, informante, dense_rank() OVER (PARTITION BY informante ORDER BY periodo desc) as orden
                                  from cvp.relvis) r on i.informante = r.informante 
                    where orden = 1)`
        }

    },context);
}