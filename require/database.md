# Firestore 규칙 (유저 정보, 업로드 데이터 등)

## 1. Users

### Users Collection

users/{uid}

- "uid": "string", // Firebase Auth UID
- "email": "string", // 사용자 이메일
- "displayName": "string", // 표시 이름
- "photoURL": "string", // 프로필 사진 URL
- "createdAt": "timestamp",// 계정 생성 시간
- "updatedAt": "timestamp" // 정보 수정 시간

## 2. Posts
게시글 관련 정보를 저장하는 컬렉션입니다.

### Posts Collection

- "postId": "string", // 게시글 고유 ID
- "authorId": "string", // 작성자 UID
- "caption": "string", // 게시글 내용
- "mediaUrls": ["string"], // 미디어(이미지/동영상) URL 배열
- "mediaTypes": ["string"], // 미디어 타입 배열 ("image" or "video")
- "likes": ["string"], // 좋아요 누른 사용자 UID 배열
- "createdAt": "timestamp",// 작성 시간
- "updatedAt": "timestamp" // 수정 시간

### Comments Collection (Sub-collection)

posts/{postId}/comments/{commentId}

- "commentId": "string", // 댓글 고유 ID
- "authorId": "string", // 작성자 UID
- "content": "string", // 댓글 내용
- "createdAt": "timestamp",// 작성 시간
- "updatedAt": "timestamp" // 수정 시간

## 3. Firebase Storage
미디어 파일 저장소 구조입니다.

### 디렉토리 구조

├── profiles/
│   └── {uid}/
│       └── profile.jpg    // 프로필 이미지
│
└── posts/
    └── {postId}/
        └── media/
            ├── image1.jpg     // 이미지 파일
            ├── image2.jpg
            ├── video1.mp4     // 동영상 파일
            └── video2.mp4

## 데이터 관리 지침

1. 사용자 데이터
   - 민감한 개인정보는 저장하지 않음
   - 프로필 이미지는 5MB 이하로 제한
   - 이메일 인증 필수

2. 게시글 데이터
   - 이미지는 게시글당 최대 10장
   - 각 이미지 크기는 10MB 이하
   - 부적절한 콘텐츠 필터링

3. 저장소 관리
   - 미사용 파일 주기적 정리
   - 백업 정책 수립
   - 용량 모니터링
   

## 보안 규칙

### Firestore 보안 규칙
- 사용자 문서: 본인만 쓰기 기능, 인증된 사용자 읽기 가능
- 게시글 문서: 인증된 사용자 읽기/생성 가능, 작성자만 수정/삭제 가능

### Storage 보안 규칙
- 프로필 이미지: 본인만 업로드 가능, 모든 사용자 읽기 가능
- 이미지 파일: 이미지 형식만 허용
- 게시글 미디어:
  - 인증된 사용자만 업로드 가능
  - 이미지: jpg/png 형식
  - 동영상: mp4 형식
  - 작성자만 삭제 가능
  - 모든 사용자 읽기 가능

## 구현 계획

### 1. 인증 기능
- [x] Google 로그인 구현
- [ ] 로그인 상태 유지
- [ ] 로그아웃 기능
- [ ] 사용자 프로필 정보 Firestore에 저장

### 2. 프로필 관리
- [ ] 프로필 이미지 업로드
  - [ ] Storage에 이미지 저장
  - [ ] URL을 Firestore user 문서에 업데이트
- [ ] 프로필 정보 수정
- [ ] 프로필 화면 표시

### 3. 게시글 기능
- [ ] 게시글 작성
  - [ ] 이미지/동영상 선택
  - [ ] Storage에 미디어 파일 업로드
  - [ ] Firestore에 게시글 정보 저장
- [ ] 게시글 표시
  - [ ] 미디어 파일 로드
  - [ ] 작성자 정보 표시
- [ ] 게시글 수정/삭제

### 4. 댓글 기능
- [ ] 댓글 작성
- [ ] 댓글 표시
- [ ] 댓글 삭제

### 6. 피드 기능
- [ ] 최신 게시글 목록
- [ ] 무한 스크롤
- [ ] 미디어 파일 캐싱

### 7. 보안 규칙 적용
- [ ] Firestore 규칙 설정
- [ ] Storage 규칙 설정
- [ ] 사용자 권한 검증

### 8. 성능 최적화
- [ ] 이미지 리사이징
- [ ] 데이터 캐싱
- [ ] 페이지네이션

### 9. 에러 처리
- [ ] 네트워크 오류 처리
- [ ] 권한 오류 처리
- [ ] 사용자 피드백 제공