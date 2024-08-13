import '../utils/date_show_util.dart';

class Comment {
  String id;
  String content;
  String province;
  int commentUserId;
  String commentUserName;
  String commentUserAvatar;
  String parentId;
  int replyUserId;
  String replyUserName;
  String pictureUrl;
  int commentLikeNum;
  int commentReplyNum;
  int notesId;
  bool isTop;
  bool isLike;
  int createTime;
  String showTime;

  Comment({
    required this.id,
    required this.content,
    required this.province,
    required commentUserId,
    required this.commentUserName,
    required this.commentUserAvatar,
    required this.parentId,
    required replyUserId,
    required this.replyUserName,
    String? pictureUrl,
    required this.commentLikeNum,
    int? commentReplyNum,
    required notesId,
    required this.isTop,
    required this.isLike,
    required String createTime,
  })  : commentUserId = int.parse(commentUserId.toString()),
        replyUserId = int.parse(replyUserId.toString()),
        notesId = int.parse(notesId.toString()),
        createTime = int.parse(createTime.toString()),
        commentReplyNum =
            commentReplyNum == null ? 0 : int.parse(commentReplyNum.toString()),
        pictureUrl = pictureUrl ?? "",
        showTime = DateShowUtil.showDateWithTime(int.parse(createTime));

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      province: json['province'],
      commentUserId: json['commentUserId'],
      commentUserName: json['commentUserName'],
      commentUserAvatar: json['commentUserAvatar'],
      parentId: json['parentId'],
      replyUserId: json['replyUserId'],
      replyUserName: json['replyUserName'],
      pictureUrl: json['pictureUrl'],
      commentLikeNum: json['commentLikeNum'],
      commentReplyNum: json['commentReplyNum'],
      notesId: json['notesId'],
      isTop: json['isTop'],
      isLike: json['isLike'],
      createTime: json['createTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'province': province,
      'commentUserId': commentUserId,
      'commentUserName': commentUserName,
      'commentUserAvatar': commentUserAvatar,
      'parentId': parentId,
      'replyUserId': replyUserId,
      'replyUserName': replyUserName,
      'pictureUrl': pictureUrl,
      'commentLikeNum': commentLikeNum,
      'commentReplyNum': commentReplyNum,
      'notesId': notesId,
      'isTop': isTop,
      'isLike': isLike,
      'createTime': createTime,
    };
  }
}

class CommentVO {
  Comment comment;
  List<Comment> childCommentList = [];
  bool hasMore = true;
  bool isLoadMore = false;

  int page;
  int size;

  CommentVO({
    required this.comment,
  })  : page = 1,
        size = 10;
}
