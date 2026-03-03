import {html}  from 'js-to-html';
declare const XLSX:any;
const my=myOwn;

const TABLE_ELEMENT_ID = 'cuadro_resultante';

/**
 * Exporta una tabla HTML específica a un archivo Excel (.xlsx).
 * Requiere que la librería SheetJS (xlsx.full.min.js) esté cargada.
 * @param tableID El ID del elemento <table> a exportar (ej: 'miTabla').
 * @param filename El nombre base para el archivo de salida.
 */
function exportTableToExcel(tableID: string, filename: string, separador_decimal: string): void {
    const table = document.getElementById(tableID);

    if (!table || !(table instanceof HTMLTableElement)) {
        console.error(`Tabla con ID '${tableID}' no encontrada.`);
        return;
    }

    let ws = XLSX.utils.table_to_sheet(table, { raw: separador_decimal == ',' });

    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Datos");
    XLSX.writeFile(wb, filename + ".xlsx");
}

function generateTableHtml(data: any[]) {
    // 1. Obtenemos la fila que contiene los nombres de las columnas (Tipo_CA, Edad, etc.)
    const headerRow = data[1];

    if (!headerRow) return html.p('Error: No se encontraron datos en la fila 1.');

    // 2. Extraemos los nombres de las propiedades del objeto (renglon, formato_renglon, columna1...)
    const todasLasPropiedades = Object.keys(headerRow);

    // 3. Buscamos la posición de "formato_renglon" dentro de esas propiedades
    const indice = todasLasPropiedades.indexOf("formato_renglon");

    if (indice === -1) {
        // Si no encuentra la propiedad, imprimimos en consola para debuguear
        console.error("Propiedades encontradas:", todasLasPropiedades);
        return html.p('Error: No se encontró la columna "formato_renglon".');
    }

    // 4. Cortamos para obtener solo las llaves de las columnas que nos interesan
    const columnKeys = todasLasPropiedades.slice(indice + 1);

    // 5. Armamos el encabezado usando los VALORES de la fila 1
    const theadContent = columnKeys.map(key => html.th(headerRow[key]?.toString() || ""));

    const thead = html.thead([
        html.tr(theadContent)
    ]);

    // 6. Armamos el cuerpo con el resto de los datos (desde la fila 2 en adelante)
    const dataRows = data.slice(2);

    const tbodyContent = dataRows.map((row: any) => {
        const rowCells = columnKeys.map(key => {
            let value = row[key]?.toString() || "";
            // Eliminamos espacios extra que podrían causar que isNaN falle
            return html.td(value.trim());
        });
        return html.tr(rowCells);
    });

    const tbody = html.tbody(tbodyContent);

    return html.table({ id: TABLE_ELEMENT_ID }, [thead, tbody]);
}

function generateActionButtons(cuadro: string, separador_decimal: string) {
    let exportButton = html.button({}, 'exportar').create()
    exportButton.onclick = () => exportTableToExcel(TABLE_ELEMENT_ID,`cuadro_${cuadro}`, separador_decimal);
    return html.div({ class: 'actions' }, [
        exportButton
    ]);
}

my.wScreens.proc.result.mostrar_cuadro=function(result:any, divResult:any){
    divResult.appendChild(generateTableHtml(result.rows).create());
    divResult.appendChild(generateActionButtons(result.cuadro, result.separador_decimal).create());
}