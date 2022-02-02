"use strict";

var changing = require('best-globals').changing;
var definnerBitacora = require('../../node_modules/backend-plus/lib/tables/table-bitacora.js');

const CALCULO_ACTION = 'fechacalculo_touch';
const PERIODO_BASE_CORRER_ACTION = 'periodobase_correr';

module.exports = function(context){
    const BITACORA_TABLENAME = context.be.config.server.bitacoraTableName || 'bitacora';
    var defNewElement = definnerBitacora(context);
    defNewElement=changing(defNewElement,{
        name:'ejecucion_calculos',
        title:'calculos en ejecucion',
        tableName:'ejecucion_calculos',
        editable:false,
        allow:{
            insert: false,
            delete: false,
            update: false,
            import: false,
        },
    });
    defNewElement.refrescable=true;
    defNewElement.sql={
        from:`
            (select * 
                from ${context.be.db.quoteIdent(BITACORA_TABLENAME)} 
                where procedure_name in 
                    (
                        ${context.be.db.quoteLiteral(CALCULO_ACTION)},
                        ${context.be.db.quoteLiteral(PERIODO_BASE_CORRER_ACTION)}
                    )
                    and (end_date is null or end_date >= current_date)
            )
        `,
        isTable: false,
    };
    return context.be.tableDefAdapt(defNewElement, context);
}
