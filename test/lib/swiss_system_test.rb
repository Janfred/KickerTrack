require 'test_helper'

class SwissSystemTest < ActionDispatch::IntegrationTest

  @@team = [
    {team_id: 1, freeplay_lock: false, freeplay_team: false, data: {points: 5}},
    {team_id: 2, freeplay_lock: false, freeplay_team: false, data: {points: 8}},
    {team_id: 3, freeplay_lock: true,  freeplay_team: false, data: {points: 3}},
    {team_id: 4, freeplay_lock: false, freeplay_team: true,  data: {points: 0}}
  ]

  @@simple_pointgroup = Proc.new { |t| t[:data][:points] }
  @@simple_sort_func = Proc.new { |a,b| a[:data][:points]<=>b[:data][:points] }

  test "SwissSystem initialize one team" do
    teams = [@@team[0]]
    paarings = []
    sort_function = Proc.new { |a,b| a[:data][:points]<=>b[:data][:points] }
    assert_raises(SwissSystem::SwissSystemInitializeException) {
      SwissSystem::SwissSystem.new(teams, paarings, @@simple_pointgroup, @@simple_sort_func)
    }
  end

  test "SwissSystem basic paaring" do
    teams = [@@team[0], @@team[1]]
    paarings = []
    swiss_system = SwissSystem::SwissSystem.new(teams, paarings, @@simple_pointgroup, @@simple_sort_func)
    result = swiss_system.basic_paaring
  end

  test "SwissSystem basic paaring impossible paaring" do
    teams = [@@team[2], @@team[3]]
    paarings = []
    swiss_system = SwissSystem::SwissSystem.new(teams, paarings, @@simple_pointgroup, @@simple_sort_func)
    assert_raises(SwissSystem::SwissSystemPaaringException) {
      swiss_system.basic_paaring
    }
  end

  test "SwissSystem basic paaring 19 rounds" do
    teams = []
    (1..20).each do |i|
      teams << {team_id: i, freeplay_lock: false, freeplay_team: false, data: {points: 0}}
    end
    paarings = []

    # Calculate 19 rounds (everybody vs everybody)
    19.times do |i|
      swiss_system = SwissSystem::SwissSystem.new(teams, paarings, @@simple_pointgroup, @@simple_sort_func)
      new_paarings = swiss_system.basic_paaring
      new_paarings.each do |p|
        paarings << {round: i, team_1: p[0], team_2: p[1]}
      end
    end

    # All possible paarings have been played, now no paaring should be possible
    swiss_system = SwissSystem::SwissSystem.new(teams, paarings, @@simple_pointgroup, @@simple_sort_func)
    assert_raises(SwissSystem::SwissSystemPaaringException) {
      new_paarings = swiss_system.basic_paaring
    }
  end
end
