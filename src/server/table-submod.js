"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'submod',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      ,typeName:'text'   },
            {name:'panel'                        ,typeName:'integer'},
            {name:'tarea'                        ,typeName:'integer'},
            {name:'modalidad'                    ,typeName:'text'   },
            {name:'informantes'                  ,typeName:'text'   },
            {name:'formularios'                  ,typeName:'text'   },
        ],
        primaryKey:['periodo','panel','tarea','modalidad'],
        sql:{
            isTable: false,
            from:`(select periodo, panel, tarea, modalidad, string_agg(submod_informantes, ';') informantes, string_agg(submod_formularios, ';') formularios 
                   from (select t.periodo, t.panel, t.tarea, t.modalidad, i.tipoinformante||':'||count(distinct informante) as submod_informantes, 
                         i.tipoinformante||':'||count(*) as submod_formularios 
                        from reltar t 
                        join relvis v using (periodo, panel, tarea) 
                        join informantes i using(informante)
                        group by t.periodo, t.panel, t.tarea, t.modalidad, i.tipoinformante
                        order by t.periodo, t.panel, t.tarea, t.modalidad, i.tipoinformante) a
                   group by periodo, panel, tarea, modalidad
                   order by periodo, panel, tarea, modalidad
                )`,
        },
    });
}

 