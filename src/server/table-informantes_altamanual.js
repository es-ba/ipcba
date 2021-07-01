"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='analista'||context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'informantes_altamanual',
        tableName:'informantes',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        //nombrecalle	altura	distrito	fraccion	radio	manzana

        fields:[
            {name: "generar"                  , typeName: "bigint" , editable:false, clientSide:'altamanualgenerar'},
            {name:'informante'                , typeName:'integer' , allow:{update:puedeEditar}},
            {name:'nombreinformante'          , typeName:'text'    , allow:{update:puedeEditar}, postInput:'upperSpanish'},
            {name:'altamanualperiodo'         , typeName:'text'    , allow:{update:puedeEditar}, title:'AltaEnPeriodo'},
            {name:'altamanualpanel'           , typeName:'integer' , allow:{update:puedeEditar}, title:'AltaEnPanel'},
            {name:'altamanualtarea'           , typeName:'integer' , allow:{update:puedeEditar}, title:'AltaEnTarea'},
            {name:'estado'                    , typeName:'text'    , editable:false},
            {name:'tipoinformante'            , typeName:'text'    , allow:{update:puedeEditar}, title:'TI', postInput:'upperSpanish'},
            {name:'rubro'                     , typeName:'integer' , allow:{update:puedeEditar}},

            {name:'periodo'                   , typeName:'text'     , editable:false, title:'ultimoPeriodo'},
            {name:'direccion'                 , typeName:'text'    , editable:false},           
            {name:'nombrecalle'               , typeName:'text'    , allow:{update:puedeEditar}, postInput:'upperSpanish'},
            {name:'altura'                    , typeName:'text'    , allow:{update:puedeEditar}},
            {name:'distrito'                  , typeName:'integer' , allow:{update:puedeEditar}},
            {name:'fraccion'                  , typeName:'integer' , allow:{update:puedeEditar}},
            {name:'radio'                     , typeName:'integer' , allow:{update:puedeEditar}},
            {name:'manzana'                   , typeName:'integer' , allow:{update:puedeEditar}},
            {name:'contacto'                  , typeName:'text'    , allow:{update:puedeEditar}},
            {name:'telcontacto'               , typeName:'text'    , allow:{update:puedeEditar}},
            {name:'web'                       , typeName:'text'    , allow:{update:puedeEditar}},
            {name:'email'                     , typeName:'text'    , allow:{update:puedeEditar}},

            {name:'altamanualconfirmar'       , typeName:'timestamp', allow:{update:puedeEditar}},
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
                   nombrecalle, altura, distrito, fraccion, radio, manzana, contacto, telcontacto, web, email,  altamanualconfirmar, r.periodo
                     from informantes i 
                     left join (select distinct periodo, informante, dense_rank() OVER (PARTITION BY informante ORDER BY periodo desc) as orden
                                  from cvp.relvis) r on i.informante = r.informante 
                    where coalesce(orden, 0) <= 1)`
        }

    },context);
}