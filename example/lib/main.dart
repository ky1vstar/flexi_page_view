import 'package:flexi_page_view/flexi_page_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlexiPageView Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = PageController();
  var _alignment = Alignment.topCenter;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showModalSheet() async {
    final modalPageController = PageController();
    var currentPageInModal = 0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      builder: (BuildContext context) {
        // Use a StatefulWidget for the modal content to manage page indicator state
        return StatefulBuilder(
          builder: (BuildContext modalContext, StateSetter modalSetState) {
            // Padding widget around this Column was removed in the previous step (correct)
            return SafeArea(
              left: false,
              right: false,
              minimum: EdgeInsets.only(bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      FlexiPageView(
                        controller: modalPageController,
                        // Uses instance variable
                        alignment: Alignment.bottomCenter,
                        onPageChanged: (index) {
                          modalSetState(() {
                            currentPageInModal =
                                index; // Uses instance variable
                          });
                        },
                        children: [
                          _buildModalPage(
                            color: Colors.amberAccent,
                            title: 'Page 1: Short & Sweet',
                            content:
                                'This is the first page. It has a little bit of content.',
                            height: 150,
                          ),
                          _buildModalPage(
                            color: Colors.lightBlueAccent,
                            title: 'Page 2: A Bit Taller',
                            content:
                                'This page is a bit taller, demonstrating how FlexiPageView adapts. It contains more text to make it grow. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                            height: 250,
                          ),
                          _buildModalPage(
                            color: Colors.lightGreenAccent,
                            title: 'Page 3: The Tallest One!',
                            content:
                                'And this is the tallest page of them all! FlexiPageView handles this with ease. It includes a FlutterLogo just for fun! Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                            includeLogo: true,
                            height: 350,
                          ),
                          _buildModalPage(
                            color: Colors.pinkAccent,
                            title: 'Page 4: Images & Icons',
                            content:
                                'Let\'s add some visuals! This page includes an image and some icons to showcase different types of content. The height adjusts beautifully.',
                            height: 300,
                            customContent: Column(
                              children: [
                                Image.network(
                                  'https://picsum.photos/seed/flutter/200/100',
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 30,
                                    ),
                                    Icon(
                                      Icons.thumb_up,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Visuals make everything better!',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: 16,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white, Colors.white.withAlpha(0)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      // Assuming 4 pages
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 2.0,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              currentPageInModal ==
                                  index // Uses instance variable
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    modalPageController.dispose();
  }

  Widget _buildModalPage({
    required Color color,
    required String title,
    required String content,
    double? height,
    bool includeLogo = false,
    Widget? customContent,
  }) {
    return SafeArea(
      minimum: EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05), // Added opacity
          borderRadius: BorderRadius.circular(12), // Added rounded corners
          border: Border.all(color: color, width: 1), // Added border
        ),
        height: height,
        // color: color, // Color is now part of BoxDecoration
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (customContent != null)
                Flexible(child: customContent)
              else
                Flexible(
                  child: Text(
                    content,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              if (includeLogo) ...[
                const SizedBox(height: 16),
                const FlutterLogo(size: 50),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('FlexiPageView Demo'),
      ),
      body: Column(
        spacing: 16,
        children: [
          SizedBox(),
          SegmentedButton<Alignment>(
            segments: [
              ButtonSegment(value: Alignment.topCenter, label: Text('Top')),
              ButtonSegment(value: Alignment.center, label: Text('Center')),
              ButtonSegment(
                value: Alignment.bottomCenter,
                label: Text('Bottom'),
              ),
            ],
            selected: {_alignment},
            onSelectionChanged: (newSelection) {
              setState(() {
                _alignment = newSelection.first;
              });
            },
          ),
          FlexiPageView(
            controller: _controller,
            alignment: _alignment,
            children: [
              Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ListTile(
                      leading: Icon(Icons.height),
                      title: Text('Dynamic Height Adjustment'),
                      subtitle: Text(
                        'The height of `FlexiPageView` smoothly transitions to match the height of the currently visible page.',
                      ),
                    ),
                    const ListTile(
                      leading: Icon(Icons.change_circle),
                      title: Text('Drop-in Replacement'),
                      subtitle: Text(
                        'Fully compatible with the `PageView` API, making it easy to integrate into existing projects.',
                      ),
                    ),
                    const ListTile(
                      leading: Icon(Icons.dashboard_customize),
                      title: Text('Customizable'),
                      subtitle: Text(
                        'Supports all standard `PageView` properties, such as `controller`, `scrollDirection`, and `physics`.',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text('SOUNDS GREAT!'),
                          onPressed: () {
                            _controller.nextPage(
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Container(
                  height: 150,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore Custom Height',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Discover how this card maintains a cozy 150px height, perfect for showcasing neat content!',
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FlutterLogo(size: 70),
                      const SizedBox(height: 16),
                      Text(
                        'Flutter Power!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'See the Flutter logo in action! This card is a great example of combining images and text.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Text('This label will move as you scroll between pages'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showModalSheet, // Updated onPressed
        tooltip: 'Show Modal', // Updated tooltip
        child: const Icon(Icons.present_to_all),
      ),
    );
  }
}
