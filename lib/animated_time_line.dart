library;

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class TimelineDecorationImage {
  final String image;
  // image type: network or file or asset
  final String type;

  TimelineDecorationImage({required this.image, required this.type});

  static TimelineDecorationImage mock() {
    return TimelineDecorationImage(
        image:
            'https://img1.baidu.com/it/u=3447440298,1362600045&fm=253&fmt=auto&app=138&f=JPEG?w=750&h=500',
        type: 'network');
  }

  Widget build({double width = 300, double height = 300}) {
    Widget img;

    if (type == 'network') {
      img = Image.network(
        image,
        fit: BoxFit.cover,
      );
    } else if (type == 'file') {
      img = Image.file(
        File(image),
        fit: BoxFit.cover,
      );
    } else if (type == 'asset') {
      img = Image.asset(
        image,
        fit: BoxFit.cover,
      );
    } else {
      img = Container();
    }

    return SizedBox(
      width: width,
      height: height,
      child: img,
    );
  }
}

class TimelineItem {
  final int id;
  final String title;
  final String? description;
  final TimelineDecorationImage? decorationImage;
  final List<SubTimelineItem> subItems;

  TimelineItem({
    required this.id,
    required this.title,
    this.description,
    this.decorationImage,
    this.subItems = const [],
  });

  static TimelineItem mock(int id) {
    return TimelineItem(
        id: id,
        title: 'Title $id',
        description: 'Description',
        decorationImage: TimelineDecorationImage.mock(),
        subItems: [
          SubTimelineItem(
            title: 'Sub Title1',
            description: 'Sub Description',
          ),
          SubTimelineItem(
            title: 'Sub Title2',
            description: 'Sub Description',
          )
        ]);
  }
}

class SubTimelineItem {
  final String title;
  final String? description;

  SubTimelineItem({
    required this.title,
    this.description,
  });
}

class _TimelineItemWidget extends StatefulWidget {
  const _TimelineItemWidget(
      {required this.item, required this.notifier, required this.height});
  final TimelineItem item;
  final ValueNotifier<int> notifier;
  final double height;

  @override
  State<_TimelineItemWidget> createState() => __TimelineItemWidgetState();
}

class __TimelineItemWidgetState extends State<_TimelineItemWidget> {
  bool showSubItem = false;

  @override
  Widget build(BuildContext context) {
    bool isThis = widget.notifier.value == widget.item.id;

    return Material(
      elevation: isThis ? 4 : 0,
      child: AnimatedContainer(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(isThis ? 4 : 0)),
        duration: Duration(milliseconds: 500),
        width: isThis ? 500 : 300,
        child: Row(
          children: [
            SizedBox(
              height: widget.height,
              width: 300,
              child: Stack(
                children: [
                  SizedBox.expand(),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Builder(builder: (c) {
                      return widget.item.decorationImage?.build(
                              width: 300, height: widget.height * 0.6) ??
                          SizedBox(
                            width: 300,
                            height: widget.height * 0.6,
                          );
                    }),
                  ),
                  Positioned(
                      top: 0.5 * widget.height,
                      child: Container(
                        width: 300,
                        height: 0.5 * widget.height,
                        color: Colors.white.withValues(alpha: 0.5),
                      ))
                ],
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              width: isThis ? 200 : 0,
              child: isThis
                  ? Column(
                      children: widget.item.subItems
                          .map((e) => Text(e.title))
                          .toList(),
                    )
                  : Container(),
            )
          ],
        ),
      ),
    );
  }
}

class AnimatedTimeLine extends StatefulWidget {
  const AnimatedTimeLine(
      {super.key, this.height = 400, this.width, required this.items});
  final double height;
  final double? width;
  final List<TimelineItem> items;

  @override
  State<AnimatedTimeLine> createState() => _AnimatedTimeLineState();
}

class _AnimatedTimeLineState extends State<AnimatedTimeLine> {
  late double width = widget.width ?? MediaQuery.of(context).size.width;
  late final ValueNotifier<int> notifier = ValueNotifier(widget.items.first.id);
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.offset >= controller.position.maxScrollExtent) {
        notifier.value = widget.items.last.id;
      } else if (controller.offset <= controller.position.minScrollExtent) {
        notifier.value = widget.items.first.id;
      } else {
        int index = ((controller.offset + 200) / 300).floor();
        if (index >= 0 && index < widget.items.length) {
          notifier.value = widget.items[index].id;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: notifier,
        builder: (c, v, _) {
          return SizedBox(
            height: widget.height,
            width: width,
            child: Column(
              spacing: 10,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.items.map((e) {
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: _TimelineItemWidget(
                          item: e,
                          notifier: notifier,
                          height: widget.height,
                        ),
                      );
                    }).toList(),
                  ),
                )),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  height: 30,
                  child: Row(
                    spacing: 10,
                    children: widget.items
                        .mapIndexed((i, e) => GestureDetector(
                              onTap: () {
                                notifier.value = e.id;
                                if (i > 0) {
                                  controller.animateTo((i - 1) * 300 + 200,
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.easeInOut);
                                }
                              },
                              child: Container(
                                width: (width -
                                        20 -
                                        (widget.items.length - 1) * 10) /
                                    widget.items.length,
                                decoration: BoxDecoration(
                                  color: e.id == v ? Colors.blue : Colors.grey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                )
              ],
            ),
          );
        });
  }
}
