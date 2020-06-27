import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'dart:async';


class RegistrosDeServico extends StatefulWidget {
  RegistrosDeServico({this.app});
  final FirebaseApp app;

  @override
  _RegistrosDeServicoState createState() => _RegistrosDeServicoState();
}

class _RegistrosDeServicoState extends State<RegistrosDeServico> {
  //int _counter;
  DatabaseReference _nomeRef;
  DatabaseReference _messagesRef;
  StreamSubscription<Event> _nomeSubscription;
  StreamSubscription<Event> _messagesSubscription;
  bool _anchorToBottom = false;

  String _nome = '';
  //String _kTestKey = 'Hello';
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
      body: Column(
        children: <Widget>[
          ListTile(
            leading: Checkbox(
              onChanged: (bool value) {
                setState(() {
                  _anchorToBottom = value;
                });
              },
              value: _anchorToBottom,
            ),
            title: const Text('Visualizar ultimos Registros'),
          ),
          Flexible(
            child: FirebaseAnimatedList(
              key: ValueKey<bool>(_anchorToBottom),
              query: _messagesRef,
              reverse: _anchorToBottom,
              sort: _anchorToBottom

                  ? (DataSnapshot a, DataSnapshot b) => b.key.compareTo(a.key)
                  : null,
              itemBuilder: (BuildContext context, DataSnapshot snapshot, 
                  Animation<double> animation, int index) {
                return SizeTransition(
                  sizeFactor: animation,
                  
                  child: Row(
                    children:<Widget>[
                      SizedBox(
                      width: 300,
                      child: Card(
                      color: Colors.blueGrey[900],
                        child: new Row(
                          
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                        
                        FlatButton(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                                //badgeColor: Colors.blueGrey,
                          new Divider(height: 5.0, color: Colors.white),
                                Text(
                                " ${ snapshot.value.toString() }"  ,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:  FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.left,
                                  
                                ),
                          new Divider(height: 5.0, color: Colors.white),
                               
                          ],

                          ),                          
                        ),
                       
                      ],

                        ),                       
                      ),

                      ),
                      
                    ]
                  ),
                );
              },
            ),
          ),
        ],
      ),

    );
  }
}