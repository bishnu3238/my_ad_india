import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pack/extensions/contextx.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget buildSectionText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
    );
  }

  Widget buildTeamCard(String name, String role, String imagePath) {
    return Column(
      children: [
        CircleAvatar(radius: 40, backgroundImage: AssetImage(imagePath)),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(role, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: GoogleFonts.poppins(color: context.colorScheme.surface),
        ),
        backgroundColor: context.colorScheme.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSectionTitle("Welcome to MyAd"),
              buildSectionText(
                "MyAd is your go-to platform for finding and offering services with ease. We connect users with reliable service providers, ensuring smooth, transparent, and secure interactions across industries.",
              ),
              const SizedBox(height: 20),
              buildSectionTitle("Our Mission"),
              buildSectionText(
                "To empower individuals and businesses by providing a trusted platform where services are discovered, booked, and reviewed—all in one place.",
              ),
              const SizedBox(height: 20),
              buildSectionTitle("Why Choose Us"),
              buildSectionText(
                "• Seamless service discovery\n"
                "• Verified and trusted providers\n"
                "• Easy communication and booking tools\n"
                "• Secure payments and review systems",
              ),
              const SizedBox(height: 20),
              // buildSectionTitle("Our Team"),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: [
              //     buildTeamCard(
              //       "Aditi Sharma",
              //       "Founder",
              //       "assets/images/founder.png",
              //     ),
              //     buildTeamCard(
              //       "Ravi Kumar",
              //       "Tech Lead",
              //       "assets/images/techlead.png",
              //     ),
              //     buildTeamCard(
              //       "Priya Nair",
              //       "Design Lead",
              //       "assets/images/designer.png",
              //     ),
              //   ],
              // ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  "Together, we aim to make everyday tasks easier, one connection at a time.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
