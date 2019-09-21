import * as React from "react";
import * as ReactDOM from "react-dom";
import { useState } from "react";

import { Application, WScreen } from "./components/marcos";
import { PruebaRelevamientoPrecios } from "./components/ejemplo-precios";
import { CssBaseline } from "@material-ui/core";

function ExampleApplication(){
    return <Application>
        <WScreen page='formulario_1' iconName="LocalAtm">
            <PruebaRelevamientoPrecios/>
        </WScreen>
        <WScreen page='formulario_2' iconName="LocalAtm">
            <PruebaRelevamientoPrecios/>
        </WScreen>
    </Application>;
}

ReactDOM.render(
    <React.StrictMode>
        <CssBaseline />
        <ExampleApplication />
    </React.StrictMode>,
    document.getElementById("main_layout")
)
