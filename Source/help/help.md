# minGUI — Guide simple

minGUI est une bibliothèque d'interface pour LÖVE, écrite en Lua. Elle fournit
des fenêtres, des conteneurs, des champs texte et des gadgets utilisables
directement sur le bureau.

## Démarrer

Conserver le dossier `minGUI/` et ses thèmes à côté de `main.lua`.
Les constantes sont disponibles après `minGUI_init()`.

```lua
require "minGUI/minGUI"

local window, button, input

function love.load()
    minGUI_init()
    local flags = bit.bor(MG_FLAG_WINDOW_TITLEBAR, MG_FLAG_WINDOW_BUTTONS)
    window = minGUI:add_window(40, 40, 400, 240, "Ma fenêtre", flags)
    input = minGUI:add_string(10, 10, 240, 25, "Bonjour", nil, window)
    button = minGUI:add_button(10, 45, 120, 25, "Effacer", nil, window)
end

function love.textinput(text)
    minGUI_textinput(text)
end

function love.update(dt)
    minGUI_update_events(dt)
    while true do
        local id, event = minGUI:get_gadget_events()
        if id == nil then break end
        if id == button and event == MG_EVENT_LEFT_MOUSE_CLICK then
            minGUI:set_gadget_text(input, "")
        end
    end
end

function love.draw()
    minGUI_draw_all()
end
```

## Créer et placer les gadgets

Les fonctions `add_*` retournent l'identifiant du gadget. Conserver cet ID pour
lire son état, modifier son texte ou traiter ses événements.

Les dimensions et positions sont en pixels. Pour un gadget avec parent,
`x` et `y` sont relatifs à la zone de contenu de ce parent. Sans parent,
le gadget est posé sur le bureau, derrière les fenêtres.

`flags` et `parent` sont facultatifs. Utiliser `nil` pour laisser un argument
facultatif à sa valeur par défaut. Combiner les flags avec `bit.bor(...)`.

```lua
-- Gadget directement sur le bureau.
local desktopButton = minGUI:add_button(20, 20, 140, 25, "Bouton")

-- Gadget dans une fenêtre.
local field = minGUI:add_string(10, 10, 180, 25, "Texte", nil, window)
```

## Fenêtres et conteneurs

```lua
minGUI:add_window(x, y, width, height, title, flags, parent)
minGUI:add_panel(x, y, width, height, flags, parent)
minGUI:add_scrollarea(x, y, width, height, realWidth, realHeight, flags, parent)
```

Un `panel` contient d'autres gadgets. Une `scrollarea` a un fond blanc et une
surface réelle au moins aussi grande que ses dimensions visibles. Ses
scrollbars internes permettent d'accéder au contenu masqué. Elles occupent
une partie de la zone visible ; les positions des enfants restent celles de
la surface réelle.

```lua
local area = minGUI:add_scrollarea(10, 10, 280, 140, 560, 300, nil, window)
minGUI:add_button(390, 240, 140, 25, "Plus loin", nil, area)
```

| Flag de fenêtre | Effet |
| --- | --- |
| `MG_FLAG_WINDOW_TITLEBAR` | Barre de titre ; déplacement à la souris |
| `MG_FLAG_WINDOW_CLOSE` | Bouton de fermeture |
| `MG_FLAG_WINDOW_MAXIMIZE` | Bouton d'agrandissement |
| `MG_FLAG_WINDOW_RESIZE` | Redimensionnement à la souris |
| `MG_FLAG_WINDOW_BUTTONS` | Les trois boutons précédents |
| `MG_FLAG_WINDOW_CENTERED` | Position initiale centrée |
| `MG_FLAG_WINDOW_TOP_PRIORITY` | Priorité d'affichage sur les fenêtres ordinaires |

```lua
minGUI:set_window_on_top(window) -- Active et place devant, selon sa priorité.
minGUI:maximize_window(window)   -- Agrandit ou restaure.
minGUI:resize_window(window, 500, 300)
minGUI:delete_gadget(window)     -- Supprime aussi ses enfants.
```

## Gadgets courants

Les signatures suivantes acceptent toutes `flags, parent` en derniers arguments.

