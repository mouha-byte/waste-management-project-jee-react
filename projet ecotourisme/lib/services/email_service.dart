import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // TODO: Replace with your actual SMTP credentials
  // For Gmail, generate an App Password: https://myaccount.google.com/apppasswords
  // Do NOT use your real login password!
  static const String _username = 'mouhanedmliki6@gmail.com';
  static const String _password = 'nhxc ymgu fkrk lcmc'; 
  
  static Future<bool> sendWelcomeEmail(String recipientEmail, String appCodeKey) async {
    // If credentials are not set, just print to console (simulation)
    if (_username.contains('your-email') || _password.contains('your-app')) {
      print('==================================================');
      print('SIMULATION EMAIL SENDING (Credentials not set)');
      print('To: $recipientEmail');
      print('Subject: Bienvenue sur EcoGuide !');
      print('Code Key: $appCodeKey');
      print('==================================================');
      return true;
    }

    final smtpServer = gmail(_username, _password);
    
    // Create the message
    final message = Message()
      ..from = Address(_username, 'EcoGuide Team')
      ..recipients.add(recipientEmail)
      ..subject = 'Bienvenue sur EcoGuide ! 🌿'
      ..html = '''
        <h1>Bienvenue sur EcoGuide !</h1>
        <p>Merci de vous être inscrit sur notre plateforme d'écotourisme.</p>
        <p>Voici votre clé d'application personelle :</p>
        <div style="background-color: #f0fdf4; padding: 20px; border-radius: 10px; border: 1px solid #16a34a; text-align: center; margin: 20px 0;">
          <h2 style="color: #166534; font-family: monospace; letter-spacing: 2px;">$appCodeKey</h2>
        </div>
        <p>Conservez ce code précieusement.</p>
        <p>À bientôt,<br>L'équipe EcoGuide</p>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      return true;
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }
}
