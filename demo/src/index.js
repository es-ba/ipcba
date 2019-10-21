"use strict";
exports.__esModule = true;
var React = require("react");
var ReactDOM = require("react-dom");
var marcos_1 = require("./components/marcos");
var ejemplo_precios_1 = require("./components/ejemplo-precios");
var core_1 = require("@material-ui/core");
function ExampleApplication() {
    return <marcos_1.Application>
        <marcos_1.WScreen page='formulario_1' iconName="LocalAtm">
            <ejemplo_precios_1.PruebaRelevamientoPrecios />
        </marcos_1.WScreen>
        <marcos_1.WScreen page='formulario_2' iconName="LocalAtm">
            <ejemplo_precios_1.PruebaRelevamientoPrecios />
        </marcos_1.WScreen>
    </marcos_1.Application>;
}
ReactDOM.render(<React.StrictMode>
        <core_1.CssBaseline />
        <ExampleApplication />
    </React.StrictMode>, document.getElementById("main_layout"));
