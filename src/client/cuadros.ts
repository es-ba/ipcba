import {html}  from 'js-to-html';
const my=myOwn;

const TABLE_ELEMENT_ID = 'cuadro_resultante';

function exportTableToExcel(tableID: string, filename: string): void {
    const table = document.getElementById(tableID) as HTMLTableElement;
    if (!table) return console.error('Tabla no encontrada');

    const htmlContent = `
        <html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            </head>
        <body>
            ${table.outerHTML}
        </body>
        </html>
    `;

    const blob = new Blob([htmlContent], { type: 'application/vnd.ms-excel' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", `${filename}.xls`);

    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

function generateTableHtml(data: any[]) {
    const headerRow = data[1];

    if (!headerRow) return html.p('Error: No se encontraron datos en la fila 1.');

    const todasLasPropiedades = Object.keys(headerRow);

    const indice = todasLasPropiedades.indexOf("formato_renglon");

    if (indice === -1) {
        console.error("Propiedades encontradas:", todasLasPropiedades);
        return html.p('Error: No se encontró la columna "formato_renglon".');
    }

    const columnKeys = todasLasPropiedades.slice(indice + 1);

    const theadContent = columnKeys.map(key => html.th(headerRow[key]?.toString() || ""));

    const thead = html.thead([
        html.tr(theadContent)
    ]);

    const dataRows = data.slice(2);

    const tbodyContent = dataRows.map((row: any) => {
        const rowCells = columnKeys.map(key => {
            let value = row[key]?.toString() || "";
            return html.td(value.trim());
        });
        return html.tr(rowCells);
    });

    const tbody = html.tbody(tbodyContent);

    return html.table({ id: TABLE_ELEMENT_ID, class: 'tabla-cuadro'}, [thead, tbody]);
}

function generateActionButtons(cuadro: string) {
    let exportButton = html.button({}, 'exportar').create()
    exportButton.onclick = () => exportTableToExcel(TABLE_ELEMENT_ID,`cuadro_${cuadro}`);
    return html.div({ class: 'actions' }, [
        exportButton
    ]);
}

my.wScreens.proc.result.mostrar_cuadro=function(result:any, divResult:any){
  divResult.appendChild(generateActionButtons(result.cuadro).create());
  divResult.appendChild(generateTableHtml(result.rows).create());
}