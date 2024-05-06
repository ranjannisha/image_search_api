part of 'search_bloc.dart';

abstract class SearchEvent {}

class FetchImagesEvent extends SearchEvent {
  final String query;

  FetchImagesEvent(this.query);
}

class FetchNextPageEvent extends SearchEvent {
  final String query;

  FetchNextPageEvent(this.query);
}

class ToggleFavoriteEvent extends SearchEvent {
  final String imageUrl;

  ToggleFavoriteEvent(this.imageUrl);
}