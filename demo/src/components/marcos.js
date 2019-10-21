"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
exports.__esModule = true;
var React = require("react");
var react_1 = require("react");
var core_1 = require("@material-ui/core");
var core_2 = require("@material-ui/core");
var core_3 = require("@material-ui/core");
var likeAr = require("like-ar");
function useFetch(url, defaultData) {
    var _this = this;
    var _a = react_1.useState(defaultData), data = _a[0], updateData = _a[1];
    var _b = react_1.useState(null), err = _b[0], updateErr = _b[1];
    react_1.useEffect(function () {
        var ajaxRequest = function () { return __awaiter(_this, void 0, void 0, function () {
            var resp, json, err_1;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 3, , 4]);
                        return [4 /*yield*/, fetch(url)];
                    case 1:
                        resp = _a.sent();
                        return [4 /*yield*/, resp.json()];
                    case 2:
                        json = _a.sent();
                        updateData(json);
                        return [3 /*break*/, 4];
                    case 3:
                        err_1 = _a.sent();
                        updateErr(err_1);
                        return [3 /*break*/, 4];
                    case 4: return [2 /*return*/];
                }
            });
        }); };
        ajaxRequest();
    }, [url]);
    return [data, err];
}
exports.useFetch = useFetch;
function fetchAndDispatch(url, dispatchDataOrError, typeDoing, typeOk, content) {
    var _this = this;
    dispatchDataOrError({ type: typeDoing });
    var ajaxRequest = function () { return __awaiter(_this, void 0, void 0, function () {
        var resp, json, content, err_2, details, _a, _b;
        return __generator(this, function (_c) {
            switch (_c.label) {
                case 0:
                    resp = null;
                    _c.label = 1;
                case 1:
                    _c.trys.push([1, 6, , 13]);
                    return [4 /*yield*/, fetch(url)];
                case 2:
                    resp = _c.sent();
                    if (!(resp.status == 200)) return [3 /*break*/, 4];
                    return [4 /*yield*/, resp.json()
                        // TODO: generalizar y pasar el timestamp a otro lado
                    ];
                case 3:
                    json = _c.sent();
                    content = __assign(__assign({}, json), { content: JSON.parse(json.content) });
                    dispatchDataOrError({ type: typeOk, payload: content });
                    return [3 /*break*/, 5];
                case 4:
                    dispatchDataOrError({ type: 'TX_ERROR', payload: { code: resp.status, message: resp.status + ' ' + resp.statusText, details: url } });
                    _c.label = 5;
                case 5: return [3 /*break*/, 13];
                case 6:
                    err_2 = _c.sent();
                    _c.label = 7;
                case 7:
                    _c.trys.push([7, , 11, 12]);
                    _a = resp;
                    if (!_a) return [3 /*break*/, 10];
                    _b = resp.statusText;
                    if (_b) return [3 /*break*/, 9];
                    return [4 /*yield*/, resp.text()];
                case 8:
                    _b = (_c.sent()).substr(0, 10);
                    _c.label = 9;
                case 9:
                    _a = (_b);
                    _c.label = 10;
                case 10:
                    details = _a;
                    console.log(details);
                    err_2.details = details;
                    return [3 /*break*/, 12];
                case 11:
                    console.log(err_2);
                    dispatchDataOrError({ type: 'TX_ERROR', payload: err_2 });
                    return [7 /*endfinally*/];
                case 12: return [3 /*break*/, 13];
                case 13: return [2 /*return*/];
            }
        });
    }); };
    ajaxRequest();
}
exports.fetchAndDispatch = fetchAndDispatch;
var MENUTYPE = 'draw';
function Conditional(props) {
    return props.visible ? <>
        {props.children}
    </> : null;
}
exports.Conditional = Conditional;
function WScreen(props) {
    return <>
        {props.children}
    </>;
}
exports.WScreen = WScreen;
var useStyles = core_2.makeStyles(function (theme) { return ({
    root: {
        flexGrow: 1
    },
    menuButton: {
        marginRight: theme.spacing(2)
    },
    title: {
        flexGrow: 1
    },
    list: {
        width: 250
    },
    fullList: {
        width: 'auto'
    }
}); });
// https://material-ui.com/components/material-icons/
exports.materialIoIconsSvgPath = {
    Assignment: "M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z",
    Code: "M9.4 16.6L4.8 12l4.6-4.6L8 6l-6 6 6 6 1.4-1.4zm5.2 0l4.6-4.6-4.6-4.6L16 6l6 6-6 6-1.4-1.4z",
    EmojiObjects: "M12 3c-.46 0-.93.04-1.4.14-2.76.53-4.96 2.76-5.48 5.52-.48 2.61.48 5.01 2.22 6.56.43.38.66.91.66 1.47V19c0 1.1.9 2 2 2h.28c.35.6.98 1 1.72 1s1.38-.4 1.72-1H14c1.1 0 2-.9 2-2v-2.31c0-.55.22-1.09.64-1.46C18.09 13.95 19 12.08 19 10c0-3.87-3.13-7-7-7zm2 16h-4v-1h4v1zm0-2h-4v-1h4v1zm-1.5-5.59V14h-1v-2.59L9.67 9.59l.71-.71L12 10.5l1.62-1.62.71.71-1.83 1.82z",
    Label: "M17.63 5.84C17.27 5.33 16.67 5 16 5L5 5.01C3.9 5.01 3 5.9 3 7v10c0 1.1.9 1.99 2 1.99L16 19c.67 0 1.27-.33 1.63-.84L22 12l-4.37-6.16z",
    LocalAtm: "M11 17h2v-1h1c.55 0 1-.45 1-1v-3c0-.55-.45-1-1-1h-3v-1h4V8h-2V7h-2v1h-1c-.55 0-1 .45-1 1v3c0 .55.45 1 1 1h3v1H9v2h2v1zm9-13H4c-1.11 0-1.99.89-1.99 2L2 18c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V6c0-1.11-.89-2-2-2zm0 14H4V6h16v12z",
    Menu: "M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z"
};
function splitVariables(line) {
    return (likeAr(line.slice(line[0] == '?' || line[0] == '#' ? 1 : 0).split('&'))
        .build(function (asignacion) {
        var _a, _b;
        var eqPosition = asignacion.indexOf('=');
        return eqPosition ? (_a = {}, _a[asignacion.substr(0, eqPosition)] = asignacion.substr(eqPosition + 1), _a) : (_b = {}, _b[asignacion] = true, _b);
    }));
}
function Application(props) {
    var classes = useStyles();
    var _a = React.useState(false), drawOpened = _a[0], setDrawOpened = _a[1];
    var locationParts = splitVariables(location.hash);
    console.log(locationParts);
    var _b = react_1.useState(locationParts.w || 'main'), selectedPage = _b[0], setSelectedPage = _b[1];
    react_1.useEffect(function () {
        if (selectedPage) {
            location.hash = 'w=' + selectedPage;
        }
        else {
            location.hash = '';
        }
        var onHashChange = function () {
            var locationParts = splitVariables(location.hash);
            if (locationParts.w && locationParts.w != selectedPage) {
                setSelectedPage(locationParts.w);
            }
        };
        window.addEventListener('hashchange', onHashChange);
        return function cleanUp() {
            window.removeEventListener('hashchange', onHashChange);
        };
    });
    var _c = react_1.useState(null), hamburguerMenu = _c[0], setHamburguerMenu = _c[1];
    var toggleDrawer = function (open) { return function (event) {
        if (event.type === 'keydown' &&
            (event.key === 'Tab' ||
                event.key === 'Shift')) {
            return;
        }
        setDrawOpened(open);
    }; };
    return <>
        <core_1.AppBar position="static">
            <core_1.Toolbar>
                <core_1.IconButton edge="start" className={classes.menuButton} color="inherit" aria-label="menu" onClick={function (event) { return MENUTYPE == 'simple' ? setHamburguerMenu(event.currentTarget) : setDrawOpened(true); }}>
                    <core_2.SvgIcon>
                        <path d={exports.materialIoIconsSvgPath.Menu}/>
                    </core_2.SvgIcon>
                </core_1.IconButton>
                <core_2.Typography variant="h6" className={classes.title}>
                    demo formularios
                </core_2.Typography>
                <core_1.Button color="inherit">Login</core_1.Button>
            </core_1.Toolbar>            
        </core_1.AppBar>
        {props.children.map(function (child) {
        return child.props.page && child.props.children ?
            <Conditional key={child.props.page} visible={child.props.page == selectedPage}>{child}</Conditional>
            : child;
    })}
        <core_3.Drawer open={drawOpened} onClose={toggleDrawer(false)}>
            <div className={classes.list} role="presentation" onClick={toggleDrawer(false)} onKeyDown={toggleDrawer(false)}>
                <core_3.List>
                    {props.children.map(function (child) {
        var item = child.props;
        if (item == null) {
            return null;
        }
        return (<core_3.ListItem button key={item.page} onClick={function () {
            setSelectedPage(child.props.page);
            setDrawOpened(false);
        }}>
                                <core_3.ListItemIcon>
                                    <core_2.SvgIcon>
                                        <path d={item.iconSvgPath || exports.materialIoIconsSvgPath[item.iconName || 'Label']}/>
                                    </core_2.SvgIcon>
                                </core_3.ListItemIcon>
                                <core_3.ListItemText primary={item.menuLabel || item.page}/>
                            </core_3.ListItem>);
    })}
                </core_3.List>
            </div>
        </core_3.Drawer>
        <core_1.Menu anchorEl={hamburguerMenu} keepMounted open={Boolean(hamburguerMenu)} onClose={function () { return setHamburguerMenu(null); }}>
            {props.children.map(function (child) {
        return child.props.page ?
            <core_1.MenuItem key={child.props.page} onClick={function () {
                setSelectedPage(child.props.page);
                setHamburguerMenu(null);
            }}>
                        {child.props.menuLabel || child.props.page}
                    </core_1.MenuItem>
            : null;
    })}
        </core_1.Menu>
    </>;
}
exports.Application = Application;
