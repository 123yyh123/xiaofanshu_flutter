import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/utils/comment_util.dart';
import 'package:xiaofanshu_flutter/utils/store_util.dart';

import '../static/default_data.dart';

class ItemView extends StatefulWidget {
  final int id;
  final String coverPicture;
  final String noteTitle;
  final String authorAvatar;
  final String authorName;
  final int authorId;
  int notesLikeNum;
  final int notesType;
  bool isLike;

  ItemView({
    super.key,
    required String id,
    required String authorId,
    required this.coverPicture,
    required this.noteTitle,
    required this.authorAvatar,
    required this.authorName,
    required this.notesLikeNum,
    required this.notesType,
    required this.isLike,
  })  : id = int.parse(id),
        authorId = int.parse(authorId);

  @override
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  late RxString coverPicture;
  late RxString noteTitle;
  late RxString authorAvatar;
  late RxString authorName;
  late RxInt notesLikeNum;
  late RxInt notesType;
  late RxBool isLike;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    coverPicture = widget.coverPicture.obs;
    noteTitle = widget.noteTitle.obs;
    authorAvatar = widget.authorAvatar.obs;
    authorName = widget.authorName.obs;
    notesLikeNum = widget.notesLikeNum.obs;
    notesType = widget.notesType.obs;
    isLike = widget.isLike.obs;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTap: () {
          notesType.value == 0
              ? Get.toNamed('/notes/detail/image', arguments: widget.id)
              : Get.toNamed('/notes/detail/video', arguments: widget.id);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 0,
                      maxHeight: 250,
                      minWidth: double.infinity,
                      maxWidth: double.infinity,
                    ),
                    child: Builder(builder: (context) {
                      return CachedNetworkImage(
                        imageUrl: coverPicture.value,
                        fit: BoxFit.cover,
                        // 缓存固定宽高的图片
                        maxWidthDiskCache: context.width.toInt(),
                        maxHeightDiskCache: context.height.toInt(),
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) {
                          return Center(
                            child: CircularProgressIndicator(
                              value: downloadProgress.progress,
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.running_with_errors_sharp,
                                  color: Colors.black45,
                                ),
                                Text(
                                  '加载失败了',
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
                notesType.value == 0
                    ? const SizedBox()
                    : Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 12,
                          ).paddingAll(2),
                        ),
                      ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  noteTitle.value.fixAutoLines(),
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 14,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: Image(
                            image: NetworkImage(authorAvatar.value),
                            width: 20,
                            height: 20,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          authorName.value,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    LikeButton(
                        mainAxisAlignment: MainAxisAlignment.end,
                        likeCountPadding: const EdgeInsets.all(0),
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked
                                ? CustomColor.primaryColor
                                : Colors.black54,
                            size: 16,
                          );
                        },
                        isLiked: isLike.value,
                        likeCount: notesLikeNum.value,
                        onTap: (bool isLiked) async {
                          setState(() {
                            isLike.value = !isLike.value;
                            if (isLike.value) {
                              notesLikeNum.value++;
                            } else {
                              notesLikeNum.value--;
                            }
                          });
                          int userId = int.parse(jsonDecode(
                                  await readData('userInfo') ??
                                      jsonEncode(DefaultData.user))['id']
                              .toString());
                          NoteApi.praiseNotes(
                              widget.id, userId, widget.authorId);
                          return !isLiked;
                        }),
                    // GestureDetector(
                    //   onTap: () async {
                    //     setState(() {
                    //       isLike.value = !isLike.value;
                    //       if (isLike.value) {
                    //         notesLikeNum.value++;
                    //         // 触发动画
                    //       } else {
                    //         notesLikeNum.value--;
                    //       }
                    //     });
                    //     int userId = int.parse(jsonDecode(
                    //             await readData('userInfo') ??
                    //                 jsonEncode(DefaultData.user))['id']
                    //         .toString());
                    //     NoteApi.praiseNotes(widget.id, userId, widget.authorId);
                    //   },
                    //   child: Row(
                    //     children: [
                    //       Icon(
                    //         isLike.value
                    //             ? Icons.favorite
                    //             : Icons.favorite_border,
                    //         size: 16,
                    //         color: isLike.value
                    //             ? CustomColor.primaryColor
                    //             : Colors.black54,
                    //       ),
                    //       const SizedBox(width: 4),
                    //       notesLikeNum.value == 0
                    //           ? const SizedBox(width: 0)
                    //           : Text(
                    //               notesLikeNum.value.toString(),
                    //               style: const TextStyle(
                    //                 fontSize: 14,
                    //                 color: Colors.black54,
                    //               ),
                    //             ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ).marginOnly(top: 6),
              ],
            ).paddingAll(6),
          ],
        ),
      ),
    );
  }
}
