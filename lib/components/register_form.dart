import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  FirebaseAuth auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  late String username;
  late String email;
  late String password;
  late String? termsMessage;

  bool _showPassword = false;
  bool _agreeToTerms = false;

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um nome de usuário';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value!.isEmpty) {
      return 'Por favor, insira um email';
    } else if (!regExp.hasMatch(value)) {
      return 'Por favor, insira um email válido.';
    } else {
      return null;
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma senha';
    } else if (value.length < 6) {
      return 'Por favor, insira uma senha mais forte';
    }
    return null;
  }

  void _popUpTerms(context) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                    'Bem-vindo ao nosso aplicativo!\nAntes de começar a usar nosso serviço, leia atentamente estes termos de uso que regem o uso do nosso aplicativo e quaisquer outros serviços que possamos oferecer (o "Serviço"). \nAo usar o nosso Serviço, você concorda com estes Termos. Se você não concordar com estes Termos, não use nosso Serviço.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1C4036),
                    )),
                const Text(
                    '\nColeta de dados\n\nNós coletamos informações pessoais do usuário para fornecer o Serviço e melhorar sua experiência no aplicativo. As informações que coletamos podem incluir seu nome, endereço de e-mail, informações de perfil e outras informações que você fornecer.\n\nO uso das informações coletadas é regido pela nossa Política de Privacidade, que você deve ler cuidadosamente antes de utilizar nosso serviço. Nós nos comprometemos a manter suas informações pessoais seguras e protegidas, em conformidade com as normas da Lei Geral de Proteção de Dados (LGPD).\n\nUso do Serviço\n\nO nosso serviço é fornecido "como está" e não fazemos garantias expressas ou implícitas quanto à sua disponibilidade, adequação a um determinado propósito, segurança ou confiabilidade. Você é responsável por garantir que o uso do Serviço esteja em conformidade com as leis e regulamentos aplicáveis.\n\nO nosso Serviço pode permitir que você envie conteúdo, como mensagens, fotos e outros materiais. Ao enviar conteúdo, você garante que tem o direito de fazê-lo e concede a nós uma licença não exclusiva, mundial, livre de royalties, sublicenciável e transferível para usar, reproduzir, distribuir, preparar obras derivadas e exibir publicamente o conteúdo em conexão com o nosso Serviço.\n\nRestrições de Uso\n\nVocê concorda em não utilizar o nosso Serviço para qualquer finalidade ilegal ou não autorizada, incluindo, mas não se limitando a, a violação de direitos autorais e de propriedade intelectual.\n\nLinks para outros sites\n\nO nosso Serviço pode conter links para sites de terceiros. Não somos responsáveis pelo conteúdo ou práticas de privacidade desses sites. Sugerimos que você leia os termos de uso e a política de privacidade desses sites antes de utilizá-los.\n\nAlterações aos Termos de Uso\n\nPodemos atualizar estes Termos de tempos em tempos. É sua responsabilidade revisar estes Termos periodicamente para verificar se houve alterações. Seu uso continuado do Serviço após a publicação de quaisquer alterações a estes Termos significa que você aceita e concorda com as alterações.\n\nRescisão\n\nPodemos rescindir ou suspender o seu acesso ao Serviço imediatamente, sem aviso prévio ou responsabilidade, por qualquer motivo, incluindo, mas não se limitando a, a violação destes Termos.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1C4036),
                    )),
                Container(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: Color(0xFF1C4036)),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3FA63C)),
                      onPressed: () {
                        setState(() => _agreeToTerms = true);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Concordar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  void showAlertTerms(String? termsMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(termsMessage!),
      ),
    );
  }

  void showAlert(value, String? errorAnswer) {
    if (value == true) {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Cheque seu email!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1C4036))),
                      Text(
                          '\nEstamos animados para acompanhar você nessa jornada culinária!!!\n\nEnviamos um email para ${auth.currentUser?.email} com um link de confirmação!',
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF1C4036))),
                      Container(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3FA63C)),
                            onPressed: () =>
                                Navigator.of(context).popAndPushNamed('/login'),
                            child: const Text(
                              "OK",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
      _confirmEmail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(errorAnswer!),
        ),
      );
    }
  }

  void _confirmEmail() async {
    try {
      await auth.currentUser!.sendEmailVerification();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Falha ao enviar a verificação de email'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _saveUserData() {
    try {
      auth.currentUser?.updateDisplayName(username);
      auth.currentUser?.updatePhotoURL(
          'https://firebasestorage.googleapis.com/v0/b/healthy-cook-79dd3.appspot.com/o/defaultImages%2Fuser.png?alt=media&token=622520e8-d262-4253-8682-565fb9b8228b');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  _register(BuildContext context) async {
    if (_agreeToTerms == true) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        try {
          await auth.createUserWithEmailAndPassword(
              email: email, password: password);
          showAlert(true, null);
          _saveUserData();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            showAlert(false, 'A senha é muito fraca.');
          } else if (e.code == 'email-already-in-use') {
            showAlert(false, 'O endereço de e-mail já está em uso.');
          } else {
            showAlert(false, 'Ocorreu um erro ao cadastrar o usuário');
          }
        } catch (e) {
          showAlert(false, 'Ocorreu um erro desconhecido');
          if (kDebugMode) {
            print(e);
          }
        }
      }
    } else {
      showAlertTerms('Aceite os termos de uso para cadastrar-se.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Cadastro',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C4036)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            child: TextFormField(
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.person,
                  color: Color(0xFF1C4036),
                ),
                labelText: 'Nome do usuário',
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSaved: (value) => username = value!,
              validator: _validateUsername,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            child: TextFormField(
              keyboardType:
                  TextInputType.emailAddress, // aparece o @ no teclado
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.email,
                  color: Color(0xFF1C4036),
                ),
                labelText: "Email",
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSaved: (value) => email = value!,
              validator: _validateEmail,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            child: TextFormField(
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.key,
                  color: Color(0xFF1C4036),
                ),
                suffixIcon: IconButton(
                  color: const Color(0xFF1C4036),
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
                labelText: "Senha",
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSaved: (value) => password = value!,
              validator: _validatePassword,
              obscureText: !_showPassword,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() => _agreeToTerms = !_agreeToTerms);
                },
              ),
              TextButton(
                onPressed: () => _popUpTerms(context),
                child: const Text(
                  'Termos de uso',
                  style: TextStyle(color: Color(0xFF18592F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: () => _register(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3FA63C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                "Cadastrar",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
