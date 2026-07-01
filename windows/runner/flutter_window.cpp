#include "flutter_window.h"

#include <dwmapi.h>
#include <flutter/standard_method_codec.h>

#include <optional>
#include <string>
#include <variant>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  // Let Dart colour the native title bar (caption + text + button glyphs) so the
  // system chrome blends into the warm-paper app surface.
  title_bar_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "labtrack/window",
          &flutter::StandardMethodCodec::GetInstance());
  HWND hwnd = GetHandle();
  title_bar_channel_->SetMethodCallHandler(
      [hwnd](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() != "setTitleBar") {
          result->NotImplemented();
          return;
        }
        const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
        if (args != nullptr) {
          auto get_int = [&](const char* key, int fallback) -> int {
            auto it = args->find(flutter::EncodableValue(std::string(key)));
            if (it != args->end()) {
              if (auto p = std::get_if<int32_t>(&it->second)) return *p;
              if (auto p = std::get_if<int64_t>(&it->second))
                return static_cast<int>(*p);
            }
            return fallback;
          };
          auto get_bool = [&](const char* key, bool fallback) -> bool {
            auto it = args->find(flutter::EncodableValue(std::string(key)));
            if (it != args->end()) {
              if (auto p = std::get_if<bool>(&it->second)) return *p;
            }
            return fallback;
          };
          int caption = get_int("caption", 0xFAF9F5);
          int text = get_int("text", 0x1A1915);
          BOOL dark = get_bool("dark", false) ? TRUE : FALSE;
          COLORREF cap =
              RGB((caption >> 16) & 0xFF, (caption >> 8) & 0xFF, caption & 0xFF);
          COLORREF txt =
              RGB((text >> 16) & 0xFF, (text >> 8) & 0xFF, text & 0xFF);
          const DWORD kImmersiveDarkMode = 20;
          const DWORD kCaptionColor = 35;
          const DWORD kTextColor = 36;
          DwmSetWindowAttribute(hwnd, kImmersiveDarkMode, &dark, sizeof(dark));
          DwmSetWindowAttribute(hwnd, kCaptionColor, &cap, sizeof(cap));
          DwmSetWindowAttribute(hwnd, kTextColor, &txt, sizeof(txt));
        }
        result->Success();
      });

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
