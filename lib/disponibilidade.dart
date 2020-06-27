import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:firebase_database/ui/firebase_animated_list.dart';



class RadioButton extends StatefulWidget {
  RadioButton({this.app});
  final FirebaseApp app;
  @override
  RadioButtonState createState() {
    return new RadioButtonState();
  }
}

class RadioButtonState extends State<RadioButton> {
  
  String _situacao = '';
  DatabaseReference _radioRef; 
  DatabaseReference _statusRef;
  StreamSubscription<Event> _radioSubscription;
  StreamSubscription<Event> _messagesSubscription;
 // bool _anchorToBottom = false;
  
  bool _value1 = false;
  bool _value2 = false;
  bool _value3 = false;

  //void _value1Changed(bool value) => setState(() => _value1 = value);
  //void _value2Changed(bool value) => setState(() => _value2 = value);
  //void _value3Changed(bool value) => setState(() => _value3 = value);


  //int _radioValue1 = 1;
  String _kTestValue = 'world!';
  String _fechado ='Fechado  🚫';
  String _aberto ='Aberto  ✅';
  String _almoco ='Almoço  🍽';
  String _statusAtivo = '';
  
  DatabaseError _error;

  @override
  void initState() {
    super.initState();
    // Demonstrates configuring to the database using a file
    _radioRef = FirebaseDatabase.instance.reference().child('situacao');
 

    // Demonstrates configuring the database directly
    final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
    _statusRef = database.reference().child('status');
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
        _statusAtivo= event.snapshot.value ?? 0;
        
        

      });
    },  
     onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    _messagesSubscription =
        _statusRef.limitToLast(10).onChildAdded.listen((Event event) {
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
  }

    Future<void> _increment() async {
    // Increment counter in transaction.
    final TransactionResult transactionResult =
      await _radioRef.runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? 0) + 1;
      return mutableData;
    });

    if (transactionResult.committed) {
      _statusRef.push().set(<String, String>{
        _statusAtivo:  ''
      });
    }else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
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

        bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              IconButton(icon: Icon(Icons.account_circle,
                color: Colors.white,
              ), onPressed: () {},),
              
            ],
          ),
        ),
      body: new ListView(
        padding: EdgeInsets.all(10.0),
            children: <Widget>[
               Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                  
                  const ListTile(
                    leading: Icon(
                      Icons.today,
                      color: Colors.orange,
                      
                      ),
                    title: Text('Selecione a Disponibilidade',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight:  FontWeight.bold,
                    ),
                    ),
                    subtitle: Text('Opção que determina se o seu salão está aberto ou fechado ou em horário de almoço.',
                    style: TextStyle(
                      color: Colors.black38,
                    ),                    
                    ),
                  ),

                    new Padding(
                      padding: new EdgeInsets.all(8.0),
                    ),
                    new Divider(height: 5.0, color: Colors.blueGrey),
                    new Padding(
                      padding: new EdgeInsets.all(8.0),
                    ),
                    new Text(
                      'Selecione uma das opções :',
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.orange,
                      ),
                    ),   
                    SizedBox(
                      height: 20,
                    ),
               
                    new Card(
                      
                      color: Colors.white,
                      child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new CheckboxListTile(
                            value: _value1,
                            //onChanged: _value1Changed,
                            title: new Text('Fechado',
                            style: TextStyle(
                              color: Colors.orange,
                            ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            subtitle: new Text('Selecione apenas essa.',
                            style: TextStyle(
                              color: Colors.blueGrey,
                            ),                         
                            ),
                            secondary: new Icon(Icons.cancel,
                            color: Colors.red,
                            ),
                            activeColor: Colors.red,
                           onChanged: (bool _value1Changed) {

                            setState(() {
                                _value1 = _value1Changed;
                                if(_value1 == true){
                                  _statusAtivo = _fechado ;
                                }else{ 
                                  return  ;

                                }

                            },);}
                        ),
                        new CheckboxListTile(
                            value: _value2,
                            //onChanged: _value2Changed,
                            title: new Text('Aberto',
                            style: TextStyle(
                              color: Colors.orange,
                            ),                           
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            subtitle: new Text('Selecione apenas essa.',
                            style: TextStyle(
                              color: Colors.blueGrey,
                            ),                      
                            ),
                            secondary: new Icon(Icons.check_box,
                            color: Colors.green,
                            ),
                            activeColor: Colors.green,
                           onChanged: (bool _value2Changed) {

                            setState(() {
                                _value2 = _value2Changed;
                                if(_value2 == true){
                                  _statusAtivo = _aberto;
                                }else{ 
                                  return  ;

                                }
                            },);}                            
                        ),
                        new CheckboxListTile(
                            value: _value3,
                            //onChanged: _value3Changed,
                            title: new Text('Almoço',
                            style: TextStyle(
                              color: Colors.orange,
                            ),                        
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            subtitle: new Text('Selecione apenas essa.',
                            style: TextStyle(
                              color: Colors.blueGrey,
                            ),       
                            ),
                            secondary: new Icon(Icons.fastfood,
                            color: Colors.orange,
                            ),
                            activeColor: Colors.orange,
                            onChanged: (bool _value3Changed) {

                              setState(() {
                                  _value3 = _value3Changed ;
                                if(_value3 == true){
                                  _statusAtivo = _almoco;
                                }else{ 
                                  return  ;

                                }
                            },);}

                        ),
                      ],
                    ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    new Card(
                      color: Colors.orange[50],
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
                          height: 80,
                          
                            child: new FirebaseAnimatedList(
                            query: _statusRef.limitToLast(1),
                            //padding: new EdgeInsets.all(5.0),
                            reverse: false,
                            itemBuilder: (_, DataSnapshot snapshot,
                              Animation<double> animation, int index) {

                                return new   Badge(
                                badgeColor: Colors.white,
                                badgeContent: Text(
                                  snapshot.value.toString(),
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 30,
  
                              );    
                              
                            }
                            ),
                          ),                    			                
                  ]),


            ],
              ));
      
    
  }
}