| Création | Usage |
| --- | --- |
| `add_button(x, y, w, h, text, flags, parent)` | Bouton texte |
| `add_button_image(x, y, w, h, image, flags, parent)` | Bouton avec une image LÖVE |
| `add_label(x, y, w, h, text, flags, parent)` | Texte affiché |
| `add_string(x, y, w, h, text, flags, parent)` | Saisie sur une ligne |
| `add_editor(x, y, w, h, text, flags, parent)` | Saisie sur plusieurs lignes |
| `add_image(x, y, w, h, image, flags, parent)` | Image sélectionnable |
| `add_checkbox(x, y, w, h, text, flags, parent)` | Case à cocher |
| `add_option(x, y, w, h, text, flags, parent)` | Choix exclusif entre options de même parent |
| `add_spin(x, y, w, h, value, minValue, maxValue, flags, parent)` | Valeur numérique |
| `add_canvas(x, y, w, h, flags, parent)` | Surface de dessin |

Pour une image, passer par exemple `love.graphics.newImage("image.png")`.

Les champs texte gèrent le texte UTF-8 et les raccourcis usuels de sélection,
copie, collage et suppression. Un double clic dans une `string` sélectionne
tout son texte. `MG_FLAG_NOT_EDITABLE` rend un champ en lecture seule.
`MG_FLAG_NO_SCROLLBARS` masque les scrollbars de l'éditeur.

Pour un label, utiliser `MG_FLAG_ALIGN_LEFT`, `MG_FLAG_ALIGN_RIGHT` ou
`MG_FLAG_ALIGN_CENTER`.

## Listes et combo box

```lua
local list = minGUI:add_list(770, 135, 220, 140, {"Apple", "Banana", "Cherry"})
local combo = minGUI:add_combo_box(770, 300, 220, 28, {"Red", "Green", "Blue"})

minGUI:set_gadget_state(combo, 2)
local index = minGUI:get_gadget_state(combo) -- 2
local text = minGUI:get_gadget_text(combo)  -- "Green"
```

Ces deux fonctions acceptent aussi `flags, parent`. Les indices commencent à
`1` ; `0` indique l'absence de sélection. Le premier élément est sélectionné
à la création d'une liste non vide.

Les listes utilisent les scrollbars internes lorsque les éléments dépassent
la zone visible. Dans une combo box, la scrollbar apparaît dans la liste
ouverte. Les touches Haut, Bas, Home et End changent le choix du gadget qui a
le focus. Échap ferme la liste déroulante.

Un changement par l'utilisateur émet `MG_EVENT_SELECTION_CHANGED`.

## Lire et modifier un gadget

```lua
minGUI:set_gadget_text(id, "Nouveau texte")
local text = minGUI:get_gadget_text(id)

minGUI:set_gadget_state(checkbox, true)
local checked = minGUI:get_gadget_state(checkbox)

minGUI:set_focus(input)
minGUI:set_cursor_xy(editor, 0, 0) -- Colonne et ligne à partir de zéro.
local position = minGUI:get_cursor_position(editor) -- Position UTF-8 absolue.

local x = minGUI:get_gadget_x(id)
local y = minGUI:get_gadget_y(id)
local width = minGUI:get_gadget_width(id)
local height = minGUI:get_gadget_height(id)
minGUI:delete_gadget(id)
```

`get_gadget_state()` retourne un booléen pour les cases/options, une valeur
numérique pour les spins/scrollbars et un indice pour les listes/combo box.

## Événements

Vider les files avec une boucle à chaque mise à jour. Chaque lecture retire
l'événement retourné. Une file vide retourne `nil`.

```lua
local id, event, source, drop, info = minGUI:get_gadget_events()
```

| Événement | Signification |
| --- | --- |
| `MG_EVENT_LEFT_MOUSE_CLICK` | Clic gauche |
| `MG_EVENT_RIGHT_MOUSE_CLICK` | Clic droit |
| `MG_EVENT_LEFT_MOUSE_PRESSED` / `MG_EVENT_RIGHT_MOUSE_PRESSED` | Appui, pour les gadgets qui l'émettent |
| `MG_EVENT_LEFT_MOUSE_DOWN` / `MG_EVENT_RIGHT_MOUSE_DOWN` | Bouton maintenu, selon le gadget |
| `MG_EVENT_LEFT_MOUSE_DOUBLECLICK` / `MG_EVENT_RIGHT_MOUSE_DOUBLECLICK` | Double clic, selon le gadget |
| `MG_EVENT_SELECTION_CHANGED` | Choix modifié dans une liste ou combo box |
| `MG_EVENT_DRAG_DROPPED` | Dépôt sur le gadget `id`, depuis `source` |

Les événements `MOUSE_CLICK` et `MOUSE_RELEASED` partagent leur valeur.
Pour une image, `info` fournit notamment `filePath`, `fileName`, `parent` et,
si applicable, `scrollarea`.

## Glisser-déposer

Ajouter `MG_FLAG_DRAG_DROPPABLE` à la source et à la cible lors de leur création.
Ce flag est pris en charge par `string`, `editor` et `image`. Il n'y a pas de
fonction d'activation supplémentaire.

