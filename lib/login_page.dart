import 'package:flutter/material.dart';
import 'package:kaiquecortes/primary_button.dart';
import 'auth.dart';
import 'package:flutter/services.dart' ;
import 'package:badges/badges.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:firebase_database/ui/firebase_animated_list.dart';


class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title, this.auth, this.onSignIn, this.app}) : super(key: key);

  final String title;
  final BaseAuth auth;
  final VoidCallback onSignIn;
  final FirebaseApp app;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

enum FormType {
  login,
  register
}

class _LoginPageState extends State<LoginPage> {
  static final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _name;
  FormType _formType = FormType.login;
  String _authHint = '';
  String _statusAtivo = '';

  

  DatabaseReference _radioRef; 
  DatabaseReference _statusRef;
  DatabaseReference _tabelaDePrecoRef;

  StreamSubscription<Event> _radioSubscription;
  StreamSubscription<Event> _messagesSubscription;
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


  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
  
  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        String userId = _formType == FormType.login
            ? await widget.auth.signIn(_email, _password)
            : await widget.auth.createUser(_email, _password);
        setState(() {
          _authHint = 'Signed In\n\nUser id: $userId';
        });
        widget.onSignIn();
      }
      catch (e) {
        setState(() {
          _authHint = 'Erro de login\n\n${e.toString()}';
        });
        print(e);
      }
    } else {
      setState(() {
        _authHint = '';
      });
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
      _authHint = '';
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
      _authHint = '';
    });
  }

  List<Widget> usernameAndPassword() {
    return [
      padded(child: new TextFormField(
        key: new Key('email'),
        decoration: new InputDecoration(labelText: 'Email: ',
        focusColor: Colors.orange,
        labelStyle: TextStyle(
          color:Colors.orange,
        ),
        ),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
        onSaved: (val) => _email = val,
      )),
      padded(child: new TextFormField(
        key: new Key('password'),
        decoration: new InputDecoration(labelText: 'Senha: ',
        focusColor: Colors.orange,
        labelStyle: TextStyle(
          color:Colors.orange,
        )
        ),
        obscureText: true,
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Password can\'t be empty.' : null,
        onSaved: (val) => _password = val,
      )),

    ];
  }

  List<Widget> submitWidgets() {
    
       
        return [
          new PrimaryButton(
            key: new Key('login'),
            text: 'Login',
            height: 44.0,
            onPressed: validateAndSubmit
          ),
          /*
          new FlatButton(
            key: new Key('need-account'),
            child: new Text("Precisa de uma conta? Registro"),
            onPressed: moveToRegister
          ), */
        ];
        
    /*  case FormType.register:
        return [
          new PrimaryButton(
            key: new Key('register'),
            text: 'Criar conta',
            height: 44.0,
            onPressed: validateAndSubmit
          ),
          new FlatButton(
            key: new Key('need-login'),
            child: new Text("Já tem uma conta ? Realize o login"),
            onPressed: moveToLogin
          ),
        ]; */
    
    //return null;
  }

  Widget hintText() {
    return new Container(
        height: 100.0,
        padding: const EdgeInsets.all(32.0),
        child: new Text(
            _authHint,
            key: new Key('hint'),
            style: new TextStyle(fontSize: 18.0, color: Colors.grey),
            textAlign: TextAlign.center)
    );
  }
  void _settingModalBottomSheet(context){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
          return Container(
            //color: Colors.black,
            child: new Wrap(
            children: <Widget>[
              new Card(
              child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                
                const ListTile(
                    leading: Icon(
                      Icons.security,
                      color: Colors.orange,
                      
                    ),
                    trailing: Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: Colors.orange,
                      
                      ),
                    title: Text('Login do Administrador',
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                    ),
                   
                        
                ),
                new Container(
                  
                    padding: const EdgeInsets.all(10.0),
                    color: Colors.white,
                    child: new Form(
                        key: formKey,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: usernameAndPassword() + submitWidgets(),
                          
                        ),
                       
                    ),
                ),

                SizedBox(
                  height: 100,
                ),
              ]
              
              ),
            ),
            
            ],
          ),
          );
          
      }
      
    );

}

  void _tabelaDePrecos(context){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
          return Container(
            //color: Colors.black,
            child: new Wrap(
            children: <Widget>[
              new Card(
                color:Colors.white,
                child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(
                      Icons.wc,
                      color: Colors.orange,
                      
                      ),
                      title: Text('Corte Masculino e Feminino',
                    style: TextStyle(
                      color: Colors.orange,
                      //fontWeight: FontWeight.bold,

                    ),
                    ),
                    subtitle: Text(' Químicas consultar com o Cabeleireiro(a) ',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      
                    ),                    
                    ),
                     
                  ),        
                          SizedBox(
                            width: 310,
                            height: 100,
                             child: new FirebaseAnimatedList(
                            query:FirebaseDatabase.instance
                            .reference().child("tabela_de_preco").orderByChild('Feminino').limitToLast(1),
                            //padding: new EdgeInsets.all(5.0),
                            reverse: false,
                            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                              Animation<double> animation, int index) {

                                return new   Badge(
                                badgeColor: Colors.orange[200],
                                badgeContent: Text(
                                  '${  snapshot.value.toString()  }',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.start,
                                  
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 10,
  
                              );    
                              
                            })
                            ),       
                          
                    
                    
                  
                  
                  SizedBox(
                    height: 10,
                  ),  
                  new Divider(height: 5.0, color: Colors.blueGrey),

                      FlatButton(
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                              Badge(
                                badgeColor: Colors.white,
                                badgeContent: Text(
                                  'Voltar',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 5,
                              ), 
                              SizedBox(
                                width: 10,
                              ),    
                                Badge(
                                badgeColor: Colors.white,
                                badgeContent: Icon(
                                  Icons.arrow_drop_down,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 30,
      
                                ),                                                               

                          ],   
                        ),
                        color: Colors.white,
                       onPressed: () {
                        Navigator.pop(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      
                        
                        },
                      ),      
                ],
                ),
              )
              ],
              ),
              );
          }
        );
}


  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
    ]);
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Kaique Cortes"),
      ),

          bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              
                        FlatButton(
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                              Badge(
                                badgeColor: Colors.black,
                                badgeContent: Text(
                                  ' Area Administrativa ',
                                  style: TextStyle(
                                    color: Colors.orange[200],
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
                                  Icons.assessment,
                                  size: 16,
                                  color: Colors.orange[200],
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 30,
      
                                ),
                          ],
                        ),
                       onPressed: () {
                         _settingModalBottomSheet(context);
                       }),
            
              
            ],
          ),
        ),
      backgroundColor: Colors.black,
      body: new SingleChildScrollView(child: new Container(
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage("imagens.dart/fundo.png"), fit: BoxFit.fill)),
        padding: const EdgeInsets.only(top:215),
        child: new Column(
          children: [
            Card(
              color: Colors.white,
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                  const ListTile(
                    leading: Icon(
                      Icons.today,
                      color: Colors.orange,
                      
                      ),
                    title: Text('Disponibilidade',
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                    ),
                    subtitle: Text('Opção que determina se o seu salão está aberto, fechado ou em horário de almoço.',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),                    
                    ),
                  ), 
                  FlatButton(onPressed: null, 
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                            
                        SizedBox(
                          width: 100,
                          height: 30,
                          
                            child: new FirebaseAnimatedList(
                            query:FirebaseDatabase.instance
                            .reference().child("status").limitToLast(1),
                            //padding: new EdgeInsets.all(5.0),
                            reverse: false,
                            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                              Animation<double> animation, int index) {

                                return new   Badge(
                                badgeColor: Colors.white,
                                badgeContent: Text(
                                  '${  snapshot.value.toString()  }',
                                  style: TextStyle(
                                    color: Colors.green[200],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.2,
                                  ),
                                  textAlign: TextAlign.center,
                                  
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 30,
  
                              );    
                              
                            }
                            ),
                          ), 


                              SizedBox(
                                width: 15,
                              ),                  
                                Badge(
                                badgeColor: Colors.white,
                                badgeContent: Icon(
                                  Icons.error_outline ,
                                  size: 16,
                                  color: Colors.green[200],
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 30,
      
                                ),                      
                              ],
                  )
                  
                  ),                
                  ],

              ),
            ),

            Card(
              color: Colors.white,
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                  const ListTile(
                    leading: Icon(
                      Icons.credit_card,
                      color: Colors.orange,
                      
                      ),
                    title: Text('Tabela de preços',
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                    ),
                    subtitle: Text('Consulte a tabela de preço de nossos serviços.',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),                    
                    ),
                  ), 
                  FlatButton(
                       onPressed: () {
                         _tabelaDePrecos(context);
                       }, 
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                              Badge(
                                badgeColor: Colors.white,
                                badgeContent: Text(
                                  ' Ver nossos preços ',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight:  FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Badge(
                                badgeColor: Colors.white,
                                badgeContent: Icon(
                                  Icons.eject,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 30,
      
                                ),  
                     
                              ],
                  )
                  
                  ),                
                  ],

              ),
            ),

            new Card(
              color: Colors.black,
              child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  SizedBox(
                            width: 65,
                            height: 30,
                            child: new FirebaseAnimatedList(
                            query:FirebaseDatabase.instance
                            .reference().child("fila").limitToLast(1),
                            //padding: new EdgeInsets.all(5.0),
                            reverse: false,
                            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                              Animation<double> animation, int index) {

                                return new   Badge(
                                badgeColor: Colors.black,
                                badgeContent: Text(
                                  '${  snapshot.value.toString()  }',
                                  style: TextStyle(
                                    color: Colors.red[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.start,
                                  
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 10,
  
                              );    
                              
                            })
                            ),  
                              SizedBox(
                                width: 5,
                              ),
                             
                          SizedBox(
                            width: 125,
                            height: 30,
                            child: new FirebaseAnimatedList(
                            query:FirebaseDatabase.instance
                            .reference().child("cadeira").limitToLast(1),
                            //padding: new EdgeInsets.all(5.0),
                            reverse: false,
                            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                              Animation<double> animation, int index) {

                                return new   Badge(
                                badgeColor: Colors.black,
                                badgeContent: Text(
                                  '${  snapshot.value.toString()  }',
                                  style: TextStyle(
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.start,
                                  
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 10,
  
                              );    
                              
                            })
                            ),
                                ],
                              ),
                                                         
                            ],
                          ),
 
                          onPressed: null, 
                        ),
                      ],
              ),        
              
            ),

            
            /*
             */
            //hintText()
          ]
        )
      )),
      
      
    );
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}

