import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flexi_page_view/src/unbounded_viewport.dart';

/// A sliver that contains multiple box children that each fills the viewport.
///
/// _To learn more about slivers, see [CustomScrollView.slivers]._
///
/// [SliverFillViewport] places its children in a linear array along the main
/// axis. Each child is sized to fill the viewport, both in the main and cross
/// axis.
///
/// See also:
///
///  * [SliverFixedExtentList], which has a configurable
///    [SliverFixedExtentList.itemExtent].
///  * [SliverPrototypeExtentList], which is similar to [SliverFixedExtentList]
///    except that it uses a prototype list item instead of a pixel value to define
///    the main axis extent of each item.
///  * [SliverList], which does not require its children to have the same
///    extent in the main axis.
class SliverFlexiPageView extends StatelessWidget {
  /// Creates a sliver whose box children that each fill the viewport.
  const SliverFlexiPageView({
    super.key,
    this.alignment = AlignmentDirectional.topStart,
    required this.delegate,
    this.viewportFraction = 1.0,
    this.padEnds = true,
  }) : assert(viewportFraction > 0.0);

  final AlignmentGeometry alignment;

  /// The fraction of the viewport that each child should fill in the main axis.
  ///
  /// If this fraction is less than 1.0, more than one child will be visible at
  /// once. If this fraction is greater than 1.0, each child will be larger than
  /// the viewport in the main axis.
  final double viewportFraction;

  /// Whether to add padding to both ends of the list.
  ///
  /// If this is set to true and [viewportFraction] < 1.0, padding will be added
  /// such that the first and last child slivers will be in the center of the
  /// viewport when scrolled all the way to the start or end, respectively. You
  /// may want to set this to false if this [SliverFillViewport] is not the only
  /// widget along this main axis, such as in a [CustomScrollView] with multiple
  /// children.
  ///
  /// If [viewportFraction] is greater than one, this option has no effect.
  /// Defaults to true.
  final bool padEnds;

  /// {@macro flutter.widgets.SliverMultiBoxAdaptorWidget.delegate}
  final SliverChildDelegate delegate;

  @override
  Widget build(BuildContext context) {
    return _SliverUnboundedFractionalPadding(
      viewportFraction: padEnds ? clampDouble(1 - viewportFraction, 0, 1) / 2 : 0,
      sliver: _SliverFlexiPageViewRenderObjectWidget(
        alignment: alignment,
        viewportFraction: viewportFraction,
        delegate: delegate,
      ),
    );
  }
}

class _SliverUnboundedFractionalPadding extends SingleChildRenderObjectWidget {
  const _SliverUnboundedFractionalPadding({this.viewportFraction = 0, Widget? sliver})
    : assert(viewportFraction >= 0),
      assert(viewportFraction <= 0.5),
      super(child: sliver);

  final double viewportFraction;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderUnboundedSliverFractionalPadding(viewportFraction: viewportFraction);

  @override
  void updateRenderObject(BuildContext context, _RenderUnboundedSliverFractionalPadding renderObject) {
    renderObject.viewportFraction = viewportFraction;
  }
}

class _RenderUnboundedSliverFractionalPadding extends RenderSliverEdgeInsetsPadding {
  _RenderUnboundedSliverFractionalPadding({double viewportFraction = 0})
    : assert(viewportFraction <= 0.5),
      assert(viewportFraction >= 0),
      _viewportFraction = viewportFraction;

  SliverConstraints? _lastResolvedConstraints;

  double get viewportFraction => _viewportFraction;
  double _viewportFraction;
  set viewportFraction(double newValue) {
    if (_viewportFraction == newValue) {
      return;
    }
    _viewportFraction = newValue;
    _markNeedsResolution();
  }

  @override
  EdgeInsets? get resolvedPadding => _resolvedPadding;
  EdgeInsets? _resolvedPadding;

  void _markNeedsResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  void _resolve() {
    if (_resolvedPadding != null && _lastResolvedConstraints == constraints) {
      return;
    }

    final double paddingValue = constraints.viewportMainAxisExtent * viewportFraction;
    _lastResolvedConstraints = constraints;
    _resolvedPadding = switch (constraints.axis) {
      Axis.horizontal => EdgeInsets.symmetric(horizontal: paddingValue),
      Axis.vertical => EdgeInsets.symmetric(vertical: paddingValue),
    };

    return;
  }

