import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotted_ufersa/models/campus.dart';
import 'package:spotted_ufersa/screens/chat_screen.dart';
import 'package:spotted_ufersa/utils/colors.dart';
import 'package:spotted_ufersa/utils/global_variable.dart';
import 'package:spotted_ufersa/widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Campus> listaCampus = [];
  bool isSelected = false;
  Campus? selectedCampus =
      Campus(name: "Mossoró", campusId: "ijLYXMuEvj4OhF5sUZlG");
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: backgroundColor,
              actions: [
                SizedBox(
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.filter_alt_outlined,
                            color: primaryColor,
                          ),
                          onPressed: () {
                            filterWidget(context);
                          },
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/ic_instagram.svg',
                        color: primaryColor,
                        height: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.messenger_outline,
                            color: primaryColor,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
      body: StreamBuilder(
        stream: (isSelected && selectedCampus!.campusId != "")
            ? FirebaseFirestore.instance
                .collection('posts')
                .orderBy("datePublished", descending: true)
                .where('campus', isEqualTo: selectedCampus!.name)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('posts')
                .orderBy("datePublished", descending: true)
                .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (ctx, index) => PostCard(
                snap: snapshot.data!.docs[index].data(),
              ),
            );
          }
        },
      ),
    );
  }

  filterWidget(BuildContext context) {
    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) {
        return Dialog(
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection("campus")
                .orderBy('name')
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Erro ao carregar dados');
              } else {
                List<DropdownMenuItem<Campus>> items = [];
                items.add(
                  DropdownMenuItem(
                    value: Campus(name: "Todos", campusId: ""),
                    child: Text("Todos"),
                  ),
                );
                for (var document in snapshot.data!.docs) {
                  Campus camp = new Campus(name: "name", campusId: "campusId");
                  camp.campusId = document.id;
                  camp.name =
                      (document.data()! as Map<String, dynamic>)['name'];
                  listaCampus.add(camp);
                  items.add(DropdownMenuItem(
                    value: camp,
                    child: Text(camp.name),
                  ));
                }
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: Center(
                    child: DropdownButton<Campus>(
                      value: items[0].value,
                      onChanged: (value) {
                        setState(() {
                          selectedCampus = value;
                          isSelected = true;
                        });
                        Navigator.of(context).pop();
                      },
                      items: items,
                      hint: Text('Selecione um campus'),
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
