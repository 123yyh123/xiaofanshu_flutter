import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class MapImageUtil {
  static Future<ByteData> urlToImage({
    String networkImage = '',
    Size size = const Size(double.maxFinite, double.maxFinite),
    Alignment alignment = Alignment.center,
    double devicePixelRatio = 1.0,
    double pixelRatio = 1.0,
  }) async {
    Widget widget = await imageFromByteData(networkImage);
    RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    RenderView renderView = RenderView(
      child: RenderPositionedBox(alignment: alignment, child: repaintBoundary),
      configuration: ViewConfiguration(
        physicalConstraints: BoxConstraints(
          minWidth: size.width,
          maxWidth: size.width,
          minHeight: size.height,
          maxHeight: size.height,
        ),
        logicalConstraints: BoxConstraints(
          minWidth: size.width,
          maxWidth: size.width,
          minHeight: size.height,
          maxHeight: size.height,
        ),
        devicePixelRatio: devicePixelRatio,
      ),
      view: WidgetsBinding.instance.platformDispatcher.views.first,
    );

    PipelineOwner pipelineOwner = PipelineOwner();
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
    RenderObjectToWidgetElement rootElement = RenderObjectToWidgetAdapter(
      container: repaintBoundary,
      child: widget,
    ).attachToRenderTree(buildOwner);
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    ui.Image image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!;
  }

  static Future<Widget> imageFromByteData(String name) async {
    NetworkImage provider = NetworkImage(name);
    await precacheImage(provider, Get.context!);
    return Container(
      alignment: Alignment.center,
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1971FF), Color(0xFFD4E4FF)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Container(
          alignment: Alignment.center,
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: provider,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
