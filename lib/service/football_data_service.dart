import 'package:dio/dio.dart';
import 'package:futledge/core/constants.dart';
import '../models/league.dart';
import '../models/standing.dart';

class FootballDataService {
  static final FootballDataService instance = FootballDataService._internal();
  factory FootballDataService() => instance;
  FootballDataService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://free-api-live-football-data.p.rapidapi.com',
    headers: {
      'X-RapidAPI-Key': Constants.apiKey, // Your key
      'X-RapidAPI-Host': 'free-api-live-football-data.p.rapidapi.com',
    },
  ));

  Future<List<League>> getAllLeagues() async {
    final response = await _dio.get('/football-get-all-leagues');
    if (response.data['status'] != 'success') return [];

    final List<dynamic> leaguesJson = response.data['response']['leagues'];
    return leaguesJson.map((json) => League.fromJson(json)).toList();
  }

  Future<List<Standing>> getStandings(String leagueId) async {
    final response = await _dio.get(
      '/football-get-standing-all',
      queryParameters: {'leagueid': leagueId},
    );

    if (response.data['status'] != 'success') return [];

    final List<dynamic> standingsJson = response.data['response']['standing'];
    return standingsJson.map((json) => Standing.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getTopAssists(String leagueId) async {
    final response = await _dio.get(
      '/football-get-top-players-by-assists',
      queryParameters: {'leagueid': leagueId},
    );

    if (response.data['status'] != 'success') return [];

    return List<Map<String, dynamic>>.from(response.data['response']['players']);
  }

  Future<List<Map<String, dynamic>>> getTopPlayers(String leagueId, String stat) async {
    final endpoint = stat == 'goals'
        ? '/football-get-top-players-by-goals'
        : stat == 'rating'
        ? '/football-get-top-players-by-rating'
        : '/football-get-top-players-by-assists';

    final response = await _dio.get(endpoint, queryParameters: {'leagueid': leagueId});

    if (response.data['status'] != 'success') return [];

    return List<Map<String, dynamic>>.from(response.data['response']['players']);
  }

}