"use strict";

var fs=require('fs').promises;

var fileName = process.argv[2];

console.log('normalizando',fileName);

async function normalize(fileName){
    var content = await fs.readFile(fileName,'utf8');
    /// REEMPLAZAR CHARACTER VARYING POR TEXT
    content = content.replace(/character varying\(\d+\)/g,"text");
    /// REEMPLAZAR cvp.sino_dom POR TEXT
    content = content.replace(/cvp.sino_dom/g,"text");
    /// FIN REEMPLAZOS
    await fs.writeFile(fileName,content);
    console.log('normalizado');
    process.exit();
}

normalize(fileName);