  @override
  void performLayout() {
    _resolve();
    super.performLayout();
    if (geometry != null && child?.geometry is UnboundedSliverGeometry) {
      final childGeometry = child!.geometry! as UnboundedSliverGeometry;
      geometry = UnboundedSliverGeometry(existing: geometry!, crossAxisSize: childGeometry.crossAxisSize);
    }
  }
}

class _SliverFlexiPageViewRenderObjectWidget extends SliverMultiBoxAdaptorWidget {
  const _SliverFlexiPageViewRenderObjectWidget({
    required super.delegate,
    this.alignment = AlignmentDirectional.topStart,
    this.viewportFraction = 1.0,
  }) : assert(viewportFraction > 0.0);

  final AlignmentGeometry alignment;
  final double viewportFraction;

  @override
  RenderFlexiPageView createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element = context as SliverMultiBoxAdaptorElement;
    return RenderFlexiPageView(
      childManager: element,
      alignment: alignment.resolve(Directionality.of(context)),
      viewportFraction: viewportFraction,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlexiPageView renderObject) {
    renderObject
      ..viewportFraction = viewportFraction
      ..alignment = alignment.resolve(Directionality.of(context));
  }
}

class RenderFlexiPageView extends RenderSliverFillViewport {
  RenderFlexiPageView({required super.childManager, required Alignment alignment, super.viewportFraction})
    : _alignment = alignment;

  Alignment get alignment => _alignment;
  set alignment(Alignment alignment) {
    if (alignment == _alignment) {
      return;
    }
    _alignment = alignment;
    markNeedsLayout();
  }

  Alignment _alignment;

  final _laidOutChildren = <int, RenderBox>{};

  BoxConstraints _getChildConstraints(int index) {
    double extent;
    if (itemExtentBuilder == null) {
      extent = itemExtent;
    } else {
      extent = itemExtentBuilder!(index, _currentLayoutDimensions)!;
    }
    var childConstraints = constraints.asBoxConstraints(minExtent: extent, maxExtent: extent);
    if (constraints.axis == Axis.horizontal) {
      childConstraints = childConstraints.copyWith(minHeight: 0);
    } else {
      childConstraints = childConstraints.copyWith(minWidth: 0);
    }
    return childConstraints;
  }

