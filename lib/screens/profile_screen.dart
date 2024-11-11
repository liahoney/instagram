import 'package:flutter/material.dart';
import '../models/profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 기본 이미지 리스트
    final baseImages = [
      'assets/images/post1.png',
      'assets/images/post2.png',
      'assets/images/post3.png',
      'assets/images/post4.png',
      'assets/images/post5.png',
    ];
    
    // 이미지 리스트를 3번 반복하여 15개의 이미지 생성
    final feedImages = [
      ...baseImages,  // 1-5
      ...baseImages,  // 6-10
      ...baseImages,  // 11-15
    ];
    
    // 프로필 데이터 업데이트
    final profile = Profile(
      username: 'flutter_developer',
      profileImageUrl: 'assets/images/profile.png',
      posts: feedImages.length,  // 15개로 업데이트됨
      followers: 1234,
      following: 321,
      fullName: 'Flutter Developer',
      bio: '플러터 개발자입니다 👨‍💻\nUI/UX 디자인에 관심이 많습니다 🎨',
      postImages: feedImages,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(profile.username),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(profile),
                _buildProfileInfo(profile),
                _buildActionButtons(),
                const Divider(height: 1),
              ],
            ),
          ),
          _buildPostGrid(profile),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Profile profile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(profile.profileImageUrl), // NetworkImage에서 AssetImage로 변경
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('게시물', profile.posts),
                _buildStatColumn('팔로워', profile.followers),
                _buildStatColumn('팔로잉', profile.following),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(Profile profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.fullName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(profile.bio),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('프로필 편집'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                child: const Icon(Icons.person_add_outlined, size: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.grid_on),
              onPressed: () {},
              iconSize: 28,
            ),
            IconButton(
              icon: const Icon(Icons.person_pin_outlined),
              onPressed: () {},
              iconSize: 28,
              color: Colors.grey,
            ),
          ],
        ),
        const Divider(
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }

  Widget _buildPostGrid(Profile profile) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Image.asset(
            profile.postImages[index],
            fit: BoxFit.cover,
          );
        },
        childCount: profile.postImages.length,
      ),
    );
  }
} 