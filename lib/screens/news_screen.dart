import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/station_config.dart';
import '../theme/glass_theme.dart';

class NewsScreen extends StatefulWidget {
  final StationConfig config;

  const NewsScreen({super.key, required this.config});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final categories = <String>{
      'All',
      ...widget.config.news.map((n) => n.category),
    }.toList();

    final filtered = _selectedCategory == 'All'
        ? widget.config.news
        : widget.config.news
            .where((n) => n.category == _selectedCategory)
            .toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 4),
            child: Text(
              'News & Updates',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Headlines, traffic & music from ${widget.config.stationName}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final selected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  selectedColor: widget.config.primaryColor,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  side: BorderSide(
                    color: selected
                        ? widget.config.primaryColor
                        : Colors.white.withValues(alpha: 0.12),
                  ),
                  labelStyle: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: Colors.white,
                  ),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No stories in $_selectedCategory right now.',
                      style:
                          TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 160),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final article = filtered[index];
                      if (index == 0) {
                        return _FeaturedNewsCard(
                          article: article,
                          config: widget.config,
                          onTap: () => _openArticle(context, article),
                        );
                      }
                      return _NewsListCard(
                        article: article,
                        config: widget.config,
                        onTap: () => _openArticle(context, article),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openArticle(BuildContext context, NewsArticle article) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GlassTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.config.primaryColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: widget.config.accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      article.publishedAt,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  article.body.isNotEmpty ? article.body : article.summary,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                if (article.articleUrl != null &&
                    article.articleUrl!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () async {
                      final uri = Uri.tryParse(article.articleUrl!);
                      if (uri != null) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Read Full Story'),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _FeaturedNewsCard extends StatelessWidget {
  final NewsArticle article;
  final StationConfig config;
  final VoidCallback onTap;

  const _FeaturedNewsCard({
    required this.article,
    required this.config,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.13,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [config.primaryColor, config.accentColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'TOP • ${article.category.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                article.publishedAt,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            article.summary,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Colors.white.withValues(alpha: 0.72),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _NewsListCard extends StatelessWidget {
  final NewsArticle article;
  final StationConfig config;
  final VoidCallback onTap;

  const _NewsListCard({
    required this.article,
    required this.config,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(20),
      opacity: 0.07,
      onTap: onTap,
      child: Row(
        children: [
          ArtworkBox(
            artworkUrl: article.imageUrl ?? config.defaultArtworkUrl,
            primaryColor: config.primaryColor,
            accentColor: config.accentColor,
            size: 62,
            radius: 14,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${article.category.toUpperCase()} • ${article.publishedAt}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: config.accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  article.summary,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.62),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
