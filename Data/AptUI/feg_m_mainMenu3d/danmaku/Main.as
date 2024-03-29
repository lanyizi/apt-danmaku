﻿import danmaku.Game;
import danmaku.World;
import danmaku.components.Alice;
import danmaku.components.AliceStage1;
import danmaku.components.AliceStage2;
import danmaku.components.AliceStage3;
import danmaku.components.Flare;
import danmaku.components.PlayerControl;
import danmaku.components.Reimu;
import danmaku.overlays.Border;
import danmaku.overlays.GameDialogue;
import danmaku.overlays.Options;
import danmaku.overlays.PlayerStats;
import danmaku.overlays.TextButton;
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
        // log = Bind.oneArg(diagnostics, diagnostics.log);

        // 把通讯星给扔了！
        log("Gloabl comlink: " + _global.comLink);
        _global.comLink._y = -100;
        Mouse.hide();

        var worldMovieClip: MovieClip = movieClip.createEmptyMovieClip("world", 100);
        var borderMovieClip: MovieClip = movieClip.createEmptyMovieClip("border", 50);
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

        // 创建显示生命值的 UI
        setupPlayerStats(world, overlayMovieClip);

        // 创建角色
        world.onAfterNextFrame(function() {
            createCharacters(world, movieClip.mouseClickChecker, borderMovieClip);
        });

        // 在游戏结束之后执行的函数
        Game.instance().onGameVictory = function() {
            showVictoryDialogue(messageHandler, world, overlayMovieClip);
        };
        Game.instance().onGameDefeat = function() {
            world.paused = true;
            var menu = overlayMovieClip.attachMovie("Options", "menu", 200);
            var options: Options = new Options(menu, function() {
                createCharacters(world, movieClip.mouseClickChecker, borderMovieClip);
                world.paused = false;
                Game.instance().fighting = true;
            }, "续关");
        };

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
            }, "继续");
        };
        world.addOnFrameListener("updatePause", function() {
            pause.sprite()._visible = Game.instance().fighting;
        });
    }

    // 创建显示生命值的 UI
    private static function setupPlayerStats(world: World, overlay: MovieClip): Void {
        var sprite: MovieClip = overlay.attachMovie("PlayerStats", "playerStats", 300);
        sprite._x = 900 + (1366 - 900) / 2 + 4;
        sprite._y = 64;
        var playerStats: PlayerStats = new PlayerStats(sprite, world);
    }

    // 创建角色
    private static function createCharacters(world: World, mouseButton: Button, borderMovieClip: MovieClip): Void {
        // 清除老的物体
        var old: Array = world.findComponents(Reimu)
            .concat(world.findComponents(Alice))
            .concat(world.findComponents(Flare))
        for (var i = 0; i < old.length; ++i) {
            world.destroy(old[i].gameObject());
        }

        var aliceObject = world.instantiate("Alice");
        var levels: Array = [new AliceStage1(), new AliceStage2(), new AliceStage3()];
        // 支持续关
        if (Game.instance().currentStage > 0) {
            Game.instance().currentStage -= 1;
        }
        var currentStage = Game.instance().currentStage;
        levels.splice(0, currentStage);
        var alice: Alice = aliceObject.addComponent(new Alice(0, 0));
        alice.getNextLevel = function() { return levels.shift(); };

        var reimuObject = world.instantiate("Reimu");
        var playerControl: PlayerControl = new PlayerControl(mouseButton);
        playerControl.topEdge = (768 - 720) / 2;
        playerControl.bottomEdge = 720 + (768 - 720) / 2;
        playerControl.leftEdge = (1366 - 900) / 2;
        playerControl.rightEdge = 900 + (1366 - 900) / 2;
        reimuObject.addComponent(playerControl);
        var reimu: Reimu = reimuObject.addComponent(new Reimu());
        reimu.hitpoint = currentStage === 0 ? 7 : 3;

        // 创建边框
        var border: Border = new Border(borderMovieClip, playerControl, world);
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

    // 显示游戏胜利之后的对话
    private static function showVictoryDialogue(messageHandler: MessageHandler, world: World, overlay: MovieClip): Void {
        var sprite = overlay.attachMovie("GameDialogue", "dialog", 50);
        sprite._x = 683;
        sprite._y = 384;
        var dialog: GameDialogue = new GameDialogue(sprite, [
            { title: "爱丽丝", character: "alice", text: "行啦行啦，在 30FPS 的世界里打弹幕游戏有什么意思~" },
            { title: "灵梦", character: "reimuAngry", text: "怪不得总觉得有点不对劲！" },
            { title: "爱丽丝", character: "alice", text: "灵梦看来肯定不知道红色警戒3呢~" },
            { title: "爱丽丝", character: "alice", text: "这是一款由云亼开发的即时战略游戏，大概是因为这款游戏早就死透了，所以幻想入了吧（" },
            { title: "爱丽丝", character: "alice", text: "与其互扔符卡，灵梦不如来和我的人偶们打一局红警3呀！" },
            { title: "灵梦", character: "reimuNormal", text: "……所以你那些“人工智能”人偶其实就是用来打电子游戏的吗" },
            { title: "爱丽丝", character: "alice", text: "诶~ 之前还来势汹汹的，现在怯战了吗？" },
            { title: "灵梦", character: "reimuAngry", text: "看来被看扁了呢，红警3又怎样，区区人偶，我一打五也没问题！" }
        ]);
        dialog.onStepChanged = function(step) {
            if (step === 7) {
                createRa3Match(messageHandler, world);
            }
        };
        world.addOnFrameListener("dialog2", function() {
            dialog.update();
            if (dialog.isFinished()) {
                world.removeOnFrameListener("dialog2");
            }
        });
    }

    private static function createRa3Match(messageHandler: MessageHandler, world: World): Void {
        var lan: Lan = new Lan(messageHandler, log, Game.instance().difficulty);
        world.addOnFrameListener("lanGame", function() {
            lan.tryCreateLanGame();
            lan.processPendingTasks();
        });
        messageHandler.addOnExitScreenHandler(function() {
            world.removeOnFrameListener("lanGame");
        });
    }

    public static function log(message: String): Void {}
}