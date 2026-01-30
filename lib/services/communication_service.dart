import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';

class CommunicationService {
  // Make a phone call
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      throw Exception('Could not launch phone call: $e');
    }
  }

  // Send SMS
  Future<void> sendSMS(String phoneNumber, String message) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      throw Exception('Could not send SMS: $e');
    }
  }

  // Send WhatsApp message
  Future<void> sendWhatsApp(String phoneNumber, String message) async {
    final Uri whatsappUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: '/$phoneNumber',
      queryParameters: {'text': message},
    );
    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      throw Exception('Could not launch WhatsApp: $e');
    }
  }

  // Generate auto message with student details
  String generateStudentMessage({
    required Student student,
    required String className,
    required String academicYear,
  }) {
    return '''
Hello,

This is a message regarding:
Student Name: ${student.studentName}
Roll Number: ${student.rollNumber}
Class: $className
Academic Year: $academicYear
Behavior Status: ${student.behaviorColor.label}

Please contact for further details.

Regards,
HOD - Electrical Engineering Department
''';
  }

  // Generate auto message for guardian
  String generateGuardianMessage({
    required Student student,
    required String className,
    required String academicYear,
  }) {
    return '''
Dear Guardian,

This is a message regarding your ward:
Student Name: ${student.studentName}
Roll Number: ${student.rollNumber}
Class: $className
Academic Year: $academicYear
Behavior Status: ${student.behaviorColor.label}

Please contact the department for more information.

Regards,
HOD - Electrical Engineering Department
''';
  }

  // Get formatted phone number (remove spaces and special characters)
  String formatPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  }

  // Check if phone number is valid
  bool isValidPhoneNumber(String phoneNumber) {
    final formatted = formatPhoneNumber(phoneNumber);
    return formatted.length >= 10;
  }
}
