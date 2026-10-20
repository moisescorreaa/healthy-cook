import 'dart:developer';

/// Envio de e-mails transacionais.
abstract class Mailer {
  Future<void> send({
    required String to,
    required String subject,
    required String body,
  });
}

/// Implementação de desenvolvimento: escreve o e-mail no console.
/// Troque por uma implementação SMTP para produção.
class ConsoleMailer implements Mailer {
  const ConsoleMailer();

  @override
  Future<void> send({
    required String to,
    required String subject,
    required String body,
  }) async {
    final message =
        '\n===== E-MAIL =====\nPara: $to\nAssunto: $subject\n\n'
        '$body\n==================\n';
    log(message, name: 'mailer');
    // ignore: avoid_print
    print(message);
  }
}
