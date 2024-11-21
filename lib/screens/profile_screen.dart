import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Firebase Auth 추가
import '../models/profile.dart';
import '../models/post.dart';  // Post 클래스 import 추가
import 'login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userEmail = 'Loading...';  // 초기값 설정
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserEmail();  // 사용자 이메일 로드
  }

  // 사용자 이메일을 가져오는 함수
  Future<void> _loadUserEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        setState(() {
          userEmail = user.email ?? 'No email';  // 이메일이 없는 경우 기본값 설정
        });
      }
    } catch (e) {
      print('사용자 정보 로드 오류: $e');
      if (mounted) {
        setState(() {
          userEmail = 'Error loading email';
        });
      }
    }
  }

  // 로그아웃 처리
  Future<void> _handleLogout() async {
    try {
      // Google 로그아웃
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      
      // Firebase 로그아웃
      await FirebaseAuth.instance.signOut();
      
      if (mounted) {
        // 로그아웃 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그아웃되었습니다')),
        );
        
        // 로그인 화면으로 이동
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('로그아웃 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 실패: $e')),
        );
      }
    }
  }

  // 프로필 이미지 선택
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
        await _uploadProfileImage();
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 실패: $e')),
      );
    }
  }
  
  // 프로필 이미지 업로드
  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) return;
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // Storage에 이미지 업로드
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profiles/${user.uid}/profile.jpg');
          
      await storageRef.putFile(_imageFile!);
      
      // 업로드된 이미지의 URL 가져오기
      final imageUrl = await storageRef.getDownloadURL();
      
      // Firestore에 URL 업데이트
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'photoURL': imageUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 이미지가 업데이트되었습니다')),
        );
      }
    } catch (e) {
      print('이미지 업로드 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 업로드 실패: $e')),
        );
      }
    }
  }

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
    
    // 프로필 데이터 업데이트 - 이메일 사용
    final profile = Profile(
      username: userEmail,  // 하드코딩된 값 대신 실제 이메일 사용
      profileImageUrl: 'assets/images/profile.png',
      posts: feedImages.length,
      followers: 1234,
      following: 321,
      fullName: 'Flutter Developer',
      bio: '플러터 개발자입니다 👨‍💻\nUI/UX 디자인에 관심이 많습니다 🎨',
      postImages: feedImages,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(profile.username),  // 이메일이 표시됨
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {
              // CreatePostScreen으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePostScreen(),
                ),
              );
            },
            tooltip: '게시글 작성',
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,  // 로그아웃 함수 연결
            tooltip: '로그아웃',
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
          Stack(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (profile.photoURL != null
                          ? NetworkImage(profile.photoURL!) as ImageProvider
                          : const AssetImage('assets/images/profile.png')),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
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
                  onPressed: () {
                    // EditProfileScreen으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('에러가 발생했습니다: ${snapshot.error}')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final posts = snapshot.data?.docs ?? [];
        
        if (posts.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('게시글이 없습니다')),
          );
        }

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = Post.fromFirestore(
                posts[index].data() as Map<String, dynamic>,
                posts[index].id,
              );
              
              // 첫 번째 미디어 파일만 표시
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(post: post),
                    ),
                  );
                },
                child: Image.network(
                  post.mediaUrls.first,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.error));
                  },
                ),
              );
            },
            childCount: posts.length,
          ),
        );
      },
    );
  }
} 