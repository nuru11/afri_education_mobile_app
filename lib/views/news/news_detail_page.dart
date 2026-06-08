import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vector_academy/models/models.dart';
import 'package:vector_academy/services/services.dart';
import 'package:vector_academy/utils/utils.dart';

class NewsDetailPage extends StatefulWidget {
  final News? news;
  final int? newsId;

  const NewsDetailPage({super.key, this.news, this.newsId});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  News? _news;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to ensure Get.arguments is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNews();
    });
  }

  void _initializeNews() {
    if (widget.news != null) {
      _news = widget.news;
      setState(() {});
      return;
    }

    if (widget.newsId != null) {
      _loadNewsById(widget.newsId!);
      return;
    }

    // Try multiple ways to get arguments
    var args = Get.parameters;

    if (args['id'] != null) {
      final newsId = args['id'];
      if (newsId != null) {
        final id = int.tryParse(newsId);
        if (id != null) _loadNewsById(id);
      }
    }
  }

  Future<void> _loadNewsById(int newsId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newsService = NewsService();
      final news = await newsService.getNewsById(newsId);
      if (news != null) {
        setState(() {
          _news = news;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Future.microtask(() {
          if (mounted) {
            Get.back();
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Future.microtask(() {
        if (mounted) {
          Get.back();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_news == null) {
      return Scaffold(
        appBar: AppBar(title: Text('News')),
        body: Center(child: Text('News not found')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Hero Image
          _buildModernAppBar(context),

          // Article Content
          SliverToBoxAdapter(child: _buildArticleContent(context)),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    final news = _news!;
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => safePop(context: context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF2D3748)),
            onPressed: () => _shareNews(context),
          ),
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                news.coverImage ??
                    'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=400&h=300&fit=crop',
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
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleContent(BuildContext context) {
    final news = _news!;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Title
            Text(
              news.title.capitalize!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
                height: 1.3,
              ),
            ),

            const SizedBox(height: 20),

            // Article Meta Info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    news.category.capitalize!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Icon(Icons.access_time, color: Colors.grey[500], size: 16),
                const SizedBox(width: 4),
                Text(
                  toAgoDate(news.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                // Reading time estimate
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${_estimateReadingTime(news.content)} min read",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Article Content with Markdown Support
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: MarkdownBody(
                data: news.content,
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                    height: 1.3,
                  ),
                  h2: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                    height: 1.3,
                  ),
                  h3: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                    height: 1.3,
                  ),
                  p: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF4A5568),
                    height: 1.6,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  em: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF4A5568),
                  ),
                  code: TextStyle(
                    backgroundColor: Colors.grey[200],
                    color: const Color(0xFF2D3748),
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  blockquote: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                    // borderLeft: BorderSide(
                    //   color: const Color(0xFF667eea),
                    //   width: 4,
                    // ),
                  ),
                  listBullet: const TextStyle(
                    color: Color(0xFF667eea),
                    fontSize: 16,
                  ),
                  tableBorder: TableBorder.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                  tableHead: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  tableBody: TextStyle(color: const Color(0xFF4A5568)),
                ),
                selectable: true,
                onTapLink: (text, href, title) {
                  // TODO: Handle link taps
                  if (href != null) {
                    // You can implement URL launcher here
                    logger.d('Tapped link: $href');
                  }
                },
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            // _buildActionButtons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  int _estimateReadingTime(String content) {
    // Rough estimation: 200 words per minute
    final wordCount = content.split(' ').length;
    return (wordCount / 200).ceil().clamp(1, 60);
  }

  Future<void> _shareNews(BuildContext context) async {
    if (_news == null) return;

    try {
      final shareLink = ShareUtils.generateNewsLink(_news!.id);
      final shareText = '${_news!.title}\n\n$shareLink';

      await Share.share(shareText, subject: _news!.title);
    } catch (e) {
      logger.e('Error sharing news: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share news'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
