import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:reorderables/reorderables.dart';

import '../rendering/wrap.dart';
import './passthrough_overlay.dart';
import './typedefs.dart';
import './wrap.dart';
import 'reorderable_mixin.dart';

class ReorderableWrap extends StatefulWidget {
  ReorderableWrap({
    required this.children,
    required this.onReorder,
    this.header,
    this.footer,
    this.controller,
    this.direction = Axis.horizontal,
    this.scrollDirection = Axis.vertical,
    this.scrollPhysics,
    this.padding,
    this.buildItemsContainer,
    this.buildDraggableFeedback,
    this.needsLongPressDraggable = true,
    this.alignment = WrapAlignment.start,
    this.spacing = 0.0,
    this.runAlignment = WrapAlignment.start,
    this.runSpacing = 0.0,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.minMainAxisCount,
    this.maxMainAxisCount,
    this.onNoReorder,
    this.onReorderStarted,
    this.reorderAnimationDuration = const Duration(milliseconds: 200),
    this.scrollAnimationDuration = const Duration(milliseconds: 200),
    this.ignorePrimaryScrollController = false,
    this.enableReorder = true,
    Key? key,
  }) : super(key: key);
  final List<Widget>? header;
  final Widget? footer;
  final ScrollController? controller;
  final List<Widget> children;
  final Axis direction;
  final Axis scrollDirection;
  final ScrollPhysics? scrollPhysics;
  final EdgeInsets? padding;
  final ReorderCallback onReorder;
  final NoReorderCallback? onNoReorder;
  final ReorderStartedCallback? onReorderStarted;
  final BuildItemsContainer? buildItemsContainer;
  final BuildDraggableFeedback? buildDraggableFeedback;
  final bool needsLongPressDraggable;
  final WrapAlignment alignment;
  final double spacing;
  final WrapAlignment runAlignment;
  final double runSpacing;
  final WrapCrossAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final int? minMainAxisCount;
  final int? maxMainAxisCount;
  final Duration reorderAnimationDuration;
  final Duration scrollAnimationDuration;
  final bool ignorePrimaryScrollController;
  final bool enableReorder;

  @override
  _ReorderableWrapState createState() => _ReorderableWrapState();
}

class _ReorderableWrapState extends State<ReorderableWrap> {
  final GlobalKey _overlayKey =
      GlobalKey(debugLabel: '$ReorderableWrap overlay key');
  late PassthroughOverlayEntry _listOverlayEntry;

