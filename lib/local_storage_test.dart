import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageTestApp extends StatefulWidget {
  const LocalStorageTestApp({super.key});

  @override
  State<LocalStorageTestApp> createState() => _LocalStorageTestAppState();
}

class _LocalStorageTestAppState extends State<LocalStorageTestApp> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _readKeyController = TextEditingController();

  String _readResult = '';
  List<String> _allKeys = [];

  @override
  void initState() {
    super.initState();
    _loadAllKeys();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    _readKeyController.dispose();
    super.dispose();
  }

  // 全てのキーを読み込み
  Future<void> _loadAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allKeys = prefs.getKeys().toList();
    });
  }

  // データを保存
  Future<void> _saveData() async {
    if (_keyController.text.isEmpty || _valueController.text.isEmpty) {
      _showSnackBar('キーと値の両方を入力してください');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyController.text, _valueController.text);

    _showSnackBar(
      'データを保存しました: ${_keyController.text} = ${_valueController.text}',
    );
    _keyController.clear();
    _valueController.clear();
    _loadAllKeys();
  }

  // データを読み込み
  Future<void> _readData() async {
    if (_readKeyController.text.isEmpty) {
      _showSnackBar('読み込むキーを入力してください');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_readKeyController.text);

    setState(() {
      _readResult = value ?? 'キー "${_readKeyController.text}" は見つかりませんでした';
    });
  }

  // データを削除
  Future<void> _deleteData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);

    _showSnackBar('データを削除しました: $key');
    _loadAllKeys();

    // 読み込み結果もクリア
    if (_readResult.contains(key)) {
      setState(() {
        _readResult = '';
      });
    }
  }

  // 全データを削除
  Future<void> _clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _showSnackBar('全てのデータを削除しました');
    setState(() {
      _readResult = '';
    });
    _loadAllKeys();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ローカルストレージ テスト'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // データ保存セクション
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'データを保存',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _keyController,
                        decoration: const InputDecoration(
                          labelText: 'キー',
                          border: OutlineInputBorder(),
                          hintText: '例: username',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _valueController,
                        decoration: const InputDecoration(
                          labelText: '値',
                          border: OutlineInputBorder(),
                          hintText: '例: yamada_taro',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveData,
                          child: const Text('保存'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // データ読み込みセクション
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'データを読み込み',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _readKeyController,
                        decoration: const InputDecoration(
                          labelText: '読み込むキー',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _readData,
                          child: const Text('読み込み'),
                        ),
                      ),
                      if (_readResult.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            '結果: $_readResult',
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 保存済みデータ一覧セクション
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '保存済みデータ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _allKeys.isNotEmpty
                                ? _clearAllData
                                : null,
                            icon: const Icon(Icons.delete_sweep),
                            label: const Text('全削除'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_allKeys.isEmpty)
                        const Text(
                          '保存されているデータはありません',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ...(_allKeys.map(
                          (key) => FutureBuilder<String?>(
                            future: SharedPreferences.getInstance().then(
                              (prefs) => prefs.getString(key),
                            ),
                            builder: (context, snapshot) {
                              final value = snapshot.data ?? '';
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(key),
                                  subtitle: Text(value),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteData(key),
                                  ),
                                ),
                              );
                            },
                          ),
                        )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
