import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:spotted_ufersa/providers/user_provider.dart';
import 'package:spotted_ufersa/resources/firestore_methods.dart';
import 'package:spotted_ufersa/resources/storage_methods.dart';
import 'package:spotted_ufersa/utils/colors.dart';
import 'package:spotted_ufersa/utils/utils.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  late Future<QuerySnapshot> campusData;
  String? selectedCampus;
  late String campusId;
  bool isLoading = false;
  String? photoUrl;
  bool unsafeTag = false;
  final TextEditingController _descriptionController = TextEditingController();

  void initState() {
    super.initState();
    campusData =
        FirebaseFirestore.instance.collection("campus").orderBy('name').get();
  }

  void verifyImageSafty(
      String uid, String username, String campusId, String campus) async {
    bool isSafe = false;

    const String apiUrl = 'https://api.openai.com/v1/chat/completions';
    var snaps = await FirebaseFirestore.instance
        .collection('vars')
        .doc('api_keys')
        .get();
    String apiKey = snaps.data()!['api_key'];
    '';
    setState(() {
      isLoading = true;
    });
    photoUrl =
        await StorageMethods().uploadImageToStorage('posts', _file!, true);

    final Map<String, dynamic> requestBody = {
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text":
                  "Esta imagem ou o texto a seguir representa algo impróprio ou imoral? '${_descriptionController.text} .' responda somente 'true' ou 'false' "
            },
            {
              "type": "image_url",
              "image_url": {"url": "$photoUrl"}
            }
          ]
        }
      ],
      "max_tokens": 300
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      print('Response: ${response.body}');
      final Map decode = json.decode(response.body);
      if (((decode['choices'][0]['message']['content']) as String)
              .toLowerCase() !=
          'true') {
        isSafe = true;
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }

    setState(() {
      isLoading = false;
    });

    if (isSafe == true) {
      unsafeTag = false;
      postImage(uid, username, campusId, campus);
    } else {
      unsafeTag = true;
    }
  }

  void postImage(
      String uid, String username, String campusId, String campus) async {
    setState(() {
      isLoading = true;
    });
    try {
      String res = await FireStoreMethods().uploadPost(
          _descriptionController.text,
          _file!,
          uid,
          username,
          campusId,
          campus,
          photoUrl!);
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

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return _file == null
        ? Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              toolbarHeight: 0,
            ),
            body: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Uint8List file = await pickImage(ImageSource.gallery);
                      setState(
                        () {
                          _file = file;
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.photo_library_sharp),
                            ),
                            const Text('Escolher da Galeria'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Uint8List file = await pickImage(ImageSource.camera);
                      setState(
                        () {
                          _file = file;
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradient,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.camera_alt_outlined),
                            ),
                            Text('Tirar Foto'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 75,
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: backgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: clearImage,
              ),
              title: const Text(
                'Postar',
              ),
              centerTitle: false,
              actions: <Widget>[
                TextButton(
                  onPressed: () => verifyImageSafty(
                    userProvider.getUser.uid,
                    userProvider.getUser.username,
                    campusId,
                    selectedCampus!,
                  ),
                  child: const Text(
                    "Enviar",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                )
              ],
            ),
            body: Column(
              children: <Widget>[
                isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(padding: EdgeInsets.only(top: 0.0)),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        fit: BoxFit.contain,
                        alignment: FractionalOffset.center,
                        image: MemoryImage(_file!),
                      )),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                            hintText: "Escreva Algo...",
                            border: InputBorder.none),
                        maxLines: 2,
                        maxLength: 120,
                      ),
                      unsafeTag
                          ? Text(
                              'Conteúdo sensível detectado',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            )
                          : Container(),
                      FutureBuilder<QuerySnapshot>(
                        future: campusData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Erro ao carregar dados');
                          } else {
                            List<DropdownMenuItem<String>> items = [];
                            snapshot.data!.docs.forEach((document) {
                              campusId = document.id;
                              String campusNome = (document.data()!
                                  as Map<String, dynamic>)['name'];
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
                ),
              ],
            ),
          );
  }
}
