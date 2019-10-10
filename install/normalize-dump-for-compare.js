"use strict";

var fs=require('fs').promises;

var fileName = process.argv[2];

console.log('normalizando',fileName);

async function normalize(fileName){
    var content = await fs.readFile(fileName,'utf8');
    /// REEMPLAZAR CHARACTER VARYING POR TEXT
    content = content
        .replace(/character varying\(\d+\)/g,"text")
        .replace(/character varying/g,"text")
        .replace(/text(::text)+/g,"text")
        .replace(/\(('[^']*')::text\)::text+/g,"$1::text");
    /// QUITAR EN LA COMPARACIÓN LAS CONSTRAINTS QUE IMPIDEN QUE LOS TEXTOS SEAN '' 
    content = content
        .replace(/\s*CONSTRAINT "\w+<>''" CHECK \(+\w+\s*<> ''::text\)+,?/g,"");
    /// QUITAR EN LAS opciones generadas por backend-plus en el atributo options:[]
    content = content
        .replace(/\s*CONSTRAINT "\w+ invalid option" CHECK \(+\w+ = ANY \(ARRAY\[.+\]\)+,?/g,"");
    /// QUITAR el ::text de las constraints de valor valido
    content = content
        .replace(/CHECK \(comun.cadena_valida\(\((\w+)\)::text/g,"CHECK (comun.cadena_valida($1");
    content = content
        .replace(/(CHECK \(+)\((\w+)\)::text/g,"$1$2");
    /// QUITAR LAS COMAS QUE QUEDAN DE MÁS AL SACAR CONSTRAINTS:
    content = content
        .replace(/\),\n\);/g,")\n);");
    content = content
        .replace(/\s*CONSTRAINT "\w+ invalid option" CHECK \(+\w+ = ANY \(ARRAY\[.+\]\)+,?/g,"");
    /// REEMPLAZAR cvp.sino_dom POR TEXT
    content = content.replace(/cvp.sino_dom/g,"text");
    /// FIN REEMPLAZOS
    await fs.writeFile(fileName,content);
    console.log('normalizado');
    process.exit();
}

normalize(fileName);