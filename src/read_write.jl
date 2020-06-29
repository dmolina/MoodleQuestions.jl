using Parameters
using LightXML
using OrderedCollections
using SimpleTranslations
using Formatting

@enum QuestionType multiple=1 boolean=2

@with_kw struct QuestionMultiple
    tag::String
    question::String
    options::Vector{String}
    rights::Vector{UInt8}
    shuffle::Bool
end

@with_kw struct QuestionTrueFalse
    tag::String
    question::String
    right::Bool
end

@with_kw struct QuestionEssay
    tag::String
    question::String
end

@with_kw struct Quiz
    multiples::Vector{QuestionMultiple}=QuestionMultiple[]
    booleans::Vector{QuestionTrueFalse}=QuestionTrueFalse[]
    essays::Vector{QuestionEssay}=QuestionEssay[]
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

read_swad(fname::AbstractString)::Quiz

Read a XML documentation from SWAD and return a Quiz answer
"""
function read_swad(fname::AbstractString)::Quiz
    xdoc = parse_file(fname)
    xroot = root(xdoc)
    questions = xroot["question"]
    quiz = Quiz()
    categories = String[]

    for xquestion in questions
        typestr = attribute(xquestion, "type")
        type::QuestionType = multiple

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
        elseif type == multiple
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
            push!(quiz.multiples, QuestionMultiple(tag=tag, question=question,
                                           options=options,
                                           rights=[right],
                                               shuffle=shuffle))
        end
    end

    return quiz
end

function get_moodle_type(question::QuestionMultiple)
    return "multichoice"
end

function get_moodle_type(question::QuestionTrueFalse)
    return "truefalse"
end

function get_moodle_type(question::QuestionEssay)
    return "essay"
end

function get_moodle_type(question)
    error("Error, type of question '$(type)' is unknown")
end

function save_question_moodle!(xquestion, question::QuestionMultiple, penalty)
    generalfeedback = new_child(xquestion, "generalfeedback")
    # generalfeedback empty
    set_attribute(generalfeedback, "format", "html")
    new_child(generalfeedback, "text")
    # parameters
    if length(question.rights)==1
        single = "true"
    else
        single = "false"
    end

    params = OrderedDict("generalfeedback" => "1", "hidden" => "0", "penalty"=>penalty,
                         "single" => single, "shuffleanswers" => (question.shuffle ? "true" : "false"),
                          "answernumbering" => "abc")

    for (key, value) in params
        node = new_child(xquestion, key)
        add_text(node, value)
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
end

function save_question_moodle!(xquestion, question::QuestionTrueFalse, penalty)
end

function save_question_moodle!(xquestion, question::QuestionEssay, penalty)
    answer = new_child(xquestion, "answer")
    set_attribute(answer, "fraction", "0")
    text = new_child(answer, "text")
    return
end

"""
Create the header of a question for Moodle

create_header_question_moodle(xroot, tag, type)
"""
function create_header_question_moodle(xroot, question, i, penalty=0)
    xquestion = new_child(xroot, "question")
    # Set the type
    set_attribute(xquestion, "type", get_moodle_type(question))

    # Get penalty
    if penalty == 0
        penalty_str = "0"
    else
        penalty_str = "-$(penalty)"
    end

    # Put the id of the question
    name = new_child(new_child(xquestion, "name"), "text")
    add_text(name, "Question_$(i)")

    # Put the question text
    questiontext = new_child(xquestion, "questiontext")
    set_attribute(questiontext, "format", "html")
    text = new_child(questiontext, "text")
    add_text(text, "$(question.question)")

    save_question_moodle!(xquestion, question, penalty_str)

    return xquestion
end

function add_answer_moodle(xquestion, description::AbstractString; format="html", penalty=0, right::Bool=true)
    answer=new_child(xquestion, "answer")

    if right
        fraction = "100"
    elseif penalty == -33
        fraction = "-33.33333"
    else
        fraction = "$penalty"
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

function is_multiple_boolean(question::QuestionMultiple)
    if length(question.options) != 2
        return false
    else
        option = question.options[1]

        return option in [get_msg("true"), get_msg("false")];
    end
end

function is_also(questions, question_str::AbstractString)
    for question in questions
        if (question.question == question_str)
            return true
        end
    end
    return false
end

"""

Save the quiz into a group of categories.

    save_to_moodle(quiz::Quiz, category::AbstractString)
