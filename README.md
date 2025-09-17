# FlexiPageView

`FlexiPageView` is a drop-in replacement for Flutter's `PageView` widget. It provides the same API
as `PageView` while dynamically adjusting its height (cross-axis dimension) to match the height of
the currently visible page. This makes it ideal for scenarios where pages have varying heights.

<p align="center">
  <img src="https://raw.githubusercontent.com/ky1vstar/flexi_page_view/refs/heads/master/assets/demo.gif" alt="">
</p>

## Features

- **Dynamic Height Adjustment**: The height of `FlexiPageView` smoothly transitions to match the
  height of the currently visible page.
- **Drop-in Replacement**: Fully compatible with the `PageView` API, making it easy to integrate
  into existing projects.
- **Customizable**: Supports all standard `PageView` properties, such as `controller`,
  `scrollDirection`, and `physics`.

## Installation

Add the following dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flexi_page_view: <latest_version>
```

Run `flutter pub get` to fetch the package.

## Usage

Replace your `PageView` widget with `FlexiPageView`. The API remains the same, but now the height of
the widget will dynamically adjust based on the height of the current page.

### Example

```dart
import 'package:flexi_page_view/flexi_page_view.dart';

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlexiPageView(
        children: [
          Container(
            height: 100,
            color: Colors.red,
            child: Center(child: Text('Page 1')),
          ),
          Container(
            height: 200,
            color: Colors.green,
            child: Center(child: Text('Page 2')),
          ),
          Container(
            height: 150,
            color: Colors.blue,
            child: Center(child: Text('Page 3')),
          ),
        ],
      ),
    );
  }
}
```

## Credits

This package is inspired by
the [Gist](https://gist.github.com/vejmartin/b8df4c94587bdad63f5b4ff111ff581c)
by [vejmartin](https://gist.github.com/vejmartin).

### Key Properties

`FlexiPageView` supports all properties of `PageView`, including:

- `controller`: Controls the page view's scrolling behavior.
- `scrollDirection`: Specifies the axis along which the pages scroll (`Axis.horizontal` or
  `Axis.vertical`).
- `physics`: Defines the scroll physics for the page view.
- `children`: A list of widgets representing the pages.

## How It Works

`FlexiPageView` calculates the height of the currently visible page and smoothly animates the
widget's height during page transitions. This ensures a seamless user experience when navigating
between pages with different heights.

## Compatibility

`FlexiPageView` is compatible with all Flutter versions that support `PageView`. It can be used in
any project where dynamic height adjustment is required.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.