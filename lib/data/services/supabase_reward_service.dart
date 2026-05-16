import 'package:green_miles_app/data/models/reward_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRewardService {
  SupabaseRewardService(this._client);

  final SupabaseClient _client;

  Future<List<RewardModel>> fetchRewards() async {
    final rows = await _client
        .from('rewards')
        .select()
        .eq('is_active', true)
        .order('points', ascending: true);

    return rows
        .map((row) => RewardModel.fromSupabase(Map<String, dynamic>.from(row)))
        .toList();
  }
}
