import ra3.MessageHandler;
import ra3.MapHeuristic;

import danmaku.World;

class ra3.Lan {
    private static var INITIAL: Number = 0;
    private static var READY: Number = 1;
    private static var CREATE_GAME: Number = 2;
    private static var GAME_CREATED: Number = 3;
    private static var MAP_LIST_RETRIEVED: Number = 4;
    private static var SIX_PLAYERS_MAP_FOUND: Number = 5;
    private static var DESTROYED: Number = 6;

    private var _messageHandler: MessageHandler;
    private var _logger: Function;
    private var _status: Number;
    private var _sixPlayersMaps: Array;
    private var _rulesToBeSet: Array;
    private var _parsedMaps: Object;
    private var _allMaps: Array;
    private var _maps: Array;
    private var _nextMapId: String;
    private var _currentStartPositions: String;
    private var _switchMapTimeout: Number;

    public function Lan(messageHandler: MessageHandler, logger: Function) {
        _messageHandler = messageHandler;
        _logger = logger;
        _status = INITIAL;
        _sixPlayersMaps = [];
        _rulesToBeSet = [];
        _parsedMaps = {};
        _allMaps = [];
        _maps = [];
        _switchMapTimeout = 0;
        callGameFunction("%SetGameSetupMode?Mode=None");
        callGameFunction("%LanInit");
        var self = this;
        _messageHandler.addMessageHandler(MessageHandler.bind1(this, handleMessages));
        _messageHandler.addOnExitScreenHandler(MessageHandler.bind0(this, destroy));
        _logger("Lan initialized");
    }

    public function canCreateGame() { return _status === READY; }

    public function tryCreateLanGame() {
        if (!canCreateGame()) {
            return;
        }
        _status = CREATE_GAME;
        callGameFunction("%LanCreateGame");
    }

    public function processPendingTasks() {
        if (_status === DESTROYED) {
            return;
        }
        if (_rulesToBeSet.length > 0) {
            var data = _rulesToBeSet.shift();
            _logger("Executing " + data);
            fscommand("CallGameFunction", data);
        }
        if (_status === MAP_LIST_RETRIEVED && _allMaps.length > 0) {
            --_switchMapTimeout;
            if (_switchMapTimeout <= 0) {



                var failedMap = _nextMapId;



                _maps.push(_nextMapId); // put the failed map back
                var randomIndex = Math.floor(Math.random() * _allMaps.length);
                _nextMapId = _allMaps[randomIndex];
                _switchMapTimeout = 90;

                World.test.lg.buttonText.text = "Failed map: " + failedMap + "_allMaps length " + _allMaps.length + "; randomIndex: " + randomIndex + "; _next: " + _nextMapId + "; allMaps: " + _allMaps;
                _logger("Failed map: " + failedMap + "_allMaps length " + _allMaps.length + "; randomIndex: " + randomIndex + "; _next: " + _nextMapId + "; allMaps: " + _allMaps);


                fscommand("CallGameFunction", "%SetMap?Map=" + _nextMapId);
            }
            else {
                findSixPlayersMap();
            }

        }
    }

    private function handleMessages(message) {
        var messageText = "" + message;
        for (var k in _global.MSGCODE) {
            if (_global.MSGCODE[k] == message) {
                messageText = k;
            }
        }
        _logger("Status: " + messageText + "~" + _status);

        if (message === _global.MSGCODE.FE_MP_REFRESH_CHAT_TEXTLIST) {
            var ruery = {};
            loadVariables("QueryGameEngine?CHAT_HISTORY?ChatMode=" + 2, ruery);
            if (ruery.CHAT_HISTORY_COUNT != undefined) {
                var colors = ruery.CHAT_HISTORY_COLORS.split(",");
                var count: Number = Number(ruery.CHAT_HISTORY_COUNT);
                for (var i = 0; i < count; ++i) {
                    _logger("$CHAT_TEXT_LOCAL" + String(i));
                }
            }
        }

        switch (_status) {
            case INITIAL:
            case READY:
                if (message !== _global.MSGCODE.FE_MP_LAN_LOBBY_STATE_CHANGE) {
                    return false;
                }
                var query = {};
                loadVariables("QueryGameEngine?LAN_CAN_HOST_OR_JOIN", query);
                _status = query.LAN_CAN_HOST_OR_JOIN == "1"
                    ? READY
                    : INITIAL;
                return true;
            case CREATE_GAME:
                if (message === _global.MSGCODE.FE_LAN_HOST_GAME_CREATED) {
                    onGameCreated();
                    return true;
                }
                return false;
            case GAME_CREATED:
                if (message === _global.MSGCODE.FE_MP_UPDATE_GAME_SETTINGS) {
                    retrieveMapList();
                    return true;
                }
                return false;
            case MAP_LIST_RETRIEVED:
                if (message === _global.MSGCODE.FE_MP_UPDATE_GAME_SETTINGS) {
                    findSixPlayersMap();
                    return true;
                }
                return false;
            case SIX_PLAYERS_MAP_FOUND:
            case DESTROYED:
                return false;
        }
        return false;
    }

