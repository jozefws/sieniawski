import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SieniawskiApp());
}

class SieniawskiApp extends StatelessWidget {
  const SieniawskiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sieniawski',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A2E),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Georgia',
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _heroKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _historyKey = GlobalKey();
  final _contactKey = GlobalKey();

  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Semantics(
        // Landmark: main content
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _HeroSection(key: _heroKey, isMobile: isMobile, scrollOffset: _scrollOffset),
                  _AboutSection(key: _aboutKey, isMobile: isMobile),
                  _HistorySection(key: _historyKey, isMobile: isMobile),
                  _ContactSection(key: _contactKey, isMobile: isMobile),
                  const _Footer(),
                ],
              ),
            ),
            _NavBar(
              isMobile: isMobile,
              scrollOffset: _scrollOffset,
              onHome: () => _scrollTo(_heroKey),
              onAbout: () => _scrollTo(_aboutKey),
              onHistory: () => _scrollTo(_historyKey),
              onContact: () => _scrollTo(_contactKey),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final bool isMobile;
  final double scrollOffset;
  final VoidCallback onHome;
  final VoidCallback onAbout;
  final VoidCallback onHistory;
  final VoidCallback onContact;

  const _NavBar({
    required this.isMobile,
    required this.scrollOffset,
    required this.onHome,
    required this.onAbout,
    required this.onHistory,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final isScrolled = scrollOffset > 50;

    return Semantics(
      header: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 64,
        decoration: BoxDecoration(
          color: isScrolled ? const Color(0xE6090914) : Colors.transparent,
          boxShadow: isScrolled
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12)]
              : [],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48),
          child: Row(
            children: [
              Semantics(
                label: 'Sieniawski — scroll to top',
                button: true,
                child: GestureDetector(
                  onTap: onHome,
                  child: const ExcludeSemantics(
                    child: Text(
                      'SIENIAWSKI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (!isMobile) ...[
                _NavItem('About', onAbout),
                const SizedBox(width: 32),
                _NavItem('History', onHistory),
                const SizedBox(width: 32),
                _NavItem('Contact', onContact),
              ] else
                _MobileMenu(
                  onAbout: onAbout,
                  onHistory: onHistory,
                  onContact: onContact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavItem(this.label, this.onTap);

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Navigate to ${widget.label} section',
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: _hovered ? const Color(0xFFD4AF37) : Colors.white70,
              fontSize: 13,
              letterSpacing: 2,
            ),
            child: Text(widget.label.toUpperCase()),
          ),
        ),
      ),
    );
  }
}

class _MobileMenu extends StatefulWidget {
  final VoidCallback onAbout;
  final VoidCallback onHistory;
  final VoidCallback onContact;
  const _MobileMenu({required this.onAbout, required this.onHistory, required this.onContact});

  @override
  State<_MobileMenu> createState() => _MobileMenuState();
}

class _MobileMenuState extends State<_MobileMenu> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Open navigation menu',
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.menu, color: Colors.white70),
        tooltip: 'Navigation menu',
        color: const Color(0xFF1A1A2E),
        onSelected: (v) {
          if (v == 'about') widget.onAbout();
          if (v == 'history') widget.onHistory();
          if (v == 'contact') widget.onContact();
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'about', child: Text('About', style: TextStyle(color: Colors.white))),
          const PopupMenuItem(value: 'history', child: Text('History', style: TextStyle(color: Colors.white))),
          const PopupMenuItem(value: 'contact', child: Text('Contact', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool isMobile;
  final double scrollOffset;

  const _HeroSection({super.key, required this.isMobile, required this.scrollOffset});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Semantics(
      label: 'Sieniawski — A Family Name. Hero section.',
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Transform.translate(
              offset: Offset(0, scrollOffset * 0.4),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D0D1A),
                      Color(0xFF1A1A3E),
                      Color(0xFF0D1A2E),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 64),
                  ExcludeSemantics(child: _CoatOfArms()),
                  const SizedBox(height: 40),
                  Text(
                    'SIENIAWSKI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 36 : 64,
                      fontWeight: FontWeight.w300,
                      letterSpacing: isMobile ? 8 : 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 48),
                  ExcludeSemantics(
                    child: Container(width: 1, height: 48, color: const Color(0xFFD4AF37)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoatOfArms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(120, 140),
      painter: _ShieldPainter(),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const gold = Color(0xFFD4AF37);
    const navy = Color(0xFF1A1A3E);

    final shieldPath = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height * 0.15)
      ..lineTo(size.width, size.height * 0.6)
      ..quadraticBezierTo(size.width, size.height, size.width / 2, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height * 0.6)
      ..lineTo(0, size.height * 0.15)
      ..close();

    canvas.drawPath(shieldPath, Paint()..color = navy);
    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'S',
        style: TextStyle(
          color: gold,
          fontSize: 66,
          fontWeight: FontWeight.w300,
          fontFamily: 'Georgia',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2 - 4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AboutSection extends StatelessWidget {
  final bool isMobile;
  const _AboutSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'About section',
      child: Container(
        color: const Color(0xFF0F0F1F),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 120,
          vertical: 96,
        ),
        child: Column(
          children: [
            const _SectionLabel('ABOUT'),
            const SizedBox(height: 40),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: const Text(
                'The Sieniawski name carries centuries of heritage. Originating in Poland, the family has been associated with nobility, military service, and cultural contributions throughout history.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  height: 1.9,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 64),
            Wrap(
              spacing: 32,
              runSpacing: 32,
              alignment: WrapAlignment.center,
              children: [
                _StatCard('Origin', 'Polish', Icons.place_outlined),
                _StatCard('Heritage', 'Noble', Icons.shield_outlined),
                _StatCard('Est.', '15th C.', Icons.history_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard(this.label, this.value, this.icon);

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.label}: ${widget.value}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 160,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            border: Border.all(
              color: _hovered ? const Color(0xFFD4AF37) : Colors.white12,
              width: 1,
            ),
            color: _hovered ? const Color(0x10D4AF37) : Colors.transparent,
          ),
          child: Column(
            children: [
              ExcludeSemantics(
                child: Icon(widget.icon, color: const Color(0xFFD4AF37), size: 28),
              ),
              const SizedBox(height: 12),
              ExcludeSemantics(
                child: Text(
                  widget.value,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w300),
                ),
              ),
              const SizedBox(height: 4),
              ExcludeSemantics(
                child: Text(
                  widget.label.toUpperCase(),
                  style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  final bool isMobile;
  const _HistorySection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'History section',
      child: Container(
        color: const Color(0xFF0D0D1A),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 120,
          vertical: 96,
        ),
        child: Column(
          children: [
            const _SectionLabel('HISTORY'),
            const SizedBox(height: 64),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  _TimelineItem(
                    era: '15th Century',
                    text: 'The Sieniawski family rose to prominence in the Polish-Lithuanian Commonwealth, known for their service in the nobility.',
                    isMobile: isMobile,
                  ),
                  _TimelineItem(
                    era: '16th to 17th Century',
                    text: 'The family held significant estates and played roles in the political and military affairs of the Commonwealth.',
                    isMobile: isMobile,
                  ),
                  _TimelineItem(
                    era: 'Modern Era',
                    text: "Descendants of the Sieniawski name are found across Europe and beyond, carrying the family's legacy into the present day.",
                    isMobile: isMobile,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String era;
  final String text;
  final bool isMobile;
  final bool isLast;

  const _TimelineItem({
    required this.era,
    required this.text,
    required this.isMobile,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$era: $text',
      child: ExcludeSemantics(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: isMobile ? 0 : 180,
                child: isMobile
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 4, right: 24),
                        child: Text(
                          era,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
              ),
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4AF37),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 1, color: Colors.white12),
                    ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isMobile) ...[
                        Text(
                          era,
                          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, letterSpacing: 1),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        text,
                        style: const TextStyle(color: Colors.white60, fontSize: 15, height: 1.8),
                      ),
                    ],
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

class _ContactSection extends StatelessWidget {
  final bool isMobile;
  const _ContactSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Contact section',
      child: Container(
        color: const Color(0xFF0F0F1F),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 120,
          vertical: 96,
        ),
        child: Column(
          children: [
            const _SectionLabel('CONTACT'),
            const SizedBox(height: 24),
            const Text(
              'Get in touch with the family',
              style: TextStyle(color: Colors.white38, fontSize: 14, letterSpacing: 1),
            ),
            const SizedBox(height: 48),
            _GoldButton(
              label: 'EMAIL US',
              onTap: () => launchUrl(Uri.parse('mailto:contact@sieniawski.co.uk')),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _GoldButton({required this.label, required this.onTap});

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _hovered ? const Color(0xFFD4AF37) : Colors.transparent,
              border: Border.all(color: const Color(0xFFD4AF37)),
            ),
            child: ExcludeSemantics(
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _hovered ? Colors.black : const Color(0xFFD4AF37),
                  fontSize: 12,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Footer. Copyright 2026 Sieniawski Family',
      child: Container(
        color: const Color(0xFF080810),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: const ExcludeSemantics(
          child: Text(
            '© 2026 Sieniawski Family · sieniawski.co.uk',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 1),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              letterSpacing: 5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(width: 40, height: 1, color: const Color(0xFFD4AF37)),
        ],
      ),
    );
  }
}
