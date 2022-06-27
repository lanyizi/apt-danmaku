import danmaku.Game;
import danmaku.World;
import danmaku.components.Alice;
import danmaku.components.AliceStage1;
import danmaku.components.AliceStage2;
import danmaku.components.AliceStage3;
import danmaku.components.PlayerControl;
import danmaku.components.Reimu;
import danmaku.overlays.GameDialogue;
import danmaku.overlays.TextButton;
import danmaku.overlays.Options;
import danmaku.utilities.Bind;
import danmaku.utilities.Diagnostics;
import ra3.Lan;
import ra3.MessageHandler;
import ra3.GameSound;

class danmaku.Main {
    public static function initialize(movieClip: MovieClip): Void {
        var messageHandler: MessageHandler = new MessageHandler();
        messageHandler.addOnExitScreenHandler(function() {
            delete _global.danmaku;
            delete _global.ra3;
        });

        var diagnostics: Diagnostics = new Diagnostics(movieClip.log);
        // 设置写日志的函数
        log = Bind.oneArg(diagnostics, diagnostics.log);

        // 把通讯星给扔了！
        log("Gloabl comlink: " + _global.comLink);
        _global.comLink._y = -100;
        Mouse.hide();

        var worldMovieClip: MovieClip = movieClip.createEmptyMovieClip("world", 100);
        var overlayMovieClip: MovieClip = movieClip.createEmptyMovieClip("overlay", 200);
        var world: World = new World(worldMovieClip, movieClip._width, movieClip._height);

        worldMovieClip.onEnterFrame = function() {
            world.update();
            diagnostics.updateFps();
            movieClip.statistics.text = diagnostics.getDescription(world);
        };
        messageHandler.addOnExitScreenHandler(function() {
            world.destroyAll();
            worldMovieClip.onEnterFrame = null;
        });

        // 初始化选项菜单以及暂停按钮等
        showStartOptions(world, overlayMovieClip);

        // 创建角色
        world.onAfterNextFrame(function() {
            var aliceObject = world.instantiate("Alice");
            var levels: Array = [new AliceStage1(), new AliceStage2(), new AliceStage3()];
            var alice: Alice = aliceObject.addComponent(new Alice(0, 0));
            alice.getNextLevel = function() { return levels.shift(); };

            var reimuObject = world.instantiate("Reimu");
            var mouseButton: Button = movieClip.mouseClickChecker;
            var playerControl: PlayerControl = new PlayerControl(mouseButton);
            playerControl.topEdge = (768 - 720) / 2;
            playerControl.bottomEdge = 720 + (768 - 720) / 2;
            playerControl.leftEdge = (1366 - 900) / 2;
            playerControl.rightEdge = 900 + (1366 - 900) / 2;
            reimuObject.addComponent(playerControl);
            reimuObject.addComponent(new Reimu());
        });

        // 播放音乐
        GameSound.play("AyakashiSet05TheDollMakerOfBucuresti", 4 * 60 + 40);
    }

    // 游戏开始之前，先显示选单
    private static function showStartOptions(world: World, overlay: MovieClip): Void {
        // 游戏开始之前，先暂停游戏并将其设置为不可见
        world.paused = true;
        world.movieClip()._visible = false;
        // 创建选单
        var menu = overlay.attachMovie("Options", "menu", 200);
        var options: Options = new Options(menu, function() {
            // 选单关闭之后，开始游戏
            world.movieClip()._visible = true;
            world.paused = false;
            // 然后顺便也创建一下暂停按钮
            setupPauseButton(world, overlay);
            // 并显示对话
            showInitialDialogue(world, overlay);
        });
    }

    // 创建暂停按钮
    private static function setupPauseButton(world: World, overlay: MovieClip): Void {
        var sprite = overlay.attachMovie("TextButton", "pause", 100);
        var pause: TextButton = new TextButton(sprite);
        pause.sprite()._x = 1120;
        pause.sprite()._y = 10;
        pause.setWidth(60);
        pause.setText("暂停");
        pause.onClick = function() {
            // 点击按钮之后，暂停游戏并显示选单
            world.paused = true;
            var menu = overlay.attachMovie("Options", "menu", 200);
            var options: Options = new Options(menu, function() {
                world.paused = false;
            });
        };
    }

    // 显示游戏开始之前的对话
    private static function showInitialDialogue(world: World, overlay: MovieClip): Void {
        var sprite = overlay.attachMovie("GameDialogue", "dialog", 50);
        sprite._x = 683;
        sprite._y = 384;
        var dialog: GameDialogue = new GameDialogue(sprite, [
            { title: "博丽灵梦", character: "reimuNormal", text: "爱丽丝！" },
            { title: "爱丽丝·玛格特洛依德", character: "alice", text: "灵梦？这么晚了来找我有什么事吗" },
            { title: "灵梦", character: "reimuAngry", text: "你在偷偷研究什么危险的东西吧，什么“人工智能”人偶！" },
            { title: "爱丽丝", character: "alice", text: "什么嘛 看来不是来找我的啊。\n可先不管你说的是哪种人偶，我作为一个人偶使，研究人偶难道有什么问题吗？" },
            { title: "灵梦", character: "reimuAngry", text: "看来直接承认了呢！这么危险的东西，要是脱离了控制的话会引发大危机的！" },
            { title: "爱丽丝", character: "alice", text: "我好像知道灵梦的想的是什么了，当然不是你想的那样哦，不妨来亲自看一看吧！" },
            { title: "灵梦", character: "reimuAngry", text: "看来只能由我亲自把爱丽丝的人偶给拆光了呢！" }
        ]);
        dialog.onStepChanged = function(step) {
            if (step === 5) {
                GameSound.play("AyakashiSet06DollJudgementTruncated", 4 * 60 + 53)
            }
        }
        world.addOnFrameListener("dialog1", function() {
            dialog.update();
            if (dialog.isFinished()) {
                world.removeOnFrameListener("dialog1");
                Game.instance().fighting = true;
            }
        });
    }

    public static function log(message: String): Void {}
}