    private function onGameCreated() {
        _status = GAME_CREATED;
        callGameFunction("%SetGameSetupMode?Mode=Network");
        var query = {};
        // 看上去必须先去“得知自己是否是房主”，游戏之后才能加载其他信息，不知道为啥
        loadVariables("QueryGameEngine?IsPcGameHost", query);
        _logger("Is host: " + (query.IsPcGameHost == "1"));
    }

    private function retrieveMapList() {
        var query = {};
        loadVariables("QueryGameEngine?MP_MAP_LIST", query);
        _allMaps = query.MP_MAP_LIST.split(",");
        _maps = _allMaps.slice();
        var length = _maps.length;
        for (var i = 0; i < length; ++i) { // shuffle array
            var randomIndex = Math.floor(Math.random() * length);
            var placeholder = _maps[i];
            _maps[i] = _maps[randomIndex];
            _maps[randomIndex] = placeholder;
        }
        _logger("Maps count: " + _maps.length);
        if (_maps.length < 1) {
            return;
        }
        _status = MAP_LIST_RETRIEVED;
        callGameFunction("%SetPlayerStatus?Slot=1|Status=5");
        callGameFunction("%SetPlayerStatus?Slot=2|Status=5");
        callGameFunction("%SetPlayerStatus?Slot=3|Status=5");
        callGameFunction("%SetPlayerStatus?Slot=4|Status=5");
        callGameFunction("%SetPlayerStatus?Slot=5|Status=5");
    }

    private var MAPTEXTFIELDID = 0;
    private var curArrIndex: Number = 0;
    private var curButtons: Array = [];
    private var allButtons: Array = [];
    private function changePage(diff: Number) {
        curArrIndex = Math.max(0, Math.min(allButtons.length, Math.round(curArrIndex + diff)));
        for (var i = 0; i < curButtons.length; ++i) {
            curButtons[i]._visible = false;
        }
        curButtons = allButtons[curArrIndex];
        for (var i = 0; i < curButtons.length; ++i) {
            curButtons[i]._visible = true;
        }
    }

