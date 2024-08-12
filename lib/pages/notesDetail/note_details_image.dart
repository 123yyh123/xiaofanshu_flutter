import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:xiaofanshu_flutter/apis/app.dart';
import 'package:xiaofanshu_flutter/config/custom_icon.dart';
import 'package:xiaofanshu_flutter/controller/note_details_image_controller.dart';
import 'package:get/get.dart';
import 'package:xiaofanshu_flutter/static/custom_color.dart';
import 'package:xiaofanshu_flutter/utils/Adapt.dart';
import 'package:xiaofanshu_flutter/utils/comment_util.dart';

class NoteDetailsImage extends StatefulWidget {
  const NoteDetailsImage({super.key});

  @override
  State<NoteDetailsImage> createState() => _NoteDetailsImageState();
}

class _NoteDetailsImageState extends State<NoteDetailsImage> {
  NoteDetailsImageController noteDetailsImageController = Get.find();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 25,
          ),
          onPressed: () {
            Get.back();
          },
        ).marginOnly(left: 5),
        leadingWidth: 28,
        title: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(
                            noteDetailsImageController.notes.value.avatarUrl,
                            scale: 1.0),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Adapt.setRpx(200),
                    ),
                    child: Text(
                      noteDetailsImageController.notes.value.nickname,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              noteDetailsImageController.notes.value.belongUserId ==
                      noteDetailsImageController.userInfo.value.id
                  ? GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.more_horiz,
                        size: 25,
                        color: Colors.black,
                      ))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            noteDetailsImageController.notes.value.isFollow =
                                !noteDetailsImageController
                                    .notes.value.isFollow;
                            noteDetailsImageController.notes.refresh();
                            UserApi.attentionUser(
                              noteDetailsImageController.userInfo.value.id,
                              noteDetailsImageController
                                  .notes.value.belongUserId,
                            );
                          },
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: noteDetailsImageController
                                        .notes.value.isFollow
                                    ? CustomColor.unselectedColor
                                    : CustomColor.primaryColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              noteDetailsImageController.notes.value.isFollow
                                  ? '已关注'
                                  : '关注',
                              style: TextStyle(
                                fontSize: 12,
                                color: noteDetailsImageController
                                        .notes.value.isFollow
                                    ? CustomColor.unselectedColor
                                    : CustomColor.primaryColor,
                              ),
                            ).paddingOnly(
                                left: 20, right: 20, top: 5, bottom: 5),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            CustomIcon.share,
                            size: 25,
                            color: Colors.black,
                          ),
                        ).paddingOnly(left: 15, right: 10),
                      ],
                    ),
            ],
          ),
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: Adapt.setRpx(
                        noteDetailsImageController.swiperHeight.value),
                    maxWidth: double.infinity,
                  ),
                  child: Swiper(
                    itemBuilder: (context, index) {
                      return noteDetailsImageController
                                  .notes.value.notesResources[index].url ==
                              ''
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : CachedNetworkImage(
                              imageUrl: noteDetailsImageController
                                  .notes.value.notesResources[index].url,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error,
                                size: 50,
                              ),
                            );
                    },
                    indicatorLayout: PageIndicatorLayout.WARM,
                    itemCount: noteDetailsImageController
                        .notes.value.notesResources.length,
                    pagination: const SwiperPagination(),
                    loop: false,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    noteDetailsImageController.notes.value.title.fixAutoLines(),
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ).paddingAll(10),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
