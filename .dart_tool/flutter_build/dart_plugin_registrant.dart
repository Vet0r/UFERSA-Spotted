//
// Generated file. Do not edit.
// This file is generated from template in file `flutter_tools/lib/src/flutter_plugins.dart`.
//

// @dart = 2.15

import 'dart:io'; // flutter_ignore: dart_io_import.
import 'package:flutter_image_compress_common/flutter_image_compress_common.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:flutter_image_compress_common/flutter_image_compress_common.dart';
import 'package:image_picker_ios/image_picker_ios.dart';
import 'package:file_selector_linux/file_selector_linux.dart';
import 'package:flutter_local_notifications_linux/flutter_local_notifications_linux.dart';
import 'package:image_picker_linux/image_picker_linux.dart';
import 'package:file_selector_macos/file_selector_macos.dart';
import 'package:flutter_image_compress_macos/flutter_image_compress_macos.dart';
import 'package:image_picker_macos/image_picker_macos.dart';
import 'package:file_selector_windows/file_selector_windows.dart';
import 'package:image_picker_windows/image_picker_windows.dart';

@pragma('vm:entry-point')
class _PluginRegistrant {

  @pragma('vm:entry-point')
  static void register() {
    if (Platform.isAndroid) {
      try {
        FlutterImageCompressCommon.registerWith();
      } catch (err) {
        print(
          '`flutter_image_compress_common` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        ImagePickerAndroid.registerWith();
      } catch (err) {
        print(
          '`image_picker_android` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

    } else if (Platform.isIOS) {
      try {
        FlutterImageCompressCommon.registerWith();
      } catch (err) {
        print(
          '`flutter_image_compress_common` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        ImagePickerIOS.registerWith();
      } catch (err) {
        print(
          '`image_picker_ios` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

    } else if (Platform.isLinux) {
      try {
        FileSelectorLinux.registerWith();
      } catch (err) {
        print(
          '`file_selector_linux` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        LinuxFlutterLocalNotificationsPlugin.registerWith();
      } catch (err) {
        print(
          '`flutter_local_notifications_linux` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        ImagePickerLinux.registerWith();
      } catch (err) {
        print(
          '`image_picker_linux` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

    } else if (Platform.isMacOS) {
      try {
        FileSelectorMacOS.registerWith();
      } catch (err) {
        print(
          '`file_selector_macos` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        FlutterImageCompressMacos.registerWith();
      } catch (err) {
        print(
          '`flutter_image_compress_macos` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        ImagePickerMacOS.registerWith();
      } catch (err) {
        print(
          '`image_picker_macos` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

    } else if (Platform.isWindows) {
      try {
        FileSelectorWindows.registerWith();
      } catch (err) {
        print(
          '`file_selector_windows` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

      try {
        ImagePickerWindows.registerWith();
      } catch (err) {
        print(
          '`image_picker_windows` threw an error: $err. '
          'The app may not function as expected until you remove this plugin from pubspec.yaml'
        );
      }

    }
  }
}