    private function findSixPlayersMap() {
        var positions = getPositions();
        if (positions.text === _currentStartPositions) {
            _logger("Map not changed yet");
            return;
        }
        _logger("Map changed!");
        _currentStartPositions = positions.text;
        var currentMap = _nextMapId;
        if (_parsedMaps[currentMap]) {
            _logger("Skipping already parsed " + currentMap);
            currentMap = undefined;
        }
        if (currentMap !== undefined) {
            _parsedMaps[currentMap] = 1;
            var lastPlayerData = positions.array[5];
            var isSixPlayers = lastPlayerData.v;

            var result = "x" + lastPlayerData.x + ",y" + lastPlayerData.y + ",v" + lastPlayerData.v;
            _logger("M" + currentMap + "~" + result);
            if (isSixPlayers) {
                var isNormalMap = MapHeuristic.isNormalSixPlayersMap(positions.array);
                _sixPlayersMaps.push(currentMap);


                var curId = MAPTEXTFIELDID++;
                if (!World.test.previousPage) {
                    allButtons.push([]);
                    changePage(0);
                    _logger("Initializing, " + World.test)
                    var lg = World.test.attachMovie("TestT2", "lg", 100097)
                    _logger("Initializing, " + lg);
                    lg._x = 1200;
                    lg._y = 550;
                    var pp = World.test.attachMovie("TestT", "previousPage", 1098);
                    _logger("Initializing, " + pp);
                    var np = World.test.attachMovie("TestT", "nextPage", 1099);
                    _logger("Initializing, " + np);
                    pp._x = 11 * 105;
                    np._x = 11 * 105;
                    pp._y = 630;
                    np._y = 675;
                    pp.buttonText.text = "Previous Page";
                    np.buttonText.text = "Next Page";
                    var self = this;
                    var ppb: Button = pp.button;
                    var npb: Button = np.button;
                    ppb.onPress = function() { self.changePage(-1); }
                    npb.onPress = function() { self.changePage(+1); }
                }
                if (curButtons.length > 7 * 15) {
                    allButtons.push([]);
                    changePage(+1);
                }
                var t: MovieClip = World.test.attachMovie("TestT", "maptest" + curId, 1100 + curId);
                t._x = (Math.floor(curId / 15) % 7 + 0.6) * 145;
                t._y = (curId % 15 + 0.8) * 45;
                t.buttonText.text = "Map Id " + currentMap;
                for (var i = 0; i < _allMaps.length; ++i) {
                    if (_allMaps[i] === currentMap) {
                        t.buttonText.text = "$MP_MAP_LIST_" + i;
                    }
                }

                var self = this;
                t.button.onPress = function() {
                    if (!t._visible || self._status != SIX_PLAYERS_MAP_FOUND) {
                        return;
                    }
                    World.test.lg.buttonText.text = "Map ID " + currentMap + ";\n" + positions.text;
                    World.test.lg.buttonText.text += "\nIs normal maps: " + MapHeuristic.judgeSixPlayersMap(positions.array);
                    fscommand("CallGameFunction", "%SetMap?Map=" + currentMap);
                    for (var i = 0; i < 6; ++i) {
                        var x = World.test.MapPreviewComponent._x;
                        var y = World.test.MapPreviewComponent._y;
                        var w = World.test.MapPreviewComponent._width;
                        var h = World.test.MapPreviewComponent._height;
                        var mc: MovieClip = World.test["sp" + (i + 1)];
                        mc._x = x + (positions.array[i].x - 0.5) * w;
                        mc._y = y + (positions.array[i].y - 0.5) * h;
                    }
                };
                if (!isNormalMap) {
                    t._alpha = 50;
                }
                curButtons.push(t);
            }
        }

        var next = _maps.pop();
        while (next !== undefined && _parsedMaps[next]) {
            next = _maps.pop();
        }
        if (next !== undefined) {
            _nextMapId = next;
            _logger("Next map: " + _nextMapId + ", next type: " + (typeof _nextMapId));
            World.test.lg.buttonText.text = "Remaining maps: " + _maps + "; next is not undefined: " + (_nextMapId !== undefined);

            _switchMapTimeout = 90;
            callGameFunction("%SetMap?Map=" + _nextMapId);
            return;
        }

        _logger("No more maps");
        World.test.lg.buttonText.text = "Choose a map from left!";
        _status = SIX_PLAYERS_MAP_FOUND;
        var randomIndex = Math.floor(Math.random() * _sixPlayersMaps.length);
        _logger("Starting with map = " + _sixPlayersMaps[randomIndex]);
        callGameFunction("%ResetRules");
        callGameFunction("%SetMap?Map=" + _sixPlayersMaps[randomIndex]);

        return;

        callGameFunction("%StartGame");
    }

    private function destroy() {
        if (_status === DESTROYED) {
            return;
        }
        _logger("destroying")
        _status = DESTROYED;
    }

    private static function getPositions(): Object {
        var positions = [];
        var info = "";
        for (var i = 0; i < 6; ++i) {
            var query = {};
            loadVariables("QueryGameEngine?START_POSITION?Position=" + i, query);
            var px = Number(query.START_POSITION_X);
            var py = Number(query.START_POSITION_Y);
            var valid = query.START_POSITION_VALID == "1";
            info += ("x=" + px + ", y=" + py + ", v=" + valid + ";\n");
            positions.push({ x: px, y: py, v: valid });
        }
        return { text: info, array: positions }
    }

    private function callGameFunction(data: String) {
        _rulesToBeSet.push(data);
    }
}