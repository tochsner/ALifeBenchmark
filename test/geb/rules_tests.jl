@testset "Rule Matching Tests" begin

    @test ALifeBenchmark._is_match("", "") == true
    @test ALifeBenchmark._is_match("", "1") == true
    @test ALifeBenchmark._is_match("1", "1") == true
    @test ALifeBenchmark._is_match("1", "100") == true
    @test ALifeBenchmark._is_match("1", "0") == false

    @test ALifeBenchmark._is_match("101", "0") == false
    @test ALifeBenchmark._is_match("101", "1") == false
    @test ALifeBenchmark._is_match("101", "101") == true
    @test ALifeBenchmark._is_match("101", "10111") == true

end

@testset "Rule Decoding Tests" begin

    @test ALifeBenchmark._get_rule_at("11011011011111111", 1) == ALifeBenchmark.Rule("1", "1", "1", true, true, true, true, true, true, 1, 17)
    @test ALifeBenchmark._get_rule_at("11011011011111111", 2) == nothing
    @test ALifeBenchmark._get_rule_at("11011011011111111", 17) == nothing

    @test ALifeBenchmark.get_rules("11011011011111111") == [
        ALifeBenchmark.Rule("1", "1", "1", true, true, true, true, true, true, 1, 17)
    ]

    @test ALifeBenchmark._get_rule_at("111011001011100000", 1) == ALifeBenchmark.Rule("", "1", "0", false, true, true, true, false, false, 1, 15)
    @test ALifeBenchmark._get_rule_at("111011001011100000", 2) == ALifeBenchmark.Rule("1", "0", "1", true, false, false, false, false, false, 2, 18)
    @test ALifeBenchmark._get_rule_at("111011001011100000", 3) == nothing

    @test ALifeBenchmark.get_rules("111011001011100000") == [
        ALifeBenchmark.Rule("", "1", "0", false, true, true, true, false, false, 1, 15),
        ALifeBenchmark.Rule("1", "0", "1", true, false, false, false, false, false, 2, 18)
    ]

end

@testset "Rule Filtering Tests" begin

    @test ALifeBenchmark.find_best_matches("0", [""]) == [""]
    @test ALifeBenchmark.find_best_matches("0", ["", "0", "1"]) == ["0"]
    @test ALifeBenchmark.find_best_matches("0", ["", "0", "1", "01"]) == ["0"]
    @test ALifeBenchmark.find_best_matches("000000", ["01", "0100", "110001", "0", "000"]) == ["000"]
    @test ALifeBenchmark.find_best_matches("010001", ["01", "0100", "110001"]) == ["0100"]

    @test ALifeBenchmark.filter_rules([
        ALifeBenchmark.Rule("", "11", "111", false, false, false, false, false, false, 0, 0),
        ALifeBenchmark.Rule("0", "11", "111", false, false, false, false, false, false, 1, 1),
        ALifeBenchmark.Rule("01", "11", "111", false, false, false, false, false, false, 2, 2),
        ALifeBenchmark.Rule("00", "11", "111", false, false, false, false, false, false, 3, 3)
    ]) == [
        ALifeBenchmark.Rule("00", "11", "111", false, false, false, false, false, false, 3, 3),
        ALifeBenchmark.Rule("01", "11", "111", false, false, false, false, false, false, 2, 2),
        ALifeBenchmark.Rule("", "11", "111", false, false, false, false, false, false, 0, 0)
    ]

    @test ALifeBenchmark.filter_rules([
        ALifeBenchmark.Rule("", "11", "111", false, false, false, false, false, false, 0, 0),
        ALifeBenchmark.Rule("0", "11", "111", false, false, false, false, false, false, 1, 1),
        ALifeBenchmark.Rule("01", "11", "0011", false, false, false, false, false, false, 2, 2),
        ALifeBenchmark.Rule("00", "11", "111", false, false, false, false, false, false, 3, 3),
        ALifeBenchmark.Rule("000", "11", "111", false, false, false, false, false, false, 4, 4),
        ALifeBenchmark.Rule("11", "11", "111", false, false, false, false, false, false, 5, 5)
        ]) == Any[
            ALifeBenchmark.Rule("00", "11", "111", false, false, false, false, false, false, 3, 3),
            ALifeBenchmark.Rule("000", "11", "111", false, false, false, false, false, false, 4, 4),
            ALifeBenchmark.Rule("01", "11", "0011", false, false, false, false, false, false, 2, 2),
            ALifeBenchmark.Rule("11", "11", "111", false, false, false, false, false, false, 5, 5)
    ]

    @test ALifeBenchmark.filter_rules([
        ALifeBenchmark.Rule("", "11", "111", false, false, false, false, false, false, 0, 0),
        ALifeBenchmark.Rule("0", "11", "111", false, false, false, false, false, false, 1, 1),
        ALifeBenchmark.Rule("01", "11", "0011", false, false, false, false, false, false, 2, 2),
        ALifeBenchmark.Rule("00", "11", "0011", false, false, false, false, false, false, 1, 3),
        ALifeBenchmark.Rule("000", "11", "111", false, false, false, false, false, false, 4, 4),
        ALifeBenchmark.Rule("11", "11", "111", false, false, false, false, false, false, 5, 5)
        ]) == Any[
        ALifeBenchmark.Rule("00", "11", "0011", false, false, false, false, false, false, 1, 3),
        ALifeBenchmark.Rule("000", "11", "111", false, false, false, false, false, false, 4, 4),
        ALifeBenchmark.Rule("11", "11", "111", false, false, false, false, false, false, 5, 5)        
    ]

    @test ALifeBenchmark.filter_rules([
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 5),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 1, 6)
        ]) == Any[
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 5),
    ]

    @test ALifeBenchmark.filter_rules([
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 5),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 10, 16)
        ]) == Any[
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 5),
    ]

end

@testset "Overlapping Tests" begin

    @test ALifeBenchmark._overlap(
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 10),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 10)
    ) == true
    @test ALifeBenchmark._overlap(
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 10),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 5, 10)
    ) == true
    @test ALifeBenchmark._overlap(
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 10),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 5, 20)
    ) == true
    @test ALifeBenchmark._overlap(
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 5, 10),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 10)
    ) == true
    @test ALifeBenchmark._overlap(
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 5, 10),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 7)
    ) == true
    @test ALifeBenchmark._overlap(
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 20),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 3, 7)
    ) == true
    @test ALifeBenchmark._overlap(
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 10, 20),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 5, 30)
    ) == true

    @test ALifeBenchmark._overlap(
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 4),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 5, 10)
    ) == false
    @test ALifeBenchmark._overlap(
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 4),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 20, 40)
    ) == false


    rules = [
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 4),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 20, 40),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 50, 60)
    ]
    to_add = [
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 4, 10),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 61, 70),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 65, 80)
    ]
    ALifeBenchmark._append_non_overlapping!(rules, to_add)
    @test rules == [
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 0, 4),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 20, 40),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 50, 60),
        ALifeBenchmark.Rule("", "", "", false, false, false, false, false, false, 61, 70)
    ]

end
