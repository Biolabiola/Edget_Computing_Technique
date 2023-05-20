import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edge_cloud_computing/resources/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class CloudBucketList extends StatefulWidget {

   // CloudBucketList({Key? key}) : super(key: key){
   //   _stream = _reference.snapshots();
   // }
  @override
  State<CloudBucketList> createState() => _CloudBucketListState();
}

class _CloudBucketListState extends State<CloudBucketList> {
  CollectionReference _reference = FirebaseFirestore.instance.collection("imageUrls");
  late Stream<QuerySnapshot> _stream;

  int totalImage = 0;

  @override
  void initState() {
    super.initState();
    _stream = _reference.snapshots();
    _stream.listen((QuerySnapshot querySnapshot) {
      setState(() {
        totalImage = querySnapshot.docs.length;
      });
    });
    getCount(totalImage);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColor.cardColor,
        title: Text('Abiola Cloud Bucket List', style:  TextStyle(color: Colors.white),),),
      body: Column(
        children: [
          Row(
           // crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 30,
                margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white
                ),
                padding: EdgeInsets.all(3),
                  child: Text('Total Image in Bucket $totalImage', style: TextStyle(color: Colors.orange, fontSize: 20),)),
            ],
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _stream,
                builder: (BuildContext context, AsyncSnapshot snapshot){

                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }

                //check if there's any error
                if(snapshot.hasError){
                  return Center(child: Text("some error occurred ${snapshot.error.toString()}"),);

                }
                // check if there's data available to pull
                if(snapshot.hasData){

                  //get the Data
                  QuerySnapshot querySnapshot = snapshot.data;
                  List<QueryDocumentSnapshot> documents  = querySnapshot.docs;
                  //Convert the documents to Map
                  List<Map> items = documents.map((e) => e.data() as Map).toList();

                 getCount(items.length);

                  // Display the List
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                    child: ListView.builder(
                      itemCount: items.length,
                        itemBuilder: (context, int index){

                        //get the item at this index
                          Map thisItem = items[index];

                          // FirestoreListView(
                          //     loadingBuilder: (_) => CircularProgressIndicator(),
                          //     query: FirebaseFirestore.instance.collection("imageUrls").orderBy("timestamp", descending: true),
                          //     itemBuilder: (context, snapshot){
                          //       Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
                          //       Timestamp t = data['timestamp'] as Timestamp;
                          //       DateTime date = t.toDate();
                          //       print("Date   $date");
                          //       return Container();
                          //     });

                          //Timestamp t = thisItem['timestamp'];
                          // Timestamp t = thisItem['timestamp'] as Timestamp;
                          // DateTime date = t.toDate();

                          // print("Printing  date====================${date.toString()}"); //2019-12-28 18:48:48.364
                          // print("Printing date in seconds ++++++++++++++${date.second}"); //2019-12-28 18:48:48.364

                          print("Printing ids of all Items  ${_reference.id}");
                          //return the widget for the list items
                          return Card(
                            color: AppColor.cardColor,
                            child: ListTile(
                              title: Text('${thisItem['name']}', style: const TextStyle(color: Colors.white),),
                              subtitle: Text('offload Time ${thisItem['duration']} Milliseconds', style: TextStyle(color: Colors.orange),),
                              leading: Container(
                                height: 80,
                                  width: 80,
                                  child: thisItem.containsKey('imageUrl')? Image.network('${thisItem['imageUrl']}'): Container()),
                              onTap: () {
                                print("Printing ids of all Items in On Tap ${_reference.id}");
                               // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ItemDetails(id: thisItem['id'],)));
                              },
                            ),
                          );
                        }),
                  );
                }
                return Container();

            }),
          ),

        ],
      ),
    );
  }
  Future<void> getCount(int total)async{
    setState(() {
      totalImage = total;
    });
  }
}
