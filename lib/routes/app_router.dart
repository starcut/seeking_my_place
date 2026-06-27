import 'package:go_router/go_router.dart';
import 'package:seeking_my_place/features/place/presentation/screens/home_screen.dart';
import 'package:seeking_my_place/features/place/presentation/screens/place_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/place/:id',
      builder: (context, state) {
        final placeId = state.pathParameters['id']!;
        return PlaceDetailScreen(placeId: placeId);
      },
    ),
  ],
);
