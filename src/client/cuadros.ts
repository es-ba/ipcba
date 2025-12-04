import {html}  from 'js-to-html';

var my=myOwn;

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

    return html.table({ id: 'miTabla' }, [thead, tbody]);
}

function generateActionButtons() {
    let exportButton = html.button({}, 'Imprimir Tabla').create()
    exportButton.onclick = () => {console.log('exporta')}
    return html.div({ class: 'actions' }, [
        exportButton
    ]);
}

my.wScreens.proc.result.mostrar_cuadro=function(result, divResult){
    divResult.appendChild(generateTableHtml(result).create());
    divResult.appendChild(generateActionButtons().create());
}