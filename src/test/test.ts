"use strict";

import * as pg from "pg-promise-strict";
import * as MiniTools from "mini-tools";
import * as Assert from "assert";

function toRows(rowsInMultilineString:string):(string|null)[][]{
    var rows = rowsInMultilineString.split(/\r?\n/g).filter(x=>!/^\s*$/.test(x)).map(row=>
        row.split(',').map(cell=>cell.trim()).map(cell=>cell=='NULL'?null:cell)
    );
    console.log(rows);
    return rows;
}

var wherePeriodo=`periodo in ('a1900m01')`;
// var wherePeriodo='(select comentariosper   from periodos    where periodo    = x.periodo   )';

type TablaInfo = {nombre:string, nombreNombre:string, whereDelete:string};
var tablas:TablaInfo[] = ([
    {nombre:'relatr'      , whereDelete:wherePeriodo},
    {nombre:'relpre'      , whereDelete:wherePeriodo},
    {nombre:'relvis'      , whereDelete:wherePeriodo},
    {nombre:'relinf'      , whereDelete:wherePeriodo},
    {nombre:'reltar'      , whereDelete:wherePeriodo},
    {nombre:'relpan'      , whereDelete:wherePeriodo},
    {nombre:'relmon'      , whereDelete:wherePeriodo},
    {nombre:'forinf'      , nombreNombre:'(select nombreinformante from informantes where informante = x.informante)'},
    {nombre:'forprod'     , nombreNombre:'(select nombreproducto   from productos   where producto   = x.producto  )'},
    {nombre:'prodatr'     , nombreNombre:'(select nombreproducto   from productos   where producto   = x.producto  )'},
    {nombre:'atributos'   ,},
    {nombre:'formularios' ,},
    {nombre:'informantes' ,},
    {nombre:'rubros'      ,},
    {nombre:'productos'   ,},
    {nombre:'periodos'    ,nombreNombre:`comentariosper`},
] as ({nombre:string} & Partial<TablaInfo>)[]).map(t=>({
    nombreNombre: 'nombre'+t.nombre.substr(0, t.nombre.length-1),
    ...t,
})).map(t=>({
    whereDelete: `${t.nombreNombre} like 'TEST %'`,
    ...t,
}));

async function deletes(client:pg.Client){
    for(var t of tablas){
        await client.query(`DELETE FROM ${t.nombre} x WHERE ${t.whereDelete}`).execute();
    }
}

