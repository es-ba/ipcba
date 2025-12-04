import {html}  from 'js-to-html';

var my=myOwn;

const TABLE_ELEMENT_ID = 'cuadro_resultante';

/**
 * Exporta una tabla HTML específica a un archivo Excel (.xlsx).
 * Requiere que la librería SheetJS (xlsx.full.min.js) esté cargada.
 * @param tableID El ID del elemento <table> a exportar (ej: 'miTabla').
 * @param filename El nombre base para el archivo de salida.
 */
function exportTableToExcel(tableID: string, filename: string): void {
    // 1. Obtener la tabla del DOM
    const table = document.getElementById(tableID);
    
    if (!table || !(table instanceof HTMLTableElement)) {
        console.error(`Tabla con ID '${tableID}' no encontrada.`);
        return;
    }

    // 2. Convertir el elemento HTML <table> a una hoja de cálculo (Workbook Sheet)
    const ws = XLSX.utils.table_to_sheet(table);

    // 3. Crear un nuevo libro de trabajo (Workbook)
    const wb = XLSX.utils.book_new();
    
    // 4. Agregar la hoja de cálculo al libro, nombrándola "Datos"
    XLSX.utils.book_append_sheet(wb, ws, "Datos");

    // 5. Escribir y descargar el archivo XLSX
    // Esto genera y descarga el archivo usando el nombre especificado.
    XLSX.writeFile(wb, filename + ".xlsx");
    
    console.log(`Tabla exportada a ${filename}.xlsx`);
}

function generateTableHtml(data:any) {
    const headerRow = data.find(r => r.renglon === 1);
    if (!headerRow) return html.p('Error: No se encontraron encabezados.');

    const columnKeys = Object.keys(headerRow).filter(key => key.startsWith('columna'));
  
    const theadContent = columnKeys.map(key => html.th(headerRow[key] as string));
    
    const thead = html.thead([
        html.tr(theadContent) 
    ]);

    const dataRows = data.filter(r => r.renglon >= 101);
    
    const tbodyContent = dataRows.map((row:any) => {
        const rowCells = columnKeys.map(key => html.td(row[key]));
        return html.tr(rowCells);
    });
    const tbody = html.tbody(tbodyContent);

    return html.table({ id: TABLE_ELEMENT_ID }, [thead, tbody]);
}

function generateActionButtons() {
    let exportButton = html.button({}, 'exportar').create()
    exportButton.onclick = () => exportTableToExcel(TABLE_ELEMENT_ID,'cuadro') //TODO: parametrizar
    return html.div({ class: 'actions' }, [
        exportButton
    ]);
}

my.wScreens.proc.result.mostrar_cuadro=function(result, divResult){
    divResult.appendChild(generateTableHtml(result.rows).create());
    divResult.appendChild(generateActionButtons().create());
}