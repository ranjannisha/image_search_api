import 'dart:ui';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixabay_image_search/bloc/search_bloc.dart';
import 'favorite_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<SearchBloc>(context).add(FetchImagesEvent(''));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      BlocProvider.of<SearchBloc>(context)
          .add(FetchNextPageEvent(_searchController.text));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= maxScroll;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pixabay Image Search'),
        backgroundColor: Colors.greenAccent,
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(10.0),
                child:
                TextField(
                  controller: _searchController,
                  onChanged: (text) {
                    if (text.isEmpty) {
                      BlocProvider.of<SearchBloc>(context).add(FetchImagesEvent(''));
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    filled: true,
                    fillColor: Colors.grey[200],
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        BlocProvider.of<SearchBloc>(context)
                                    .add(FetchImagesEvent(_searchController.text));
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.greenAccent),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  ),
                ),
              ),
              Expanded(
                child: _buildImageList(state),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(120, 60),
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FavoriteScreen(favoriteImages: state.favoriteImages),
                    ),
                  );
                },
                child: const Text('Favorite Images',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageList(SearchState state) {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Display two items in each row
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount:
          state.hasReachedMax ? state.images.length : state.images.length + 1,
      itemBuilder: (context, index) {
        if (index < state.images.length) {
          final isFavorited = state.favoriteImages
              .contains(state.images[index]['largeImageURL']);
          return GestureDetector(
            onTap: () {
              BlocProvider.of<SearchBloc>(context).add(
                  ToggleFavoriteEvent(state.images[index]['largeImageURL']));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: state.images[index]['largeImageURL'],
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.white,
                          child: Container(
                            color: Colors.grey,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 5),
                    Text(state.images[index]['user']),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.image),
                    SizedBox(width: 5),
                    Text(
                        getReadableImageSize(state.images[index]['imageSize'])),
                  ],
                ),
              ],
            ),
          );
        } else if (!state.hasReachedMax) {
          return Container();
        } else {
          return Container(); // End of List
        }
      },
    );
  }

  String getReadableImageSize(int imageSize) {
    if (imageSize < 1024) {
      return '$imageSize B';
    } else if (imageSize < 1048576) {
      return '${(imageSize / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(imageSize / 1048576).toStringAsFixed(2)} MB';
    }
  }
}
