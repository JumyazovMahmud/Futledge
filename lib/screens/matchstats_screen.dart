import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/api_service.dart';

class MatchStatsScreen extends StatelessWidget {
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamId;
  final String awayTeamId;
  final String score;
  final String status;

  const MatchStatsScreen({
    super.key,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.score,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$homeTeam vs $awayTeam'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: FutureBuilder(
        future: ApiService.get('/football-get-match-event-all-stats', {'eventid': matchId}),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'Error loading stats: ${snapshot.error ?? 'No data'}',
                style: TextStyle(color: Colors.red[400]),
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data as Map<String, dynamic>;
          final List statsSections = data['response']?['stats'] as List? ?? [];

          if (statsSections.isEmpty) {
            return const Center(child: Text('No statistics available'));
          }

          final Map<String, List<dynamic>> groupedStats = {};

          for (var section in statsSections) {
            final String title = section['title'] ?? 'Stats';
            final List stats = section['stats'] ?? [];

            if (!groupedStats.containsKey(title)) {
              groupedStats[title] = [];
            }
            groupedStats[title]!.addAll(stats);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[800],
                          child: CachedNetworkImage(
                            imageUrl: 'https://images.fotmob.com/image_resources/logo/teamlogo/${homeTeamId}_large.png',
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.sports_soccer, size: 40),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 110,
                          child: Text(
                            homeTeam,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        Text(
                          score,
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFFF5722)),
                        ),
                        Text(
                          status,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[800],
                          child: CachedNetworkImage(
                            imageUrl: 'https://images.fotmob.com/image_resources/logo/teamlogo/${awayTeamId}_large.png',
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.sports_soccer, size: 40),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 110,
                          child: Text(
                            awayTeam,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                ...groupedStats.entries.map<Widget>((entry) {
                  final String title = entry.key;
                  final List stats = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      ...stats.map<Widget>((stat) {
                        final String statTitle = stat['title'] ?? '';
                        final List values = stat['stats'] ?? [];
                        final String type = stat['type'] ?? 'text';
                        final String highlighted = stat['highlighted'] ?? 'equal';

                        if (type == 'title') {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              statTitle,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          );
                        }

                        final String homeValue = values.length > 0 ? values[0]?.toString() ?? '-' : '-';
                        final String awayValue = values.length > 1 ? values[1]?.toString() ?? '-' : '-';

                        final Color homeColor = highlighted == 'home' ? Colors.greenAccent : Colors.white;
                        final Color awayColor = highlighted == 'away' ? Colors.greenAccent : Colors.white;

                        if (type == 'graph') {
                          final int home = int.tryParse(homeValue) ?? 0;
                          final int away = int.tryParse(awayValue) ?? 0;
                          final int total = home + away;
                          final int homeFlex = total > 0 ? (home * 100 ~/ total).clamp(1, 99) : 50;
                          final int awayFlex = total > 0 ? (away * 100 ~/ total).clamp(1, 99) : 50;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  statTitle,
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: homeFlex,
                                      child: Container(
                                        height: 24,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: homeColor,
                                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                        ),
                                        child: Text(
                                          '$home%',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: awayFlex,
                                      child: Container(
                                        height: 24,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: awayColor,
                                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                                        ),
                                        child: Text(
                                          '$away%',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                homeValue,
                                style: TextStyle(fontSize: 16, color: homeColor, fontWeight: FontWeight.w600),
                              ),
                              Expanded(
                                child: Text(
                                  statTitle,
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                awayValue,
                                style: TextStyle(fontSize: 16, color: awayColor, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                    ],
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}