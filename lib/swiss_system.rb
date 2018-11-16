# Swiss System calculator
# For every new round a new instance of this calculator must be initialized
class SwissSystem

  @teams = []
  @paarings = []
  @pointgroup_identifier = nil
  @sort_function = nil
  @teams_by_id = {}

  # Initializes the swiss system with the given teams, existing rounds and indicating functions
  # @param teams an array containing all teams as map in the form {team_id: [Integer], freeplay_lock: [Boolean], freeplay_team: [Boolean], data: [Map]} with the data map containing all necessary information for the ordering function. The boolean `freeplay_lock` indicates, wether the team is not to be scheduled against the "Freeplay"-Team e.g. because they won a game because the opponent didn't show up. Must be an even count.
  # @param paarings An array of all played paarings in the form {team_1: [Integer], team_2: [Integer]}
  # @param pointgroup_identifier function for getting the pointgroup identifier
  # @param sort_function function for sorting the teams
  # @throws SwissSystemInitializeException if the team count is not even
  def initialize(teams, paarings, pointgroup_identifier, sort_function)
    raise SwissSystemInitializeException.new, "Team count is not even" if teams.length % 2 != 0
    @teams = teams
    @teams.each do |team|
      raise SwissSystemInitializeException.new, "Double Team ID" if @teams_by_id[team[:team_id]]
      begin
        @teams_by_id[team[:team_id]] = {team: team, blacklist: [], pointgroup: pointgroup_identifier.call(team)}
      rescue => e
        raise SwissSystemInitializeException.new, "Exception in pointgroup calculation function: #{e.class}, #{e.message}"
      end
    end
    @paarings = paarings
    @paarings.each do |paaring|
      @teams_by_id[paaring[:team_1]][:blacklist] << paaring[:team_2] if paaring[:team_1] && paaring[:team_2] && @team_by_id[paaring[:team_1]]
      @teams_by_id[paaring[:team_2]][:blacklist] << paaring[:team_1] if paaring[:team_1] && paaring[:team_2] && @team_by_id[paaring[:team_2]]
    end
  end

  # Calculates a basic paaring as fallback
  # @throws SwissSystemPaaringException if no paaring is possible
  def basic_paaring
    paarings = basic_paaring_recursive(@teams_by_id.keys, [])
  end

  private

  # Helper function for {basic_paaring}
  # calculates the next possible paaring for the given team_ids
  # @param team_ids [Array] of team ids still to pair
  # @param current_paarings [Array] of Arrays with paarings
  def basic_paaring_recursive(team_ids, current_paarings)
    return current_paarings if team_ids.empty?
    team1  = team_ids.delete_at 0
    team_ids.each do |team2|
      next if @teams_by_id[team1][:blacklist].include? team2
      next if @teams_by_id[team2][:blacklist].include? team1
      begin
        next_team_ids = team_ids.clone
        next_team_ids.delete team2
        return basic_paaring_recursive(next_team_ids, current_paarings + [[team1, team2]])
      rescue SwissSystemPaaringException => e
      end
    end
    raise SwissSystemPaaringException.new, "No paaring possible"
  end
end
# Exception for handling errors during initialization
# usually thrown if the data format doesn't match the requested format
class SwissSystemInitializeException < RuntimeError
end
# Exception during paarings.
# Thrown, when no paaring is possible under the given preconditions
class SwissSystemPaaringException < RuntimeError
end
