

### Layout

Container
 └── Text(label)

### Style

- width: full
- height: 48
- borderRadius: 12

### Actions

- onTap()

---

## AppBarDefault

### Props

- title: String
- backButton: optional

---

## PlaceCard

### Layout

Row
 ├── Expanded
 │    └── Column
 │         ├── Row
 │         │    ├── Text(category)
 │         │    ├── Icon(purpose)
 │         │    ├── Spacer
 │         │    └── Icon(is_visited)
 │         ├── Text(place_name)
 │         └── Text(address)
 ├── IconButton(global)
 └── IconButton(menu)

### Data Binding

- category ← place_list.category
- place_name ← place_list.place_name
- address ← place_list.address
- is_visited ← place_list.is_visited

### Actions

- onTap → navigate(PlaceDetailScreen)
- leftSwipe
  - show delete action
- onTap DeleteAction
  - show confirmation dialog
- pin
  - prioritize display order

---

## PlaceForm

### Props

- initialValue: PlaceFormUiModel?
- onChanged(value)
- readOnly: bool

### Layout

Form
 ├── TextField(place_name)
 ├── Dropdown(category)
 ├── Dropdown(purpose)
 ├── TextField(url)
 ├── TextField(address)
 ├── MapPicker(latitude, longitude)
 └── Checkbox(is_visited)

---

## Validation

- place_name required

- latitude
  - min: -90
  - max: 90

- longitude
  - min: -180
  - max: 180

- url
  - optional
  - valid URL format

---

## Actions

- onAddressInputCompleted
  - geocode address
  - update latitude
  - update longitude

# 3. HomeScreen

## Layout

Scaffold
 ├── appBar: AppBarDefault
 │    └── SettingButton
 ├── body:
 │    └── Stack
 │         ├── GoogleMap
 │         └── DraggableScrollableSheet
 │              └── Column
 │                   ├── SearchBar
 │                   ├── RadiusFilter
 │                   └── Expanded
 │                        └── ListView(PlaceCard)
 └── floatingActionButton
      └── AddPlaceButton

---

## Components

- AppBarDefault
- SettingButton
- GoogleMap
- SearchBar
- RadiusFilter
- PlaceCard
- AddPlaceButton

---

## State

### UI State

- selectedPlaceId
  - selected marker id
  - selected list item id
- searchKeyword
- radiusEnabled

### Data State

- loading
  - CircularProgressIndicator
- loaded
  - show place list
- empty
  - Text("登録なし")
- error
  - Dialog("データ取得エラー")


---

## Actions

- onTap SettingButton
  - navigate(SettingScreen)

- onTap PlaceCard
  - navigate(PlaceDetailScreen)

- onTap AddPlaceButton
  - navigate(AddPlaceScreen)

- onTap MapMarker
  - select place
  - show MarkerInfoBubble
  - use ScrollController
  - highlight selected PlaceCard

- tap empty map area
  - clear selectedPlaceId

---

## Behavior

- map marker tap
  - show place_name bubble
  - synchronize map and list selection

- selected PlaceCard
  - backgroundColor: #fff2b8

- sheet drag
  - resize list area

- search input
  - filter places

- radius change
  - update visible places
  - update circle size


---

## Navigation

- HomeScreen → SettingScreen
- HomeScreen → PlaceDetailScreen
- HomeScreen → AddPlaceScreen

---

# 4. SearchBar

## Layout

Row
 ├── SearchIcon
 ├── TextField(keyword)
 └── ClearButton

---

## Behavior

- input updates search keyword
- clear button resets keyword
- partial match
- case insensitive
- target fields:
  - place_name
  - address

---

# 5. RadiusFilter

## Layout

Row
 ├── Slider(100 ~ 50000)
 ├── Text(distance)
 └── Switch(enabled)

---

## Behavior

- switch ON
  - enable radius filter
  - slider active
  - search by radius

- switch OFF
  - disable radius filter
  - slider disabled
  - search without radius limit

- slider updates search radius

---

## State

- enabled: bool
- radiusMeter: double

---

# 6. GoogleMap Area

## Components

- GoogleMap
- MapMarker
  - placeId
  - latitude
  - longitude
  - selected
- RadiusCircleOverlay
- MarkerInfoBubble

---

## Layout

Stack
 └── GoogleMap

---

## Behavior

- marker tap
  - show place preview
  - update selectedPlaceId

- debounce map move event

- radius filter enabled
  - draw RadiusCircleOverlay

- radius change
  - update RadiusCircleOverlay size

- radius filter disabled
  - hide RadiusCircleOverlay

---

# 7. AddPlaceScreen

## Layout

Scaffold
 ├── appBar: AppBarDefault
 └── body:
      └── SingleChildScrollView
           └── Column
                ├── PlaceForm
                └── PrimaryButton("Save")

---

## Validation

- place_name required

- latitude
  - min: -90
  - max: 90

- longitude
  - min: -180
  - max: 180

- url
  - optional
  - valid URL format

---

## Actions

- onAddressInputCompleted
  - geocode address
  - update latitude
  - update longitude

- onTap Save
  - validate form
  - save place
  - navigate back

---

## State

- editing
- loading
- saving
- success
- error(message)

---

## Error Handling

- show dialog on save failure
- show snackbar on validation failure

---

# 8. PlaceDetailScreen

## Route Params

- placeId: String

---

## State

- loading
- loaded
- editing
- saving
- success
- error(message)

---

## Layout

Scaffold
 ├── appBar: AppBarDefault
 └── body:
      └── SingleChildScrollView
           └── if(viewMode)
                └── ViewLayout
           └── if(editMode)
                └── EditLayout

---

# ViewLayout

Column
 ├── Text(place_name)
 ├── Text(category)
 ├── Text(purpose)
 ├── Text(url)
 ├── AddressRow
 ├── GoogleMapPreview
 ├── VisitedBadge
 ├── PrimaryButton("Edit")
 └── DangerButton("Delete")

---

# EditLayout

Column
 ├── PlaceForm
 ├── PrimaryButton("Save")
 └── SecondaryButton("Cancel")

---

## Actions

- onTap Edit
  - switch mode → edit

- onTap Cancel
  - discard changes
  - switch mode → view

- onTap Save
  - validate form
  - update place
  - switch mode → view

- onTap Delete
  - show confirmation dialog
  - delete place
  - navigate back

---

## Error Handling

- show dialog on save failure
- show snackbar on validation failure

# 9. SettingScreen

## Layout

Scaffold
 ├── appBar: AppBarDefault
 └── body:
      └── ListView
           ├── DataSection
           └── AppInfoSection

---

## DataSection

Column
 ├── ExportButton
 └── ImportButton

---

## AppInfoSection

Column
 └── AppVersion

---

## Actions

- export database
- import database

---

## State

- idle
- exporting
- importing
- success
- error(message)

---

## Error Handling

- show dialog on export failure
- show dialog on import failure
- show snackbar on success

---

# 10. Global State Pattern

## Standard State

- loading
  - initial load
  - refresh
- loaded(List<PlaceUiModel>)
- empty
  - when places.isEmpty- empty
- error(message)

---

# 11. Navigation Flow

HomeScreen
 ├── AddPlaceScreen
 ├── PlaceDetailScreen
 └── EditPlaceScreen

EditPlaceScreen
 └── PlaceForm