// screens/player_detail_screen.dart (FLAGS REMOVED)
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/api_service.dart';

class PlayerDetailScreen extends StatelessWidget {
  final int playerId;
  final String playerName;

  const PlayerDetailScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playerName),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          ApiService.get('/football-get-player-detail', {'playerid': playerId.toString()}),
          ApiService.get('/football-get-player-logo', {'playerid': playerId.toString()}),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading player data', style: TextStyle(color: Colors.white70)));
          }

          final detailData = snapshot.data![0] as Map<String, dynamic>;
          final logoData = snapshot.data![1] as Map<String, dynamic>;

          final String photoUrl = logoData['response']?['url'] ??
              'https://via.placeholder.com/200';

          List details = (detailData['response']?['detail'] as List?) ?? [];
          details = details.where((item) {
            final String title = item['title'] ?? '';
            return title.toLowerCase() != 'shirt';
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey[800],
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: photoUrl,
                            fit: BoxFit.cover,
                            width: 160,
                            height: 160,
                            placeholder: (_, __) => Container(
                              color: Colors.grey[800],
                              child: const CircularProgressIndicator(color: Color(0xFFFF5722)),
                            ),
                            errorWidget: (_, __, ___) => const Icon(Icons.person, size: 80, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        playerName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2.0,
                    mainAxisExtent: 110,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: details.length,
                  itemBuilder: (context, i) {
                    final item = details[i] as Map<String, dynamic>;
                    final title = item['title'] ?? '';
                    final valueMap = item['value'] as Map<String, dynamic>?;

                    String displayValue = '';

                    if (valueMap != null) {
                      if (valueMap.containsKey('fallback')) {
                        dynamic fallback = valueMap['fallback'];
                        if (fallback is String) {
                          displayValue = fallback;
                        } else if (fallback is Map && fallback.containsKey('utcTime')) {
                          final date = DateTime.parse(fallback['utcTime']);
                          displayValue = '${date.day}/${date.month}/${date.year}';
                        }
                      } else if (valueMap.containsKey('numberValue')) {
                        final num = valueMap['numberValue'];
                        if (title == 'Market value') {
                          displayValue = '€${(num / 1000000).toStringAsFixed(1)}M';
                        } else if (title == 'Height') {
                          displayValue = '$num cm';
                        } else {
                          displayValue = num.toString();
                        }
                      } else if (valueMap.containsKey('key')) {
                        displayValue = (valueMap['key'] ?? valueMap['fallback'] ?? '')
                            .toString()
                            .capitalize();
                      }
                    }

                    // No flag icon at all anymore
                    return Card(
                      color: const Color(0xFF2A2A2A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: TextStyle(color: Colors.grey[400], fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              displayValue,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : this[0].toUpperCase() + substring(1).toLowerCase();
  }
}