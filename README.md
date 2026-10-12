# 3d 标注工具

## Build requirements

Use Qt 6.4 or newer with Quick, Quick Controls 2 and Quick Dialogs.
Qt 6.4 is the minimum used by the existing
[ColorDialog](https://doc.qt.io/qt-6/qml-qtquick-dialogs-colordialog.html) and
[objectCreationFailed signal](https://doc.qt.io/qt-6/qqmlapplicationengine.html#objectCreationFailed).
The Windows control style is retained on Windows; other platforms use Fusion.

```sh
cmake -S . -B build -DCMAKE_PREFIX_PATH=/path/to/Qt/6.x/platform
cmake --build build --parallel 2
```

A successful source review does not validate a macOS bundle. Build and test the
packaged application on macOS before releasing it.
