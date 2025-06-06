import 'package:flexi_page_view/flexi_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FlexiPageView adjusts height when scrolling between pages', (tester) async {
    final controller = PageController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          widthFactor: 1,
          child: FlexiPageView(
            controller: controller,
            children: [Container(height: 200, color: Colors.red), Container(height: 400, color: Colors.blue)],
          ),
        ),
      ),
    );

    // Verify initial height matches the first page
    expect(tester.getSize(find.byType(FlexiPageView)).height, 200);

    // Programmatically jump to the second page
    controller.jumpToPage(1);
    await tester.pumpAndSettle();

    // Verify height has changed to match the second page
    expect(tester.getSize(find.byType(FlexiPageView)).height, 400);
  });

  testWidgets('FlexiPageView interpolates height dynamically during manual scrolling', (tester) async {
    final controller = PageController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: FlexiPageView(
            controller: controller,
            children: [Container(height: 200, color: Colors.red), Container(height: 400, color: Colors.blue)],
          ),
        ),
      ),
    );

    // Verify initial height matches first page
    expect(tester.getSize(find.byType(FlexiPageView)).height, 200);

    // Start scrolling to the second page
    final gesture = await tester.startGesture(tester.getCenter(find.byType(FlexiPageView)));
    await gesture.moveBy(const Offset(-400, 0)); // Move halfway
    await tester.pumpAndSettle();

    // Verify height is approximately the middle value between page heights
    expect(tester.getSize(find.byType(FlexiPageView)).height, moreOrLessEquals(300));

    // Complete the scroll to page 2
    await gesture.moveBy(const Offset(-200, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    // Verify final height matches second page
    expect(tester.getSize(find.byType(FlexiPageView)).height, 400);
  });

  testWidgets('FlexiPageView with bottomCenter alignment positions content correctly', (tester) async {
    final controller = PageController();
    addTearDown(controller.dispose);

    // Create two containers with different heights
    final firstPage = Container(height: 200, color: Colors.red, child: const Text('Page 1'));

    final secondPage = Container(height: 400, color: Colors.blue, child: const Text('Page 2'));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: FlexiPageView(
          controller: controller,
          alignment: Alignment.bottomCenter,
          children: [firstPage, secondPage],
        ),
      ),
    );

    // Find the first page's text
    final firstPageTextFinder = find.text('Page 1');

    // Verify initial height matches the first page
    expect(tester.getSize(firstPageTextFinder).height, 200);

    // Calculate the expected position for bottom center alignment
    final firstPageTextPos = tester.getCenter(firstPageTextFinder);
    expect(firstPageTextPos.dy, 600 - 200 / 2); // At vertical center of the 200-height container

    // Programmatically jump to the second page
    controller.jumpToPage(1);
    await tester.pumpAndSettle();

    // Find the second page's text
    final secondPageTextFinder = find.text('Page 2');

    // Verify height has changed to match the second page
    expect(tester.getSize(secondPageTextFinder).height, 400);

    // Calculate the expected position for bottom center alignment
    final secondPageTextPos = tester.getCenter(secondPageTextFinder);

    // Verify text position is still centered in the taller container
    expect(secondPageTextPos.dy, 600 - 400 / 2); // At vertical center of the 400-height container
  });
}