"""
function save_to_moodle_category(quiz::Quiz, category::AbstractString; penalty_options=0, penalty_boolean=0)
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

    if (penalty_options > 0)
        penalty_options_answer = convert(Int, -100*penalty_options)
    else
        penalty_options_answer = 0
    end

    if (penalty_boolean > 0)
        penalty_boolean_answer = convert(Int, -100*penalty_boolean)
    else
        penalty_boolean_answer = 0
    end

    multiples = quiz.multiples
    essays = quiz.essays
    booleans = quiz.booleans

    if (penalty_boolean != 0)
        options = [get_msg("true"), get_msg("false")]

        for question in booleans
            if !is_also(multiples, question.question)
                rights = [(question.right) ? 1 : 2]
                push!(multiples, QuestionMultiple(question.tag, question.question, options,
                                                  rights, true))
            end
        end
        booleans = QuestionTrueFalse[]
    end

    # Put all the questions
    for (i, question) in enumerate(multiples)
        if question.tag != category
            continue
        end

        penalty = 0
        if is_multiple_boolean(question)
            penalty = penalty_boolean_answer
        else
            penalty = penalty_options_answer
        end

        xquestion = create_header_question_moodle(xroot, question, i)
        # Show the answers
        for (posi,option) in enumerate(question.options)
            add_answer_moodle(xquestion, option, right = (posi in question.rights), penalty=penalty)
        end
    end

    for (i, question) in enumerate(essays)
        if question.tag != category
            continue
        end

        xquestion = create_header_question_moodle(xroot, question, i)
    end

    # Put all the true/false questions
    for (i, question) in enumerate(booleans)
        if question.tag != category
            continue
        end

        xquestion = create_header_question_moodle(xroot, question, i)

        # Show the answers
        add_answer_moodle(xquestion, "true", format="moodle_auto_format", right=(question.right==true))
        add_answer_moodle(xquestion, "false", format="moodle_auto_format", right=(question.right==false))
    end

    return xdoc
end

function save_to_moodle(quiz::Quiz, template::AbstractString; penalty_options=0, penalty_boolean=0)
    for category in quiz.categories
        fname = replace(template, ".xml" => "_$(category).xml")
        fname = replace(fname, " " => "_")
        xdoc = save_to_moodle_category(quiz, category, penalty_options=penalty_options,
                                       penalty_boolean=penalty_boolean)
        save_file(xdoc, fname)
    end
end

"""
Save the questions in a file as a XML Moodle Question

    txt_to_moodle(fname::AbstractString, template::AbstractString)

"""
function txt_to_moodle(fname::AbstractString, template::AbstractString, penalty=0)
    quiz = txt_to_quiz(fname)
    save_to_moodle(quiz, template, penalty)
    return nothing
end

"""
Read the text file to create the Quiz

    read_txt(fname)
"""
function read_txt(fname::AbstractString)::Quiz
    fmessages = joinpath(dirname(pathof(MoodleQuestions)), "messages.ini")
    loadmsgs!(fmessages, strict_mode=true)

    isfile(fname) || error(format(get_msg("reading_file"), fname))
    open(fname) do file
        return read_txt(file)
    end
end

function is_category(line)
    return startswith(line, r"\*\s*")
end

function get_category_name(line)
    mcat = match(r"^\*\s*(.*)$", line)
    @assert !isnothing(mcat)
    return mcat.captures[1]
end

function is_question_truefalse(line)
    return endswith(line, r"[+-–]")
end

function get_truefalse_question(line)
    return line[1:end-1]
end

function get_essay_question(line)
    return line[2:end-1]
end

function is_question_essay(line)
    return startswith(line, "[") && endswith(line, "]")
end

function is_question_true(line)
    return line[end] == '+'
end

function is_question_options(line)
    return !endswith(line, r"[+-–]") && !startswith(line, r"[+-–]")
end

function is_option(line)
    return startswith(line, r"[+-–]")
end

function get_option(line)
    is_true = (line[1] == '+')
    option = strip(line[2:end])
    return option, is_true
end

function save_question!(questions, category, question, options::AbstractArray{String,1},
                       trues::AbstractArray{Int32,1}, shuffle::Bool)
    if isempty(trues)
        error(format(get_msg("noright_question"), question))
    end

    push!(questions, QuestionMultiple(tag=category,
                                      question=question, options=options, rights=trues,
                                      shuffle=shuffle))
end

"""
Read the text file to create the Quiz

    read_txt(io::IO)
"""
function read_txt(io::IO)::Quiz
    categories = String[]
    response_error = nothing
    category = "Default"
    question = ""
    shuffle = true
    trues = Int32[]
    options = String[]
    booleanQuestions = QuestionTrueFalse[]
    questions = QuestionMultiple[]
    essays = QuestionEssay[]

    for line in readlines(io)
        line = strip(line)

        if (isempty(line))
            continue
        end

        if !is_category(line) && isempty(categories)
            push!(categories, category)
        end

        if is_category(line)
            oldcategory = category
            category = get_category_name(line)
            push!(categories, category)

            if !isempty(question)
                save_question!(questions, oldcategory, question, options, trues, shuffle)
                options = String[]
                trues = Int32[]
                shuffle = true
                question = ""
            end
        elseif is_question_truefalse(line) || is_question_essay(line)

            if !isempty(options)
                save_question!(questions, category, question, options, trues, shuffle)
                options = String[]
                trues = Int32[]
                shuffle = true
                question = ""
            end

            if (is_question_truefalse(line))
                push!(booleanQuestions, QuestionTrueFalse(tag=category,
                                                      question=get_truefalse_question(line),
                                                          right=is_question_true(line)))
            else
                push!(essays, QuestionEssay(tag=category, question=get_essay_question(line)))
            end
            question = ""
        elseif is_option(line)
            # Check error
            if isempty(question)
                error(format(get_msg("noquestion_line"), line))
            end
            option, is_true = get_option(line)
            push!(options, option)

            if (is_true)
                push!(trues, length(options))
            end

            if occursin(r"\b[ABCDEF]\b", line)
                shuffle = false
            end
        elseif is_question_options(line)
            if !isempty(options)
                save_question!(questions, category, question, options, trues, shuffle)
                options = String[]
                trues = Int32[]
                shuffle = true
                question = ""
            elseif !isempty(question)
                error(format(get_msg("nooption"), question))
            end

            if !isempty(question)
                question *= "\n$line"
            else
                question = line
            end
        end
   end

    if (question != "")
        save_question!(questions, category, question, options, trues, shuffle)
    end

    return Quiz(categories=categories, multiples=questions, essays=essays, booleans=booleanQuestions)
end
