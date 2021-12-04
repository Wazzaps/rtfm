//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <native_winpos/native_winpos_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) native_winpos_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "NativeWinposPlugin");
  native_winpos_plugin_register_with_registrar(native_winpos_registrar);
}
