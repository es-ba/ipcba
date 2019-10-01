"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'caldiv_vw',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'              , typeName:'text'    },
            {name:'calculo'              , typeName:'integer' },
            {name:'producto'             , typeName:'text'    },
            {name:'nombreproducto'       , typeName:'text'    },
            {name:'division'             , typeName:'text'    },
            {name:'prompriimpact'        , typeName:'decimal'  },
            {name:'prompriimpant'        , typeName:'decimal'  },
            {name:'varpriimp'            , typeName:'decimal'  },
            {name:'cantpriimp'           , typeName:'integer' },
            {name:'promprel'             , typeName:'decimal'  },
            {name:'promdiv'              , typeName:'decimal'  },
            {name:'promdivant'           , typeName:'decimal'  },
            {name:'promedioredondeado'   , typeName:'decimal'  },
            {name:'impdiv'               , typeName:'text'    },
            {name:'cantincluidos'        , typeName:'integer' },
            {name:'cantrealesincluidos'  , typeName:'integer' },
            {name:'cantconprecioparacalestac', typeName:'integer'},
            {name:'cantrealesexcluidos'  , typeName:'integer' },
            {name:'promvar'              , typeName:'decimal'  },
            {name:'cantaltas'            , typeName:'integer' },
            {name:'promaltas'            , typeName:'decimal'  },
            {name:'cantbajas'            , typeName:'integer' },
            {name:'prombajas'            , typeName:'decimal'  },
            {name:'cantimputados'        , typeName:'integer' },
            {name:'ponderadordiv'        , typeName:'decimal'  },
            {name:'umbralpriimp'         , typeName:'integer' },
            {name:'umbraldescarte'       , typeName:'integer' },
            {name:'umbralbajaauto'       , typeName:'integer' },
            {name:'cantidadconprecio'    , typeName:'integer' },
            {name:'profundidad'          , typeName:'integer' },
            {name:'divisionpadre'        , typeName:'text'    },
            {name:'tipo_promedio'        , typeName:'text'    },
            {name:'raiz'                 , typeName:'boolean' },            
            {name:'cantexcluidos'            , typeName:'integer' ,allow:{select:false}},      
            {name:'promexcluidos'            , typeName:'decimal'  ,allow:{select:false}},   
            {name:'promimputados'            , typeName:'decimal'  ,allow:{select:false}},   
            {name:'promrealesincluidos'      , typeName:'decimal'  ,allow:{select:false}},   
            //{name:'promrealesexcluidos'      , typeName:'decimal'  ,allow:{select:false}},   
            {name:'cantrealesdescartados'    , typeName:'integer' ,allow:{select:false}},   
            {name:'cantpreciostotales'       , typeName:'integer' ,allow:{select:false}},    
            {name:'cantpreciosingresados'    , typeName:'integer' ,allow:{select:false}},    
            //{name:'cantconprecioparacalestac', typeName:'integer' ,allow:{select:false}},             
            {name:'variacion'            , typeName:'decimal'  },
            {name:'promsinimpext'        , typeName:'decimal'  },
            {name:'varsinimpext'         , typeName:'decimal'  },
            {name:'varsincambio'         , typeName:'decimal'  },
            {name:'varsinaltasbajas'     , typeName:'decimal'  },
            {name:'promrealesexcluidos'  , typeName:'decimal'  },
            {name:'publicado'            , typeName:'boolean'  },
            {name:'responsable'          , typeName:'text'     },
        ],
        filterColumns:[
            {column:'periodo', operator:'>=', value:context.be.internalData.filterUltimoPeriodo},
            {column:'calculo', operator:'=' ,value:context.be.internalData.filterUltimoCalculo}
        ],        
        primaryKey:['periodo','calculo','producto','division'],
    },context);
}