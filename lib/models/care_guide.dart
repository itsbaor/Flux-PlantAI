class CareGuide {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String category;
  final String readTime;
  final String difficulty;
  final List<String> tags;
  final List<CareGuideSection> sections;
  final List<String> tips;
  final bool isFavorite;
  final DateTime? publishedDate;

  CareGuide({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.description,
    required this.imageUrl,
    this.category = 'General',
    this.readTime = '5 min',
    this.difficulty = 'Beginner',
    this.tags = const [],
    this.sections = const [],
    this.tips = const [],
    this.isFavorite = false,
    this.publishedDate,
  });

  CareGuide copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    String? imageUrl,
    String? category,
    String? readTime,
    String? difficulty,
    List<String>? tags,
    List<CareGuideSection>? sections,
    List<String>? tips,
    bool? isFavorite,
    DateTime? publishedDate,
  }) {
    return CareGuide(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      readTime: readTime ?? this.readTime,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      sections: sections ?? this.sections,
      tips: tips ?? this.tips,
      isFavorite: isFavorite ?? this.isFavorite,
      publishedDate: publishedDate ?? this.publishedDate,
    );
  }
}

class CareGuideSection {
  final String title;
  final String content;
  final String? iconName;

  CareGuideSection({
    required this.title,
    required this.content,
    this.iconName,
  });
}

