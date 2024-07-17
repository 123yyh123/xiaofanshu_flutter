import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/utils/comment_util.dart';

class ItemView extends StatefulWidget {
  final String coverPicture;
  final String noteTitle;
  final String authorAvatar;
  final String authorName;
  final int notesLikeNum;
  final int notesType;
  final bool isLike;

  const ItemView({
    super.key,
    required this.coverPicture,
    required this.noteTitle,
    required this.authorAvatar,
    required this.authorName,
    required this.notesLikeNum,
    required this.notesType,
    required this.isLike,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              child: Image(
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  );
                },
                image: NetworkImage(coverPicture.value),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                noteTitle.value.fixAutoLines(),
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 16,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
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
                          width: 25,
                          height: 25,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        authorName.value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        isLike.value ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isLike.value
                            ? CustomColor.primaryColor
                            : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      notesLikeNum.value == 0
                          ? const SizedBox(width: 0)
                          : Text(
                              notesLikeNum.value.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                    ],
                  ),
                ],
              ).marginOnly(top: 6),
            ],
          ).paddingAll(6),
        ],
      ),
    );
  }
}
