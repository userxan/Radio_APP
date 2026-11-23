import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/station_config.dart';

class GlassTheme {
  static const Color obsidian = Color(0xFF080A0F);
  static const Color surfaceDark = Color(0xFF121620);

  static ThemeData build(StationConfig config) {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: obsidian,
      colorScheme: ColorScheme.dark(
        primary: config.primaryColor,
        secondary: config.accentColor,
        surface: surfaceDark,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }
}

/// Dynamic blurred artwork + glowing gradient orbs for the Spotify/Apple Music vibe.
class AmbientBackdrop extends StatelessWidget {
  final String? artworkUrl;
  final Color primaryColor;
  final Color accentColor;
  final Widget child;

  const AmbientBackdrop({
    super.key,
    required this.artworkUrl,
    required this.primaryColor,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: GlassTheme.obsidian),
        if (artworkUrl != null && artworkUrl!.isNotEmpty)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            child: CachedNetworkImage(
              key: ValueKey(artworkUrl),
              imageUrl: artworkUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        // Ambient brand color orbs
        Positioned(
          top: -120,
          left: -80,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.35),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.25),
            ),
          ),
        ),
        // Heavy frosted blur + dark readability scrim
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 65, sigmaY: 65),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  GlassTheme.obsidian.withValues(alpha: 0.78),
                  GlassTheme.obsidian.withValues(alpha: 0.94),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Reusable frosted-glass card surface.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double opacity;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.opacity = 0.08,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: content,
      ),
    );
  }
}

/// Artwork display with smooth fallback to local station logo asset, then gradient emblem.
class ArtworkBox extends StatelessWidget {
  final String? artworkUrl;
  final String? logoAssetPath;
  final Color primaryColor;
  final Color accentColor;
  final double size;
  final double radius;

  const ArtworkBox({
    super.key,
    required this.artworkUrl,
    this.logoAssetPath,
    required this.primaryColor,
    required this.accentColor,
    required this.size,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.38),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: (artworkUrl != null && artworkUrl!.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: artworkUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _logoOrFallback(),
                errorWidget: (_, __, ___) => _logoOrFallback(),
              )
            : _logoOrFallback(),
      ),
    );
  }

  Widget _logoOrFallback() {
    if (logoAssetPath != null && logoAssetPath!.isNotEmpty) {
      return Image.asset(
        logoAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, accentColor],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.radio_rounded,
          size: size * 0.36,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
