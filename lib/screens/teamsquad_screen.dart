import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/api_service.dart';
import '../widgets/shimmer_list.dart';

class TeamSquadScreen extends StatelessWidget {
  final int teamId;
  final String teamName;

  const TeamSquadScreen({
    super.key,
    required this.teamId,
    required this.teamName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$teamName Squad'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: FutureBuilder(
        future: ApiService.get('/football-get-list-player', {'teamid': teamId.toString()}),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerList(count: 20);
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading squad',
                style: TextStyle(color: Colors.red[400]),
              ),
            );
          }


          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No squad data available'));
          }

          final data = snapshot.data as Map<String, dynamic>;
          final squadGroups = (data['response']?['list']?['squad'] as List?) ?? [];

          if (squadGroups.isEmpty) {
            return const Center(child: Text('No players found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: squadGroups.length,
            itemBuilder: (context, groupIndex) {
              final group = squadGroups[groupIndex] as Map<String, dynamic>;
              final String title = (group['title'] as String?)?.toUpperCase() ?? 'UNKNOWN';
              final List members = (group['members'] as List?) ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5722),
                      ),
                    ),
                  ),
                  ...members.map<Widget>((player) {
                    final p = player as Map<String, dynamic>;

                    final String playerName = p['name'] ?? 'Unknown Player';
                    final int? shirtNumber = p['shirtNumber'];
                    final String position = p['positionIdsDesc'] ?? '';
                    final bool isInjured = p['injured'] == true || p['injury'] != null;
                    final String? injuryInfo = p['injury']?['expectedReturn'];
                    final String playerId = p['id'].toString();

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      color: const Color(0xFF2A2A2A),
                      child: ListTile(
                        leading: FutureBuilder(
                          future: ApiService.get('/football-get-player-logo', {'playerid': playerId}),
                          builder: (context, logoSnapshot) {
                            String imageUrl = '';

                            if (logoSnapshot.hasData && logoSnapshot.data != null) {
                              final logoData = logoSnapshot.data as Map<String, dynamic>;
                              imageUrl = logoData['response']?['url'] ?? '';
                            }

                            return CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[800],
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFFF5722),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.person,
                                  color: Colors.white54,
                                  size: 30,
                                ),
                                imageBuilder: (context, imageProvider) => CircleAvatar(
                                  backgroundImage: imageProvider,
                                  radius: 30,
                                ),
                              ),
                            );
                          },
                        ),
                        title: Text(
                          playerName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (shirtNumber != null)
                              Text('#$shirtNumber • $position'),
                            if (isInjured)
                              Text(
                                'Injured${injuryInfo != null ? ' - $injuryInfo' : ''}',
                                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: isInjured
                            ? const Icon(Icons.local_hospital, color: Colors.redAccent)
                            : null,
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }
}