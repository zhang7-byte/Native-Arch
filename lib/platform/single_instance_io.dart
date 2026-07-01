import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

// Win32 constants (kept local).
const _errorAlreadyExists = 183;
const _swRestore = 9;

// Matches the native window title created in windows/runner/main.cpp.
const _windowTitle = 'labtrack';
const _mutexName = r'Local\labtrack_single_instance';

// CreateMutexW isn't re-exported by this win32 version, so bind it directly.
// Lazily initialised, so it's only touched on Windows (guarded below).
final _createMutexW = DynamicLibrary.open('kernel32.dll').lookupFunction<
    IntPtr Function(Pointer<Void>, Int32, Pointer<Utf16>),
    int Function(Pointer<Void>, int, Pointer<Utf16>)>('CreateMutexW');

/// On Windows: try to acquire a process-wide named mutex. If another instance
/// already holds it, focus that window and exit this process so no second window
/// opens. Otherwise hold the mutex (for this process's lifetime) and return.
/// No-op on non-Windows platforms.
Future<void> enforceSingleInstance() async {
  if (defaultTargetPlatform != TargetPlatform.windows) return;
  final name = _mutexName.toNativeUtf16();
  try {
    _createMutexW(nullptr, 0, name);
    final alreadyRunning = GetLastError() == _errorAlreadyExists;
    if (alreadyRunning) {
      _focusExisting();
      exit(0); // the running instance stays; this one bows out
    }
    // We now own the mutex; intentionally leave the handle open for the
    // process lifetime so it's released only when we exit.
  } finally {
    malloc.free(name);
  }
}

void _focusExisting() {
  final title = _windowTitle.toNativeUtf16();
  try {
    final hwnd = FindWindow(nullptr, title);
    if (hwnd != 0) {
      ShowWindow(hwnd, _swRestore); // un-minimise / restore from tray
      SetForegroundWindow(hwnd);
    }
  } catch (_) {
    // Best-effort focus; the single-instance guarantee still holds.
  } finally {
    malloc.free(title);
  }
}
