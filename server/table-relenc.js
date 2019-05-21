"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'relenc',
        //title:'Relenc',
        editable:puedeEditar,
        fields:[
            {name:'periodo'            , typeName:'text'    , nullable:false},
            {name:'panel'              , typeName:'integer' , nullable:false},
            {name:'tarea'              , typeName:'integer' , nullable:false},
            {name:'encuestador'        , typeName:'text'    , nullable:false},
            {name:'encuestadornombre'  , typeName:'text'    , nullable:false},
            {name:'titular'            , typeName:'text'    , nullable:false},
            {name:'titularnombre'      , typeName:'text'    , nullable:false},
        ],
        primaryKey:['periodo','panel','tarea'],
        foreignKeys:[
            {references:'personal', fields:[
                {source:'encuestador'         , target:'persona'     },
            ]},
            {references:'pantar', fields:[
                {source:'panel'         , target:'panel'     },
                {source:'tarea'         , target:'tarea'     },
            ]},
            {references:'periodos', fields:[
                {source:'periodo'         , target:'periodo'     },
            ]},
        ],
        sql:{
            from: `(select 
                        r.periodo, 
                        r.panel, 
                        r.tarea, 
                        r.encuestador, 
                        p.nombre||' '||p.apellido as encuestadornombre, 
                        t.encuestador as titular, 
                        pe.nombre||' '||pe.apellido as titularnombre
                        from relenc r inner join personal p on p.persona = r.encuestador
                                      inner join tareas t on t.tarea = r.tarea
                                      inner join personal pe on pe.persona = t.encuestador
                    )`,
        }    
    }, context);
}