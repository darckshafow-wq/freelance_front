class MockData {
  static bool useMock = true;
  static bool useFreelanceMock = true;

  static Map<String, dynamic> mockLoginResponse = {
    'access_token': 'mock_token_12345',
    'user': {
      'id': 1,
      'email': 'client3@freelance.example.com',
      'full_name': 'Jean Client',
      'role': 'CLIENT',
    },
  };

  static List<Map<String, dynamic>> mockFreelances = List.generate(15, (index) => {
    'id': index + 1,
    'full_name': [
      'Mohamed Ndiaye', 'Sophie Martin', 'Alex Johnson', 'Awa Fall', 'Jean Dupont',
      'Fatou Sow', 'Lucas Bernard', 'Chloé Petit', 'Thomas Morel', 'Julie Lefebvre',
      'Adam Sy', 'Eva Diallo', 'Marc Durand', 'Inès Garcia', 'Paul Roux'
    ][index % 10],
    'email': 'freelance${index + 1}@example.com',
    'role': 'FREELANCER',
    'profile': {
      'id': index + 1,
      'user_id': index + 1,
      'bio': 'Expert en développement avec plus de 5 ans d\'expérience. Passionné par les interfaces fluides et robustes.',
      'skills': index % 2 == 0 ? ['Flutter', 'Dart', 'Firebase'] : ['UI/UX', 'Figma', 'Prototypage'],
      'avatar_url': 'https://i.pravatar.cc/150?u=freelance${index + 1}',
      'rating_average': 4.5 + (index % 5) / 10,
      'identity_verified': true,
    }
  });

  static List<Map<String, dynamic>> mockProjects = [
    {
      'id': 1,
      'title': 'Plateforme E-learning Flutter',
      'description': 'Développement d\'une application mobile complète pour cours en ligne avec vidéos et quiz.',
      'status': 'OPEN',
      'execution_date': '2026-11-15T10:00:00Z',
      'budget': 4500.0,
      'category': 'Développement',
      'skills': ['Flutter', 'Firebase', 'Vimeo API'],
      'proposals_count': 5,
    },
    {
      'id': 2,
      'title': 'Identité Visuelle Startup Tech',
      'description': 'Création d\'un logo, charte graphique et supports marketing pour une nouvelle startup IA.',
      'status': 'ACTIVE',
      'execution_date': '2026-10-20T14:00:00Z',
      'budget': 1200.0,
      'category': 'Design',
      'skills': ['Illustrator', 'Branding', 'IA'],
      'proposals_count': 18,
    },
    {
      'id': 3,
      'title': 'App de Livraison de Repas',
      'description': 'Interface client et livreur avec géolocalisation en temps réel.',
      'status': 'OPEN',
      'execution_date': '2026-12-01T09:00:00Z',
      'budget': 6000.0,
      'category': 'Développement',
      'skills': ['Flutter', 'Google Maps', 'Node.js'],
      'proposals_count': 3,
    },
    {
      'id': 4,
      'title': 'Montage Vidéo Publicitaire',
      'description': 'Montage d\'une vidéo de 30 secondes pour réseaux sociaux à partir de rushs fournis.',
      'status': 'OPEN',
      'execution_date': '2026-10-05T12:00:00Z',
      'budget': 400.0,
      'category': 'Vidéo',
      'skills': ['Premiere Pro', 'Color Grading'],
      'proposals_count': 12,
    },
    {
      'id': 5,
      'title': 'Audit SEO Site E-commerce',
      'description': 'Analyse complète et recommandations pour améliorer le positionnement Google.',
      'status': 'COMPLETED',
      'execution_date': '2026-08-15T10:00:00Z',
      'budget': 850.0,
      'category': 'Marketing',
      'skills': ['SEO', 'Semrush', 'Analytics'],
      'proposals_count': 7,
    },
    {
      'id': 6,
      'title': 'Traduction Technique Anglais/Français',
      'description': 'Documentation logicielle de 50 pages à traduire avec précision.',
      'status': 'OPEN',
      'execution_date': '2026-10-30T09:00:00Z',
      'budget': 1500.0,
      'category': 'Rédaction',
      'skills': ['Traduction', 'Technique'],
      'proposals_count': 2,
    },
  ];

  static List<Map<String, dynamic>> mockProposals = [
    {
      'id': 1,
      'project_id': 1,
      'freelance_id': 2,
      'message': 'Expert Flutter avec 5 ans d\'expérience. J\'ai déjà réalisé plusieurs plateformes e-commerce similaires à votre besoin.',
      'proposed_price': 1450.0,
      'status': 'PENDING',
      'created_at': '2026-09-05T10:00:00Z',
    },
    {
      'id': 2,
      'project_id': 1,
      'freelance_id': 3,
      'message': 'Bonjour, je suis disponible immédiatement. Mon portfolio contient des exemples de designs innovants.',
      'proposed_price': 1550.0,
      'status': 'INTERVIEW',
      'created_at': '2026-09-06T11:30:00Z',
    },
    {
      'id': 3,
      'project_id': 2,
      'freelance_id': 4,
      'message': 'Spécialiste Branding, je peux créer une identité visuelle forte pour votre startup.',
      'proposed_price': 300.0,
      'status': 'INTERVIEW',
      'created_at': '2026-09-07T09:00:00Z',
    },
    {
      'id': 4,
      'project_id': 4,
      'freelance_id': 5,
      'message': 'Je réalise des animations 2D fluides sous After Effects. Voici mon showreel.',
      'proposed_price': 750.0,
      'status': 'PENDING',
      'created_at': '2026-09-08T15:00:00Z',
    },
  ];

  static List<Map<String, dynamic>> mockReviews = [
    {
      'id': 1,
      'project_id': 5,
      'reviewer_id': 1,
      'reviewee_id': 6,
      'rating': 5.0,
      'comment': 'Travail très sérieux, communication claire et livraison dans les délais.',
      'created_at': '2026-08-20T10:00:00Z',
      'reviewer_name': 'Fatou Sow',
      'reviewer_avatar_url': 'https://i.pravatar.cc/150?u=freelance6',
      'project_title': 'Audit SEO Site E-commerce',
      'application_date': '2026-07-20T10:00:00Z',
      'completion_date': '2026-08-15T10:00:00Z',
    },
    {
      'id': 2,
      'project_id': 4,
      'reviewer_id': 5,
      'reviewee_id': 1,
      'rating': 4.5,
      'comment': 'Très bonne collaboration et des propositions créatives.',
      'created_at': '2026-08-10T10:00:00Z',
      'reviewer_name': 'Jean Dupont',
      'reviewer_avatar_url': 'https://i.pravatar.cc/150?u=freelance5',
      'project_title': 'Montage Vidéo Publicitaire',
      'application_date': '2026-07-01T10:00:00Z',
      'completion_date': '2026-08-05T10:00:00Z',
    },
  ];

  static List<Map<String, dynamic>> mockFeedbacks = [
    {
      'id': 1,
      'user_id': 1,
      'subject': 'Question sur une mission',
      'content': 'Je souhaite obtenir des informations sur le fonctionnement des propositions.',
      'admin_reply': '',
      'status': 'PENDING',
      'created_at': '2026-09-02T09:30:00Z',
    },
    {
      'id': 2,
      'user_id': 1,
      'subject': 'Compte vérifié',
      'content': 'Merci pour votre aide, mon profil est maintenant vérifié.',
      'admin_reply': 'Nous avons bien pris en compte votre demande.',
      'status': 'RESOLVED',
      'created_at': '2026-08-28T14:00:00Z',
    },
  ];

  static List<Map<String, dynamic>> mockMessages = [
    {
      'id': 1,
      'project_id': 1,
      'sender_id': 3,
      'receiver_id': 1,
      'content': 'Bonjour Jean, merci pour l\'invitation à l\'interview !',
      'timestamp': '2026-09-07T10:00:00Z',
    },
    {
      'id': 2,
      'project_id': 1,
      'sender_id': 1,
      'receiver_id': 3,
      'content': 'Avec plaisir Alex. Pouvons-nous parler de l\'intégration Stripe ?',
      'timestamp': '2026-09-07T10:05:00Z',
    },
    {
      'id': 3,
      'project_id': 1,
      'sender_id': 3,
      'receiver_id': 1,
      'content': 'Oui, j\'ai l\'habitude d\'utiliser Stripe Connect pour les marketplaces.',
      'timestamp': '2026-09-07T10:08:00Z',
    },
  ];

  static List<Map<String, dynamic>> mockNotifications = [
    {
      'id': 1,
      'user_id': 1,
      'title': 'Nouvelle proposition',
      'content': 'Alex Doe a postulé à votre projet "Site Web E-commerce".',
      'type': 'PROPOSAL',
      'is_read': false,
      'created_at': '2026-09-08T09:00:00Z',
    },
    {
      'id': 2,
      'user_id': 1,
      'title': 'Message reçu',
      'content': 'Vous avez un nouveau message de Sophie Design.',
      'type': 'MESSAGE',
      'is_read': true,
      'created_at': '2026-09-07T14:30:00Z',
    },
    {
      'id': 3,
      'user_id': 1,
      'title': 'Projet validé',
      'content': 'Votre projet "Design Logo" a été validé par l\'administrateur.',
      'type': 'SYSTEM',
      'is_read': false,
      'created_at': '2026-09-06T10:00:00Z',
    },
  ];

  static Map<String, dynamic> mockProfile = {
    'id': 1,
    'bio': 'Passionné de technologie et de design.',
    'skills': ['Flutter', 'React', 'Node.js'],
    'avatar_url': 'https://i.pravatar.cc/150?u=1',
    'rating_average': 4.8,
  };
}
