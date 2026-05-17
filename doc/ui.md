# UI Design

# 1. Screens

- HomeScreen
- PlaceDetailScreen
- AddPlaceScreen
- SettingScreen

# 2. Components

## HomeScreen Layout

Stack
 ├── GoogleMap (full screen)
 ├── DraggableScrollableSheet
 │    └── ListView(PlaceCard)

## PrimaryButton

- width: full
- height: 48
- radius: 12
- action: onTap()

## PlaceCard

- title: place_name
- subtitle: category
- right: is_visited icon
- onTap: navigate(PlaceDetailScreen)

## AppBarDefault

- title: String
- back button: optional

# 3. PlaceListScreen

## Layout

Column
 ├── AppBarDefault(title="Places")
 ├── SearchBar
 ├── FilterRow
 ├── Expanded(ListView)
 ├── FloatingActionButton(AddPlaceScreen)

## List Item

- widget: PlaceCard
- data source: place_list

## State

- loading → CircularProgressIndicator
- empty → Text("No places")
- error → Text("Error occurred")
- loaded → ListView

## Actions

- onTap PlaceCard → navigate(PlaceDetailScreen)
- FAB → AddPlaceScreen

# 4. AddPlaceScreen

## Layout

Form
 ├── TextField(place_name)
 ├── TextField(address)
 ├── MapPicker(latitude, longitude)
 ├── Dropdown(purpose)
 ├── Switch(is_visited)
 ├── PrimaryButton("Save")

## Validation

- place_name: required
- latitude: -90 ~ 90
- longitude: -180 ~ 180

# 5. MapScreen

## Layout

Stack
 ├── GoogleMap
 ├── FloatingSearchBar
 ├── BottomSheet(place preview)

## Behavior

- marker tap → show BottomSheet
- long press → AddPlaceScreen (lat/lng prefilled)

# 6. Navigation Flow

HomeScreen → PlaceListScreen  
PlaceListScreen → PlaceDetailScreen  
PlaceListScreen → AddPlaceScreen  
MapScreen → PlaceDetailScreen  

# 7. Data Binding

## PlaceCard

- place_name ← place_list.place_name  
- category ← place_list.category  
- is_visited ← place_list.is_visited  

# 8. State Model

- loading
- loaded(List<Place>)
- empty
- error(String)

# 9. Notes

- UI構造と状態を分離する
- Layoutはツリー形式で記述する
- 画面単位で独立させる
- Flutterコード生成を前提とした設計