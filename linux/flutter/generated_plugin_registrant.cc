//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <file_saver/file_saver_plugin.h>
#include <flutter_usb/flutter_usb_plugin.h>
#include <hid_listener/hid_listener_plugin.h>
#include <printing/printing_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) file_saver_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FileSaverPlugin");
  file_saver_plugin_register_with_registrar(file_saver_registrar);
  g_autoptr(FlPluginRegistrar) flutter_usb_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterUsbPlugin");
  flutter_usb_plugin_register_with_registrar(flutter_usb_registrar);
  g_autoptr(FlPluginRegistrar) hid_listener_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "HidListenerPlugin");
  hid_listener_plugin_register_with_registrar(hid_listener_registrar);
  g_autoptr(FlPluginRegistrar) printing_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "PrintingPlugin");
  printing_plugin_register_with_registrar(printing_registrar);
}