  late SliverLayoutDimensions _currentLayoutDimensions;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _SliverFlexiPageViewParentData) {
      child.parentData = _SliverFlexiPageViewParentData();
    }
  }

  @override
  void performLayout() {
    // assert((itemExtent != null && itemExtentBuilder == null) || (itemExtent == null && itemExtentBuilder != null));
    assert(itemExtentBuilder != null || (itemExtent.isFinite && itemExtent >= 0));

    _laidOutChildren.clear();
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final double scrollOffset = constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;

    _currentLayoutDimensions = SliverLayoutDimensions(
      scrollOffset: constraints.scrollOffset,
      precedingScrollExtent: constraints.precedingScrollExtent,
      viewportMainAxisExtent: constraints.viewportMainAxisExtent,
      crossAxisExtent: constraints.crossAxisExtent,
    );
    // TODO(Piinks): Clean up when deprecation expires.
    const double deprecatedExtraItemExtent = -1;

    final int firstIndex = getMinChildIndexForScrollOffset(scrollOffset, deprecatedExtraItemExtent);
    final int? targetLastIndex =
        targetEndScrollOffset.isFinite
            ? getMaxChildIndexForScrollOffset(targetEndScrollOffset, deprecatedExtraItemExtent)
            : null;

    if (firstChild != null) {
      final int leadingGarbage = calculateLeadingGarbage(firstIndex: firstIndex);
      final int trailingGarbage = targetLastIndex != null ? calculateTrailingGarbage(lastIndex: targetLastIndex) : 0;
      collectGarbage(leadingGarbage, trailingGarbage);
    } else {
      collectGarbage(0, 0);
    }

    if (firstChild == null) {
      final double layoutOffset = indexToLayoutOffset(deprecatedExtraItemExtent, firstIndex);
      if (!addInitialChild(index: firstIndex, layoutOffset: layoutOffset)) {
        // There are either no children, or we are past the end of all our children.
        final double max;
        if (firstIndex <= 0) {
          max = 0.0;
        } else {
          max = computeMaxScrollOffset(constraints, deprecatedExtraItemExtent);
        }
        geometry = SliverGeometry(scrollExtent: max, maxPaintExtent: max);
        _finzlizeGeometry();
        childManager.didFinishLayout();
        return;
      }
    }

    RenderBox? trailingChildWithLayout;

    for (int index = indexOf(firstChild!) - 1; index >= firstIndex; --index) {
      final RenderBox? child = insertAndLayoutLeadingChild(_getChildConstraints(index), parentUsesSize: true);
      _onDidLayoutChild(child);
      if (child == null) {
        // Items before the previously first child are no longer present.
        // Reset the scroll offset to offset all items prior and up to the
        // missing item. Let parent re-layout everything.
        geometry = SliverGeometry(scrollOffsetCorrection: indexToLayoutOffset(deprecatedExtraItemExtent, index));
        _finzlizeGeometry();
        return;
      }
      final SliverMultiBoxAdaptorParentData childParentData = child.parentData! as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset = indexToLayoutOffset(deprecatedExtraItemExtent, index);
      assert(childParentData.index == index);
      trailingChildWithLayout ??= child;
    }

    if (trailingChildWithLayout == null) {
      firstChild!.layout(_getChildConstraints(indexOf(firstChild!)), parentUsesSize: true);
      _onDidLayoutChild(firstChild);
      final SliverMultiBoxAdaptorParentData childParentData =
          firstChild!.parentData! as SliverMultiBoxAdaptorParentData;
      childParentData.layoutOffset = indexToLayoutOffset(deprecatedExtraItemExtent, firstIndex);
      trailingChildWithLayout = firstChild;
    }

    double estimatedMaxScrollOffset = double.infinity;
    for (
      int index = indexOf(trailingChildWithLayout!) + 1;
      targetLastIndex == null || index <= targetLastIndex;
      ++index
    ) {
      RenderBox? child = childAfter(trailingChildWithLayout!);
      if (child == null || indexOf(child) != index) {
        child = insertAndLayoutChild(_getChildConstraints(index), after: trailingChildWithLayout, parentUsesSize: true);
        _onDidLayoutChild(child);
        if (child == null) {
          // We have run out of children.
          estimatedMaxScrollOffset = indexToLayoutOffset(deprecatedExtraItemExtent, index);
          break;
        }
      } else {
        child.layout(_getChildConstraints(index), parentUsesSize: true);
        _onDidLayoutChild(child);
      }
      trailingChildWithLayout = child;
      final SliverMultiBoxAdaptorParentData childParentData = child.parentData! as SliverMultiBoxAdaptorParentData;
      assert(childParentData.index == index);
      childParentData.layoutOffset = indexToLayoutOffset(deprecatedExtraItemExtent, childParentData.index!);
    }

    final int lastIndex = indexOf(lastChild!);
    final double leadingScrollOffset = indexToLayoutOffset(deprecatedExtraItemExtent, firstIndex);
    final double trailingScrollOffset = indexToLayoutOffset(deprecatedExtraItemExtent, lastIndex + 1);

    assert(firstIndex == 0 || childScrollOffset(firstChild!)! - scrollOffset <= precisionErrorTolerance);
    assert(debugAssertChildListIsNonEmptyAndContiguous());
    assert(indexOf(firstChild!) == firstIndex);
    assert(targetLastIndex == null || lastIndex <= targetLastIndex);

    estimatedMaxScrollOffset = math.min(
      estimatedMaxScrollOffset,
      estimateMaxScrollOffset(
        constraints,
        firstIndex: firstIndex,
        lastIndex: lastIndex,
        leadingScrollOffset: leadingScrollOffset,
        trailingScrollOffset: trailingScrollOffset,
      ),
    );

    final double paintExtent = calculatePaintOffset(constraints, from: leadingScrollOffset, to: trailingScrollOffset);

    final double cacheExtent = calculateCacheOffset(constraints, from: leadingScrollOffset, to: trailingScrollOffset);

    final double targetEndScrollOffsetForPaint = constraints.scrollOffset + constraints.remainingPaintExtent;
    final int? targetLastIndexForPaint =
        targetEndScrollOffsetForPaint.isFinite
            ? getMaxChildIndexForScrollOffset(targetEndScrollOffsetForPaint, deprecatedExtraItemExtent)
            : null;

    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow:
          (targetLastIndexForPaint != null && lastIndex >= targetLastIndexForPaint) || constraints.scrollOffset > 0.0,
    );
    _finzlizeGeometry();

    // We may have started the layout while scrolled to the end, which would not
    // expose a new child.
    if (estimatedMaxScrollOffset == trailingScrollOffset) {
      childManager.setDidUnderflow(true);
    }
    childManager.didFinishLayout();
  }

  @override
  double childCrossAxisPosition(covariant RenderObject child) {
    final childParentData = child.parentData! as _SliverFlexiPageViewParentData;
    return childParentData.crossAxisOffset;
  }

  // should call update after each child is laid out
  void _onDidLayoutChild(RenderBox? child) {
    if (child == null) {
      return;
    }
    final childParentData = child.parentData! as SliverMultiBoxAdaptorParentData;
    final index = childParentData.index;
    if (index == null) {
      return;
    }
    _laidOutChildren[index] = child;
  }

  void _finzlizeGeometry() {
    final geometry = this.geometry;
    final constraints = this.constraints;
    if (geometry == null || _laidOutChildren.isEmpty) {
      return;
    }
    final page = _getPage();
    final fromChild = _laidOutChildren[page.floor()];
    final toChild = _laidOutChildren[page.ceil()];
    final crossAxisSize =
        _lerpDouble(
          fromChild?.size.crossAxisDimension(constraints.axis),
          toChild?.size.crossAxisDimension(constraints.axis),
          page - page.floorToDouble(),
        ) ??
        0;
    this.geometry = UnboundedSliverGeometry(existing: geometry, crossAxisSize: crossAxisSize);

    for (final child in _laidOutChildren.values) {
      final childParentData = child.parentData! as _SliverFlexiPageViewParentData;
      final center = (crossAxisSize - child.size.crossAxisDimension(constraints.axis)) / 2;
      childParentData.crossAxisOffset = center + alignment.crossAxisDimension(constraints.axis) * center;
    }
  }

  double _getPage() {
    final viewportDimension = constraints.viewportMainAxisExtent;
    assert(viewportDimension > 0.0);
    final initialPageOffset = math.max(0, viewportDimension * (viewportFraction - 1) / 2);
    final actual = math.max(0.0, constraints.scrollOffset - initialPageOffset) / (viewportDimension * viewportFraction);
    final round = actual.roundToDouble();
    if ((actual - round).abs() < precisionErrorTolerance) {
      return round;
    }
    return actual;
  }
}

