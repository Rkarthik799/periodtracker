// lib/tips_screen.dart
// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      _TipSection(
        icon: "🍓",
        title: "Foods to Eat",
        description:
            "Support your body with iron-rich, anti-inflammatory foods during your cycle:",
        tips: [
          "🥦 Leafy greens (spinach, kale)",
          "🍫 Dark chocolate (in moderation)",
          "🍌 Bananas (reduce cramps, boost mood)",
          "🧄 Ginger and turmeric (anti-inflammatory)",
          "🐟 Salmon (omega-3s for inflammation)",
        ],
        source:
            "https://www.healthline.com/health/womens-health/foods-to-eat-during-period",
      ),
      _TipSection(
        icon: "🚫",
        title: "Foods to Avoid",
        description: "Minimize discomfort by avoiding:",
        tips: [
          "🥤 Caffeine (can increase cramps)",
          "🧂 Excess salt (causes bloating)",
          "🍟 Fried and fatty foods",
          "🍬 Sugary snacks (blood sugar spikes)",
        ],
        source:
            "https://www.medicalnewstoday.com/articles/foods-to-avoid-during-your-period",
      ),
      _TipSection(
        icon: "💤",
        title: "Lifestyle Tips",
        description:
            "Gentle self-care routines help your body stay in balance:",
        tips: [
          "🧘‍♀️ Light yoga or stretching",
          "🚶‍♀️ Walks in fresh air",
          "🛁 Warm baths to ease cramps",
          "💧 Stay hydrated (8+ glasses/day)",
          "😴 Aim for 7-9 hours of sleep",
        ],
        source: "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9833120/",
      ),
      _TipSection(
        icon: "⚠️",
        title: "When to See a Doctor",
        description: "Consult a professional if you experience:",
        tips: [
          "⏱️ Periods lasting more than 7 days",
          "😖 Extreme or sudden cramps",
          "🚨 Heavy bleeding or clotting",
          "🌀 Dizziness or fatigue",
        ],
        source: "https://www.acog.org/womens-health/faqs/your-menstrual-cycle",
      ),
    ];

    return Container(
      color: const Color(0xFFFFF2F7),
      child: ListView.separated(
        shrinkWrap: true, // Important: allow embedding
        physics: NeverScrollableScrollPhysics(), // Important: no nested scroll
        padding: const EdgeInsets.all(20),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (_, i) => sections[i],
      ),
    );
  }
}

class _TipSection extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final List<String> tips;
  final String source;

  const _TipSection({
    required this.icon,
    required this.title,
    required this.description,
    required this.tips,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFE),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$icon  $title",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFFF5CA8),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(tip, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse(source)),
            child: Row(
              children: const [
                Icon(Icons.link, color: Color(0xFF00897B), size: 16),
                SizedBox(width: 6),
                Text(
                  "Source",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF00897B),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