  @override
  void initState() {
    super.initState();
    _listOverlayEntry = PassthroughOverlayEntry(
      opaque: false,
      builder: (BuildContext context) {
        return _ReorderableWrapContent(
          header: widget.header,
          footer: widget.footer,
          children: widget.children,
          direction: widget.direction,
          scrollDirection: widget.scrollDirection,
          scrollPhysics: widget.scrollPhysics,
          onReorder: widget.onReorder,
          onNoReorder: widget.onNoReorder,
          onReorderStarted: widget.onReorderStarted,
          padding: widget.padding,
          buildItemsContainer: widget.buildItemsContainer,
          buildDraggableFeedback: widget.buildDraggableFeedback,
          needsLongPressDraggable: widget.needsLongPressDraggable,
          alignment: widget.alignment,
          spacing: widget.spacing,
          runAlignment: widget.runAlignment,
          runSpacing: widget.runSpacing,
          crossAxisAlignment: widget.crossAxisAlignment,
          textDirection: widget.textDirection,
          verticalDirection: widget.verticalDirection,
          minMainAxisCount: widget.minMainAxisCount,
          maxMainAxisCount: widget.maxMainAxisCount,
          controller: widget.controller,
          reorderAnimationDuration: widget.reorderAnimationDuration,
          scrollAnimationDuration: widget.scrollAnimationDuration,
          enableReorder: widget.enableReorder,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final PassthroughOverlay passthroughOverlay = PassthroughOverlay(
        key: _overlayKey,
        initialEntries: <PassthroughOverlayEntry>[
          _listOverlayEntry,
        ]);
    return widget.ignorePrimaryScrollController
        ? PrimaryScrollController.none(child: passthroughOverlay)
        : passthroughOverlay;
  }
}

class _ReorderableWrapContent extends StatefulWidget {
  _ReorderableWrapContent(
      {required this.children,
      required this.direction,
      required this.scrollDirection,
      required this.scrollPhysics,
      required this.padding,
      required this.onReorder,
      required this.onNoReorder,
      required this.onReorderStarted,
      required this.buildItemsContainer,
      required this.buildDraggableFeedback,
      required this.needsLongPressDraggable,
      required this.alignment,
      required this.spacing,
      required this.runAlignment,
      required this.runSpacing,
      required this.crossAxisAlignment,
      required this.textDirection,
      required this.verticalDirection,
      required this.minMainAxisCount,
      required this.maxMainAxisCount,
      this.header,
      this.footer,
      this.controller,
      this.reorderAnimationDuration = const Duration(milliseconds: 200),
      this.scrollAnimationDuration = const Duration(milliseconds: 200),
      required this.enableReorder});

  final List<Widget>? header;
  final Widget? footer;
  final ScrollController? controller;
  final List<Widget> children;
  final Axis direction;
  final Axis scrollDirection;
  final ScrollPhysics? scrollPhysics;
  final EdgeInsets? padding;
  final ReorderCallback onReorder;
  final NoReorderCallback? onNoReorder;
  final ReorderStartedCallback? onReorderStarted;
  final BuildItemsContainer? buildItemsContainer;
  final BuildDraggableFeedback? buildDraggableFeedback;
  final bool needsLongPressDraggable;

  final WrapAlignment alignment;
  final double spacing;
  final WrapAlignment runAlignment;
  final double runSpacing;
  final WrapCrossAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final int? minMainAxisCount;
  final int? maxMainAxisCount;
  final Duration reorderAnimationDuration;
  final Duration scrollAnimationDuration;
  final bool enableReorder;

  @override
  _ReorderableWrapContentState createState() => _ReorderableWrapContentState();
}

class _ReorderableWrapContentState extends State<_ReorderableWrapContent>
    with TickerProviderStateMixin<_ReorderableWrapContent>, ReorderableMixin {
  static const double _dropAreaMargin = 0.0;
  late Duration _reorderAnimationDuration;
  late Duration _scrollAnimationDuration;
  late ScrollController _scrollController;
  late AnimationController _entranceController;
  late AnimationController _ghostController;
  Widget? _draggingWidget;
  Size? _draggingFeedbackSize;
  late List<BuildContext?> _childContexts;
  late List<Size> _childSizes;
  late List<int> _childIndexToDisplayIndex;
  late List<int> _childDisplayIndexToIndex;
  int _dragStartIndex = -1;
  int _ghostDisplayIndex = -1;
  int _currentDisplayIndex = -1;
  int _nextDisplayIndex = -1;
  bool _scrolling = false;
  final GlobalKey _wrapKey = GlobalKey(debugLabel: '$ReorderableWrap wrap key');
  late List<int> _wrapChildRunIndexes;
  late List<int> _childRunIndexes;
  late List<int> _nextChildRunIndexes;
  late List<Widget?> _wrapChildren;
  late bool enableReorder;
  double _scale = 1; // Initial scale for normal state
  bool _isDroppedOutside = false;
  int? _hoveredIndex;

  Size get _dropAreaSize {
    if (_draggingFeedbackSize == null) {
      return const Size(0, 0);
    }
    return _draggingFeedbackSize! +
        const Offset(_dropAreaMargin, _dropAreaMargin);
  }

  @override
  void initState() {
    super.initState();
    enableReorder = widget.enableReorder;
    _reorderAnimationDuration = widget.reorderAnimationDuration;
    _scrollAnimationDuration = widget.scrollAnimationDuration;
    _entranceController = AnimationController(
        value: 1.0, vsync: this, duration: _reorderAnimationDuration);
    _ghostController = AnimationController(
        value: 0, vsync: this, duration: _reorderAnimationDuration);
    _entranceController.addStatusListener(_onEntranceStatusChanged);
    _childContexts = List.filled(widget.children.length, null);
    _childSizes = List.filled(widget.children.length, const Size(0, 0));
    _wrapChildRunIndexes = List.filled(widget.children.length, -1);
    _childRunIndexes = List.filled(widget.children.length, -1);
    _nextChildRunIndexes = List.filled(widget.children.length, -1);
    _wrapChildren = List.filled(widget.children.length, null);
  }

  @override
  void didChangeDependencies() {
    _scrollController = widget.controller ??
        PrimaryScrollController.maybeOf(context) ??
        ScrollController();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _ghostController.dispose();
    super.dispose();
  }

  void _requestAnimationToNextIndex({bool isAcceptingNewTarget = false}) {
    if (_entranceController.isCompleted) {
      _ghostDisplayIndex = _currentDisplayIndex;
      if (!isAcceptingNewTarget && _nextDisplayIndex == _currentDisplayIndex) {
        return;
      }

      _currentDisplayIndex = _nextDisplayIndex;
      _ghostController.reverse(from: 1.0);
      _entranceController.forward(from: 0.0);
    }
  }

  void _onEntranceStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _requestAnimationToNextIndex();
      });
    }
  }

  void _scrollTo(BuildContext context) {
    if (_scrolling || !_scrollController.hasClients) return;
    final RenderObject contextObject = context.findRenderObject()!;
    final RenderAbstractViewport viewport =
        RenderAbstractViewport.of(contextObject);

    final double margin = widget.direction == Axis.horizontal
        ? _dropAreaSize.width
        : _dropAreaSize.height;
    final double scrollOffset = _scrollController.offset;
    final double topOffset = max(
      _scrollController.position.minScrollExtent,
      viewport.getOffsetToReveal(contextObject, 0.0).offset - margin,
    );
    final double bottomOffset = min(
      _scrollController.position.maxScrollExtent,
      viewport.getOffsetToReveal(contextObject, 1.0).offset + margin,
    );
    final bool onScreen =
        scrollOffset <= topOffset && scrollOffset >= bottomOffset;
    if (!onScreen) {
      _scrolling = true;
      _scrollController.position
          .animateTo(
        scrollOffset < bottomOffset ? bottomOffset : topOffset,
        duration: _scrollAnimationDuration,
        curve: Curves.easeInOut,
      )
          .then((void value) {
        setState(() {
          _scrolling = false;
        });
      });
    }
  }

  Widget _buildContainerForMainAxis({required List<Widget> children}) {
    WrapAlignment runAlignment;
    switch (widget.crossAxisAlignment) {
      case WrapCrossAlignment.start:
        runAlignment = WrapAlignment.start;
        break;
      case WrapCrossAlignment.end:
        runAlignment = WrapAlignment.end;
        break;
      case WrapCrossAlignment.center:
      default:
        runAlignment = WrapAlignment.center;
        break;
    }
    return Wrap(
      direction: widget.direction,
      runAlignment: runAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: children,
    );
  }

  Widget _wrap(Widget toWrap, int index) {
    _wrapChildren[index] = toWrap;
    int displayIndex = _childIndexToDisplayIndex[index];
    void onDragStarted() {
      setState(() {
        _draggingWidget = toWrap;
        _dragStartIndex = index;
        _ghostDisplayIndex = displayIndex;
        _currentDisplayIndex = displayIndex;
        _nextDisplayIndex = displayIndex;
        _entranceController.value = 1.0;
        _draggingFeedbackSize = _childContexts[index]!.size;
        for (int i = 0; i < widget.children.length; i++) {
          _childSizes[i] = _childContexts[i]!.size!;
        }

        if (_wrapKey.currentContext != null) {
          RenderWrapWithMainAxisCount wrapRenderObject =
              _wrapKey.currentContext!.findRenderObject()
                  as RenderWrapWithMainAxisCount;
          _wrapChildRunIndexes = wrapRenderObject.childRunIndexes;
          for (int i = 0; i < _childRunIndexes.length; i++) {
            _nextChildRunIndexes[i] =
                _wrapChildRunIndexes[_childIndexToDisplayIndex[i]];
          }
        } else {
          if (widget.minMainAxisCount != null &&
              widget.maxMainAxisCount != null &&
              widget.minMainAxisCount == widget.maxMainAxisCount) {
            _wrapChildRunIndexes = List.generate(widget.children.length,
                (int index) => index ~/ widget.minMainAxisCount!);
            for (int i = 0; i < _childRunIndexes.length; i++) {
              _nextChildRunIndexes[i] =
                  _wrapChildRunIndexes[_childIndexToDisplayIndex[i]];
            }
          }
        }
        widget.onReorderStarted?.call(index);
      });
    }

    void _reorder(int startIndex, int endIndex) {
      if (startIndex != endIndex)
        widget.onReorder(startIndex, endIndex);
      else if (widget.onNoReorder != null) widget.onNoReorder!(startIndex);
      _ghostController.reverse(from: 0.1);
      _entranceController.reverse(from: 0);

      _dragStartIndex = -1;
    }

    void reorder(int startIndex, int endIndex) {
      setState(() {
        _reorder(startIndex, endIndex);
      });
    }

    void onDragEnded() {
      setState(() {
        _reorder(_dragStartIndex, _currentDisplayIndex);
        _dragStartIndex = -1;
        _ghostDisplayIndex = -1;
        _currentDisplayIndex = -1;
        _nextDisplayIndex = -1;
        _draggingWidget = null;
      });
    }

    Widget wrapWithSemantics() {
      final Map<CustomSemanticsAction, VoidCallback> semanticsActions =
          <CustomSemanticsAction, VoidCallback>{};
      void moveToStart() => reorder(index, 0);
      void moveToEnd() => reorder(index, widget.children.length - 1);
      void moveBefore() => reorder(index, index - 1);
      void moveAfter() => reorder(index, index + 2);
      final MaterialLocalizations localizations =
          MaterialLocalizations.of(context);

      if (index > 0) {
        semanticsActions[CustomSemanticsAction(
            label: localizations.reorderItemToStart)] = moveToStart;
        String reorderItemBefore = localizations.reorderItemUp;
        if (widget.direction == Axis.horizontal) {
          reorderItemBefore = Directionality.of(context) == TextDirection.ltr
              ? localizations.reorderItemLeft
              : localizations.reorderItemRight;
        }
        semanticsActions[CustomSemanticsAction(label: reorderItemBefore)] =
            moveBefore;
      }

      if (index < widget.children.length - 1) {
        String reorderItemAfter = localizations.reorderItemDown;
        if (widget.direction == Axis.horizontal) {
          reorderItemAfter = Directionality.of(context) == TextDirection.ltr
              ? localizations.reorderItemRight
              : localizations.reorderItemLeft;
        }
        semanticsActions[CustomSemanticsAction(label: reorderItemAfter)] =
            moveAfter;
        semanticsActions[
                CustomSemanticsAction(label: localizations.reorderItemToEnd)] =
            moveToEnd;
      }

      return MergeSemantics(
        child: Semantics(
          customSemanticsActions: semanticsActions,
          child: toWrap,
        ),
      );
    }

    Widget _makeAppearingWidget(Widget child) {
      return makeAppearingWidget(
        child,
        _entranceController,
        null,
        widget.direction,
      );
    }

    Widget _makeDisappearingWidget(Widget child) {
      return makeDisappearingWidget(
        child,
        _ghostController,
        null,
        widget.direction,
      );
    }

    double _getVerticalTranslation(int index, int? hoveredIndex) {
      if (hoveredIndex == null || hoveredIndex == -1)
        return 0; // No translation when not hovered

      final int distance = (hoveredIndex - index).abs();

      if (distance == 0) {
        return -48 / 4; // Hovered item moves up more (e.g., 12)
      } else if (distance == 1) {
        return -48 / 6; // Neighboring item moves up slightly (e.g., 8)
      } else {
        return 0; // Items further away do not move
      }
    }

    Widget buildDraggable() {
      final Widget toWrapWithSemantics = wrapWithSemantics();

      Widget feedbackBuilder = Builder(builder: (BuildContext context) {
        BoxConstraints contentSizeConstraints = BoxConstraints.loose(
            _draggingFeedbackSize!); //renderObject.constraints
        return (widget.buildDraggableFeedback ?? defaultBuildDraggableFeedback)(
            context, contentSizeConstraints, toWrap);
      });

      bool isReorderable = widget.enableReorder;
      if (toWrap is ReorderableItem) {
        isReorderable = toWrap.reorderable;
      }

      Widget child;
      if (!isReorderable) {
        child = toWrapWithSemantics;
      } else {
        child = this.widget.needsLongPressDraggable
            ? LongPressDraggable<int>(
                maxSimultaneousDrags: 1,
                data: index,
                ignoringFeedbackSemantics: false,
                feedback: feedbackBuilder,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: ((event) {
                    setState(() {
                      _hoveredIndex = index;
                    });
                  }),
                  onExit: (event) {
                    setState(() {
                      _hoveredIndex = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    transform: Matrix4.translationValues(
                      0,
                      _getVerticalTranslation(index,
                          _hoveredIndex), // Vertical translation for hovered item
                      0,
                    ),
                    child: MetaData(
                        child: toWrapWithSemantics,
                        behavior: HitTestBehavior.opaque),
                  ),
                ),
                childWhenDragging: AnimatedContainer(
                  duration: const Duration(
                      milliseconds: 500), // Smooth animation duration
                  curve: Curves.easeInOut,
                  width: _isDroppedOutside ? 0 : 48,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Opacity(
                      opacity: 0.0,
                      child: _makeAppearingWidget(toWrap),
                    ),
                  ),
                ),
                onDragStarted: onDragStarted,
                onDragCompleted: onDragEnded,
                dragAnchorStrategy: childDragAnchorStrategy,
                onDraggableCanceled: (Velocity velocity, Offset offset) =>
                    onDragEnded(),
              )
            : Draggable<int>(
                maxSimultaneousDrags: 1,
                data: index,
                ignoringFeedbackSemantics: false,
                feedback: feedbackBuilder,
                childWhenDragging: AnimatedContainer(
                  duration: const Duration(
                      milliseconds: 500), // Smooth animation duration
                  curve: Curves.easeInOut,
                  width: _isDroppedOutside ? 0 : 48,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Opacity(
                      opacity: 0.0,
                      child: _makeAppearingWidget(toWrap),
                    ),
                  ),
                ),
                onDragUpdate: (details) {
                  final RenderBox dockBox =
                      _wrapKey.currentContext?.findRenderObject() as RenderBox;

                  final Offset dockTopLeft = dockBox.localToGlobal(Offset.zero);
                  final Size dockSize = dockBox.size;
                  final Offset dragPosition = details.globalPosition;
                  final bool isOutside = dragPosition.dx < dockTopLeft.dx ||
                      dragPosition.dx > dockTopLeft.dx + dockSize.width ||
                      dragPosition.dy < dockTopLeft.dy ||
                      dragPosition.dy > dockTopLeft.dy + dockSize.height;
                  setState(() {
                    _isDroppedOutside = isOutside;
                  });
                },
                onDragStarted: onDragStarted,
                onDragCompleted: onDragEnded,
                dragAnchorStrategy: childDragAnchorStrategy,
                onDraggableCanceled: (Velocity velocity, Offset offset) =>
                    onDragEnded(),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: ((event) {
                    setState(() {
                      _hoveredIndex = index;
                    });
                  }),
                  onExit: (event) {
                    setState(() {
                      _hoveredIndex = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    transform: Matrix4.translationValues(
                      0,
                      _getVerticalTranslation(index,
                          _hoveredIndex), // Vertical translation for hovered item
                      0,
                    ),
                    child: MetaData(
                        behavior: HitTestBehavior.opaque,
                        child: toWrapWithSemantics),
                  ),
                ),
              );
      }
      if (index >= widget.children.length) {
        child = toWrap;
      }

      return child;
    }

    var builder = Builder(builder: (BuildContext context) {
      Widget draggable = buildDraggable();
      var containedDraggable =
          ContainedDraggable(Builder(builder: (BuildContext context) {
        _childContexts[index] = context;
        return draggable;
      }), draggable is LongPressDraggable || draggable is Draggable);
      List<Widget> _includeMovedAdjacentChildIfNeeded(
          Widget child, int childDisplayIndex) {
        int checkingTargetDisplayIndex = -1;
        if (_ghostDisplayIndex < _currentDisplayIndex &&
            childDisplayIndex > _ghostDisplayIndex) {
          checkingTargetDisplayIndex = childDisplayIndex - 1;
        } else if (_ghostDisplayIndex > _currentDisplayIndex &&
            childDisplayIndex < _ghostDisplayIndex) {
          checkingTargetDisplayIndex = childDisplayIndex + 1;
        }
        if (checkingTargetDisplayIndex == -1) {
          return [child];
        }
        int checkingTargetIndex =
            _childDisplayIndexToIndex[checkingTargetDisplayIndex];
        if (checkingTargetIndex == _dragStartIndex) {
          return [child];
        }
        if (_childRunIndexes[checkingTargetIndex] == -1 ||
            _childRunIndexes[checkingTargetIndex] ==
                _wrapChildRunIndexes[checkingTargetDisplayIndex]) {
          return [child];
        }
        Widget disappearingPreChild =
            _makeDisappearingWidget(_wrapChildren[checkingTargetIndex]!);
        return _ghostDisplayIndex < _currentDisplayIndex
            ? [disappearingPreChild, child]
            : [child, disappearingPreChild];
      }

      _nextChildRunIndexes[index] = _wrapChildRunIndexes[displayIndex];

      if (_currentDisplayIndex == -1 || displayIndex == _currentDisplayIndex) {
        return _buildContainerForMainAxis(
            children: _includeMovedAdjacentChildIfNeeded(
                containedDraggable.builder, displayIndex));
      }

      bool _onWillAccept(int? toAccept, bool isPre) {
        int nextDisplayIndex;
        if (_currentDisplayIndex < displayIndex) {
          nextDisplayIndex = isPre ? displayIndex - 1 : displayIndex;
        } else {
          nextDisplayIndex = !isPre ? displayIndex + 1 : displayIndex;
        }

        bool movingToAdjacentChild =
            nextDisplayIndex <= _currentDisplayIndex + 1 &&
                nextDisplayIndex >= _currentDisplayIndex - 1;
        bool willAccept = _dragStartIndex == toAccept &&
            toAccept != index &&
            (_entranceController.isCompleted || !movingToAdjacentChild) &&
            _currentDisplayIndex != nextDisplayIndex;

        if (!willAccept) {
          return false;
        }
        if (!(_childDisplayIndexToIndex[_currentDisplayIndex] != index &&
            _currentDisplayIndex != displayIndex)) {
          return false;
        }

        if (_wrapKey.currentContext != null) {
          RenderWrapWithMainAxisCount wrapRenderObject =
              _wrapKey.currentContext!.findRenderObject()
                  as RenderWrapWithMainAxisCount;
          _wrapChildRunIndexes = wrapRenderObject.childRunIndexes;
        } else {
          if (widget.minMainAxisCount != null &&
              widget.maxMainAxisCount != null &&
              widget.minMainAxisCount == widget.maxMainAxisCount) {
            _wrapChildRunIndexes = List.generate(widget.children.length,
                (int index) => index ~/ widget.minMainAxisCount!);
          }
        }

        setState(() {
          _nextDisplayIndex = nextDisplayIndex;

          _requestAnimationToNextIndex(isAcceptingNewTarget: true);
        });
        _scrollTo(context);
        return willAccept;
      }

      Widget preDragTarget = DragTarget<int>(
        builder: (BuildContext context, List<int?> acceptedCandidates,
                List<dynamic> rejectedCandidates) =>
            const SizedBox(),
        onWillAccept: (int? toAccept) => _onWillAccept(toAccept, true),
        onAccept: (int accepted) {},
        onLeave: (Object? leaving) {},
      );
      Widget nextDragTarget = DragTarget<int>(
        builder: (BuildContext context, List<int?> acceptedCandidates,
                List<dynamic> rejectedCandidates) =>
            const SizedBox(),
        onWillAccept: (int? toAccept) => _onWillAccept(toAccept, false),
        onAccept: (int accepted) {},
        onLeave: (Object? leaving) {},
      );

      Widget dragTarget = Stack(
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          containedDraggable.builder,
          if (containedDraggable.isReorderable)
            Positioned(
                left: 0,
                top: 0,
                width: widget.direction == Axis.horizontal
                    ? _childSizes[index].width / 2
                    : _childSizes[index].width,
                height: widget.direction == Axis.vertical
                    ? _childSizes[index].height / 2
                    : _childSizes[index].height,
                child: preDragTarget),
          if (containedDraggable.isReorderable)
            Positioned(
                right: 0,
                bottom: 0,
                width: widget.direction == Axis.horizontal
                    ? _childSizes[index].width / 2
                    : _childSizes[index].width,
                height: widget.direction == Axis.vertical
                    ? _childSizes[index].height / 2
                    : _childSizes[index].height,
                child: nextDragTarget),
        ],
      );
      Widget spacing = _draggingWidget == null
          ? SizedBox.fromSize(size: _dropAreaSize)
          : Opacity(opacity: 0.0, child: _draggingWidget);

      if (_childRunIndexes[index] != -1 &&
          _childRunIndexes[index] != _wrapChildRunIndexes[displayIndex]) {
        dragTarget = _makeAppearingWidget(dragTarget);
      }

      if (displayIndex == _ghostDisplayIndex) {
        Widget ghostSpacing = _makeDisappearingWidget(spacing);
        if (_ghostDisplayIndex < _currentDisplayIndex) {
          return _buildContainerForMainAxis(
              children: [ghostSpacing] +
                  _includeMovedAdjacentChildIfNeeded(dragTarget, displayIndex));
        } else if (_ghostDisplayIndex > _currentDisplayIndex) {
          return _buildContainerForMainAxis(
              children:
                  _includeMovedAdjacentChildIfNeeded(dragTarget, displayIndex) +
                      [ghostSpacing]);
        }
      }

      return _buildContainerForMainAxis(
          children:
              _includeMovedAdjacentChildIfNeeded(dragTarget, displayIndex));
    });
    return KeyedSubtree(key: ValueKey(index), child: builder);
  }

  @override
  Widget build(BuildContext context) {
    List<E> _resizeListMember<E>(List<E> listVar, E initValue) {
      if (listVar.length < widget.children.length) {
        return listVar +
            List.filled(widget.children.length - listVar.length, initValue);
      } else if (listVar.length > widget.children.length) {
        return listVar.sublist(0, widget.children.length);
      }
      return listVar;
    }

    _childContexts = _resizeListMember(_childContexts, null);
    _childSizes = _resizeListMember(_childSizes, const Size(0, 0));
    _childDisplayIndexToIndex =
        List.generate(widget.children.length, (int index) => index);
    _childIndexToDisplayIndex =
        List.generate(widget.children.length, (int index) => index);
    if (_dragStartIndex >= 0 &&
        _currentDisplayIndex >= 0 &&
        _dragStartIndex != _currentDisplayIndex) {
      _childDisplayIndexToIndex.insert(_currentDisplayIndex,
          _childDisplayIndexToIndex.removeAt(_dragStartIndex));
    }
    int index = 0;
    _childDisplayIndexToIndex.forEach((int element) {
      _childIndexToDisplayIndex[element] = index++;
    });
    _wrapChildRunIndexes = _resizeListMember(_wrapChildRunIndexes, -1);
    _childRunIndexes = _resizeListMember(_childRunIndexes, -1);
    _nextChildRunIndexes = _resizeListMember(_nextChildRunIndexes, -1);
    _wrapChildren = _resizeListMember(_wrapChildren, null);
    _childRunIndexes = _nextChildRunIndexes.toList();
    final List<Widget> wrappedChildren = <Widget>[];
    for (int i = 0; i < widget.children.length; i++) {
      wrappedChildren.add(_wrap(widget.children[i], i));
    }
    if (_dragStartIndex >= 0 &&
        _currentDisplayIndex >= 0 &&
        _dragStartIndex != _currentDisplayIndex) {
      wrappedChildren.insert(
          _currentDisplayIndex, wrappedChildren.removeAt(_dragStartIndex));
    }
    if (widget.header != null) {
      wrappedChildren.insertAll(0, widget.header!);
    }
    if (widget.footer != null) {
      wrappedChildren.add(widget.footer!);
    }

    if (widget.controller != null &&
        PrimaryScrollController.maybeOf(context) == null) {
      return (widget.buildItemsContainer ?? defaultBuildItemsContainer)(
          context, widget.direction, wrappedChildren);
    } else {
      return SingleChildScrollView(
        scrollDirection: widget.scrollDirection,
        physics: widget.scrollPhysics,
        padding: widget.padding,
        controller: _scrollController,
        child: (widget.buildItemsContainer ?? defaultBuildItemsContainer)(
            context, widget.direction, wrappedChildren),
      );
    }
  }

  Widget defaultBuildItemsContainer(
      BuildContext context, Axis direction, List<Widget> children) {
    return WrapWithMainAxisCount(
      key: _wrapKey,
      direction: direction,
      alignment: widget.alignment,
      spacing: widget.spacing,
      runAlignment: widget.runAlignment,
      runSpacing: widget.runSpacing,
      crossAxisAlignment: widget.crossAxisAlignment,
      textDirection: widget.textDirection,
      verticalDirection: widget.verticalDirection,
      minMainAxisCount: widget.minMainAxisCount,
      maxMainAxisCount: widget.maxMainAxisCount,
      children: children,
    );
  }

  Widget defaultBuildDraggableFeedback(
      BuildContext context, BoxConstraints constraints, Widget child) {
    return Transform(
      transform: new Matrix4.rotationZ(0),
      alignment: FractionalOffset.topLeft,
      child: Material(
        elevation: 0.0,
        color: Colors.transparent,
        borderRadius: BorderRadius.zero,
        child:
            Card(child: ConstrainedBox(constraints: constraints, child: child)),
      ),
    );
  }
}

class ContainedDraggable {
  Builder builder;
  bool isReorderable;
  ContainedDraggable(this.builder, this.isReorderable);
}
