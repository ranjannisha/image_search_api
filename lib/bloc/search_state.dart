part of 'search_bloc.dart';

class SearchState {
  final List<Map<String, dynamic>> images;
  final List<String> favoriteImages;
  final bool hasReachedMax;

  SearchState(this.images, this.favoriteImages, {this.hasReachedMax = false});

  SearchState copyWith({
    List<Map<String, dynamic>>? images,
    List<String>? favoriteImages,
    bool? hasReachedMax,
  }) {
    return SearchState(
      images ?? this.images,
      favoriteImages ?? this.favoriteImages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
