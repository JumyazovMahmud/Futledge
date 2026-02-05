import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MatchCard extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final String? homeTeamId;
  final String? awayTeamId;
  final String score;
  final String status;
  final String time;
  final String league;
  final int eventId;
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamId,
    this.awayTeamId,
    required this.score,
    required this.status,
    required this.time,
    required this.league,
    required this.eventId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLive = status == 'LIVE';
    final bool isFinished = ['FT', 'AET', 'PEN'].contains(status);
    final Color statusColor = isLive
        ? Colors.redAccent
        : isFinished
        ? Colors.greenAccent
        : Colors.grey;

    final String homeLogoUrl = homeTeamId != null && homeTeamId!.isNotEmpty
        ? 'https://images.fotmob.com/image_resources/logo/teamlogo/${homeTeamId}_large.png'
        : '';
    final String awayLogoUrl = awayTeamId != null && awayTeamId!.isNotEmpty
        ? 'https://images.fotmob.com/image_resources/logo/teamlogo/${awayTeamId}_large.png'
        : '';

    final bool showTime = !isLive && !isFinished && time.isNotEmpty && time.trim() != '- -';

    // Split only if we intend to show time – and handle safely
    final timeParts = time.trim().split(RegExp(r'\s+')); // split on any whitespace
    final String timeLine1 = timeParts.isNotEmpty ? timeParts[0] : '';
    final String timeLine2 = timeParts.length > 1 ? timeParts[1] : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Home team column
              Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: homeLogoUrl.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: homeLogoUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF5722),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.sports_soccer,
                          color: Colors.grey,
                          size: 36,
                        ),
                      )
                          : const Icon(Icons.sports_soccer, color: Colors.grey, size: 36),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 100,
                    child: Text(
                      homeTeam,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),

              // Center column (score + status + time)
              Column(
                children: [
                  Text(
                    score,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5722),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLive)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (isLive || isFinished)
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                    ],
                  ),
                  if (showTime && timeLine1.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        timeLine1,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    if (timeLine2.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          timeLine2,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                  ],
                ],
              ),

              // Away team column
              Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: awayLogoUrl.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: awayLogoUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF5722),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.sports_soccer,
                          color: Colors.grey,
                          size: 36,
                        ),
                      )
                          : const Icon(Icons.sports_soccer, color: Colors.grey, size: 36),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 100,
                    child: Text(
                      awayTeam,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}