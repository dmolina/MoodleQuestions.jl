using MoodleQuestions
using Test

@testset "ReadFromSWAD" begin
    quiz = read_swad("../input_data/test_swad.xml")
    @test quiz != nothing
    @test length(quiz.multiples)==419
    @test quiz.multiples[1].shuffle == false
    @test quiz.multiples[3].shuffle == true
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
    @test !isempty(quiz.multiples)
    @test length(quiz.multiples)==2
    @test quiz.multiples[1].question == "Question 1"
    @test quiz.multiples[2].question == "Question 2"
    @test quiz.multiples[1].rights == [3]
    @test quiz.multiples[2].rights == [1]
end


@testset "ReadWithout category" begin
    content = """
    Question 1.
    - Option 1.
    + Option 2.
"""
    quiz = read_txt(IOBuffer(content))
    @test length(quiz.categories) == 1
    @test quiz.categories[1] == "Default"
end


@testset "Reading multiple" begin
    content = """
    Question 1.
    - Option 1.
    + Option 2.
    - Option 3.
    + Option 4.
"""
    quiz = read_txt(IOBuffer(content))
    question = only(quiz.multiples)
    @test length(question.options)==4
    @test question.rights == [2,4]
end

@testset "Reading multiple" begin
    content = """
Pregunta Buena.
- Opción 1.
+ Opción 2.

Pregunta 2
+ Opción 2.1.
- Opción 2.2.
+ Opción 2.3.
"""
    quiz = read_txt(IOBuffer(content))
    question = quiz.multiples[1]
    @test length(question.options)==2
    @test question.rights == [2]
    question = quiz.multiples[2]
    @test length(question.options)==3
    @test question.rights == [1,3]
end

@testset "Reading essays" begin
    content = """
Pregunta Buena.
- Opción 1.
+ Opción 2.

[Pregunta 2]

Pregunta Buena.
+ Opción 1.
"""
    quiz = read_txt(IOBuffer(content))
    @test length(quiz.multiples) == 2
    question = quiz.multiples[1]
    @test length(question.options)==2
    @test question.rights == [2]
    question = only(quiz.essays)
    @test question.question =="Pregunta 2"
end

@testset "Error in server" begin
    content = """hola. +"""
    quiz = read_txt(IOBuffer(content))
    @test length(quiz.booleans) == 1
end
