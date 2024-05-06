import 'package:bloc/bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(SearchState initialState) : super(initialState);

  final int _perPage = 20;
  int _page = 1;

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is FetchImagesEvent) {
      yield* _mapFetchImagesToState(event.query);
    } else if (event is FetchNextPageEvent) {
      yield* _mapFetchNextPageToState(event.query);
    } else if (event is ToggleFavoriteEvent) {
      yield* _mapToggleFavoriteToState(event.imageUrl);
    }
  }

  Stream<SearchState> _mapFetchImagesToState(String query) async* {
    _page = 1;
    yield* _fetchImages(query);
  }

  Stream<SearchState> _mapFetchNextPageToState(String query) async* {
    _page++;
    yield* _fetchImages(query);
  }

  Stream<SearchState> _fetchImages(String query) async* {
    String apiKey = '43713600-0c1acbb4c2027681173f30d45';
    String apiUrl = 'https://pixabay.com/api/?key=$apiKey&q=$query&per_page=$_perPage&page=$_page';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> hits = data['hits'];

        List<Map<String, dynamic>> images = [];
        for (var hit in hits) {
          images.add({
            'largeImageURL': hit['largeImageURL'],
            'user': hit['user'],
            'imageSize': hit['imageSize']
          });
        }

        bool hasReachedMax = hits.length < _perPage; // Check if there are more pages
        if (_page == 1) {
          yield SearchState(images, [], hasReachedMax: hasReachedMax);
        } else {
          yield state.copyWith(
            images: List.of(state.images)..addAll(images),
            hasReachedMax: hasReachedMax,
          );
        }
      } else {
        print('Failed to fetch images. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching images: $e');
    }
  }

  Stream<SearchState> _mapToggleFavoriteToState(String imageUrl) async* {
    final currentState = state;
    final List<String> updatedFavorites = List.from(currentState.favoriteImages);

    if (updatedFavorites.contains(imageUrl)) {
      updatedFavorites.remove(imageUrl);
    } else {
      updatedFavorites.add(imageUrl);
    }

    yield SearchState(currentState.images, updatedFavorites);
  }
}