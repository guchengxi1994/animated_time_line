library;

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class TimelineItem {
  final int id;
  final String title;
  final String? description;
  final String? decorationImage;
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
        decorationImage:
            'https://img1.baidu.com/it/u=3447440298,1362600045&fm=253&fmt=auto&app=138&f=JPEG?w=750&h=500',
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
  const _TimelineItemWidget({required this.item, required this.notifier});
  final TimelineItem item;
  final ValueNotifier<int> notifier;

  @override
  State<_TimelineItemWidget> createState() => __TimelineItemWidgetState();
}

class __TimelineItemWidgetState extends State<_TimelineItemWidget> {
  bool showSubItem = false;

  @override
  Widget build(BuildContext context) {
    bool isThis = widget.notifier.value == widget.item.id;

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      width: isThis ? 500 : 300,
      child: Row(
        children: [
          Container(
            height: double.infinity,
            decoration: widget.item.decorationImage != null
                ? BoxDecoration(
                    image: widget.item.decorationImage!.startsWith("http")
                        ? DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(widget.item.decorationImage!))
                        : DecorationImage(
                            fit: BoxFit.cover,
                            image:
                                FileImage(File(widget.item.decorationImage!))))
                : null,
            width: 300,
            child: Text(widget.item.title),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            width: isThis ? 200 : 0,
            child: isThis
                ? Column(
                    children:
                        widget.item.subItems.map((e) => Text(e.title)).toList(),
                  )
                : Container(),
          )
        ],
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
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.items.map((e) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _TimelineItemWidget(item: e, notifier: notifier),
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
                                if (i > 1) {
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
