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

## File-access recovery tests

The file picker passes local URLs to `QUrl::toLocalFile()` on every platform.
Failed reads leave the current configuration intact. Saves use `QSaveFile`
without a direct-write fallback, so a failed replacement does not truncate the
original. Permission-denied, missing, other I/O failures and readable empty
files remain distinct. Recovery uses file reselection or Save As; this app does
not require broad disk access or administrator privileges for these operations.

```sh
node --test tests/file_recovery.test.cjs
cmake -S tests -B build-file-tests -DCMAKE_PREFIX_PATH=/path/to/Qt/6.x/platform
cmake --build build-file-tests --parallel 2
ctest --test-dir build-file-tests --output-on-failure
```

The JavaScript tests run the exact QML handlers with fake choosers/I/O. The C++
test uses only QtCore and temporary files. Run it as a normal user, not root,
so file permission checks are meaningful. Neither replaces a macOS packaged-app
check: test native chooser cancel/reselect, denied/revoked folder access,
retry after changing Files and Folders permission, Unicode/space-containing
paths, and failed Save As without losing the current annotations.
