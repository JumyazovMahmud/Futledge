import 'package:flutter/material.dart';
import '../widgets/shimmer_list.dart';
import '../core/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/teamsquad_screen.dart';
import '../screens/player_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search players, teams...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() => _query = '');
                  },
                )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: ApiService.get(
                '/football-all-search',
                {'search': _query.isEmpty ? 'm' : _query},
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ShimmerList(count: 15);
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No results'));
                }

                final data = snapshot.data as Map<String, dynamic>;
                final List suggestions = (data['response']?['suggestions'] as List?) ?? [];

                if (suggestions.isEmpty) {
                  return const Center(
                    child: Text(
                      'Type to search or explore trending below',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: suggestions.length,
                  itemBuilder: (context, i) {
                    final item = suggestions[i] as Map<String, dynamic>;
                    final String type = item['type'] ?? '';


                    if (type == 'player') {
                      final String playerId = item['id'].toString();
                      final String playerName = item['name'] ?? 'Unknown Player';

                      return ListTile(
                        leading: FutureBuilder(
                          future: ApiService.get('/football-get-player-logo', {'playerid': playerId}),
                          builder: (context, logoSnapshot) {
                            String photoUrl = 'https://via.placeholder.com/100';

                            if (logoSnapshot.hasData && logoSnapshot.data != null) {
                              final logoData = logoSnapshot.data as Map<String, dynamic>;
                              photoUrl = logoData['response']?['url'] ?? photoUrl;
                            }

                            return CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.grey[800],
                              backgroundImage: CachedNetworkImageProvider(photoUrl),
                              child: logoSnapshot.connectionState == ConnectionState.waiting
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFFF5722),
                                ),
                              )
                                  : null,
                            );
                          },
                        ),
                        title: Text(
                          playerName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(item['teamName'] ?? 'No team'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlayerDetailScreen(
                                playerId: int.parse(playerId),
                                playerName: playerName,
                              ),
                            ),
                          );
                        },
                      );
                    }


                    if (type == 'team') {
                      final String teamId = item['id'].toString();
                      final String teamName = item['name'] ?? 'Unknown Team';
                      final String logoUrl =
                          'https://images.fotmob.com/image_resources/logo/teamlogo/${teamId}_large.png';

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey[900],
                          child: Image.network(
                            logoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.sports_soccer, color: Colors.grey),
                          ),
                        ),
                        title: Text(
                          teamName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(item['leagueName'] ?? 'Unknown League'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TeamSquadScreen(
                                teamId: int.parse(teamId),
                                teamName: teamName,
                              ),
                            ),
                          );
                        },
                      );
                    }


                    return ListTile(
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFFF5722),
                        child: Icon(
                          type == 'league' ? Icons.emoji_events : Icons.search,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(item['name'] ?? 'Unknown'),
                      subtitle: item['leagueName'] != null ? Text(item['leagueName']) : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}