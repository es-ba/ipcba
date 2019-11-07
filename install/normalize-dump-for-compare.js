"use strict";

var fs=require('fs').promises;

var fileName = process.argv[2];
var completo = !process.argv[3]

console.log('normalizando',fileName);
console.log('args:',process.arguments);

async function normalize(fileName){
    var content = await fs.readFile(fileName,'utf8');
    if(completo){
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
        /// QUITAR COMENTARIOS
        content = content.replace(/--\s*\r?\n-- Name:.*\r?\n--\s*\r?\n/g,"\n");
        /// FIN REEMPLAZOS
    }
    /// QUITAR NOMBRES EN LAS CONTRAINTS FK
    content = content
        .replace(/ADD CONSTRAINT ["a-zA-Z_0-9 "]+ FOREIGN KEY/g,"ADD /*CONSTRAINT NAME*/ FOREIGN KEY");
    /// REEMPLAZAR NOMBRES MEJORADOS
    content = content
        .replace(/atributos_es_vigencia_key/g,'"debe haber un unico atributo es_vigencia"');
    /// REEMPLAZAR ON CASCADE NO NECESARIOS
    content = content
        .replace(/REFERENCES cvp.calculos(periodo, calculo) ON UPDATE CASCADE/g,'REFERENCES cvp.calculos(periodo, calculo)');
    /// QUITAR LOS CAMPOS DE AUDITORIA
    content = content
        .replace(/\s+(modi_usu text,)|(modi_fec timestamp without time zone,)|(modi_ope text,?)/g,'');
    /// ORDEN Y LIMPIEZA
    var partes = content.split(/\r?\n(\r?\n)+/);
    partes.sort();
    var content = partes.join("\n\n");
    content = content.replace(/\r?\n(\r?\n)+/g,"\n\n");
    await fs.writeFile(fileName, content);
    console.log('normalizado');
    process.exit();
}

normalize(fileName);