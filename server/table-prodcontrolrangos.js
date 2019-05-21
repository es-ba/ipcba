"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'prodcontrolrangos',
        //title:'Prodcontrolrangos',
        dbOrigin:'view',
        allow:{
            insert:false,
            delete:false,
            update:false,
        },        
        fields:[
            {name:'producto'              , typeName:'text'   },
            {name:'nombreproducto'        , typeName:'text'   },
            {name:'informante'            , typeName:'integer'},
            {name:'tipoinformante'        , typeName:'text'   },
            {name:'observacion'           , typeName:'integer'},
            {name:'visita'                , typeName:'integer'},
            {name:'panel'                 , typeName:'integer'},
            {name:'tarea'                 , typeName:'integer'},
            {name:'formulario'            , typeName:'integer'},
            {name:'precionormalizado'     , typeName:'decimal'},
            {name:'tipoprecio'            , typeName:'text'   },
            {name:'cambio'                , typeName:'text'   },
            {name:'impobs'                , typeName:'text'   },
            {name:'precioant'             , typeName:'decimal'},
            {name:'tipoprecioant'         , typeName:'text'   },
            {name:'antiguedadsinprecioant', typeName:'integer'},
            {name:'variac'                , typeName:'decimal'},
            {name:'promvar'               , typeName:'decimal'},
            {name:'desvvar'               , typeName:'decimal'},
            {name:'promrotativo'          , typeName:'decimal'},
            {name:'desvprot'              , typeName:'decimal'},
            {name:'razon_impobs_ant'      , typeName:'text'   },
            {name:'repregunta'            , typeName:'text'   },
        ],
        primaryKey:['producto','informante','observacion','visita'],
        sql:{
            from:`(select producto, nombreproducto, informante, tipoinformante, observacion, visita, panel, tarea, formulario, precionormalizado
                        ,tipoprecio,cambio,impobs,precioant, tipoprecioant, antiguedadsinprecioant,variac,promvar, desvvar
                        ,promrotativo,desvprot,razon_impobs_ant, repregunta
                    from cvp.control_rangos
                    where periodo=(select max(periodo) from calculos where calculo=0)
                 )`
        }
    },context);
}