using MoodleQuestions
using Test

@testset "ReadFromSWAD" begin
    quiz = read_swad("../input_data/test_swad.xml")
    @test quiz != nothing
    @test length(quiz.uniques)==419
    @test quiz.uniques[1].shuffle == false
    @test quiz.uniques[3].shuffle == true
    @test length(quiz.categories) > 0
end

@testset "ReadRightFromTXT" begin
    content = """
    * Category 1

    Question 1

    - Option 1.1.
    - Option 1.2.
    + Option 1.3.

    * Category 2

    Question 2

    + Option 2.1.
    - Option 2.2.
    """
    file = IOBuffer(content)
    quiz = read_txt(file)
    @test length(quiz.categories)==2
    @test quiz.categories[1]=="Category 1"
    @test quiz.categories[2]=="Category 2"
    @test !isempty(quiz.uniques)
    @test length(quiz.uniques)==2
    @test quiz.uniques[1].question == "Question 1"
    @test quiz.uniques[2].question == "Question 2"
    @test quiz.uniques[1].right == 3
    @test quiz.uniques[2].right == 1
end


@testset "ReadWithout category" begin
    content = """
    Question 1.
    - Option 1.
    + Option 2.
"""
    quiz = read_txt(IOBuffer(content))
    @show quiz
    @test length(quiz.categories) == 1
    @test quiz.categories[1] == "Default"
end

