# UI Contracts (programador ↔ artista)

Este documento define la base funcional para que cualquier artista pueda "skinnear" la UI sin romper lógica.

## 1) `scenes/ui/ui_root.tscn`
- Nodo raíz: `UIRoot` (`CanvasLayer`) con script `scripts/ui/ui_manager.gd`.
- Nodos esperados:
  - `MenuContainer` (`Control`): contenedor donde se instancian menús.
  - `FadeRect` (`ColorRect`): overlay para transiciones fade in/out.
- API principal (UIManager):
  - `open_menu(menu_name: String) -> Node`
  - `close_menu(menu_name: String)`
  - `get_menu(menu_name: String) -> Node`
  - `transition_to_scene(scene_path: String)`

## 2) Convención de señales para menús
Todos los menús deberían usar estas señales (si aplican):
- `requested_close`
- `requested_open_settings`
- `requested_back`

Señales específicas por menú (ejemplo):
- `exit_to_menu_requested` (pause menu)
- `requested_reload_scene` (debug overlay)

## 3) `scenes/pause_menu.tscn`
- Estructura editable:
  - `PauseToggleButton`
  - `PausePanel`
  - `MainView`
  - `SettingsView`
  - `ConfirmView`
- Script: `scripts/pause_menu.gd`.
- Comportamiento funcional ya implementado (no depende de arte):
  - pausa/reanudar
  - slider volumen
  - confirmación al salir al menú principal

## 4) `scenes/ui/combat_log_panel.tscn`
- Panel funcional de log con scroll.
- Script: `scripts/ui/combat_log_panel.gd`.
- Fuente de datos: autoload `CombatLog`.

## 5) `scenes/ui/debug_overlay.tscn`
- Overlay de desarrollo toggleable con `debug_toggle` (F1 por defecto).
- Script: `scripts/ui/debug_overlay.gd`.
- Diseñable libremente mientras se mantengan botones/señales.

## 6) Settings/Save desacoplados
- `SaveSystem` (`autoload`): persistencia versionada de datos (`user://save_data.cfg`).
- `AudioSettings` consume `SaveSystem` para volúmenes.
- Rebind base disponible en `SaveSystem.set_action_key(action_name, keycode)`.

## 7) Regla práctica
Puedes cambiar:
- Theme, fuentes, colores, paneles, iconos, tamaños, layouts.

Evita cambiar sin coordinar:
- Nombres de nodos que los scripts buscan por ruta.
- Nombres de señales que el gameplay ya conecta.
