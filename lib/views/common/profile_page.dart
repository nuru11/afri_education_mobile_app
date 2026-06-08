import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/controllers/controllers.dart';
import 'package:vector_academy/utils/navigation_utils.dart';
import 'package:vector_academy/views/views.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) => Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              _buildSliverAppBar(context, controller),
              // Profile Content
              SliverToBoxAdapter(
                child: _buildProfileContent(context, controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    ProfileController controller,
  ) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: Colors.blue[600],
      elevation: 0,
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => safePop(context: context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.white),
          onPressed: () => controller.navigateToEditProfile(),
        ),
        SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[600]!, Colors.blue[800]!],
                ),
              ),
            ),

            // Profile picture with modern styling
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => controller.showProfileImagePickerOptions(),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.2),
                            blurRadius: 30,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipOval(child: _buildProfilePicture(controller)),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    controller.fullName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    controller.user?.grade.name ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    ProfileController controller,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Information
          Text(
            'Profile Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),

          _buildProfileField(
            context,
            Icons.person_outline,
            "Full Name",
            controller.fullName,
          ),

          SizedBox(height: 20),

          _buildProfileField(
            context,
            Icons.school_outlined,
            "Class/Grade",
            controller.user?.grade.name ?? '',
          ),

          SizedBox(height: 20),

          _buildProfileField(
            context,
            Icons.phone_outlined,
            "Phone Number",
            controller.user?.phoneNumber ?? '',
          ),

          SizedBox(height: 40),

          // Agent Section
          Text(
            'Become an Agent',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),

          _buildActionButton(
            context,
            Icons.business_center,
            "Agent Program",
            "Apply to become an agent and earn coins",
            () => Get.toNamed(VIEWS.agentStatus.path),
          ),

          SizedBox(height: 40),

          // Action Buttons
          Text(
            'Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),

          _buildActionButton(
            context,
            Icons.help_outline,
            "Help & Support",
            "Get help and contact support",
            () => controller.openSupport(),
          ),

          SizedBox(height: 12),

          _buildActionButton(
            context,
            Icons.info_outline,
            "App Information",
            "Learn more about the app",
            () => controller.openAppInfo(),
          ),

          SizedBox(height: 32),

          // Delete Account Button
          _buildActionButton(
            context,
            Icons.delete_forever,
            "Delete Account",
            "Permanently delete your account and data",
            () => controller.showDeleteAccountDialog(),
            isDestructive: true,
          ),

          SizedBox(height: 20),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => controller.logout(),
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileField(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[600], size: 20),
              SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDestructive
            ? Border.all(color: Colors.red[200]!, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDestructive ? Colors.red[50] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? Colors.red[600] : Colors.grey[700],
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? Colors.red[700]
                              : Colors.grey[800],
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDestructive
                              ? Colors.red[500]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDestructive ? Colors.red[300] : Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(ProfileController controller) {
    // Show selected image if available (for preview before upload)
    if (controller.selectedProfileImage != null) {
      return Image.file(
        controller.selectedProfileImage!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }

    // Show network image if profile picture exists
    final profilePicUrl = controller.user?.profilePic;
    if (profilePicUrl != null && profilePicUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: profilePicUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[100]!, Colors.blue[200]!],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[100]!, Colors.blue[200]!],
            ),
          ),
          child: Icon(Icons.person, size: 60, color: Colors.blue[700]),
        ),
      );
    }

    // Default placeholder
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[100]!, Colors.blue[200]!],
        ),
      ),
      child: Icon(Icons.person, size: 60, color: Colors.blue[700]),
    );
  }
}
