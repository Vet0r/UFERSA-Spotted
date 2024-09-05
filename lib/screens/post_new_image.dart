import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotted_ufersa/providers/user_provider.dart';
import 'package:spotted_ufersa/resources/firestore_methods.dart';
import 'package:spotted_ufersa/utils/colors.dart';
import 'package:spotted_ufersa/utils/utils.dart';

class PostNewImage extends StatefulWidget {
  PostNewImage(
      {Key? key, required this.file, required this.descriptionController})
      : super(key: key);
  Uint8List? file;
  TextEditingController descriptionController;

  @override
  State<PostNewImage> createState() => _PostNewImageState();
}

class _PostNewImageState extends State<PostNewImage> {
  bool isLoading = false;
  late Future<QuerySnapshot> campusData;
  String? selectedCampus;
  late String campusId;

  void initState() {
    super.initState();
    campusData =
        FirebaseFirestore.instance.collection("campus").orderBy('name').get();
  }

  void clearImage() {
    setState(() {
      widget.file = null;
    });
  }

  void postImage(
      String uid, String username, String campusId, String campus) async {
    setState(() {
      isLoading = true;
    });
    try {
      String res = await FireStoreMethods().uploadPost(
        widget.descriptionController.text,
        widget.file!,
        uid,
        username,
        campusId,
        campus,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
          context,
          'Posted!',
        );
        clearImage();
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        title: const Text(
          'Nova Publicação',
        ),
        centerTitle: false,
        actions: <Widget>[
          TextButton(
            onPressed: () => postImage(
              userProvider.getUser.uid,
              userProvider.getUser.username,
              campusId,
              selectedCampus!,
            ),
            child: const Text(
              "Post",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
          )
        ],
      ),
      // POST FORM
      body: Column(
        children: <Widget>[
          isLoading
              ? const LinearProgressIndicator()
              : const Padding(padding: EdgeInsets.only(top: 0.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.width * .75,
                width: MediaQuery.of(context).size.width * .75,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.contain,
                    alignment: FractionalOffset.topCenter,
                    image: MemoryImage(widget.file!),
                  )),
                ),
              ),
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: TextField(
              controller: widget.descriptionController,
              decoration: const InputDecoration(
                  hintText: "Escreva Algo...", border: InputBorder.none),
              maxLines: 8,
            ),
          ),
          FutureBuilder<QuerySnapshot>(
            future: campusData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erro ao carregar dados');
              } else {
                List<DropdownMenuItem<String>> items = [];
                snapshot.data!.docs.forEach((document) {
                  campusId = document.id;
                  String campusNome =
                      (document.data()! as Map<String, dynamic>)['name'];
                  items.add(DropdownMenuItem(
                    value: campusNome,
                    child: Text(campusNome),
                  ));
                });
                return Column(
                  children: [
                    DropdownButton<String>(
                      value: selectedCampus,
                      onChanged: (value) {
                        setState(() {
                          selectedCampus = value;
                        });
                      },
                      items: items,
                      hint: Text('Selecione um campus'),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
