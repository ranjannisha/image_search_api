import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class FavoriteScreen extends StatefulWidget {
  final List<String> favoriteImages;

  const FavoriteScreen({Key? key, required this.favoriteImages}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Images'),
        backgroundColor: Colors.greenAccent,
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: widget.favoriteImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showRemoveDialog(index);
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl:  widget.favoriteImages[index],
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
                          ],
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showRemoveDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.greenAccent,
          title: const Text('Remove from Favorites'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you want to remove this image from favorites?')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.black),),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.favoriteImages.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Remove', style: TextStyle(color: Colors.black),),
            ),
          ],
        );
      },
    );
  }
}
