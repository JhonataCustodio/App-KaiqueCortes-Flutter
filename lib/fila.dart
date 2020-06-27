import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'dart:async';




class Fila extends StatefulWidget {
  Fila({this.app});
  final FirebaseApp app; 

  @override
  _FilaState createState() => _FilaState();
}

class _FilaState extends State<Fila> {
  int _counter;
  DatabaseReference _filaRef;
  DatabaseReference _messagesRef;
  StreamSubscription<Event> _filaSubscription;
  StreamSubscription<Event> _messagesSubscription;
  bool _anchorToBottom = false;

  String _kTestKey = 'Fila ';
  String _kTestValue = 'Clientes';
  DatabaseError _error;

  @override
  void initState() {
    super.initState();
    // Demonstrates configuring to the database using a file
    _filaRef = FirebaseDatabase.instance.reference().child('counter');
    // Demonstrates configuring the database directly
    final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
    _messagesRef = database.reference().child('fila');
    database.reference().child('counter').once().then((DataSnapshot snapshot) {
      print('Connected to second database and read ${snapshot.value}');
    });
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
    _filaRef.keepSynced(true);
    _filaSubscription = _filaRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        _counter = event.snapshot.value ?? -1;
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
    _filaSubscription.cancel();
  }

  Future<void> _increment() async {
    // Increment counter in transaction.
    final TransactionResult transactionResult =
        await _filaRef.runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? -1) + 1;
      return mutableData;
    });

    if (transactionResult.committed) {
      _messagesRef.push().set(<String, String>{
        _kTestKey: ' ${transactionResult.dataSnapshot.value}'
      });
    } else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
  }

  Future<void> _decrement() async {
    // Increment counter in transaction.
    final TransactionResult transactionResult =
        await _filaRef.runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? -1) - 1;
      return mutableData;
    });

    if (transactionResult.committed) {
      _messagesRef.push().set(<String, String>{
        _kTestKey: '${transactionResult.dataSnapshot.value}'
      });
    } else {
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
      body: Column(
        children: <Widget>[
          Card(
            child: Column(
              children: <Widget>[
                SizedBox(
            height: 100,
          ),
           const ListTile(
              leading: Icon(
              Icons.transfer_within_a_station,
              color: Colors.red,
                      
           ),
            title: Text('Informe a quantidade de clientes em espera',
              style: TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight:  FontWeight.bold,
              ),
            ),
            subtitle: Text('Seus clientes poderão visualizar a fila para o atendimento.',
            style: TextStyle(
              color: Colors.blueGrey,
              //fontWeight:  FontWeight.bold,
              ),
            ),
                  
          ),
          SizedBox(
            height: 50,
          ),
          Card(
            color: Colors.orange[50],
            child: Center(
              child: _error == null
                  ? Text(
                      'Clientes em espera $_counter time${_counter == 1 ? '' : 's'}.\n\n',
                    style: TextStyle(
                    color: Colors.black38,
                    fontWeight:  FontWeight.bold,
                    fontSize: 16
                    ),  
                    )
                  : Text(
                      'Error retrieving button tap count:\n${_error.message}',
                    ),
            ),
         
          ),
          
          new Card(       
                color: Colors.orange[50],
                child: new Column(
                mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FlatButton(
                    onPressed: _increment,
                    child: const Icon(Icons.add),
                  ),
                  FlatButton(
                    onPressed: _decrement,
                    child: const Icon(Icons.remove),
                  ),                      
                      
                ])
              ),

              ],
            ),
          ),
        ],
        
      ),
      
      
      
    );
      
  }
}

        
          
          