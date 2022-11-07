import 'package:flutter/material.dart';
import 'package:pylons_sdk/pylons_sdk.dart';

const menu = "1) Fight a goblin!\n2) Fight a troll!\n3) Fight a dragon!\n4) Buy a sword!\n"
    "5) Upgrade your sword!\n6) (!) Rest for a moment\n7) (!) Rest for a bit\n8) (!) Rest for a while\n"
    "9) (!) Power nap (9 PYL)";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PylonsWallet.setup(mode: PylonsMode.prod, host: 'flutter_wallet');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _displayMenuButtons = false;
  String _username = "";
  String _address = "";
  String _text = "lorem ipsum etc. etc.";
  bool _foundWallet = false;
  Item? _character;
  int _pylons = 0;
  int _swordLv = 0;
  int _coins = 0;
  int _shards = 0;
  int _curHp = 0;
  @override
  void initState() {
    super.initState();
    PylonsWallet.instance.exists().then((value) {
      _foundWallet = value;
      if (_foundWallet) {
        Cookbook.load("appTestCookbook");
      } else {
        throw Exception("handle this - get wallet install etc.");
      }
    });
  }

  void _displayText(String t, bool menu) {
    setState(() {
      if (menu || _text.isEmpty) {
        _text = t;
      } else {
        _text += "\n";
        _text += t;
      }
      _displayMenuButtons = menu;
    });
  }

  Future<void> _checkCharacter() async {
    _displayText("Checking character...", false);

    final prf = await Profile.get();
    if (prf == null) throw Exception("HANDLE THIS");
    _pylons = prf.getBalances["upylon"]?.toInt() ?? 0;

    // todo: make the use-latest stuff work again
    _character ??= prf.items.firstWhere((element) {
        var v = element.getLastUpdate();
        // second condition gets ?? true b/c we wind up flipping the fallback too
        return element.getString("entityType") == "character" &&
            !(element.getInt("currentHp")?.isZero ?? true);
      });

    _swordLv = _character?.getInt("swordLevel")?.toInt() ?? 0;
    _coins = _character?.getInt("coins")?.toInt() ?? 0;
    _shards = _character?.getInt("shards")?.toInt() ?? 0;
    _curHp = _character?.getInt("currentHp")?.toInt() ?? 0;
  }

  Future<void> _generateCharacter() async {
    _displayText("Generating character...", false);
    final recipe = await Recipe.get("RecipeTestAppGetCharacter");
    if (recipe == null) throw Exception("todo: handle this");
    final exec = await recipe.executeWith([]).onError((error, stackTrace) {
      throw Exception("character generation tx should not fail");
    });
    final itemId = exec.getItemOutputIds().first;
    _character = await Item.get(itemId);
  }

  Future<void> _fightGoblin() async {
    _displayText("Fighting a goblin...", false);
    final recipe = await Recipe.get("RecipeTestAppFightGoblin");
    if (recipe == null) throw Exception("todo: handle this");
    await recipe.executeWith([_character!]).onError((error, stackTrace) {
      throw Exception("combat tx should not fail");
    });
    _displayText("Victory!", false);
    var lastHp = _curHp;
    var lastCoins = _coins;
    await _checkCharacter();
    if (lastHp != _curHp) {
      _displayText("Took ${lastHp - _curHp} damage!", false);
    }
    if (lastCoins != _coins) {
      _displayText("Found ${_coins - lastCoins} coins!", false);
    }
  }

  Future<void> _fightTroll() async {
    _displayText("Fighting a troll...", false);
    if (_swordLv < 1) {
      final recipe = await Recipe.get("RecipeTestAppFightTrollUnarmed");
      if (recipe == null) throw Exception("todo: handle this");
      await recipe.executeWith([_character!]).onError((error, stackTrace) {
        throw Exception("combat tx should not fail");
      });
      _displayText("Defeat...", false);
      var lastHp = _curHp;
      await _checkCharacter();
      if (lastHp != _curHp) {
        _displayText("Took ${lastHp - _curHp} damage!", false);
      }
    } else {
      final recipe = await Recipe.get("RecipeTestAppFightTrollArmed");
      if (recipe == null) throw Exception("todo: handle this");
      await recipe.executeWith([_character!]).onError((error, stackTrace) {
        throw Exception("combat tx should not fail");
      });
      _displayText("Victory!", false);
      var lastHp = _curHp;
      var lastShards = _shards;
      await _checkCharacter();
      if (lastHp != _curHp) {
        _displayText("Took ${lastHp - _curHp} damage!", false);
      }
      if (lastShards != _shards) {
        _displayText("Found ${_shards - lastShards} shards!", false);
      }
    }
  }

  Future<void> _fightDragon() async {
    _displayText("Fighting a dragon...", false);
    if (_swordLv < 2) {
      final recipe = await Recipe.get("RecipeTestAppFightDragonUnarmed");
      if (recipe == null) throw Exception("todo: handle this");
      await recipe.executeWith([_character!]).onError((error, stackTrace) {
        throw Exception("combat tx should not fail");
      });
      _displayText("Defeat...", false);
      var lastHp = _curHp;
      await _checkCharacter();
      if (lastHp != _curHp) {
        _displayText("Took ${lastHp - _curHp} damage!", false);
      }
    } else {
      final recipe = await Recipe.get("RecipeTestAppFightDragonArmed");
      if (recipe == null) throw Exception("todo: handle this");
      await recipe.executeWith([_character!]).onError((error, stackTrace) {
        throw Exception("combat tx should not fail");
      });
      _displayText("Victory!", false);
      var lastHp = _curHp;
      await _checkCharacter();
      if (lastHp != _curHp) {
        _displayText("Took ${lastHp - _curHp} damage!", false);
      }
    }
  }

  Future<void> _buySword() async {
    if (_swordLv > 0) {
      _displayText("You already have a sword", false);
    } else if (_coins < 50 ) {
      _displayText("You need 50 coins to buy a sword", false);
    } else {
      final recipe = await Recipe.get("RecipeTestAppBuySword");
      if (recipe == null) throw Exception("todo: handle this");
      await recipe.executeWith([_character!]).onError((error, stackTrace) {
        throw Exception("purchase tx should not fail");
      });
      _displayText("Bought a sword!", false);
      var lastCoins = _coins;
      await _checkCharacter();
      if (lastCoins != _coins) {
        _displayText("Spent ${lastCoins - _coins} coins!", false);
      }
    }
  }

  Future<void> _upgradeSword() async {
    if (_swordLv > 1) {
      _displayText("You already have an upgraded sword", false);
    } else if (_shards < 5) {
      _displayText("You need 5 shards to upgrade your sword", false);
    } else {
      final recipe = await Recipe.get("RecipeTestAppPurchaseUpgradeSword");
      if (recipe == null) throw Exception("todo: handle this");
      await recipe.executeWith([_character!]).onError((error, stackTrace) {
        throw Exception("purchase tx should not fail");
      });
      _displayText("Upgraded your sword!", false);
      var lastShards = _shards;
      await _checkCharacter();
      if (lastShards != _shards) {
        _displayText("Spent ${lastShards - _shards} shards!", false);
      }
    }
  }

  // todo: retool rest functionality once delayed execs work
  // alternatively rework the rest mechanic to not use a delay? idk

  // Future<void> _rest1() async {
  //   _displayText("Resting...", false);
  //   // var sdkResponse = await PylonsWallet.instance.txExecuteRecipe(
  //   //     cookbookId: "appTestCookbook",
  //   //     recipeName: "RecipeTestAppRest25",
  //   //     itemIds: [_character!.id],
  //   //     coinInputIndex: 0,
  //   //     paymentInfo: []);
  //   // if (!sdkResponse.success) {
  //   //   throw Exception("rest tx should not fail");
  //   // }
  //   //dunno how to get exec either...
  //   var exec = "TODO";
  //   while (true) {
  //     _displayText("...", false);
  //     //sdkResponse = await PylonsWallet.instance.getExecutionBasedOnId(id: exec);
  //     // if completed break
  //   }
  //   _displayText("Done!", false);
  //   var lastHp = _curHp;
  //   await _checkCharacter();
  //   if (lastHp != _curHp) {
  //     _displayText("Recovered ${_curHp - lastHp} HP!", false);
  //   }
  // }
  //
  // Future<void> _rest2() async {
  //   _displayText("Resting...", false);
  //   // var sdkResponse = await PylonsWallet.instance.txExecuteRecipe(
  //   //     cookbookId: "appTestCookbook",
  //   //     recipeName: "RecipeTestAppRest50",
  //   //     itemIds: [_character!.id],
  //   //     coinInputIndex: 0,
  //   //     paymentInfo: []);
  //   // if (!sdkResponse.success) {
  //   //   throw Exception("rest tx should not fail");
  //   // }
  //   //dunno how to get exec either...
  //   var exec = "TODO";
  //   while (true) {
  //     _displayText("...", false);
  //     //sdkResponse = await PylonsWallet.instance.getExecutionBasedOnId(id: exec);
  //     // if completed break
  //   }
  //   _displayText("Done!", false);
  //   var lastHp = _curHp;
  //   await _checkCharacter();
  //   if (lastHp != _curHp) {
  //     _displayText("Recovered ${_curHp - lastHp} HP!", false);
  //   }
  // }
  //
  // Future<void> _rest3() async {
  //   _displayText("Resting...", false);
  //   // var sdkResponse = await PylonsWallet.instance.txExecuteRecipe(
  //   //     cookbookId: "appTestCookbook",
  //   //     recipeName: "RecipeTestAppRest100",
  //   //     itemIds: [_character!.id],
  //   //     coinInputIndex: 0,
  //   //     paymentInfo: []);
  //   // if (!sdkResponse.success) {
  //   //   throw Exception("rest tx should not fail");
  //   // }
  //   //dunno how to get exec either...
  //   var exec = "TODO";
  //   while (true) {
  //     _displayText("...", false);
  //     //sdkResponse = await PylonsWallet.instance.getExecutionBasedOnId(id: exec);
  //     // if completed break
  //   }
  //   _displayText("Done!", false);
  //   var lastHp = _curHp;
  //   await _checkCharacter();
  //   if (lastHp != _curHp) {
  //     _displayText("Recovered ${_curHp - lastHp} HP!", false);
  //   }
  // }
  //
  // Future<void> _rest4() async {
  //   if (_pylons < 9) {
  //     _displayText("You need 9 Pylons Points to take a power nap!", false);
  //     return;
  //   }
  //   _displayText("Resting...", false);
  //   // var sdkResponse = await PylonsWallet.instance.txExecuteRecipe(
  //   //     cookbookId: "appTestCookbook",
  //   //     recipeName: "RecipeTestAppRest100Premium",
  //   //     itemIds: [_character!.id],
  //   //     coinInputIndex: 0,
  //   //     paymentInfo: []);
  //   // if (!sdkResponse.success) {
  //   //   throw Exception("rest tx should not fail");
  //   // }
  //   _displayText("Done!", false);
  //   var lastHp = _curHp;
  //   await _checkCharacter();
  //   if (lastHp != _curHp) {
  //     _displayText("Recovered ${_curHp - lastHp} HP!", false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Container(
                      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.white)),
                      padding: EdgeInsets.zero,
                      child: Padding(padding: const EdgeInsets.all(32),
                          child: Text(_text, style: const TextStyle(color: Colors.white, fontSize: 16)))
                  )),
              _foundWallet ? SizedBox.fromSize(
                size: const Size.fromHeight(120),
                child: Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.white)),
                      padding: EdgeInsets.zero,
                      child: _displayMenuButtons ? Row(
                        children: [
                          Expanded(child: TextButton(onPressed: () => {_fightGoblin()}, child: const Text("0"))),
                          Expanded(child: TextButton(onPressed: () => {_fightTroll()}, child: const Text("1"))),
                          Expanded(child: TextButton(onPressed: () => {_fightDragon()}, child: const Text("2"))),
                          Expanded(child: TextButton(onPressed: () => {_buySword()}, child: const Text("3"))),
                          Expanded(child: TextButton(onPressed: () => {_upgradeSword()}, child: const Text("4"))),
                          Expanded(child: TextButton(onPressed: () => {}, child: const Text("5"))), //rest1
                          Expanded(child: TextButton(onPressed: () => {}, child: const Text("6"))), //rest2
                          Expanded(child: TextButton(onPressed: () => {}, child: const Text("7"))), //rest3
                          Expanded(child: TextButton(onPressed: () => {}, child: const Text("9"))) //rest4
                        ],
                      ) : TextButton(onPressed: () => {_displayText(menu, true)}, child: const Text("OK")),
                    )
                )
              ) : Container()
            ],
          ),
        )
    );
  }
}
