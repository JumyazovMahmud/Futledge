import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/shimmer_list.dart';
import '../core/api_service.dart';
import '../screens/teamsquad_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> popularLeagues = [
    {'id': '47', 'name': 'Premier League', 'logo': 'https://images.fotmob.com/image_resources/logo/leaguelogo/47.png'},
    {'id': '87', 'name': 'La Liga', 'logo': 'https://images.fotmob.com/image_resources/logo/leaguelogo/87.png'},
    {'id': '54', 'name': 'Bundesliga', 'logo': 'https://images.fotmob.com/image_resources/logo/leaguelogo/54.png'},
    {'id': '55', 'name': 'Serie A', 'logo': 'https://images.fotmob.com/image_resources/logo/leaguelogo/55.png'},
    {'id': '53', 'name': 'Ligue 1', 'logo': 'https://images.fotmob.com/image_resources/logo/leaguelogo/53.png'},
    {'id': '42', 'name': 'Champions League', 'logo': 'https://images.fotmob.com/image_resources/logo/leaguelogo/42.png'},
    {'id': '73', 'name': 'Europa League', 'logo': 'https://images.fotmob.com/image_resources/logo/leaguelogo/73.png'},
  ];

  String selectedLeagueId = '47';
  String selectedLeagueName = 'Premier League';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<List<dynamic>> _fetchData(String endpoint) async {
    final response = await ApiService.get(endpoint, {'leagueid': selectedLeagueId});
    if (response['status'] == 'success') {
      return response['response']['standing'] ?? response['response']['players'] ?? [];
    }
    return [];
  }

  // Fetch player logo URL directly from your API
  Future<String> _getPlayerLogoUrl(int playerId) async {
    try {
      final response = await ApiService.get('/football-get-player-logo', {'playerid': playerId.toString()});
      if (response['status'] == 'success' && response['response']?['url'] != null) {
        return response['response']['url'] as String;
      }
    } catch (e) {
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Analytics', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // League Selector
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: popularLeagues.length,
                  itemBuilder: (context, index) {
                    final league = popularLeagues[index];
                    final isSelected = league['id'] == selectedLeagueId;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        avatar: CachedNetworkImage(
                          imageUrl: league['logo'],
                          width: 24,
                          height: 24,
                          placeholder: (_, __) => const SizedBox(width: 24),
                          errorWidget: (_, __, ___) => const Icon(Icons.sports_soccer, size: 20),
                        ),
                        label: Text(league['name']),
                        selected: isSelected,
                        selectedColor: Colors.orange.shade900,
                        backgroundColor: Colors.grey[800],
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                        onSelected: (_) {
                          setState(() {
                            selectedLeagueId = league['id'];
                            selectedLeagueName = league['name'];
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.orange,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: 'Standings'),
                  Tab(text: 'Top Goals'),
                  Tab(text: 'Top Assists'),
                  Tab(text: 'Top Ratings'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStandingsTab(),
          _buildPlayerTab('/football-get-top-players-by-goals', 'goals'),
          _buildPlayerTab('/football-get-top-players-by-assists', 'assists'),
          _buildPlayerTab('/football-get-top-players-by-rating', 'rating'),
        ],
      ),
    );
  }

  Widget _buildStandingsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchData('/football-get-standing-all'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerList(count: 20);
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        final standings = snapshot.data ?? [];
        if (standings.isEmpty) {
          return const Center(child: Text('No standings available', style: TextStyle(color: Colors.white70)));
        }

        return ListView.builder(
          itemCount: standings.length,
          itemBuilder: (_, i) {
            final team = standings[i] as Map<String, dynamic>;
            final teamId = team['id'] as int;
            final logoUrl = 'https://images.fotmob.com/image_resources/logo/teamlogo/${teamId}_large.png';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              color: const Color(0xFF2A2A2A),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TeamSquadScreen(
                        teamId: teamId,
                        teamName: team['name'] ?? 'Team',
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[900],
                    child: CachedNetworkImage(
                      imageUrl: logoUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (_, __, ___) => const Icon(Icons.sports_soccer, color: Colors.grey, size: 28),
                    ),
                  ),
                  title: Text(
                    team['name'] ?? 'Unknown Team',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  subtitle: Text(
                    'P: ${team['played'] ?? 0}  W: ${team['wins'] ?? 0}  D: ${team['draws'] ?? 0}  L: ${team['losses'] ?? 0}  GD: ${team['goalConDiff'] ?? 0}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${team['pts'] ?? 0} pts',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF5722)),
                      ),
                      if (team['scoresStr'] != null)
                        Text(
                          team['scoresStr'],
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlayerTab(String endpoint, String statKey) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchData(endpoint),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerList(count: 15);
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available', style: TextStyle(color: Colors.white70)));
        }

        final players = snapshot.data!;

        return ListView.builder(
          itemCount: players.length,
          itemBuilder: (_, i) {
            final p = players[i] as Map<String, dynamic>;
            final playerId = p['id'] as int;

            final value = statKey == 'rating'
                ? double.tryParse(p[statKey].toString())?.toStringAsFixed(1) ?? p[statKey].toString()
                : p[statKey].toString();

            final teamColorHex = (p['teamColors']?['darkMode'] as String?)?.replaceAll('#', '0xFF') ?? '0xFF666666';
            final teamColor = Color(int.parse(teamColorHex));

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: const Color(0xFF2A2A2A),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Text('${i + 1}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 16),
                    FutureBuilder<String>(
                      future: _getPlayerLogoUrl(playerId),
                      builder: (context, logoSnapshot) {
                        final photoUrl = logoSnapshot.data ?? '';
                        return CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[800],
                          child: ClipOval(
                            child: photoUrl.isNotEmpty
                                ? CachedNetworkImage(
                              imageUrl: photoUrl,
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                              placeholder: (_, __) => Container(
                                color: Colors.grey[800],
                                child: const CircularProgressIndicator(color: Colors.grey),
                              ),
                              errorWidget: (_, __, ___) => const Icon(Icons.person, size: 30, color: Colors.grey),
                            )
                                : const Icon(Icons.person, size: 30, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name'],
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p['teamName'],
                            style: TextStyle(color: teamColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFF5722)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}