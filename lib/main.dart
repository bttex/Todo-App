import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async { 
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.red.shade800,
    appBarTheme: AppBarTheme(color: Colors.red.shade800,
    centerTitle: true )
  ),
  home: MyApp(),
),
 
);

}
class MyApp extends StatefulWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String input = "";

  createTodos(){
    DocumentReference documentReference = FirebaseFirestore.instance.collection("MeuTodoList").doc(input);

Map<String, String>todos = {"todoTitle": input};

documentReference.set(todos).whenComplete((){
  print("$input criado");
});

  }
  
  deleteTodos(item){
 DocumentReference documentReference = FirebaseFirestore.instance.collection("MeuTodoList").doc(item);


documentReference.delete().whenComplete((){
  print("$item deletado");
  });
  }

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("To-Do"),
      actions: [
        IconButton(onPressed: ( ) {
            showDialog(context: context,
            builder: (BuildContext context){
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                title: Text("Adicionar Tarefa"),
                content: TextField(
                  onChanged: (String value){
                    input = value;
                  },
                  
                ),
                actions: [
                  ElevatedButton(onPressed: (){
                    createTodos();
                    Navigator.of(context).pop();
                  }, child: Text("Adicionar"))
                ],
              );
            }
            

         );}, icon: Icon(CupertinoIcons.add_circled))
      ],
      ),
      body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("MeuTodoList").snapshots(),builder: (context, snapshots){
        if (!snapshots.hasData) return Center(child: CircularProgressIndicator());
        return ListView.builder(
        shrinkWrap: true,
        itemCount:snapshots.data!.docs.length,
        itemBuilder:(context, index){
          DocumentSnapshot documentSnapshot = snapshots.data!.docs[index];
          return Dismissible(key: Key(index.toString()) ,child: Card(
            elevation: 4,
            margin: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)) ,
            child: 
            ListTile(
              title:Text(documentSnapshot["todoTitle"]),
              trailing: IconButton(icon: Icon(CupertinoIcons.delete, color: Colors.red),
              onPressed: () {
                deleteTodos(documentSnapshot["todoTitle"]);

              }),
            ),
          ));
        } );
      }
    )
    );
  }
}