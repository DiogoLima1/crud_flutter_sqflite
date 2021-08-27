import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'sql_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Crud-Flutter',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  TextEditingController _nomeController = new TextEditingController();
  TextEditingController _idadeController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _nomeController.text = existingJournal['nome'];
      _idadeController.text = existingJournal['idade'];
      _emailController.text = existingJournal['email'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_) => SingleChildScrollView(
                child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
              alignment: Alignment.topCenter,
              width: double.infinity,
              height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(hintText: 'Nome'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _idadeController,
                    decoration: InputDecoration(hintText: 'Idade'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(hintText: 'Email'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addItem();
                      }

                      if (id != null) {
                        await _updateItem(id);
                      }

                      _nomeController.text = '';
                      _idadeController.text = '';
                      _emailController.text = '';

                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Criar' : 'Atualizar'),
                  )
                ],
              ),
            )));
  }

  Future<void> _addItem() async {
    if (_idadeController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Preencher Campo Idade!'),
        backgroundColor: Colors.redAccent,
      ));
    } else {
      await SQLHelper.createItem(
          _nomeController.text, _idadeController.text, _emailController.text);
      _refreshJournals();
    }
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _nomeController.text, _idadeController.text, _emailController.text);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Atualizado com sucesso!'),
      backgroundColor: Colors.blueAccent,
    ));
    _refreshJournals();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Deletado com sucesso!'),
      backgroundColor: Colors.redAccent,
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                color: Colors.blueGrey[200],
                margin: EdgeInsets.fromLTRB(8, 25, 8, 10),
                shape: Border.all(width: 2.0, color: Colors.blueGrey),
                child: ListTile(
                    contentPadding: EdgeInsets.all(20),
                    leading: Text(_journals[index]['idade'],
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 35)),
                    title: Text(_journals[index]['nome'],
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    subtitle: Text("Email: " + _journals[index]['email'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.blueGrey[400],
                            onPressed: () => _showForm(_journals[index]['id']),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.redAccent[100],
                            onPressed: () => showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                      title: Text('Você deseja mesmo excluir?'),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              _deleteItem(
                                                  _journals[index]['id']);
                                            },
                                            child: Text('Sim')),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text('Não'))
                                      ],
                                    )),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