```lua
local a = minGUI:add_string(10, 10, 180, 25, "Bonjour", MG_FLAG_DRAG_DROPPABLE, window)
local b = minGUI:add_editor(10, 50, 250, 120, "", MG_FLAG_DRAG_DROPPABLE, window)
```

Le texte d'une `string` se sélectionne au début du glissement et un aperçu suit
la souris. Sur un éditeur, un repère indique la position du dépôt.
Le GUI signale le dépôt ; le code de l'application décide du transfert.

Exemple à intégrer dans la boucle qui lit `get_gadget_events()` :

```lua
if event == MG_EVENT_DRAG_DROPPED and source == a and id == b then
    local target = minGUI.gtree[b]
    if target.editable then
        minGUI_editor_set_position(target, drop.position)
        target.selectionAnchor = nil
        local overwrite = target.overwrite
        target.overwrite = false
        minGUI_editor_replace(target, drop.text)
        target.overwrite = overwrite
    end
end
```

`drop.text` contient le texte transporté, `drop.position` le point d'insertion
UTF-8 dans un éditeur, et `drop.sources` les sources lors d'un glissement groupé.
Voir aussi le traitement de texte dans `main.lua`.

## Menus

### Barre de menus

```lua
local entries = {
    {head_menu = "File", menu_list = {"Open", "Save", "Quit"}},
    {head_menu = "Help", menu_list = {"About..."}}
}
minGUI:add_menu(4, 0, 392, 24, entries, nil, window)
```

Lire cette file dans `love.update()` :

```lua
while true do
    local menu, item = minGUI:get_menu_events()
    if menu == nil then break end
    if menu == 1 and item == 3 then love.event.quit(0) end -- File > Quit
end
```

Les retours sont les indices de la rubrique et de l'entrée, à partir de `1`.
La chaîne `"-"` représente un séparateur.

### Menu contextuel

```lua
local popup = minGUI:add_context_menu({"Open", "Save"}, window)
minGUI:show_context_menu(popup) -- À la position de la souris.
-- Ou : minGUI:show_context_menu(popup, x, y), en coordonnées écran.
minGUI:hide_context_menu()
```

Le parent est facultatif. Le menu reste dans les limites de l'écran et se ferme
après un choix, un clic extérieur ou Échap.

```lua
while true do
    local menuID, item = minGUI:get_context_menu_events()
    if menuID == nil then break end
    if menuID == popup and item == 1 then
        print("Open")
    end
end
```

## Scrollbars, timers et raccourcis

```lua
local bar = minGUI:add_scrollbar(10, 10, 20, 100, 0, 0, 100, 1,
    MG_FLAG_SCROLLBAR_VERTICAL, window)
minGUI:set_gadget_state(bar, 50)
```

L'ordre des arguments est `x, y, width, height, value, minValue, maxValue, inc,
flags, parent`. Utiliser `MG_FLAG_SCROLLBAR_HORIZONTAL` pour une barre
horizontale. Les conteneurs défilants créent leurs scrollbars internes eux-mêmes.

```lua
minGUI:start_timer(1, 1000) -- Délai en millisecondes.
-- Dans love.update :
while true do
    local timerID, event = minGUI:get_timer_events()
    if timerID == nil then break end
    if timerID == 1 and event == MG_EVENT_TIMER_TICK then print("Tick") end
end
minGUI:stop_timer(1)
```

```lua
local SAVE = 100 -- Code d'événement choisi par l'application.
minGUI:add_keyboard_shortcut(window, "ctrl+s", SAVE)
```

Le raccourci émet un événement de gadget associé à la fenêtre active.

## Apparence et dessin

```lua
minGUI:set_theme("Dark") -- Aussi : GEM, Black&White, Dark&Orange.
minGUI:set_background_color(0.5, 0.5, 0.5, 1)
minGUI:set_text_color(0, 0, 0, 1)
minGUI:set_inverted_text_color(1, 1, 1, 1)
```

Les couleurs sont des composantes de `0` à `1`. Configurer les couleurs avant
la création des gadgets, qui mémorisent certaines de ces valeurs.

```lua
local canvas = minGUI:add_canvas(10, 10, 150, 100, nil, window)
minGUI:clear_canvas(canvas, 0, 0, 0, 1)
minGUI:draw_rectangle_to_canvas(canvas, "line", 10, 10, 40, 30,
    {r=1, g=0, b=0, a=1})
```

L'exemple complet de `main.lua` montre les gadgets du bureau, les conteneurs,
les menus et le transfert de texte.
