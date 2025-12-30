import 'package:flutter/material.dart';
import '../widgets/shimmer_list.dart';
import '../core/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'standings_screen.dart';
class LeaguesScreen extends StatelessWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular Leagues')),
      body: FutureBuilder(
        future: ApiService.get('/football-popular-leagues'),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerList(count: 8);
          }


          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }


          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data as Map<String, dynamic>;

          final popularList = (data['response']?['popular'] as List?) ?? [];

          if (popularList.isEmpty) {
            return const Center(child: Text('No popular leagues found'));
          }

          return ListView.builder(
            itemCount: popularList.length,
            itemBuilder: (_, i) {
              final league = popularList[i] as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: const Color(0xFF1E1E1E),
                child: ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: league['logo'] ?? '',
                    width: 50,
                    height: 50,
                    placeholder: (_, __) => Container(
                      color: Colors.grey[800],
                      width: 50,
                      height: 50,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey[800],
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.sports_soccer, color: Colors.white38),
                    ),
                  ),
                  title: Text(
                    league['name'] ?? 'Unknown League',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${league['ccode'] ?? ''}',
                    style: const TextStyle(color: Color(0xFFB0BEC5)),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFFFF5722)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StandingsScreen(
                          leagueId: league['id'] as int,
                          leagueName: league['name'] ?? 'League',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}