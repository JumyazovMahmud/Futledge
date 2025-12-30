import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NewsCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const NewsCard({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [

            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, __) => Container(
                color: Colors.grey[800],
                child: const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722))),
              ),
              errorWidget: (_, __, ___) => Container(color: Colors.grey[800]),
            ),


            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.5, 0.8, 1.0],
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}