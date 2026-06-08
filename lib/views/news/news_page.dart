import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/controllers.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/utils/utils.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NewsController());
    return GetBuilder<NewsController>(
      builder: (controller) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            'News',
            style: TextStyle(color: Colors.black87, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // Change this line
          actions: [
            IconButton(
              icon: Icon(Icons.search),
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
              // Clean Header
              // _buildCleanHeader(context, controller),

              // Featured News Card
              if (controller.news.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildFeaturedNewsCard(context, controller),
                ),

              // Categories Section
              _buildCategoriesSection(context, controller),

              // Latest News Section
              _buildLatestNewsSection(context, controller),

              // News List
              _buildNewsList(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedNewsCard(
    BuildContext context,
    NewsController controller,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    controller.featuredNews?.coverImage ??
                        'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=400&h=280&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),

            // Featured Badge
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "FEATURED",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Category Badge
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.featuredNews?.category.capitalize ?? '',
                  style: TextStyle(
                    color: const Color(0xFF667eea),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.featuredNews?.title.capitalize ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          toAgoDate(
                            controller.featuredNews?.createdAt ??
                                DateTime.now(),
                          ),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => controller.openNewsDetail(
                            controller.featuredNews?.id ?? 0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Text(
                              "Read More",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
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
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Latest Articles",
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
                  color: const Color(0xFF667eea).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.refresh,
                  color: Color(0xFF667eea),
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
    if (controller.isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
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
                "No news available",
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

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final news = controller.news[index];
          return _buildModernNewsItem(context, news, controller);
        }, childCount: controller.news.length),
      ),
    );
  }

  Widget _buildModernNewsItem(
    BuildContext context,
    News news,
    NewsController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.openNewsDetail(news.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // News Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(
                        news.coverImage ??
                            'https://images.unsplash.com/photo-${1500000000000 + news.id}?w=80&h=80&fit=crop',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // News Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          news.category.capitalize!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF667eea),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        news.title.capitalize!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.grey[500],
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            toAgoDate(news.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        icon: Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Get.back();
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final controller = Get.find<NewsController>();
    return FutureBuilder<List<News>>(
      future: controller.searchNews(query),
      builder: (context, snapshot) {
        return snapshot.data?.isEmpty ?? true
            ? _buildNoResultsState(context)
            : _buildSearchResults(context, snapshot.data!, controller);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final controller = Get.find<NewsController>();
    return ListView.builder(
      itemBuilder: (context, index) =>
          _buildNewsItem(context, controller.news[index], controller),
      itemCount: controller.news.length,
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(child: Text('No results found'));
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<News> news,
    NewsController controller,
  ) {
    return ListView.builder(
      itemCount: news.length,
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
      title: Text(news.title),
      onTap: () => controller.openNewsDetail(news.id),
    );
  }
}
