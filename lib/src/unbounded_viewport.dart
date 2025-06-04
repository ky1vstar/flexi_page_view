import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class UnboundedSliverGeometry extends SliverGeometry {
  UnboundedSliverGeometry({
    required SliverGeometry existing,
    required this.crossAxisSize,
  }) : super(
          scrollExtent: existing.scrollExtent,
          paintExtent: existing.paintExtent,
          paintOrigin: existing.paintOrigin,
          layoutExtent: existing.layoutExtent,
          maxPaintExtent: existing.maxPaintExtent,
          maxScrollObstructionExtent: existing.maxScrollObstructionExtent,
          hitTestExtent: existing.hitTestExtent,
          visible: existing.visible,
          hasVisualOverflow: existing.hasVisualOverflow,
          scrollOffsetCorrection: existing.scrollOffsetCorrection,
          cacheExtent: existing.cacheExtent,
        );

  final double crossAxisSize;
}

class UnboundedViewport = Viewport with _UnboundedViewportMixin;
mixin _UnboundedViewportMixin on Viewport {
  @override
  RenderViewport createRenderObject(BuildContext context) {
    return UnboundedRenderViewport(
      axisDirection: axisDirection,
      crossAxisDirection: crossAxisDirection ?? Viewport.getDefaultCrossAxisDirection(context, axisDirection),
      anchor: anchor,
      offset: offset,
      cacheExtent: cacheExtent,
      cacheExtentStyle: cacheExtentStyle,
      clipBehavior: clipBehavior,
    );
  }
}

class UnboundedRenderViewport = RenderViewport with _UnboundedRenderViewportMixin;
mixin _UnboundedRenderViewportMixin on RenderViewport {
  @override
  bool get sizedByParent => false;

  double _unboundedSize = double.infinity;

  @override
  void performLayout() {
    final constraints = this.constraints;
    if (axis == Axis.horizontal) {
      _unboundedSize = constraints.maxHeight;
      size = Size(constraints.maxWidth, 0);
    } else {
      _unboundedSize = constraints.maxWidth;
      size = Size(0, constraints.maxHeight);
    }

    super.performLayout();

    switch (axis) {
      case Axis.vertical:
        offset.applyViewportDimension(size.height);
      case Axis.horizontal:
        offset.applyViewportDimension(size.width);
    }
  }

  @override
  double layoutChildSequence({
    required RenderSliver? child,
    required double scrollOffset,
    required double overlap,
    required double layoutOffset,
    required double remainingPaintExtent,
    required double mainAxisExtent,
    required double crossAxisExtent,
    required GrowthDirection growthDirection,
    required RenderSliver? Function(RenderSliver child) advance,
    required double remainingCacheExtent,
    required double cacheOrigin,
  }) {
    crossAxisExtent = _unboundedSize;
    var firstChild = child;

    final result = super.layoutChildSequence(
      child: child,
      scrollOffset: scrollOffset,
      overlap: overlap,
      layoutOffset: layoutOffset,
      remainingPaintExtent: remainingPaintExtent,
      mainAxisExtent: mainAxisExtent,
      crossAxisExtent: crossAxisExtent,
      growthDirection: growthDirection,
      advance: advance,
      remainingCacheExtent: remainingCacheExtent,
      cacheOrigin: cacheOrigin,
    );

    double unboundedSize = 0;
    while (firstChild != null) {
      final childGeometry = firstChild.geometry;
      if (childGeometry is UnboundedSliverGeometry) {
        unboundedSize = math.max(unboundedSize, childGeometry.crossAxisSize);
      }
      firstChild = advance(firstChild);
    }

    if (axis == Axis.horizontal) {
      size = Size(size.width, unboundedSize);
    } else {
      size = Size(unboundedSize, size.height);
    }

    return result;
  }
}
