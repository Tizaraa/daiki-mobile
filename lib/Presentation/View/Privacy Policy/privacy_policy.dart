import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue, // Replace with TizaraaColors.Tizara if defined elsewhere
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'Privacy Policy\n\nEffective Date: May 26, 2025\n',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const Text(
              'Thank you for using the STP Maintenance Schedule app. Your privacy is important to us. '
                  'This Privacy Policy outlines how we collect, use, disclose, and protect your information when you use our mobile application and related services. '
                  'By using the app, you agree to the terms outlined in this policy.\n',
            ),

            _sectionTitle('1. Information We Collect'),
            _bulletPoint('Account Information:\n- Login Credentials: Users log in with credentials provided by their organization. Only the password can be changed by the user.'),
            _bulletPoint('App Usage Data:\n- Maintenance Data: Information entered by technicians, such as service reports, water readings, and technical notes.\n- Photos and Media: Technicians may upload photos directly from the device\'s camera or gallery to document on-site conditions.'),
            _bulletPoint('Device Information:\n- Device Name (as assigned by the operating system)\n- IP Address (active IP at the time of data upload)\n- Network connection information (Wi-Fi/mobile data status)'),
            _bulletPoint('Location Data:\n- Approximate and precise location (when location features are used)\n- Location data is only collected when actively using location-dependent features of the app'),
            _bulletPoint('Storage Access:\n- Access to device storage to read and write necessary files, including photos and documents related to maintenance activities'),

            const Text(
              'We do not collect personally identifiable information (PII) such as your name, email address, phone number, or home address unless it is voluntarily provided as part of your organization\'s account setup.\n',
            ),

            _sectionTitle('2. Sensitive Permissions Usage'),

            const Text(
              'CAMERA PERMISSION (android.permission.CAMERA)\n',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const Text(
              'Our app requests camera permission specifically for technician users to perform their maintenance duties:\n',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            _bulletPoint('This app is designed exclusively for technician personnel who perform maintenance on wastewater treatment plant machinery and equipment'),
            _bulletPoint('Technicians use the camera to capture photographs of machinery, equipment, and their operational conditions during maintenance visits'),
            _bulletPoint('All photos taken through the camera are automatically uploaded to our secure servers for maintenance record keeping'),
            _bulletPoint('Camera access is used solely by authorized technician users for documenting equipment status, defects, repairs, and maintenance work'),
            _bulletPoint('Photos are taken only when technicians actively use the camera feature to document specific machinery or equipment'),
            _bulletPoint('We do not access your camera without explicit technician action'),
            _bulletPoint('We do not record video or audio through the camera permission'),
            _bulletPoint('Camera functionality is restricted to authorized technician accounts only'),

            const Text(
              '\nLOCATION PERMISSIONS (android.permission.ACCESS_FINE_LOCATION, android.permission.ACCESS_COARSE_LOCATION)\n',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            _bulletPoint('We collect precise and approximate location data only when technicians are actively performing maintenance tasks'),
            _bulletPoint('Location data is used to tag maintenance reports with the specific site location where work was performed'),
            _bulletPoint('Location information helps verify that maintenance work was conducted at the correct wastewater treatment facility'),
            _bulletPoint('We do not track your location continuously or when the app is not in use'),
            _bulletPoint('Location data is stored only in association with specific maintenance tasks and reports'),
            _bulletPoint('You can disable location permissions, but this may affect the accuracy of maintenance location tagging'),

            const Text(
              '\nSTORAGE PERMISSIONS (android.permission.READ_EXTERNAL_STORAGE, android.permission.WRITE_EXTERNAL_STORAGE, android.permission.READ_MEDIA_IMAGES)\n',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            _bulletPoint('Storage permissions allow technicians to access existing photos and documents on their device for maintenance reporting'),
            _bulletPoint('READ_MEDIA_IMAGES permission enables selection of existing images from device gallery for maintenance documentation'),
            _bulletPoint('READ_EXTERNAL_STORAGE allows accessing maintenance-related documents and images stored on the device'),
            _bulletPoint('WRITE_EXTERNAL_STORAGE enables saving maintenance reports and photos locally when needed'),
            _bulletPoint('We only access files that technicians specifically select for maintenance reporting purposes'),
            _bulletPoint('We do not scan, access, or upload your personal files, photos, or documents without your explicit selection'),
            _bulletPoint('Storage access is limited to maintenance-related content only'),

            const Text(
              'These permissions are essential for technicians to fulfill their maintenance documentation responsibilities. '
                  'You can revoke any permission at any time through your device settings, though this may limit app functionality.\n',
            ),

            _sectionTitle('3. Complete App Permissions Disclosure'),
            _bulletPoint('CAMERA (android.permission.CAMERA): Used exclusively by technician users to photograph machinery and equipment during maintenance visits. Photos are automatically uploaded to our secure servers for maintenance documentation and record keeping.'),
            _bulletPoint('LOCATION - FINE (android.permission.ACCESS_FINE_LOCATION): Collects precise location data to accurately tag maintenance work locations at specific wastewater treatment facilities.'),
            _bulletPoint('LOCATION - COARSE (android.permission.ACCESS_COARSE_LOCATION): Collects approximate location data as a backup for maintenance location tagging when precise location is unavailable.'),
            _bulletPoint('STORAGE - READ EXTERNAL (android.permission.READ_EXTERNAL_STORAGE): Allows technicians to access and select existing maintenance-related documents and images from device storage.'),
            _bulletPoint('STORAGE - WRITE EXTERNAL (android.permission.WRITE_EXTERNAL_STORAGE): Enables saving maintenance reports, photos, and related documents to device storage when needed.'),
            _bulletPoint('MEDIA - READ IMAGES (android.permission.READ_MEDIA_IMAGES): Allows technicians to select existing images from device gallery for maintenance documentation purposes.'),
            _bulletPoint('INTERNET (android.permission.INTERNET): Required for uploading maintenance data, photos, and reports to secure servers.'),
            _bulletPoint('NETWORK STATE (android.permission.ACCESS_NETWORK_STATE): Used to check network connectivity before data uploads and ensure reliable data transmission.'),
            _bulletPoint('WIFI STATE (android.permission.ACCESS_WIFI_STATE): Monitors WiFi connection status to optimize data uploads and ensure successful transmission of maintenance data.'),

            const Text(
              'Each permission is used only for its intended purpose related to maintenance app functionality. '
                  'You may be prompted to grant these permissions when first using related features, and you can manage permissions through your device settings.\n',
            ),

            _sectionTitle('4. How We Use Your Information'),
            _bulletPoint('To enable technicians to photograph machinery and equipment during maintenance operations'),
            _bulletPoint('To automatically upload machinery and equipment photos to secure servers for maintenance record keeping'),
            _bulletPoint('To upload and store relevant media files with appropriate location tagging'),
            _bulletPoint('To support and improve technical operations related to STP systems'),
            _bulletPoint('Photos captured through camera permission are used exclusively by technicians for machinery and equipment documentation and are automatically uploaded to our servers'),
            const Text('We do not use any data for advertising, profiling, marketing, or third-party analytics. Photos of machinery and equipment taken by technicians are never used for facial recognition, biometric identification, or any purpose other than maintenance documentation and record keeping.\n'),

            _sectionTitle('5. User Access and Technician Accounts'),
            _bulletPoint('This application is designed exclusively for technician personnel authorized by the organization.'),
            _bulletPoint('User accounts are created and managed by the organization for qualified technicians only.'),
            _bulletPoint('Technicians cannot create personal profiles.'),
            _bulletPoint('Only password updates are permitted by technician users.'),
            _bulletPoint('Camera functionality is available only to authorized technician accounts for machinery and equipment documentation.'),
            _bulletPoint('No personal or sensitive information is collected or stored beyond what is provided by your organization.\n'),

            _sectionTitle('6. Data Sharing and Disclosure'),
            const Text(
              'We do not sell, rent, or trade user data. Data is shared only as follows:\n'
                  '- With the organization\'s secure backend infrastructure for storage and processing\n'
                  '- With authorized administrators or supervisors to access maintenance records\n'
                  '- Photos of machinery and equipment taken by technicians through camera permission are shared only with authorized personnel within your organization\n'
                  '- In cases where users voluntarily provide specific personal information (e.g., during registration on associated corporate sites), such data is handled with strict confidentiality, stored securely, and not shared with third parties unless required by law.\n'
                  'We may use aggregated, anonymized data (never personal data or photos) to analyze app performance or usage trends to improve service delivery.\n',
            ),

            _sectionTitle('7. Legal Basis for Data Processing (for GDPR compliance)'),
            _bulletPoint('Legitimate Interests: Ensuring proper functioning and security of the application'),
            _bulletPoint('Contractual Necessity: Fulfilling obligations related to user-provided services'),
            _bulletPoint('Consent: For collecting location data, accessing device storage, and using camera permission to capture photos\n'),

            _sectionTitle('8. Data Security'),
            _bulletPoint('End-to-end HTTPS encryption for all data transmissions including photos'),
            _bulletPoint('Secure server-side authentication and access control'),
            _bulletPoint('Minimal sensitive data storage on your device'),
            _bulletPoint('Photos of machinery and equipment taken by technicians are encrypted during transmission and storage'),
            _bulletPoint('Regular audits and updates to protect against unauthorized access\n'),

            _sectionTitle('9. Data Retention'),
            _bulletPoint('Machinery and equipment photos taken by technicians through camera permission are retained only as long as necessary for operational, audit, or reporting purposes.'),
            _bulletPoint('Passwords are securely stored using encryption.'),
            _bulletPoint('Location data is stored only in relation to specific maintenance tasks and reports.'),
            _bulletPoint('Machinery and equipment photos taken by technicians are retained according to your organization\'s data retention policies.'),
            _bulletPoint('Data is deleted or anonymized when it is no longer needed.\n'),

            _sectionTitle('10. Children\'s Privacy'),
            const Text(
              'This app is not intended for children under 18. We do not knowingly collect personal data from minors. '
                  'If you believe a child has provided us with personal data, please contact us immediately so we can delete it. '
                  'Camera permission is restricted to authorized technician personnel only and is not accessible to children.\n',
            ),

            _sectionTitle('11. Your Rights (GDPR, CCPA & Similar Laws)'),
            _bulletPoint('Request information about what data is held (including machinery and equipment photos taken by technicians through camera permission)'),
            _bulletPoint('Request correction or deletion of your data and machinery/equipment photos'),
            _bulletPoint('Withdraw consent for location tracking, media access, and camera permission'),
            _bulletPoint('Object to or restrict processing'),
            const Text('To exercise your rights, please contact your system administrator or use the contact information below.\n'),

            _sectionTitle('12. Third-Party Services'),
            const Text(
              'Our app does not integrate with third-party services that access camera data. '
                  'All machinery and equipment photos taken by technicians through camera permission remain within our secure system and are not shared with external services.\n',
            ),

            _sectionTitle('13. Changes to This Privacy Policy'),
            const Text(
              'We may revise this Privacy Policy from time to time. Changes will be reflected by updating the "Effective Date" at the top of this document. '
                  'Continued use of the app indicates acceptance of the updated policy. '
                  'Changes affecting camera permission usage for technician operations will be prominently communicated.\n',
            ),

            _sectionTitle('14. Contact Us'),
            const Text(
              'If you have questions about this Privacy Policy or how we handle camera permission and machinery/equipment photo data by technicians, please contact:\n\n'
                  'Tizaraa\n'
                  'Email: info@tizaraa.com\n'
                  'Phone: +8801792223444\n'
                  'Address: House No: 15A, Road: 35, Dhaka 1212\n',
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  static Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 14)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}