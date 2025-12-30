import 'package:flutter/material.dart' hide DateUtils;
import 'package:intl/intl.dart';

import '../widgets/section_title.dart';
import '../widgets/news_card.dart';
import '../widgets/match_card.dart';
import '../widgets/shimmer_list.dart';
import '../core/api_service.dart';
import '../utils/date_utils.dart';
import 'matchstats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            children: [
              TextSpan(
                text: 'F',
                style: TextStyle(
                  color: Colors.red[400],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const TextSpan(
                text: 'UTLEDGE',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: ListView(
        children: [
          const SectionTitle('Trending News'),
          _buildNewsList(),
          const SectionTitle('Live Matches'),
          _buildLiveMatchesList(context),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    return FutureBuilder(
      future: ApiService.get('/football-get-trendingnews'),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return const SizedBox(
            height: 220,
            child: ShimmerList(count: 3, height: 220, isHorizontal: true),
          );
        }

        final List news = (snapshot.data['response']?['news'] as List?) ?? [];

        if (news.isEmpty) {
          return const SizedBox(height: 220, child: Center(child: Text('No news available')));
        }

        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: news.length,
            itemBuilder: (_, i) {
              final item = news[i] as Map<String, dynamic>;
              return NewsCard(
                title: item['title'] ?? 'No title',
                imageUrl: item['imageUrl'] ?? '',
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLiveMatchesList(BuildContext context) {
    final String todayDate = DateUtils.formatDateYYYYMMDDNoDash(DateTime.now());

    return FutureBuilder(
      future: ApiService.get(
        '/football-get-matches-by-date-and-league',
        {'date': todayDate},
      ),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerList(count: 4);
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading matches', style: TextStyle(color: Colors.red[400])),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No data available'));
        }

        List leagues = List.from(snapshot.data['response'] as List? ?? []);

        List allMatches = [];
        for (var league in leagues) {
          final matches = (league['matches'] as List?) ?? [];
          allMatches.addAll(matches);
        }

        final liveMatches = allMatches.where((match) {
          final status = match['status'] as Map<String, dynamic>;
          return status['started'] == true && status['finished'] != true;
        }).toList();

        if (liveMatches.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No live matches right now',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        final displayMatches = liveMatches.take(6).toList();

        return Column(
          children: displayMatches.map<Widget>((match) {
            final m = match as Map<String, dynamic>;

            final home = m['home'] as Map<String, dynamic>;
            final away = m['away'] as Map<String, dynamic>;
            final status = m['status'] as Map<String, dynamic>;

            final String score = '${home['score'] ?? '-'} - ${away['score'] ?? '-'}';

            final int eventId = m['id'] as int;

            String localTime = '';
            final String? utcTimeString = status['utcTime'];
            if (utcTimeString != null && utcTimeString.isNotEmpty) {
              try {
                final DateTime utcTime = DateTime.parse(utcTimeString);
                final DateTime localTimeDt = utcTime.toLocal();
                localTime = DateFormat('HH:mm').format(localTimeDt);
              } catch (e) {
                localTime = '';
              }
            }


            return MatchCard(
              homeTeam: home['name'] ?? 'Unknown',
              awayTeam: away['name'] ?? 'Unknown',
              homeTeamId: home['id']?.toString() ?? '',
              awayTeamId: away['id']?.toString() ?? '',
              score: score,
              status: 'LIVE',
              time: localTime,
              league: '',
              eventId: eventId,
              onTap: () {
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
                      status: 'LIVE',
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}