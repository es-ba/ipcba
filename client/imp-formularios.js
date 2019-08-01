"use strict";

my.wScreens.proc.result.imprimir_formulario_con_precios=function(result, divResult){
    var todoElFormularioCompleto = html.div({id:'imp-form'}).create();
    divResult.appendChild(todoElFormularioCompleto);
    var informanteAnterior;
    var formularioAnterior;
    var informanteAnterior;
    var formularioAnterior;
    result.forEach(function(row){
        if(formularioAnterior != row.formulario || informanteAnterior != row.informante){
            var encabezadoFormulario=html.div({class:'encabezado'},[
                html.span({class:'seccion-formulario'},[
                    html.span({class:'label-formulario'},'formulario'),
                    html.span({class:'formulario'},row.formulario),
                    html.span({class:'nombre-formulario'},row.nombreformulario),
                ]),
                html.span({class:'seccion-informante'},[
                    html.span({class:'label-informante'},'informante'),
                    html.span({class:'informante'},row.informante),
                ]),
                html.span({class:'seccion-panel'},[
                    html.span({class:'label-panel'},'panel'),
                    html.span({class:'panel'},row.panel),
                ]),
                html.span({class:'seccion-tarea'},[
                    html.span({class:'label-tarea'},'tarea'),
                    html.span({class:'tarea'},row.tarea),
                ]),
                html.div({class:'razones'},[
                    html.span({class:'razon-actual'},[
                        html.span({class:'label-razon'},'Raz'),
                        html.span({class:'razon'},row.razon),
                        html.span({class:'period'},row.period),
                    ]),
                    html.span({class:'otras-columnas'},
                        bestGlobals.serie({from:1, to:4}).map(function(numero){
                            return html.span({class:'columna-label-razon', $attrs:{columna:numero}}, 'Raz')
                        })
                    )
                ])
            ]);
            todoElFormularioCompleto.appendChild(encabezadoFormulario.create())
        }
            var sectorProducto=html.div({class:'seccion-producto-precio'},[
                html.span({class:'nombre-producto'},row.nombreproducto),
                html.span({class:'observacion'},row.observacion),
                html.span({class:'producto'},row.producto),
                html.span({class:'tipoprecio'},row.tipoprecio),
                html.span({class:'precio'},row.precio),
                html.div({class:'fila-precios'},[
                    html.span({class:'precios-actual'},[
                        html.span({class:'tipoprecio'},row.tipoprecio),
                        html.span({class:'precio'},row.precio),
                    ]),
                    html.span({class:'otras-columnas'},
                        bestGlobals.serie({from:1, to:4}).map(function(numero){
                            return html.span({class:'columna-precios', $attrs:{columna:numero}}, [/* 2 divs o span para casilleros */ ])
                        })
                    )
                ]),
                html.div({class:'fila-precios-label'},[
                    html.span({class:'precios-actual'},[
                        html.span({class:'label-tipo'},'tipo'),
                        html.span({class:'label-precio'},'precio'),
                    ]),
                    html.span({class:'otras-columnas'},
                        bestGlobals.serie({from:1, to:4}).map(function(numero){
                            return html.span({class:'columna-label-precios', $attrs:{columna:numero}},[
                                html.span({class:'label-tipo'},'tipo'),
                                html.span({class:'label-precio'},'precio'),
                            ])
                        })
                    )
                ])
            ]);
            todoElFormularioCompleto.appendChild(sectorProducto.create())
        formularioAnterior = row.formulario;
        informanteAnterior = row.informante;
    })
}