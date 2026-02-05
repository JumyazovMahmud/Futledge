import 'package:flutter/material.dart' hide DateUtils;
import '../widgets/match_card.dart';
import '../widgets/shimmer_list.dart';
import '../core/api_service.dart';
import '../utils/date_utils.dart';
import 'matchstats_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  static const List<String> topLeagues = [
    'Premier League',
    'LaLiga',
    'Serie A',
    'Bundesliga',
    'Ligue 1',
    'Champions League',
    'Europa League',
    'Saudi Pro League',
    'Super Lig',
    'Super Cup'
  ];

  @override
  Widget build(BuildContext context) {
    final String todayDate = DateUtils.formatDateYYYYMMDDNoDash(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Matches'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: FutureBuilder(
        future: ApiService.get(
          '/football-get-matches-by-date-and-league',
          {'date': todayDate},
        ),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerList(count: 15);
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load matches',
                    style: TextStyle(color: Colors.red[400], fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data received'));
          }

          List leagues = List.from(snapshot.data['response'] as List? ?? []);

          if (leagues.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    'No matches scheduled today',
                    style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          leagues = leagues.where((league) {
            final List matches = (league['matches'] as List?) ?? [];
            return matches.isNotEmpty;
          }).toList();


          leagues.sort((a, b) {
            final String nameA = a['name'] ?? '';
            final String nameB = b['name'] ?? '';

            final bool isTopA = topLeagues.contains(nameA);
            final bool isTopB = topLeagues.contains(nameB);

            if (isTopA && isTopB) {
              return topLeagues.indexOf(nameA).compareTo(topLeagues.indexOf(nameB));
            }
            if (isTopA) return -1;
            if (isTopB) return 1;
            return nameA.compareTo(nameB);
          });

          if (leagues.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    'No matches scheduled today',
                    style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: leagues.length,
            itemBuilder: (_, leagueIndex) {
              final league = leagues[leagueIndex] as Map<String, dynamic>;
              final String leagueName = league['name'] ?? 'Unknown League';
              final List matches = league['matches'] as List;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            leagueName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF5722),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${matches.length} match${matches.length > 1 ? 'es' : ''}',
                            style: TextStyle(color: Colors.grey[300], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ...matches.map<Widget>((match) {
                    final m = match as Map<String, dynamic>;

                    final home = m['home'] as Map<String, dynamic>;
                    final away = m['away'] as Map<String, dynamic>;
                    final status = m['status'] as Map<String, dynamic>;

                    final bool isLive = status['started'] == true && status['finished'] != true;
                    final bool isFinished = status['finished'] == true;

                    final String score = isLive || isFinished
                        ? '${home['score'] ?? '-'} - ${away['score'] ?? '-'}'
                        : '- -';

                    final String displayStatus = isLive
                        ? 'LIVE'
                        : isFinished
                        ? (status['reason']?['short'] ?? 'FT')
                        : m['time'] ?? 'Upcoming';

                    final int eventId = m['id'] as int;

                    return MatchCard(
                      homeTeam: home['name'] ?? 'Unknown',
                      awayTeam: away['name'] ?? 'Unknown',
                      homeTeamId: home['id']?.toString(),
                      awayTeamId: away['id']?.toString(),
                      score: score,
                      status: displayStatus,
                      time: isLive || isFinished ? '' : (m['time'] ?? ''),
                      league: leagueName,
                      eventId: eventId,
                      onTap: (isLive || isFinished)
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MatchStatsScreen(
                              matchId: eventId.toString(),
                              homeTeam: home['name'] ?? 'Home',
                              awayTeam: away['name'] ?? 'Away',
                              homeTeamId: home['id']?.toString() ?? '',
                              awayTeamId: away['id']?.toString() ?? '',
                              score: score,
                              status: displayStatus,
                            ),
                          ),
                        );
                      }
                          : null,
                    );
                  }).toList(),

                  const SizedBox(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }
}