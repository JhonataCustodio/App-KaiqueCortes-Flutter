import 'package:kaiquecortes/home_page.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';


class MyApp extends StatefulWidget {
  MyApp({this.app});
  final FirebaseApp app;

  @override
  _State createState() => new _State();
}

class  _State extends State<MyApp> {
  String _value = '';
  DatabaseReference _nomeRef;
  DatabaseReference _messagesRef;
  StreamSubscription<Event> _nomeSubscription;
  StreamSubscription<Event> _messagesSubscription;
 // bool _anchorToBottom = false;

  String _nome = '';
  String _valor='';
  String _descricao = '';
  String _data='';
  String _kTestValue = 'world!';
  DatabaseError _error;

  @override
  void initState() {
    super.initState();
    // Demonstrates configuring to the database using a file
    _nomeRef = FirebaseDatabase.instance.reference().child('nome');
    // Demonstrates configuring the database directly
    final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
    _messagesRef = database.reference().child('messages');
    database.reference().child('nome').once().then((DataSnapshot snapshot) {
      print('Connected to second database and read ${snapshot.value}');
    });
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
    _nomeRef.keepSynced(true);
    _nomeSubscription = _nomeRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        _nome = event.snapshot.value ?? 0;
        _valor = event.snapshot.value ?? 0;
        _descricao = event.snapshot.value ?? 0;
        _data = event.snapshot.value ?? 0;

      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });
    _messagesSubscription =
        _messagesRef.limitToLast(10).onChildAdded.listen((Event event) {
      print('Child added: ${event.snapshot.value}');
    }, onError: (Object o) {
      final DatabaseError error = o;
      print('Error: ${error.code} ${error.message}');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _messagesSubscription.cancel();
    _nomeSubscription.cancel();
  }

    Future<void> _increment() async {
    // Increment counter in transaction.
    final TransactionResult transactionResult =
      await _nomeRef.runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? 0) + 1;
      return mutableData;
    });

    if (transactionResult.committed) {
      _messagesRef.push().set(<String, String>{
        _nome: ' \n\n Nome Cliente: $_nome \n\n Valor: $_valor Reais \n\n Descrição: $_descricao \n\n Data: $_data ${transactionResult.dataSnapshot.value} \n\n'
      });
    } else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
  }

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(2016),
        lastDate: new DateTime(2040)
    );
    if(picked != null) setState(() => _value = picked.toString());
  }

    List<Widget> usernameAndPassword() {
    return [
       new TextFormField(
        key: new Key('nome'),
        style: TextStyle(
          color:Colors.black,
        ),
        decoration: new InputDecoration(labelText: 'Nome do Cliente: ',
        labelStyle: TextStyle(
          color: Colors.orange,
          fontSize: 14,          
        ),        
        ),
        autocorrect: false,
        validator: (val) => val.isEmpty ? _kTestValue : null,
        onChanged: (String value) {
            setState(() {
             _nome = value;
        });
        },
        //onSaved: (val) => _email = val,
      ),
      new TextFormField(
        key: new Key('pagamento'),
        keyboardType: TextInputType.number,
        style: TextStyle(
          color: Colors.black,
        ),
        decoration: new InputDecoration(labelText: 'Valor do serviço cobrado: ',
        labelStyle: TextStyle(
          color: Colors.orange,
          fontSize: 14,          
        ),
        ),
        obscureText: false,
        autocorrect: false,
        validator: (val) => val.isEmpty ? _kTestValue : null,
        onChanged: (String value) {
            setState(() {
             _valor = value;
        });
        },
       // onSaved: (val) => _password = val,
      ),
        new TextFormField(
        key: new Key('descricao'),
        style: TextStyle(
          color:Colors.black,
        ),
        decoration: new InputDecoration(labelText: 'Descricao do Serviço: ',
        labelStyle: TextStyle(
          color: Colors.orange,
          fontSize: 14,
        ),
        ),
        obscureText: false,
        autocorrect: false,
        validator: (val) => val.isEmpty ? _kTestValue : null,
        onChanged: (String value) {
            setState(() {
             _descricao = value;
        });
        },       // onSaved: (val) => _password = val,
      ),
      new Column(
        children: <Widget>[
            new Text(_data =_value,),
            
            new RaisedButton(
              onPressed: _selectDate, 
              color: Colors.orange[50],
              child: new Text('Clique para selecionar a Data ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange,
              ),
              ),
              //validator: (val) => val.isEmpty ? _kTestValue : null,

          ),
          Badge(
            badgeColor: Colors.orange,
            badgeContent: Icon(
            Icons.calendar_today,
              size: 16,
              color: Colors.white,
            ),
            shape: BadgeShape.square,
            borderRadius: 5,
      
        ),
        ],
      ),

    ];
  }

  showAlertDialog2(BuildContext context) {
   Widget cancelaButton = FlatButton(
    child: Text("Cancelar",
    style: TextStyle(
      color: Colors.blueGrey[200],
    ),
    ),
    
    onPressed:  () {
            Navigator.pop(context);

    },
    
  );
  Widget continuaButton = FlatButton(
    child: Text("Salvar",
    style: TextStyle(
      color: Colors.green[200],
    ),
    ),
    onPressed:  () {
      _increment();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    },
  );
  //configura o AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.blueGrey[900],
    title: Text("Salvar Registro",
    style: TextStyle(
      color: Colors.orange,
    ),
    ),
    content: Text("Deseja mesmo salvar esse registro ?",
    style: TextStyle(
      color: Colors.white,
    ),
    ),
    actions: [
      cancelaButton,
      continuaButton,
    ],
  );
  //exibe o diálogo
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

          List<Widget> submitWidgets() {
            return[
                ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            
                              Badge(
                                badgeColor: Colors.green[600],
                                badgeContent: Text(
                                  ' Salvar Registro ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:  FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 20,
                              ),
                               Badge(
                                badgeColor: Colors.blueGrey[900],
                                badgeContent: Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.green[200],
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 30,
      
                                ),                              

                          ],   
                        ),
                        color: Colors.white,
                        onPressed: (){
                          showAlertDialog2(context);

                        },                      
                        ),
                      
                      FlatButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                              Badge(
                                badgeColor: Colors.red[400],
                                badgeContent: Text(     
                                  ' Voltar ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:  FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 20,
                                
                              ),
                               Badge(
                                badgeColor: Colors.blueGrey[900],
                                badgeContent: Icon(
                                  Icons.cancel,
                                  size: 16,
                                  color: Colors.red[200],
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 30,
      
                                ),                              
                          ],   
                        ),
                        color: Colors.white,
                        onPressed: ()  => Navigator.pop(context, false),               

                      ),
                    ],
                  ),
                  ]; 
          }

  @override
  Widget build(BuildContext context) {
    List<Widget> formularioRegistro() {
      return [
          Container(
            child: Card(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.event_note,
                    color: Colors.orange,
                    ),
                    title: Text('Formulário de Registro de Serviço',
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                    ),
                    subtitle: Text('Abaixo coloque as informações corretas antes de salvar o formulário.',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                    ),
                  ),
                new Container(       
                    padding: const EdgeInsets.all(16.0),
                    child: new Form(
                        //key: formKey,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: usernameAndPassword(),
                        )
                    )
                ),
                new Container(
                    padding: const EdgeInsets.all(16.0),
                    child: new Form(
                        //key: formKey,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: submitWidgets(),
                        )
                    )                  
                ),
              
                ],
              ),
            ), 
          ),
          
      ];
    } 


    return Scaffold(
        appBar: new AppBar(
        actions: <Widget>[
          new FlatButton(
              child: new Text('Kaique Cortes', style: new TextStyle(fontSize: 17.0, color: Colors.white))
          ),
        ],
      ),
      body: Container(
        child: new ListView(
          children: <Widget>[
                     Column(
          children: [
            new Card(       
                color: Colors.white,
                child: new Column(
                mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Container(  
                        padding: const EdgeInsets.all(16.0),
                        child: new Form(
                          //key: formKey,
                              child: Column(
                                    mainAxisSize: MainAxisSize.min,

                                  ),
                          ),
                      ), 
                      new Container(
                        padding: const EdgeInsets.all(16.0),
                          child: new Form(
                              //key: formKey,
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: formularioRegistro(),
                                
                              ),
                          
                          ),
                          
                      ), 
                      ]),
                    
              ),
                  //hintText()
                ],
        ),
        ],

        ),

        ));        
      
  }
}