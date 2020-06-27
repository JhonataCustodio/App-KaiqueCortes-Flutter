//import 'dart:html';

import 'package:kaiquecortes/registrar_cortes.dart';
import 'package:kaiquecortes/registros_de_corte.dart';
import 'package:kaiquecortes/tabela_de_precos.dart';
import 'package:flutter/material.dart';
import 'package:kaiquecortes/auth.dart';
import 'package:badges/badges.dart';
import 'package:kaiquecortes/disponibilidade.dart';
import 'package:kaiquecortes/fila.dart';
import 'package:kaiquecortes/cadeira.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';



class HomePage extends StatelessWidget {
  HomePage({this.auth, this.onSignOut});
  final BaseAuth auth;
  final VoidCallback onSignOut;
  
  
  @override
  Widget build(BuildContext context) {

    void _signOut() async {
      try {
        await auth.signOut();
        onSignOut();
      } catch (e) {
        print(e);
      }

    }
    
    List<Widget> corpo() {
      return [
          Container(
            child: Card(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const ListTile(
                    leading: Icon(Icons.cloud_download,
                    color: Colors.orange,
                    ),
                    title: Text('Registro de Serviço',
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                    ),
                    subtitle: Text('Opção que você pode visualizar a quantidade de serviços ou registrar um serviço.',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                    ),
                  ),
                  ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: Row(
                          children: <Widget>[
                              Badge(
                                badgeColor: Colors.white,
                                badgeContent: Text(
                                  ' Ver Registro',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight:  FontWeight.bold,
                                    fontSize: 14,

                                  ),
                                  textAlign: TextAlign.center,
                                  
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 20,
                              ),  
                                Badge(
                                badgeColor: Colors.white,
                                badgeContent: Icon(
                                  Icons.visibility,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 30,
      
                                ),                            
                        
                          ],   
                        ),
                        color: Colors.white,
                        onPressed: () { Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegistrosDeServico()),
                        ); },
                      ),
                      FlatButton(
                        child: Row(
                          children: <Widget>[
                              Badge(
                                badgeColor: Colors.white,
                                badgeContent: Text(
                                  ' Registrar Serv..',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight:  FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                  
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 20,

                              ), 
                                Badge(
                                badgeColor: Colors.white,
                                badgeContent: Icon(
                                  Icons.add_circle,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 30,
      
                                ),                                
                          ],
                        ),           
                        color: Colors.white,
                        onPressed: () { Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                        ); },
                      ),
                    ],
                  ),
                ],
              ),
            ), 
          ),
          
      ];
    }
  
    List<Widget> terceiroCard() {
      return [
          Container(
            child: Card(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    subtitle: Text('Opção que determina se o seu salão está aberto ou fechado.',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),                    
                    ),
                  ),
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                        child: Row(
                          children: <Widget>[
                              Badge(
                                badgeColor: Colors.white,
                                badgeContent: Text(
                                  ' Modifique o status do salão ',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 30,
  
                              ),   
                              SizedBox(
                                width: 25,
                              ),    
                                Badge(
                                badgeColor: Colors.white,
                                badgeContent: Icon(
                                  Icons.check_box,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                shape: BadgeShape.square,
                                borderRadius: 30,
      
                                ),                                                    
                        
                          ],   
                        ),
                        color: Colors.white,
                        onPressed: () { Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RadioButton()),
                        ); },
                      ),                      
                      ],
                    ),
                  new Divider(height: 5.0, color: Colors.orange[900]),

                  const ListTile(
                    leading: Icon(Icons.transfer_within_a_station,
                    color: Colors.orange,
                    ),
                    title: Text('Fila de Clientes',
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                    ),
                    subtitle: Text('Opção onde o usuário pode visualizar quantos clientes estão em espera.',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                    ),
                  ),
                  ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: Row(
                          children: <Widget>[
                              Badge(
                                badgeColor: Colors.white,
                                badgeContent: Text(
                                  'Editar fila de espera',
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
                                width: 5,
                              ),
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
                                badgeColor: Colors.red[600],
                                badgeContent: Text(
                                  '${  snapshot.value.toString()  }',
                                  style: TextStyle(
                                    color: Colors.white,
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
                        color: Colors.white,
                          onPressed: () { Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Fila()),
                        ); },
                      ),
                      FlatButton(
                        child: Row(
                          children: <Widget>[
                            Badge(
                                badgeColor: Colors.white,
                                badgeContent: Text(
                                  'Editar Cadeira',
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
                                badgeColor: Colors.green[600],
                                badgeContent: Text(
                                  '${  snapshot.value.toString()  }',
                                  style: TextStyle(
                                    color: Colors.white,
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
                        color: Colors.white,
                          onPressed: () { Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Cadeira()),
                        ); },
                      ),
                    ],
                  ),
                ],
              ),
            ), 
          ),
          
      ];
    }  

    return new Scaffold(
      appBar: new AppBar(
        actions: <Widget>[
          new FlatButton(
              child: new Text('Kaique Cortes', style: new TextStyle(fontSize: 17.0, color: Colors.white))
          ),
        ],
      ),
      
      drawer: Drawer(
          
          child:  ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.symmetric(),
            
            children: <Widget>[
              DrawerHeader(
                child: Text('Kaique Cortes'),
                
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                //image: DecorationImage(
                //image: AssetImage("imagens.dart/Untitled2.png"), fit: BoxFit.cover)
                ),
              ),
      
              ListTile(
                leading: Icon(Icons.equalizer),
                title: Text("Gerenciamento de Tabela de Preços",
                
                ),
                subtitle: Text("Gerenciar preços do salão",
                style: TextStyle(
                  color: Colors.orange,
                ),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, 
                          MaterialPageRoute(builder: (context) => TabelaDePrecos())
              )),
              ListTile(
                leading: Icon(Icons.arrow_back_ios),
                title: Text("Voltar"),
                subtitle: Text("Voltar a pagina principal",
                style: TextStyle(
                  color: Colors.orange,
                ),
                ),
                onTap: () => Navigator.pop(context, false),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text("Sair"),
                subtitle: Text("Sair da conta",
                style: TextStyle(
                  color: Colors.orange,
                ),
                ),
                //trailing: Icon(Icons.backspace),
                onTap: () =>  _signOut(),
              ),

            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            
            /*
            children: <Widget>[
             Text("teste@teste.com",
             style: TextStyle(
             color: Colors.white,

             ), 
             ),
              IconButton(icon: Icon(Icons.account_circle,
                color: Colors.white,
              ), onPressed: () {},),
              
            ],*/
          ),
        ),
      body: new Container(
        
        color: Colors.white,
        child: new ListView(
          children: <Widget>[
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
                          children: corpo(),
                        ),
                        ),
                      ),
                      new Container(
                        padding: const EdgeInsets.all(16.0),
                          child: new Form(
                              //key: formKey,
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: terceiroCard(),
                                
                              ),
                          
                          ),
                          
                      ),                      
                      
                    ])
              ),
                  //hintText()
                ]
        ),
          ],

        ),


      ),
            //hintText()
          
    );
      
  }
}