class _SliverFlexiPageViewParentData extends SliverMultiBoxAdaptorParentData {
  double crossAxisOffset = 0;
}

extension on Size {
  // ignore: unused_element
  double mainAxisDimension(Axis axis) => switch (axis) {
    Axis.horizontal => width,
    Axis.vertical => height,
  };

  double crossAxisDimension(Axis axis) => switch (axis) {
    Axis.horizontal => height,
    Axis.vertical => width,
  };
}

extension on Alignment {
  // ignore: unused_element
  double mainAxisDimension(Axis axis) => switch (axis) {
    Axis.horizontal => x,
    Axis.vertical => y,
  };

  double crossAxisDimension(Axis axis) => switch (axis) {
    Axis.horizontal => y,
    Axis.vertical => x,
  };
}

double? _lerpDouble(num? a, num? b, double t) {
  if (a == b || (a?.isNaN ?? false) && (b?.isNaN ?? false)) {
    return a?.toDouble();
  }
  if (a == null) {
    return b?.toDouble();
  } else if (b == null) {
    return a.toDouble();
  } else {
    assert(a.isFinite, 'Cannot interpolate between finite and non-finite values');
    assert(b.isFinite, 'Cannot interpolate between finite and non-finite values');
    assert(t.isFinite, 't must be finite when interpolating between values');
    return a * (1.0 - t) + b * t;
  }
}
