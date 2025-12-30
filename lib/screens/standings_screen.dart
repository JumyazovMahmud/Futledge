import 'package:flutter/material.dart';
import '../widgets/shimmer_list.dart';
import '../core/api_service.dart';
import '../screens/teamsquad_screen.dart';

class StandingsScreen extends StatelessWidget {
  final dynamic leagueId;
  final String leagueName;

  const StandingsScreen({
    super.key,
    required this.leagueId,
    required this.leagueName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$leagueName Standings'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: FutureBuilder(
        future: ApiService.get('/football-get-standing-all', {'leagueid': leagueId.toString()}),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerList(count: 20);
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No standings available'));
          }

          final data = snapshot.data as Map<String, dynamic>;
          final List standings = (data['response']?['standing'] as List?) ?? [];

          if (standings.isEmpty) {
            return const Center(child: Text('No teams in this league'));
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
                      child: Image.network(
                        logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.sports_soccer,
                          color: Colors.grey,
                          size: 28,
                        ),
                      ),
                    ),
                    title: Text(
                      team['name'] ?? 'Unknown Team',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF5722),
                          ),
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
      ),
    );
  }
}