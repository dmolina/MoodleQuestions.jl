using Parameters
using LightXML
using OrderedCollections

@enum QuestionType unique=1 boolean=2

@with_kw struct QuestionUnique
    tag::String
    question::String
    options::Vector{String}
    right::Number
    shuffle::Bool
end

@with_kw struct QuestionTrueFalse
    tag::String
    question::String
    right::Bool
end

@with_kw struct Quiz
    uniques::Vector{QuestionUnique}=QuestionUnique[]
    booleans::Vector{QuestionTrueFalse}=QuestionTrueFalse[]
    categories::Vector{String}=String[]
end

"""
Replace the symbols in iso-9110 (Windows) to UTF-8.

    replace_utf(text::AbstractString)
"""
function replace_utf8(text::AbstractString)
    dict = Dict("&#191;"=>"¿", "&#43;" => "+", "&#37;" => "%",
                "Ã³" => "ó", "Ã¡" => "á", "Â¿" => "¿", "Ã­" => "í", "Ã©" => "é", "Ãº" => "ú")

    for (orig, new) in dict
        text = replace(text, orig=>new)
    end

    return text
end

function replace_html(text::AbstractString)
    dict = Dict("")
end

"""
Read a XML documentation from SWAD and return a Quiz answer

read_swad(fname::AbstractString)::Quiz

"""
function read_swad(fname::AbstractString)::Quiz
    xdoc = parse_file(fname)
    xroot = root(xdoc)
    questions = xroot["question"]
    quiz = Quiz()
    categories = String[]

    for xquestion in questions
        typestr = attribute(xquestion, "type")
        type::QuestionType = unique

        if !(typestr in ["uniqueChoice", "TF"])
            continue
        elseif typestr == "TF"
            type = boolean
        end

        tags = find_element(xquestion, "tags")
        tag = "Missing"

        if !isnothing(tags)
            tag_node = find_element(tags, "tag")

            if !isnothing(tag_node)
                tag = replace_utf8(content(tag_node))
            end
        end

        if !(tag in quiz.categories)
            push!(quiz.categories, tag)
        end

        text = find_element(xquestion, "stem")
        @assert !isnothing(text)
        question = replace_utf8(content(text))

        if type == boolean
            answer = parse(Bool, content(find_element(xquestion, "answer")))
            shuffle = true
            push!(quiz.booleans, QuestionTrueFalse(tag=tag, question=question, right=answer))
        elseif type == unique
            answer = find_element(xquestion, "answer")
            shuffle = attribute(answer, "shuffle")=="yes"

            xoptions = answer["option"]
            options = String[]
            right = -1

            for xoption in xoptions
                push!(options, content(find_element(xoption, "text")))

                if attribute(xoption, "correct")=="yes"
                    right=length(options)
                end
            end

            options = replace_utf8.(options)
            push!(quiz.uniques, QuestionUnique(tag=tag, question=question,
                                           options=options,
                                           right=right,
                                               shuffle=shuffle))
        end
    end

    return quiz
end

"""
Create the header of a question for Moodle

create_header_question_moodle(xroot, tag, type)
"""

function create_header_question_moodle(xroot, question::AbstractString, type::QuestionType, shuffle::Bool, i)
    xquestion = new_child(xroot, "question")

    if (type == unique)
        set_attribute(xquestion, "type", "multichoice")
    elseif (type == boolean)
        set_attribute(xquestion, "type", "truefalse")
    else
        throw("Error, type '$type' is unknown")
    end

    name = new_child(new_child(xquestion, "name"), "text")
    add_text(name, "Question_$(i)")
    questiontext = new_child(xquestion, "questiontext")
    set_attribute(questiontext, "format", "html")
    text = new_child(questiontext, "text")
    add_text(text, "$(question)")
    generalfeedback = new_child(xquestion, "generalfeedback")
    # generalfeedback empty
    set_attribute(generalfeedback, "format", "html")
    new_child(generalfeedback, "text")
    # parameters
    if type == unique
        params = OrderedDict("generalfeedback" => "1", "penalty" => "", "hidden" => "0", "penalty"=>"0",
                         "single" => "true", "shuffleanswers" => shuffle ? "true" : "false",
                                    "answernumbering" => "abc")
    else
        params = OrderedDict("generalfeedback" => "1", "penalty" => "", "hidden" => "0", "penalty"=>"0")
    end

    for (key, value) in params
        node = new_child(xquestion, key)
        add_text(node, value)
    end

    if (type == unique)

    end

    feedbacks = OrderedDict("correctfeedback" => "Respuesta correcta",
                            "partiallycorrectfeedback" => "Respuesta parcialmente correcta",
                            "incorrectfeedback" => "Respuesta incorrecta")

    for (feedback, message) in feedbacks
        node = new_child(xquestion, feedback)
        set_attribute(node, "format", "html")
        text = new_child(node, "text")
        add_text(text, message)
    end

    return xquestion
end

