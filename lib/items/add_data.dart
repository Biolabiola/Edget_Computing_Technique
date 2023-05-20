import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:edge_cloud_computing/items/bucket_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../resources/app_color.dart';

class AddData extends StatefulWidget {
  const AddData({Key? key}) : super(key: key);

  @override
  State<AddData> createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {

  TextEditingController _controllerName = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();

  bool _autoValidate = false;

  late CollectionReference imageRef;
  late firebase_storage.Reference ref;
  double value  = 0;
  bool _isLoading=false; //bool variable created
  List<File>  _image = [];
  late int counter = 0;

  final picker = ImagePicker();
  String imageUrl ='';

  final List<Map> myProducts =
  List.generate(100000, (index) => {"id": index, "name": "Product $index"})
      .toList();


  @override
  void initState() {
    super.initState();
    imageRef = FirebaseFirestore.instance.collection("imageUrls");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColor.cardColor,
        title: Text("Abiola Edge Computing Demo",style: TextStyle(color: Colors.white),),),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.0, 50.0, 8.0, 8.0),
          child: Form(
              autovalidateMode: AutovalidateMode.always,
              key: key,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Material(
                    color: AppColor.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: TextFormField(
                        validator: (value) {
                          if(value!.isEmpty) {
                            return 'Data Description must be more than 0 character';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) {
                          _controllerName.text = val.toString();
                        },

                        onTap: () {

                        },

                      style: TextStyle(color: Colors.grey),
                      decoration: InputDecoration.collapsed(
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: "Please add Data name"),

                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Material(
                    color: AppColor.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text("Image Length $counter", style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ),

                SizedBox(
                  height: 130,
                  child: Stack(
                    children:[GridView.builder(
                      scrollDirection: Axis.horizontal,
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 2 / 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20),
                        itemCount: _image.length +1,
                        itemBuilder: (BuildContext ctx, index) {
                          return index == 0 ? Center(child: IconButton(
                            onPressed: (){
                            setState(() {
                              !_isLoading ? chooseImage() : null;
                              chooseImage();
                              counter = _image.length;
                            });

                          },  icon: Icon(Icons.add, color: Colors.white,),
                         ),):
                          Container(
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              image: DecorationImage(image: FileImage(_image[index -1]), fit: BoxFit.cover),
                            ),

                          );
                        }),

                 ]),

                ),
                SizedBox(height: 30,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: ()async{
                      if(_image.isEmpty || _image.length == 0 && _controllerName.text.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("Please Add  atleast 1 Images")));
                      }else{
                        if(key.currentState!.validate()){
                          _isLoading = true;
                          key.currentState!.save();
                          _isLoading ? Center(child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(child: Container(child: Text('Offloading job..............', style: TextStyle(fontSize: 20, color: Colors.white),),)),
                              SizedBox(height: 10,),
                              CircularProgressIndicator(
                                value: value,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              )

                            ],),): Container();
                          uploadFile().whenComplete((){
                            setState(() {
                              _isLoading = false;
                              _image.clear();
                              _isLoading ? Center(child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Center(child: Container(child: Text('Offloading job..............', style: TextStyle(fontSize: 20, color: Colors.white),),)),
                                  SizedBox(height: 10,),
                                  CircularProgressIndicator(
                                    value: value,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  )

                                ],),): Container(child: Text("offloading completed for job.......", style: TextStyle(color: Colors.white, fontSize: 20),),);
                            });
                            Timer(Duration(seconds: 5), () {
                              print("Yeah, this line is printed after 3 seconds");
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CloudBucketList()));
                            });

                          });

                        }else{
                          setState(() {
                            _autoValidate = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("Add required Task Name")));
                        }
                      }

                    }, child: Text('Offload Task', style: TextStyle(fontSize: 20),)),

                    ElevatedButton(onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => CloudBucketList()));
                    }, child: Text('View Bucket', style: TextStyle(fontSize: 20),)),
                  ],
                ),
                SizedBox(height: 30,),
                _isLoading ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(child: Container(child: Text('Offloading job..............', style: TextStyle(fontSize: 20, color: Colors.white),),)),
                    SizedBox(height: 10,),
                    CircularProgressIndicator(
                      value: value,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    )

                  ],),): Container(child: Text("waiting for job.......", style: TextStyle(color: Colors.white, fontSize: 20),),),
                const SizedBox(height: 20,),


                // Container(
                //   padding: const EdgeInsets.all(50),
                //   margin:const EdgeInsets.all(50) ,
                //   color: AppColor.scaffoldBackground,
                //   //widget shown according to the state
                //   child: Center(
                //     child: !_isLoading ? Text("Task OffLoading Completed\n in   seconds", style: TextStyle(color: Colors.white),) :const CircularProgressIndicator(),
                //   ),
                // )
              ],)),
        ),
      ),
    );
  }

  chooseImage()async{
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickedFile!.path));
      counter = _image.length;
      print("Image Length = $counter");
    });

    if(pickedFile!.path == null) retrieveLostData();

  }
  Future<void> retrieveLostData()async{
    final LostData response = await picker.getLostData();
        if(response.isEmpty){
          return;
    }
        if(response.file != null){
         setState(() {
           _image.add(File(response.file!.path));
         });

        }else{
          print(response.file);
    }

  }
  Future uploadFile()async{
    int i  = 1;
    //final Stopwatch stopwatch = Stopwatch()..start();
    final stopwatch = Stopwatch();
    print(" Start Time ${stopwatch.elapsedMilliseconds}"); // 0
    print(stopwatch.isRunning); // false
    stopwatch.start();
    print(" Start Time 2 ${stopwatch.elapsedMilliseconds}"); // 0
    print(stopwatch.isRunning); // true

    for(var img in _image){
      setState(() {
       value =  i /_image.length;
      });
      ref = firebase_storage.FirebaseStorage.instance.ref().child('images/${path.basename(img.path)}');

      await ref.putFile(img).whenComplete(()async{
        setState(() {
          _image.clear();
        });
        if(stopwatch.elapsedMilliseconds < 4000){
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Dynamic Offloading  to Cloud Storage @ ${stopwatch.elapsedMilliseconds} Milliseconds")));
        }else if(stopwatch.elapsedMilliseconds <= 4000){
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Hybrid Offloading to Cloud Storage @ ${stopwatch.elapsedMilliseconds} Milliseconds")));
        }else if(stopwatch.elapsedMilliseconds >= 10000) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("static Offloading to Cloud Storage @ ${stopwatch.elapsedMilliseconds} Milliseconds")));
        }
        print("Time Taking to Offload Image to Storage ${stopwatch.elapsedMilliseconds}");
        //ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Image ${path.basename(img.path)} Saved to Cloud Storage in ${stopwatch.elapsedMilliseconds} Seconds")));
        await ref.getDownloadURL().then((value) async {
          stopwatch.stop();
          final int durationInMilliseconds = stopwatch.elapsedMilliseconds;

          //create a map of data
          Map<String, dynamic> dataToSend = {
            'name': _controllerName.text.toString(),
            'timestamp': FieldValue.serverTimestamp(),
            'duration': durationInMilliseconds,
            'imageUrl': value
          };
          if (kDebugMode) {
            print("Time Taking to Offload Task $durationInMilliseconds");
            print("Image Url  $value");
            print("timestamp  ${FieldValue.serverTimestamp().toString()}");
            print("duration  $durationInMilliseconds");
          }
          stopwatch.start();
          imageRef.add(dataToSend).whenComplete(()async{
            setState(() {
              _image.clear();
            });
            if(stopwatch.elapsedMilliseconds < 4000){
              ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Dynamic Offloading to Cloud Firebase @ ${stopwatch.elapsedMilliseconds} Milliseconds")));
            }else if(stopwatch.elapsedMilliseconds <= 4000){
              ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Hybrid Offloading to Cloud Firebase @ ${stopwatch.elapsedMilliseconds} Milliseconds")));
            }else if(stopwatch.elapsedMilliseconds >= 10000) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("static Offloading to Cloud Firebase @ ${stopwatch.elapsedMilliseconds} Milliseconds")));
            }
            // Do some work.
            if (kDebugMode) {
              print("Task Took 2 ${stopwatch.elapsedMilliseconds} Milliseconds" );
            } // Likely > 0.

           // ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Image ${path.basename(img.path)} Saved to Cloud Database in ${stopwatch.elapsedMilliseconds} Seconds")));
            stopwatch.stop();

            print(stopwatch.isRunning); // false
            Duration elapsed = stopwatch.elapsed;
            await Future.delayed(const Duration(seconds: 1));
            assert(stopwatch.elapsed == elapsed); // No measured time elapsed.
            //stopwatch.start(); // Continue measuring.

          });

          i++;
         // ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Images ${path.basename(img.path)} Saved to Cloud Database in $durationInMilliseconds Seconds")));

        });

      });
      counter = 0;
      _image.remove(img);
      _image.clear();
      //_controllerName.dispose();
    }
  }
}
