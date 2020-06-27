import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:firebase_database/ui/firebase_animated_list.dart';


class TabelaDePrecos extends StatefulWidget {
   TabelaDePrecos({this.app});
  final FirebaseApp app;
  @override
  _TabelaDePrecosState createState() => _TabelaDePrecosState();
}

class _TabelaDePrecosState extends State<TabelaDePrecos> {
  TextEditingController _controllerMasculino;
  TextEditingController _controllerFeminino;

  DatabaseReference _radioRef; 
  DatabaseReference _tabelaDePrecoRef;
  StreamSubscription<Event> _radioSubscription;
  StreamSubscription<Event> _messagesSubscription;

  DatabaseError _error;
  String _masculino = 'Masculino';
  String _feminino = 'Feminino';
  String _valor1 = '';
  String _valor2 = '';

  @override
  void initState() {
    super.initState();
    // Demonstrates configuring to the database using a file
    _radioRef = FirebaseDatabase.instance.reference().child('situacao');
    _controllerMasculino = TextEditingController();
    _controllerFeminino = TextEditingController();

    // Demonstrates configuring the database directly
    final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
    _tabelaDePrecoRef = database.reference().child('tabela_de_preco');
    database.reference().child('situacao').once().then((DataSnapshot snapshot) {
      print('Connected to second database and read ${snapshot.value}');
    });
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
    _radioRef.keepSynced(true);
 
    _radioSubscription = _radioRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        //_radioValue1 = event.snapshot.value ?? 0;
        _masculino= event.snapshot.value ?? 0;
        _feminino= event.snapshot.value ?? 0;
        _valor1= event.snapshot.value ?? 0;
        _valor2= event.snapshot.value ?? 0;


      });
    },  
     onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    _messagesSubscription =
        _tabelaDePrecoRef.limitToLast(10).onChildAdded.listen((Event event) {
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
    _radioSubscription.cancel();
    _controllerMasculino.dispose();
    _controllerFeminino.dispose();
  }

    Future<void> _increment() async {
    // Increment counter in transaction.
    final TransactionResult transactionResult =
      await _radioRef.runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? 0) + 1;
      return mutableData;
    });

    if (transactionResult.committed) {
      _tabelaDePrecoRef.push().set(<String, String>{
        _masculino:  '   Corte Masculino $_valor1    \n\n',
        _feminino:   '    Corte Feminino $_valor2     \n\n' ,
      });
    }else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
  }
 
   List<Widget> corteMasculino() {
      return [
          Container(
            child: Card(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.wc,
                    color: Colors.orange,
                    ),
                    title: Text('Corte Masculino',
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                    ),
                    subtitle: Text('Informe o valor que será cobrado pelo serviço.',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                    ),
                  ),
                  
                         Column(
                          children: <Widget>[
                           TextField(
                             decoration: InputDecoration(
                              hintText: ' Toque para digitar aqui:'
                             ),
                            controller: _controllerMasculino,
                            onSubmitted: (String value) async {
                              await showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Informações do valor do seu serviço',
                                    style: TextStyle(
                                      color:Colors.orange,
                                    ),
                                    ),
                                    content: Text('"$value".'),
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onChanged: (String value) {
                                setState(() {
                                _valor1 = value;
                            });
                            }, 
                          ),  
                                                     
                        
                          ],   
                        ),
                 
                  
                ],
              ),
            ), 
          ),
          
      ];
    }

    List<Widget> corteFeminino() {
      return [
          Container(
            child: Card(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.wc,
                    color: Colors.orange,
                    ),
                    title: Text('Corte Feminino',
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                    ),
                    subtitle: Text('Informe o valor que será cobrado pelo serviço.',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                    ),
                  ),
                  
                         Column(
                          children: <Widget>[
                           TextField(
                             decoration: InputDecoration(
                              hintText: ' Toque para digitar aqui:'
                             ),
                            controller: _controllerFeminino,
                            onSubmitted: (String value) async {
                              await showDialog<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Informações do valor do seu serviço ',
                                    style: TextStyle(
                                      color:Colors.orange,
                                    ),
                                    ),
                                    content: Text(' "$value".'),
                                   
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onChanged: (String value) {
                                setState(() {
                                _valor2 = value;
                            });
                            }, 
                          ),  
                                                     
                        
                          ],   
                        ),
                 
                  
                ],
              ),
            ), 
          ),
          
      ];
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        actions: <Widget>[
          new FlatButton(
              child: new Text('Kaique Cortes', style: new TextStyle(fontSize: 17.0, color: Colors.white))
          ),
        ],
      ),
      body: new Container(
        
        color: Colors.white,
        child: new ListView(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            const ListTile(
                    leading: Icon(
                      Icons.credit_card,
                      color: Colors.orange,
                      
                      ),
                    title: Text('Informe o preço do Serviço',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight:  FontWeight.bold,
                    ),
                    ),
                  
                  ),
                     Column(
          children: [
            new Card(       
                color: Colors.orange[50],
                child: new Column(
                mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Container(  
                        padding: const EdgeInsets.all(16.0),
                        child: new Form(
                          //key: formKey,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: corteMasculino(),
                        ),
                        ),
                      ),
                      new Container(
                        padding: const EdgeInsets.all(16.0),
                          child: new Form(
                              //key: formKey,
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: corteFeminino(),
                                
                              ),
                          
                          ),
                          
                      ),                      
                      
                    ])
              ),
                  //hintText()
                ]
        ),
                SizedBox(
                      height: 10,
                    ),
                    new Card(
                      color: Colors.white,
                      child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                              Badge(
                                badgeColor: Colors.green[600],
                                badgeContent: Text(
                                  ' Salvar Status ',
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
                        onPressed: _increment,),                   

                        FlatButton(
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                              Badge(
                                badgeColor: Colors.red[600],
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
                        onPressed: () => Navigator.pop(context, false),
                        
                      ),                     
                      ],
                      ),                        
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    SizedBox(
                          width: 300,
                          height: 120,
                          
                            child: new FirebaseAnimatedList(
                            query: _tabelaDePrecoRef.limitToLast(1),
                            //padding: new EdgeInsets.all(5.0),
                            reverse: false,
                            itemBuilder: (_, DataSnapshot snapshot,
                              Animation<double> animation, int index) {

                                return new   Badge(
                                badgeColor: Colors.orange[50],
                                badgeContent: Text(
                                  snapshot.value.toString(),
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.start,
                                  
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 10,
  
                              );    
                              
                            }
                            ),
                          ),   
          ],

        ),


      ),
    );
  }
}