// Pre-defined care guides data
class CareGuidesData {
  static List<CareGuide> getAllGuides() {
    return [
      CareGuide(
        id: '1',
        title: 'Watering 101',
        subtitle: 'Master the basics',
        description: 'Learn the essential techniques for watering your plants properly. Understand when, how much, and the best methods for different plant types.',
        imageUrl: 'assets/images/care/watering.jpg',
        category: 'Watering',
        readTime: '5 min',
        difficulty: 'Beginner',
        tags: ['watering', 'basics', 'beginners'],
        sections: [
          CareGuideSection(
            title: 'When to Water',
            content: 'The most common mistake in plant care is overwatering. Before watering, check the soil moisture by inserting your finger about 1-2 inches deep. If it feels dry, it\'s time to water. Most houseplants prefer to dry out slightly between waterings.\n\nMorning is the best time to water as it allows excess moisture to evaporate during the day, reducing the risk of fungal diseases.',
            iconName: 'schedule',
          ),
          CareGuideSection(
            title: 'How Much Water',
            content: 'Water thoroughly until it drains from the bottom of the pot. This ensures the entire root system gets moisture. Empty the saucer after 30 minutes to prevent root rot.\n\nThe amount varies by plant size and pot size. A general rule is to use about 1/4 to 1/3 of the pot\'s volume in water.',
            iconName: 'water_drop',
          ),
          CareGuideSection(
            title: 'Water Quality',
            content: 'Most tap water is fine for plants, but some are sensitive to chlorine and fluoride. Let tap water sit overnight before using, or use filtered water for sensitive plants like calatheas and carnivorous plants.\n\nRoom temperature water is best - cold water can shock the roots.',
            iconName: 'science',
          ),
          CareGuideSection(
            title: 'Signs of Problems',
            content: 'Overwatering signs: Yellow leaves, mushy stems, fungus gnats, and a musty smell from the soil.\n\nUnderwatering signs: Wilting, dry and crispy leaf edges, leaves falling off, and soil pulling away from the pot edges.',
            iconName: 'warning',
          ),
        ],
        tips: [
          'Use pots with drainage holes to prevent waterlogging',
          'Group plants with similar watering needs together',
          'Reduce watering frequency in winter when growth slows',
          'Use a moisture meter for more accurate readings',
          'Bottom watering works great for plants that don\'t like wet leaves',
        ],
        publishedDate: DateTime(2024, 1, 15),
      ),
      CareGuide(
        id: '2',
        title: 'Light Requirements',
        subtitle: 'Finding the perfect spot',
        description: 'Understanding light is crucial for plant health. Learn to read light levels and match plants to the right locations in your home.',
        imageUrl: 'assets/images/care/light.jpg',
        category: 'Light',
        readTime: '7 min',
        difficulty: 'Beginner',
        tags: ['light', 'placement', 'indoor'],
        sections: [
          CareGuideSection(
            title: 'Understanding Light Levels',
            content: 'Direct light: Sunlight that shines directly on the plant, typically through a south-facing window.\n\nBright indirect light: Strong light that doesn\'t directly hit the plant, like near an east or west window with sheer curtains.\n\nMedium light: A few feet away from windows, or north-facing windows.\n\nLow light: Areas far from windows or heavily shaded spots.',
            iconName: 'light_mode',
          ),
          CareGuideSection(
            title: 'Matching Plants to Light',
            content: 'High light plants: Succulents, cacti, most flowering plants, herbs.\n\nMedium light plants: Pothos, philodendrons, spider plants, dracaenas.\n\nLow light tolerant: Snake plants, ZZ plants, peace lilies, cast iron plants.\n\nRemember: "Low light tolerant" doesn\'t mean "no light" - all plants need some light to survive.',
            iconName: 'category',
          ),
          CareGuideSection(
            title: 'Signs of Light Problems',
            content: 'Too much light: Bleached or brown patches on leaves, wilting despite moist soil, leaves curling inward.\n\nToo little light: Leggy growth reaching toward light, small new leaves, loss of variegation, slow or no growth.',
            iconName: 'troubleshoot',
          ),
        ],
        tips: [
          'Rotate plants quarterly for even growth',
          'Clean windows regularly to maximize light',
          'Use grow lights to supplement in dark spaces',
          'Variegated plants need more light than solid green varieties',
          'Watch for seasonal changes in light intensity',
        ],
        publishedDate: DateTime(2024, 2, 10),
      ),
      CareGuide(
        id: '3',
        title: 'Repotting Guide',
        subtitle: 'When and how to repot',
        description: 'Learn when your plant needs a new home and master the repotting process to minimize stress and promote healthy growth.',
        imageUrl: 'assets/images/care/repotting.jpg',
        category: 'Maintenance',
        readTime: '8 min',
        difficulty: 'Intermediate',
        tags: ['repotting', 'soil', 'maintenance'],
        sections: [
          CareGuideSection(
            title: 'Signs It\'s Time to Repot',
            content: 'Your plant needs repotting when:\n• Roots are growing out of drainage holes\n• Water runs straight through without absorbing\n• Plant is top-heavy and tips over easily\n• Growth has significantly slowed\n• Roots are circling the pot (root-bound)\n• It\'s been 2+ years in the same pot',
            iconName: 'swap_horiz',
          ),
          CareGuideSection(
            title: 'Choosing the Right Pot',
            content: 'Select a pot 1-2 inches larger in diameter than the current one. Going too big can lead to overwatering issues as excess soil stays wet too long.\n\nAlways choose pots with drainage holes. Material matters: terracotta dries faster than plastic or ceramic.',
            iconName: 'inventory_2',
          ),
          CareGuideSection(
            title: 'The Repotting Process',
            content: '1. Water the plant a day before repotting\n2. Gently remove the plant from its pot\n3. Loosen the root ball and remove old soil\n4. Trim any dead or rotting roots\n5. Add fresh potting mix to the new pot\n6. Place the plant at the same depth as before\n7. Fill around with soil and gently firm\n8. Water thoroughly and place in indirect light',
            iconName: 'format_list_numbered',
          ),
          CareGuideSection(
            title: 'Aftercare',
            content: 'Plants may look droopy for a week or two after repotting - this is normal transplant shock. Keep in indirect light, maintain consistent moisture, and avoid fertilizing for 4-6 weeks while roots establish.',
            iconName: 'healing',
          ),
        ],
        tips: [
          'Spring and summer are the best times to repot',
          'Don\'t repot a stressed or sick plant',
          'Use fresh potting mix, not garden soil',
          'Match soil type to plant needs (cactus mix, orchid bark, etc.)',
          'Clean and sterilize pots before reusing',
        ],
        publishedDate: DateTime(2024, 3, 5),
      ),
      CareGuide(
        id: '4',
        title: 'Pest Prevention',
        subtitle: 'Keep bugs at bay',
        description: 'Identify common houseplant pests and learn effective prevention and treatment strategies to keep your plants healthy.',
        imageUrl: 'assets/images/care/pests.jpg',
        category: 'Health',
        readTime: '10 min',
        difficulty: 'Intermediate',
        tags: ['pests', 'health', 'treatment'],
        sections: [
          CareGuideSection(
            title: 'Common Houseplant Pests',
            content: 'Spider mites: Tiny specks, webbing on leaves. Thrive in dry conditions.\n\nMealybugs: White, cottony masses in leaf joints. Sticky residue.\n\nFungus gnats: Small flies around soil. Larvae damage roots.\n\nScale: Brown bumps on stems and leaves. Sticky honeydew.\n\nAphids: Small green or black insects clustering on new growth.',
            iconName: 'bug_report',
          ),
          CareGuideSection(
            title: 'Prevention Strategies',
            content: '• Inspect new plants thoroughly before bringing them home\n• Quarantine new plants for 2-3 weeks\n• Maintain proper humidity levels\n• Keep plants healthy - stressed plants attract pests\n• Clean leaves regularly to remove dust and eggs\n• Ensure good air circulation',
            iconName: 'security',
          ),
          CareGuideSection(
            title: 'Treatment Options',
            content: 'Neem oil: Organic option effective against many pests. Mix with water and spray weekly.\n\nInsecticidal soap: Safe for most plants, kills on contact. Reapply every few days.\n\nRubbing alcohol: Dab directly on mealybugs and scale with a cotton swab.\n\nSystemic treatments: For severe infestations, absorbed by the plant.',
            iconName: 'medication',
          ),
        ],
        tips: [
          'Check undersides of leaves during routine care',
          'Isolate infected plants immediately',
          'Treat the entire collection if one plant has pests',
          'Be persistent - most treatments need multiple applications',
          'Yellow sticky traps help monitor and catch flying pests',
        ],
        publishedDate: DateTime(2024, 4, 20),
      ),
      CareGuide(
        id: '5',
        title: 'Fertilizing Basics',
        subtitle: 'Feed your plants right',
        description: 'Understand plant nutrition and learn when, how, and what to feed your plants for optimal growth and health.',
        imageUrl: 'assets/images/care/fertilizer.jpg',
        category: 'Nutrition',
        readTime: '6 min',
        difficulty: 'Beginner',
        tags: ['fertilizer', 'nutrition', 'growth'],
        sections: [
          CareGuideSection(
            title: 'Understanding NPK',
            content: 'Fertilizers contain three main nutrients:\n\nNitrogen (N): Promotes leafy green growth. Essential for foliage plants.\n\nPhosphorus (P): Supports root development and flowering.\n\nPotassium (K): Overall plant health and disease resistance.\n\nThe numbers on fertilizer (e.g., 10-10-10) show the ratio of these nutrients.',
            iconName: 'science',
          ),
          CareGuideSection(
            title: 'When to Fertilize',
            content: 'Most houseplants need fertilizer during their active growing season (spring and summer). Reduce or stop fertilizing in fall and winter when growth slows.\n\nNever fertilize:\n• Newly repotted plants (wait 4-6 weeks)\n• Sick or stressed plants\n• Bone-dry soil (water first)',
            iconName: 'event',
          ),
          CareGuideSection(
            title: 'Application Methods',
            content: 'Liquid fertilizer: Dilute in water and apply every 2-4 weeks. Easy to control dosage.\n\nSlow-release granules: Apply once per season. Releases nutrients gradually.\n\nFoliar feeding: Spray diluted fertilizer on leaves for quick absorption.',
            iconName: 'local_florist',
          ),
        ],
        tips: [
          'Less is more - it\'s easier to fix under-fertilizing than over-fertilizing',
          'Always dilute to half strength for most houseplants',
          'Flush soil occasionally to prevent salt buildup',
          'Match fertilizer type to plant needs (bloom booster for flowering plants)',
          'Organic options like worm castings are gentle and effective',
        ],
        publishedDate: DateTime(2024, 5, 1),
      ),
      CareGuide(
        id: '6',
        title: 'Propagation Methods',
        subtitle: 'Multiply your plants',
        description: 'Learn different propagation techniques to create new plants from your existing collection. Save money and share with friends!',
        imageUrl: 'assets/images/care/propagation.jpg',
        category: 'Advanced',
        readTime: '12 min',
        difficulty: 'Advanced',
        tags: ['propagation', 'cuttings', 'advanced'],
        sections: [
          CareGuideSection(
            title: 'Stem Cuttings',
            content: 'The most common method. Cut a 4-6 inch stem just below a node (where leaves attach). Remove lower leaves and place in water or moist soil.\n\nBest for: Pothos, philodendrons, tradescantia, herbs, and most vining plants.',
            iconName: 'content_cut',
          ),
          CareGuideSection(
            title: 'Leaf Cuttings',
            content: 'Some plants can grow from a single leaf. Place the leaf (with or without stem) on moist soil or in water.\n\nBest for: Succulents, snake plants, begonias, African violets.',
            iconName: 'eco',
          ),
          CareGuideSection(
            title: 'Division',
            content: 'Separate a plant into multiple sections, each with roots attached. Best done during repotting.\n\nBest for: Peace lilies, snake plants, ferns, spider plants, ZZ plants.',
            iconName: 'call_split',
          ),
          CareGuideSection(
            title: 'Air Layering',
            content: 'For woody plants that are difficult to root from cuttings. Wound a stem, wrap with moist moss, and wait for roots to form before cutting.\n\nBest for: Fiddle leaf figs, rubber plants, monstera, dracaenas.',
            iconName: 'air',
          ),
        ],
        tips: [
          'Take cuttings in spring or summer for best success',
          'Use clean, sharp tools to prevent infection',
          'Rooting hormone can increase success rates',
          'Keep propagations warm and humid',
          'Be patient - some plants take weeks or months to root',
        ],
        publishedDate: DateTime(2024, 6, 15),
      ),
    ];
  }
}
