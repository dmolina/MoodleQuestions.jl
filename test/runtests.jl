using QuestionsMoodle
using Test

@testset "ReadFromSWAD" begin
    quiz = read_swad("../input_data/test_swad.xml")
    @test quiz != nothing
    @test length(quiz.uniques)==419
    @test quiz.uniques[1].shuffle == false
    @test quiz.uniques[3].shuffle == true
    @test length(quiz.categories) > 0
end
