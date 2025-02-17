import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotted_ufersa/resources/auth_methods.dart';
import 'package:spotted_ufersa/responsive/mobile_screen_layout.dart';
import 'package:spotted_ufersa/responsive/responsive_layout.dart';
import 'package:spotted_ufersa/responsive/web_screen_layout.dart';
import 'package:spotted_ufersa/screens/login_screen.dart';
import 'package:spotted_ufersa/utils/colors.dart';
import 'package:spotted_ufersa/utils/utils.dart';
import 'package:spotted_ufersa/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late Future<QuerySnapshot> campusData;
  String? selectedCampus;
  late String campusId;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool isCodeRequired = false;
  bool _isLoading = false;
  String? campus;

  @override
  void initState() {
    super.initState();
    campusData =
        FirebaseFirestore.instance.collection("campus").orderBy('name').get();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  void signUpUser(bool isCodeRequired, {String code = ''}) async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      password2: _password2Controller.text,
      campusId: campusId,
      isCodeRequired: isCodeRequired,
      code: code,
    );
    if (res == "Verifique seu Email!") {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            mobileScreenLayout: LoginScreen(),
            webScreenLayout: LoginScreen(),
          ),
        ),
      );
      showSnackBar(context, res);
      createUserCode();
    } else {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  String generateRandomString() {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        10,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }

  void createUserCode() {
    var docRef = FirebaseFirestore.instance
        .collection('codes')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    docRef.set(
      {
        'code': generateRandomString(),
        'isUsed': false,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Image.asset(
            "assets/background_image.png",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              width: width,
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 2,
                    child: Container(),
                  ),
                  Image.asset(
                    'assets/logo.png',
                    height: MediaQuery.of(context).size.height * 0.10,
                  ),
                  Image.asset(
                    'assets/logo_string.png',
                    width: width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.06,
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFieldInput(
                    hintText: 'Nome',
                    textInputType: TextInputType.text,
                    textEditingController: _usernameController,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFieldInput(
                    hintText: 'Email Institucional',
                    textInputType: TextInputType.emailAddress,
                    textEditingController: _emailController,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFieldInput(
                    hintText: 'Senha',
                    textInputType: TextInputType.text,
                    textEditingController: _passwordController,
                    isPass: true, // adicionar switch de visão de senha
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFieldInput(
                    hintText: 'Confirmar Senha',
                    textInputType: TextInputType.text,
                    textEditingController: _password2Controller,
                    isPass: true,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('vars')
                        .doc('codes')
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      } else {
                        if (((snapshot.data as DocumentSnapshot).data()
                            as Map<String, dynamic>)['isRequireCode']) {
                          isCodeRequired = true;
                          return TextFieldInput(
                            hintText: 'Código',
                            textInputType: TextInputType.text,
                            textEditingController: _codeController,
                          );
                        } else
                          return Container();
                      }
                    },
                  ),
                  const SizedBox(
                    height: 24,
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
                          String campusNome = (document.data()!
                              as Map<String, dynamic>)['name'];
                          items.add(DropdownMenuItem(
                            value: campusNome,
                            child: Text(campusNome),
                          ));
                        });
                        return DropdownButton<String>(
                          value: selectedCampus,
                          onChanged: (value) {
                            setState(() {
                              selectedCampus = value;
                            });
                          },
                          items: items,
                          hint: Text('Selecione um campus'),
                        );
                      }
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  InkWell(
                    onTap: () {
                      signUpUser(isCodeRequired, code: _codeController.text);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(80.0)),
                      ),
                      child: !_isLoading
                          ? const Text(
                              'Cadastrar',
                            )
                          : const CircularProgressIndicator(
                              color: primaryColor,
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          'Já tem uma conta?',
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text(
                            ' Login.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom + 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
