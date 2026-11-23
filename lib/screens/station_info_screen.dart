import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/station_config.dart';
import '../theme/glass_theme.dart';

/// Reworked Station Info & Studio Connect hub inspired by leading SA radio apps
/// (Jacaranda FM, YOUfm, Heart 104.9, Kfm).
class StationInfoScreen extends StatelessWidget {
  final StationConfig config;

  const StationInfoScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 140),
        children: [
          const Text(
            'Studio & Connect',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 16),
          _buildHeroStationCard(),
          const SizedBox(height: 16),
          _buildQuickStudioActions(),
          if (config.promo != null) ...[
            const SizedBox(height: 16),
            _buildPromoBanner(config.promo!),
          ],
          const SizedBox(height: 20),
          _buildStudioDirectory(),
          if (config.socialLinks.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSocialChannels(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroStationCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(26),
      opacity: 0.11,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ArtworkBox(
                artworkUrl: config.defaultArtworkUrl,
                logoAssetPath: config.logoAssetPath,
                primaryColor: config.primaryColor,
                accentColor: config.accentColor,
                size: 64,
                radius: 18,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: config.primaryColor.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        config.frequencyBadge,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: config.accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      config.stationName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      config.tagline,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (config.aboutText.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              config.aboutText,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStudioActions() {
    final actions = <Widget>[
      if (config.studioWhatsapp != null)
        Expanded(
          child: _ActionPill(
            icon: Icons.chat_rounded,
            label: 'WhatsApp',
            color: const Color(0xFF22C55E),
            onTap: () => _launch(_whatsappUri(config.studioWhatsapp!)),
          ),
        ),
      if (config.studioPhone != null) ...[
        const SizedBox(width: 10),
        Expanded(
          child: _ActionPill(
            icon: Icons.call_rounded,
            label: 'Call Studio',
            color: config.primaryColor,
            onTap: () => _launch('tel:${config.studioPhone}'),
          ),
        ),
      ],
      if (config.studioEmail != null) ...[
        const SizedBox(width: 10),
        Expanded(
          child: _ActionPill(
            icon: Icons.mail_rounded,
            label: 'Email',
            color: config.accentColor,
            onTap: () => _launch('mailto:${config.studioEmail}'),
          ),
        ),
      ],
    ];

    if (actions.isEmpty) return const SizedBox.shrink();
    return Row(children: actions);
  }

  Widget _buildPromoBanner(StationPromo promo) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.14,
      onTap: promo.actionUrl != null ? () => _launch(promo.actionUrl!) : null,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [config.primaryColor, config.accentColor],
              ),
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.badgeText.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: config.accentColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  promo.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (promo.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    promo.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (promo.actionUrl != null)
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.6)),
        ],
      ),
    );
  }

  Widget _buildStudioDirectory() {
    final rows = <_DirectoryRow>[
      if (config.studioWhatsapp != null)
        _DirectoryRow(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Studio WhatsApp / Voice Notes',
          value: config.studioWhatsapp!,
          onTap: () => _launch(_whatsappUri(config.studioWhatsapp!)),
        ),
      if (config.studioSms != null)
        _DirectoryRow(
          icon: Icons.sms_rounded,
          label: 'Studio SMS Line',
          value: config.studioSms!,
          onTap: () => _launch('sms:${config.studioSms}'),
        ),
      if (config.newsDeskEmail != null)
        _DirectoryRow(
          icon: Icons.newspaper_rounded,
          label: 'News Desk',
          value: config.newsDeskEmail!,
          onTap: () => _launch('mailto:${config.newsDeskEmail}'),
        ),
      if (config.studioAddress != null)
        _DirectoryRow(
          icon: Icons.location_on_outlined,
          label: 'Broadcast Centre',
          value: config.studioAddress!,
        ),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.08,
      child: Column(
        children: List.generate(rows.length, (i) {
          final row = rows[i];
          return Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(row.icon, color: config.accentColor, size: 20),
                title: Text(
                  row.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                subtitle: Text(
                  row.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                trailing: row.onTap != null
                    ? Icon(Icons.arrow_outward_rounded,
                        size: 16, color: Colors.white.withValues(alpha: 0.5))
                    : null,
                onTap: row.onTap,
              ),
              if (i < rows.length - 1)
                Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSocialChannels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow ${config.stationName}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        ...config.socialLinks.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              borderRadius: BorderRadius.circular(18),
              opacity: 0.08,
              onTap: () => _launch(link.url),
              child: Row(
                children: [
                  Icon(_iconForKey(link.iconKey),
                      size: 20, color: config.accentColor),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      link.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.open_in_new_rounded,
                      size: 16, color: Colors.white.withValues(alpha: 0.5)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _whatsappUri(String rawNumber) {
    final digits = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    return 'https://wa.me/${digits.replaceFirst('+', '')}';
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  IconData _iconForKey(String key) {
    switch (key.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt_rounded;
      case 'youtube':
        return Icons.play_circle_fill_rounded;
      case 'whatsapp':
        return Icons.chat_bubble_rounded;
      default:
        return Icons.language_rounded;
    }
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14),
      borderRadius: BorderRadius.circular(20),
      opacity: 0.1,
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _DirectoryRow {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _DirectoryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });
}