describe("relevamiento", function(){    
    var client:pg.Client; 
    before(async function(){
        this.timeout(40000);
        var config = await MiniTools.readConfig([{
            "db-test":{
                schema:'cvp',
                database:'cvp_test_db'
            }
        },'local-config',{
            "db-test":{
                database:'cvp_test_db' // sí o sí quiero que sea en esta DB para estar seguro de no pifiarla en el local-config
            }
        }]);
        client = await pg.connect(config['db-test']);
        await client.executeSentences(`
            BEGIN TRANSACTION;
            SET CONSTRAINTS ALL DEFERRED;
        `.split(';\n').filter(x=>!/^\s*$/.test(x))
        );
        for(var t of tablas){
            await client.query(`ALTER TABLE ${t.nombre} DISABLE TRIGGER USER`).execute();
        }
        await deletes(client);
        await client.bulkInsert({
            table:'periodos',
            columns:['periodo','ano','mes','periodoanterior','comentariosper','ingresando'],
            rows:toRows(`
                a1900m01,1900,01,NULL    ,TEST periodo 1,S
                a1900m02,1900,02,a1900m01,TEST periodo 2,S
            `)
        })
        await client.bulkInsert({
            table:'rubros',
            columns:['rubro','nombrerubro','tipoinformante','despacho'],
            rows:toRows(`
                -11,TEST rubro 11,S,A
                -12,TEST rubro 12,T,P
            `)
        })
        await client.bulkInsert({
            table:'productos',
            columns:['producto','nombreproducto'],
            rows:toRows(`
                P01,TEST Producto 1
                P02,TEST Producto 2
                P03,TEST Producto 3
            `)
        })
        await client.bulkInsert({
            table:'informantes',
            columns:['informante','nombreinformante','tipoinformante','rubro','altamanualperiodo','altamanualpanel','altamanualtarea'],
            rows:toRows(`
                888001,TEST Informante 1,T,-11,a1900m01,1,1
                888002,TEST Informante 2,S,-12,a1900m01,1,1
            `)
        })
        await client.bulkInsert({
            table:'atributos',
            columns:['atributo','nombreatributo','tipodato'],
            rows:toRows(`
                -1,TEST Atributo 1,C
                -2,TEST Atributo 2,N
            `)
        })
        await client.bulkInsert({
            table:'formularios',
            columns:['formulario','nombreformulario','operativo','activo','despacho','altamanualdesdeperiodo','orden'],
            rows:toRows(`
                -71,TEST Formulario 71,C,S,A,a1900m01,1
                -72,TEST Formulario 72,C,S,A,a1900m01,1
            `)
        })
        await client.bulkInsert({
            table:'forprod',
            columns:['formulario','producto','orden'],
            rows:toRows(`
                -71,P01,1
                -72,P01,1
                -71,P02,1
                -72,P02,1
                -72,P03,1
            `)
        })
        await client.bulkInsert({
            table:'prodatr',
            columns:['atributo','producto','orden'],
            rows:toRows(`
                -1,P01,1
                -2,P01,1
                -1,P02,1
            `)
        })
        await client.bulkInsert({
            table:'forinf',
            // TODO: no debería necesitarse forinf.altamanualperiodo
            columns:['formulario','informante','altamanualperiodo'],
            rows:toRows(`
                -71,888001,a1900m01
                -72,888002,a1900m01
            `)
        })
        await client.executeSentences(`
            COMMIT;
            SET CONSTRAINTS ALL IMMEDIATE;
            BEGIN TRANSACTION;
        `.split(';\n').filter(x=>!/^\s*$/.test(x))
        );
        for(var t of tablas){
            await client.query(`ALTER TABLE ${t.nombre} ENABLE TRIGGER USER`).execute();
        }
    });
    after(async function(){
        this.timeout(20000);
        // await deletes(client);
        await client.executeSentences(`
            SET CONSTRAINTS ALL IMMEDIATE;
        `.split(';\n')
        );
        await client.query(`COMMIT;`).execute();
        // await client.query(`ROLLBACK;`).execute();
        client.done();
    })
    it("generar primer periodo", async ()=>{
        await client.query(`UPDATE periodos SET fechageneracionperiodo=current_timestamp WHERE periodo='a1900m01'`).execute();
        return 'ok';
    })
    it("generar primer periodo panel 1", async ()=>{
        await client.bulkInsert({
            table:'relpan',
            columns:['periodo','panel','fechasalida'],
            rows:toRows(`
                a1900m01,1,1900-01-02
            `)
        })
        await client.bulkInsert({
            table:'reltar',
            columns:['periodo','panel','tarea'],
            rows:toRows(`
                a1900m01,1,1
            `)
        })
        await client.query(`UPDATE relpan SET fechageneracionpanel=current_timestamp WHERE periodo='a1900m01' and panel=1 returning 'ok'`).fetchUniqueValue();
    })
    it("insert P S O", async ()=>{
        var where=`periodo='a1900m01' AND informante=888001`
        await client.query(`UPDATE relvis SET razon=1 WHERE ${where}`).execute();
        await client.query(`UPDATE relpre SET tipoprecio='P', precio=12.5 WHERE ${where} and producto='P01'`).execute();
        var normalizado = await client.query(`SELECT precionormalizado FROM relpre WHERE ${where} and producto='P01'`).fetchUniqueValue();
        Assert.equal(normalizado,12.5);
    })
})