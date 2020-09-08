import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

void main()=>runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green[500]
      ),
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController taskTitleInputController=new TextEditingController();
  TextEditingController taskDescripInputController=new TextEditingController();

@override
initState() {
  taskTitleInputController = new TextEditingController();
  taskDescripInputController = new TextEditingController();
  super.initState();
}

_showDialog() async {
  await showDialog<String>(
    context: context,
    child: AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: Column(
        children: <Widget>[
          Text("Please fill all fields to create a new task"),
          Expanded(
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(labelText: 'Task Title*'),
              controller: taskTitleInputController,
            ),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(labelText: 'Task Description*'),
              controller: taskDescripInputController,
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            taskTitleInputController.clear();
            taskDescripInputController.clear();
            Navigator.pop(context);
          }),
        FlatButton(
          child: Text('Add'),
          onPressed: () {
            if (taskDescripInputController.text.isNotEmpty &&
                taskTitleInputController.text.isNotEmpty) {
              Firestore.instance
                .collection('todos')
                .add({
                  "title": taskTitleInputController.text,
                  "description": taskDescripInputController.text
              })
              .then((result) => {
                Navigator.pop(context),
                taskTitleInputController.clear(),
                taskDescripInputController.clear(),
              })
              .catchError((err) => print(err));
          }
        })
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("To Do List",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),),
      ),
      drawer: new Drawer(),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.green[500],
        child: new Icon(Icons.add,size: 30,color: Colors.white,),
        onPressed: ()=>_showDialog(),
      ),
      body: new StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("todos").snapshots(),
          builder : (context , snapshot){
            if (!snapshot.hasData) return new Center(child : new CircularProgressIndicator());

            return new Container(
              padding: const EdgeInsets.all(20),
              child: new ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder:(context , index)=>
                new Column(
                  children: [
                    new Card(
                      elevation: 15,
                      child: new ListTile(
                        title : new Text(snapshot.data.documents[index]["title"],style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.bold),),
                        subtitle:new Text(snapshot.data.documents[index]["description"],style: TextStyle(fontSize: 20,color: Colors.grey[600],fontWeight: FontWeight.bold),),
                        trailing: new IconButton(
                            icon: new Icon(Icons.delete,size: 30,color: Colors.red[800],),
                            onPressed: (){
                              snapshot.data.documents[index].reference.delete();
                            },
                        ),
                      ),
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 10)),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
}

