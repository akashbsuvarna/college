import 'package:flutter/material.dart';
import '../admin/core/app_theme.dart';

class LandingPortalView extends StatelessWidget {
  const LandingPortalView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 950;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background patterns
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.05),
                ),
              ),
            ),
            
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Icon(Icons.school_rounded, color: Color(0xFF0EA5E9), size: 64),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'College Management System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome! Please select your portal to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Portal Cards
                      Container(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Flex(
                        direction: isMobile ? Axis.vertical : Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _PortalCard(
                            title: 'Student Portal',
                            subtitle: 'View attendance, profile, & notifications',
                            icon: Icons.person_search_rounded,
                            color: const Color(0xFF0EA5E9),
                            onTap: () => Navigator.pushNamed(context, '/student-login'),
                          ),
                          if (isMobile) const SizedBox(height: 24) else const SizedBox(width: 24),
                          _PortalCard(
                            title: 'Teacher Portal',
                            subtitle: 'Manage classes, attendance & grades',
                            icon: Icons.co_present_rounded,
                            color: const Color(0xFF10B981),
                            onTap: () => Navigator.pushNamed(context, '/teacher-login'),
                          ),
                          if (isMobile) const SizedBox(height: 24) else const SizedBox(width: 24),
                          _PortalCard(
                            title: 'Admin Portal',
                            subtitle: 'Manage students, teachers, & academics',
                            icon: Icons.admin_panel_settings_rounded,
                            color: const Color(0xFF6366F1),
                            onTap: () => Navigator.pushNamed(context, '/login'),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 64),
                    Text(
                      '© 2024 College Admin Pro',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortalCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PortalCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_PortalCard> createState() => _PortalCardState();
}

class _PortalCardState extends State<_PortalCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered ? widget.color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
              width: 2,
            ),
            boxShadow: _isHovered ? [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ] : [],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Icon(Icons.arrow_forward_rounded, color: widget.color.withValues(alpha: 0.8), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
