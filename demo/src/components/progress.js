"use strict";
exports.__esModule = true;
var React = require("react");
var core_1 = require("@material-ui/core");
var useStyles = core_1.makeStyles({
    root: {
        flexGrow: 1
    }
});
function ProgressLine(props) {
    var classes = useStyles();
    return (<div className={classes.root}>
            <core_1.LinearProgress color={props.color || 'primary'}/>
        </div>);
}
exports.ProgressLine = ProgressLine;
