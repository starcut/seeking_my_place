import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seeking_my_place/features/place/presentation/screens/add_place_screen.dart';
import 'package:seeking_my_place/features/place/presentation/screens/home_screen.dart';
import 'package:seeking_my_place/features/place/presentation/screens/place_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/place/new',
      pageBuilder: (context, state) =>
          const MaterialPage(fullscreenDialog: true, child: AddPlaceScreen()),
    ),
    GoRoute(
      path: '/place/:id',
      builder: (context, state) {
        final placeId = state.pathParameters['id']!;
        return PlaceDetailScreen(placeId: placeId);
      },
    ),
    GoRoute(
      path: '/place/:id/edit',
      builder: (context, state) {
        final placeId = state.pathParameters['id']!;
        return AddPlaceScreen(placeId: placeId);
      },
    ),
  ],
);