function add_answer_moodle(xquestion, description::AbstractString; format="html", right::Bool=true)
    answer=new_child(xquestion, "answer")

    if right
        fraction = "100"
    else
        fraction = "0"
    end

    set_attribute(answer, "fraction", fraction)
    set_attribute(answer, "format", format)
    text = new_child(answer, "text")
    add_text(text, "$(description)")
    feedback = new_child(answer, "feedback")
    set_attribute(feedback, "format", "html")
    text = new_child(feedback, "text")
    add_text(text, "")
end

"""

Save the quiz into a group of categories.

    save_to_moodle(quiz::Quiz, category::AbstractString)
"""
function save_to_moodle_category(quiz::Quiz, category::AbstractString)
    xdoc = XMLDocument()
    # Create test
    xroot = create_root(xdoc, "quiz")
    categories = [""]
    append!(categories, quiz.categories)

    # Get all the categories
    question = new_child(xroot, "question")
    set_attribute(question, "type", "category")
    cat = new_child(question, "category")
    text = new_child(cat, "text")
    add_text(text, "\$course\$/top/$(category)")

    # Put all the questions
    for (i, question) in enumerate(quiz.uniques)
        if question.tag != category
            continue
        end

        xquestion = create_header_question_moodle(xroot, question.question, unique, question.shuffle, i)
        node = new_child(xquestion, "shownumcorrect")

        # Show the answers
        for (posi,option) in enumerate(question.options)
            add_answer_moodle(xquestion, option, right = (posi == question.right))
        end
    end
    # Put all the questions
    for (i, question) in enumerate(quiz.booleans)
        if question.tag != category
            continue
        end

        xquestion = create_header_question_moodle(xroot, question.question, boolean, true, i)

        # Show the answers
        add_answer_moodle(xquestion, "true", format="moodle_auto_format", right=(question.right==true))
        add_answer_moodle(xquestion, "false", format="moodle_auto_format", right=(question.right==false))
    end

    return xdoc
end

function save_to_moodle(quiz::Quiz, template::AbstractString)
    for category in quiz.categories
        fname = replace(template, ".xml" => "_$(category).xml")
        fname = replace(fname, " " => "_")
        xdoc = save_to_moodle_category(quiz, category)
        save_file(xdoc, fname)
    end
end

"""
Save the questions in a file as a XML Moodle Question

    txt_to_moodle(fname::AbstractString, template::AbstractString)

"""
function txt_to_moodle(fname::AbstractString, template::AbstractString)
    quiz = txt_to_quiz(fname)
    save_to_moodle(quiz, template)
    return nothing
end

"""
Read the text file to create the Quiz

    read_txt(fname)
"""
function read_txt(fname::AbstractString)::Quiz
    isfile(fname) || throw("Error reading file '$fname'")
    open(fname) do file
        return read_txt(file)
    end
end

function read_txt(io::IO)::Quiz
    categories = []
    category = ""
    question = ""
    shuffle = true
    right = -1
    options = String[]
    booleanQuestions = QuestionTrueFalse[]
    questions = QuestionUnique[]

    for line in readlines(io)
        line = strip(line)

        if (isempty(line))
            continue
        end

        mcat = match(r"^\*\s*(.*)$", line)

        if !isnothing(mcat)
            oldcategory = category
            category = mcat.captures[1]
            push!(categories, category)

            if !isempty(question)
                if (right == -1)
                    throw("Error: neither option of question '$question' is right")
                end
                push!(questions, QuestionUnique(tag=oldcategory,
                                                question=question, options=options, right=right,
                                                shuffle=shuffle))
                shuffle = true
            end
        elseif !startswith(line, r"[+-]")

            if !isempty(options)
                if (right == -1)
                    throw("Error: neither option of question '$line' is right")
                end
                push!(questions, QuestionUnique(tag=category,
                                                question=question, options=options, right=right,
                                                shuffle=shuffle))
                shuffle = true
                options = String[]
                right = -1

                # True/False Question
                if endswith(line, r"[+-]")
                    question = strip(line[1:end-1])
                    right = (line[end] == '+')
                    push!(booleanQuestions, QuestionTrueFalse(tag=category,
                                                              question=question,
                                                              right=right))
                    question = ""
                else
                    question = line
                end
            elseif !isempty(question)
                question *= "\n$line"
            else
                question = line;
            end
        else
            moption = match(r"([+-])\s*(.*)$", line)

            if !isempty(line) !isnothing(moption)
                @assert !isempty(category)
                @assert !isempty(question)
                push!(options, moption.captures[2])

                if (moption.captures[1] == "+")
                    if (right != -1)
                        throw("Not more than one option is acceptable")
                    end
                    right = length(options)
                end

                if occursin(r"\b[ABCDEF]\b", line)
                    shuffle = false
                end
            end
        end
    end

    if (question != "")
        if endswith(question, r"[+-]")
            right = (question[end] == '+')
            question = strip(question[1:end-1])
            push!(booleanQuestions, QuestionTrueFalse(tag=category,
                                                      question=question,
                                                      right=right))
        else
            push!(questions, QuestionUnique(tag=category,
                                            question=question, options=options, right=right,
                                            shuffle=shuffle))
        end
    end


    return  Quiz(categories=categories, uniques=questions, booleans=booleanQuestions)
end
