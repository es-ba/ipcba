"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='ingresador' || context.user.usu_rol ==='programador' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recep_gabinete'|| context.user.usu_rol ==='migracion'|| context.user.usu_rol ==='supervisor';
    return context.be.tableDefAdapt({
        name:'control_comentariosrelvis',
        tableName:'relvis',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },        
        fields:[
            {name:'periodo'                      ,typeName:'text'   , allow:{update:false}      }, 
            {name:'informante'                   ,typeName:'integer', allow:{update:false}      },
            {name:'visita'                       ,typeName:'integer', allow:{update:false}      },
            {name:'panel'                        ,typeName:'integer', allow:{update:false}      },
            {name:'tarea'                        ,typeName:'integer', allow:{update:false}      },
            {name:'encuestador'                  ,typeName:'text'   , allow:{update:false}, title:'enc'},
            {name:'nombreencuestador'            ,typeName:'text'   , allow:{update:false}      },
            {name:'recepcionista'                ,typeName:'text'   , allow:{update:false}, title:'rec'},
            {name:'nombrerecepcionista'          ,typeName:'text'   , allow:{update:false}      },
            {name:'rubro'                        ,typeName:'integer', allow:{update:false}      },
            {name:'nombrerubro'                  ,typeName:'text'   , allow:{update:false}      },
            {name:'formulario'                   ,typeName:'integer', allow:{update:false}, title:'for'},
            {name:'nombreformulario'             ,typeName:'text'   , allow:{update:false}      },
            {name:'comentarios'                  ,typeName:'text'   , allow:{update:puedeEditar}, width:500},
        ],
        primaryKey:['periodo','informante','visita','formulario'],
        sortColumns:[{column:'periodo'},{column:'panel'},{column:'tarea'},{column:'informante'},{column:'visita'},{column:'formulario'}],        
        sql:{
            from:`(SELECT r.periodo, r.informante, r.visita, r.panel, r.tarea, r.encuestador,
            (pe.nombre::text || ' '::text) || pe.apellido::text AS nombreencuestador,
            r.recepcionista, (pr.nombre::text || ' '::text) || pr.apellido::text AS nombrerecepcionista,
            i.rubro, u.nombrerubro, r.formulario, f.nombreformulario, r.comentarios
             FROM cvp.relvis r
             LEFT JOIN cvp.informantes i ON r.informante = i.informante
             LEFT JOIN cvp.personal pe ON r.encuestador::text = pe.persona::text
             LEFT JOIN cvp.personal pr ON r.recepcionista::text = pr.persona::text
             LEFT JOIN cvp.rubros u ON i.rubro = u.rubro
             LEFT JOIN cvp.formularios f ON r.formulario = f.formulario
            WHERE r.comentarios IS NOT NULL)`
        }
    },context);
}