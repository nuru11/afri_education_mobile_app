import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/controllers.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/utils/utils.dart';

const _newsAccent = Color(0xFF667eea);

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NewsController());
    return GetBuilder<NewsController>(
      builder: (controller) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'News',
            style: TextStyle(color: Colors.black87, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () =>
                  showSearch(context: context, delegate: NewsSearchDelegate()),
            ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              if (controller.isShowingOfflineData)
                SliverToBoxAdapter(child: _buildOfflineNotice()),
              if (_shouldShowFeatured(controller))
                SliverToBoxAdapter(
                  child: _buildFeaturedNewsCard(context, controller),
                ),
              _buildCategoriesSection(context, controller),
              _buildLatestNewsSection(context, controller),
              _buildNewsList(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldShowFeatured(NewsController controller) {
    final featured = controller.featuredNews;
    if (featured == null) return false;
    return controller.news.any((n) => n.id == featured.id);
  }

  Widget _buildFeaturedNewsCard(
    BuildContext context,
    NewsController controller,
  ) {
    final featured = controller.featuredNews!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => controller.openNewsDetail(featured.id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _NewsCoverImage(
                  imageUrl: featured.coverImage,
                  iconSize: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _newsAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            featured.category.capitalize ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _newsAccent,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.access_time,
                          color: Colors.grey[500],
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          toAgoDate(featured.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      featured.title.capitalize ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD89C)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: Color(0xFF8A5A00)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "You're offline – showing saved data",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A5A00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(
    BuildContext context,
    NewsController controller,
  ) {
    if (controller.categories.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isSelected = index == controller.selectedCategoryIndex;

            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => controller.changeCategory(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey[300]!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLatestNewsSection(
    BuildContext context,
    NewsController controller,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Latest Articles',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            GestureDetector(
              onTap: () => controller.refreshNews(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _newsAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.refresh,
                  color: _newsAccent,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList(BuildContext context, NewsController controller) {
    if (controller.isLoading && controller.news.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_newsAccent),
          ),
        ),
      );
    }

    if (controller.news.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No news available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final featuredId = _shouldShowFeatured(controller)
        ? controller.featuredNews?.id
        : null;
    final gridNews = featuredId == null
        ? controller.news
        : controller.news.where((n) => n.id != featuredId).toList();

    if (gridNews.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox(height: 24));
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.78,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final news = gridNews[index];
            return _NewsGridTile(
              news: news,
              onTap: () => controller.openNewsDetail(news.id),
            );
          },
          childCount: gridNews.length,
        ),
      ),
    );
  }
}

class _NewsGridTile extends StatelessWidget {
  const _NewsGridTile({required this.news, required this.onTap});

  final News news;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _NewsCoverImage(imageUrl: news.coverImage),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                news.title.capitalize ?? news.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${news.category.capitalize ?? news.category} · ${toAgoDate(news.createdAt)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsCoverImage extends StatelessWidget {
  const _NewsCoverImage({this.imageUrl, this.iconSize = 28});

  final String? imageUrl;
  final double iconSize;

  bool get _hasUrl => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasUrl) return _fallback();

    return CachedNetworkImage(
      imageUrl: imageUrl!.trim(),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: _newsAccent.withValues(alpha: 0.08),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _newsAccent,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      color: _newsAccent.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.article_outlined,
          color: _newsAccent,
          size: iconSize,
        ),
      ),
    );
  }
}

class NewsSearchDelegate extends SearchDelegate<News> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Get.back();
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final controller = Get.find<NewsController>();
    return FutureBuilder<List<News>>(
      future: controller.searchNews(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_newsAccent),
            ),
          );
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return _buildNoResultsState(context);
        }
        return _buildSearchResults(context, results, controller);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final controller = Get.find<NewsController>();
    return _buildSearchResults(context, controller.news, controller);
  }

  Widget _buildNoResultsState(BuildContext context) {
    return const Center(child: Text('No results found'));
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<News> news,
    NewsController controller,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: news.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) =>
          _buildNewsItem(context, news[index], controller),
    );
  }

  Widget _buildNewsItem(
    BuildContext context,
    News news,
    NewsController controller,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 56,
          height: 56,
          child: _NewsCoverImage(imageUrl: news.coverImage, iconSize: 22),
        ),
      ),
      title: Text(
        news.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3748),
        ),
      ),
      subtitle: Text(
        '${news.category.capitalize ?? news.category} · ${toAgoDate(news.createdAt)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      onTap: () => controller.openNewsDetail(news.id),
    );
  }
}
