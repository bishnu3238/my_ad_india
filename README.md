# my_ad


[//]: Make it executable: (**_`(chmod +x version_bump.sh)`_**)
## Usage: ./version_bump.sh [options] [version] [build-number]
```shell
Options:
-d, --debug        Enable debug output
--build-only       Skip version bump and only build
--no-build         Skip build step
--help             Show this help message

Version can be:
major              Bump major version (X.0.0)
minor              Bump minor version (x.X.0)
patch              Bump patch version (x.x.X)
x.y.z              Set specific version


EXAMPLE : ./version_bump.sh minor // Bump minor version:
          ./version_bump.sh 2.0.0 42 // Set specific version and build number:
          ./version_bump.sh --build-only // Only build without changing version:
          ./version_bump.sh major --no-build // Bump major version but skip build:
          
```



A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
