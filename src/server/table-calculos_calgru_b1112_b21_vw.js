"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'calculos_calgru_b1112_b21_vw',
        title:'calgru_b1112_b21_vw',
        editable:false,
        allow:{
            insert:false,
            delete:false,
            update:false,
        },
        fields:[
            {name:'periodo'             , typeName:'text'       , nullable:false},
            {name:'calculo'             , typeName:'integer'    , nullable:false},
        ],
        primaryKey:['periodo','calculo'],
        detailTables:[
            {table: 'calgru_b1112_b21_vw' , fields:['periodo', 'calculo'], abr:'G_b1112_b21' , label: 'G_b1112_b21'},
        ],        
        filterColumns:[
            {column:'calculo', operator:'=' , value:context.be.internalData.filterUltimoCalculo},
            {column:'periodo', operator:'>=', value:context.be.internalData.filterUltimoPeriodo},
        ],    
        sortColumns:[{column:'periodo', order:-1}, {column:'calculo'}],
        sql:{
            from:`(SELECT c.periodo, c.calculo
		             FROM calculos c 
	                   JOIN parametros p ON unicoregistro
		               JOIN calculos_def cd ON c.calculo = cd.calculo
	                   WHERE cd.principal AND c.periodo > periodo_empalme
	               UNION 
	               SELECT c.periodo, c.calculoprincipal_b21 as calculo
	                 FROM calculos_b1112 c 
	                 JOIN parametros p ON unicoregistro
		             JOIN calculos_def cd ON c.calculoprincipal_b21 = cd.calculo
	                 WHERE cd.principal AND c.periodo <= periodo_empalme)`
        }    
    }, context);
}