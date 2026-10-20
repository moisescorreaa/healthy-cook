import 'package:flutter/material.dart';
import 'package:healthy_cook/components/feedback.dart';
import 'package:healthy_cook/components/validators.dart';
import 'package:healthy_cook/data/api_exception.dart';
import 'package:healthy_cook/data/auth_controller.dart';
import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  late String username;
  late String email;
  late String password;

  bool _showPassword = false;
  bool _agreeToTerms = false;
  bool _loading = false;

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira um nome de usuário';
    }
    if (value.trim().length < 2) {
      return 'O nome deve ter pelo menos 2 caracteres';
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

  void _showWelcomeDialog(String email) {
    showDialog(
        context: context,
        barrierDismissible: false,
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
                        '\nEstamos animados para acompanhar você nessa jornada culinária!!!\n\nEnviamos um email para $email com um link de confirmação!',
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
                          onPressed: () => Navigator.of(context)
                              .pushNamedAndRemoveUntil('/home', (_) => false),
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
  }

  Future<void> _register() async {
    if (_loading) return;
    if (!_agreeToTerms) {
      showErrorSnackBar(context, 'Aceite os termos de uso para cadastrar-se.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);
    try {
      await context.read<AuthController>().register(
            name: username.trim(),
            email: email.trim(),
            password: password,
          );
      if (!mounted) return;
      _showWelcomeDialog(email.trim());
    } on ApiException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(
        context,
        e.code == 'email_in_use'
            ? 'O endereço de e-mail já está em uso.'
            : e.userMessage,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
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
              validator: validateEmail,
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
              validator: validateNewPassword,
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
              onPressed: _loading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3FA63C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Cadastrar",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
