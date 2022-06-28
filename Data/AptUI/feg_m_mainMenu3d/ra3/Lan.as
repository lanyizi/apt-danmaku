import ra3.MessageHandler;
import ra3.MapHeuristic;

// 为了打 log 而引入的，该删了！
import danmaku.World;

// 这个类的名字其实应该改成 LanBasedGame 之类的（
// 它的作用其实是自动在局域网大厅创建一个房间并自动启动游戏
// 之所以是局域网，是因为遭遇战会有 Skirmish.ini 的 bug
// 它会自动读取地图列表，通过地图上的出生点，找到能支持 6 个玩家的地图
// 然后启动一局让玩家 1v5 AI 的游戏（
// 由于功能复杂，因此它比较乱，而且有着大量（已经失效）的打 log 代码需要删除（
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
    private var _difficulty: Number;

    public function Lan(messageHandler: MessageHandler, logger: Function, difficulty: Number) {
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
        var self: Lan = this;
        _messageHandler.addMessageHandler(function(m) {
            self.handleMessages(m);
        });
        _messageHandler.addOnExitScreenHandler(function() {
            self.destroy();
        });
        _logger("Lan initialized");
        _difficulty = difficulty + 2;
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
        for (var i = 1; i <= 5; ++i) {
            callGameFunction("%SetPlayerStatus?Slot=" + String(i) + "|Status=" + String(_difficulty));
            callGameFunction("%SetTeam?Slot=" + String(i) + "|Team=2");
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
            }
        }

        var next = _maps.pop();
        while (next !== undefined && _parsedMaps[next]) {
            next = _maps.pop();
        }
        if (next !== undefined) {
            _nextMapId = next;
            _logger("Next map: " + _nextMapId + ", next type: " + (typeof _nextMapId));

            _switchMapTimeout = 90;
            callGameFunction("%SetMap?Map=" + _nextMapId);
            return;
        }

        _logger("No more maps");
        _status = SIX_PLAYERS_MAP_FOUND;
        var randomIndex = Math.floor(Math.random() * _sixPlayersMaps.length);
        _logger("Starting with map = " + _sixPlayersMaps[randomIndex]);
        callGameFunction("%ResetRules");
        callGameFunction("%SetMap?Map=" + _sixPlayersMaps[randomIndex]);
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