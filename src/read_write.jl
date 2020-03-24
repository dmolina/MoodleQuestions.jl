using Parameters
using LightXML
using OrderedCollections

@with_kw struct QuestionUnique
    tag::String
    question::String
    options::Vector{String}
    right::Number
    shuffle::Bool
end

@with_kw struct Quiz
    uniques::Vector{QuestionUnique}=QuestionUnique[]
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

        if attribute(xquestion, "type") != "uniqueChoice"
            continue
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

    return quiz
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

        xquestion = new_child(xroot, "question")
        set_attribute(xquestion, "type", "multichoice")
        name = new_child(new_child(xquestion, "name"), "text")
        add_text(name, "Question_$(i)")
        questiontext = new_child(xquestion, "questiontext")
        set_attribute(questiontext, "format", "html")
        text = new_child(questiontext, "text")
        add_text(text, "$(question.question)")
        generalfeedback = new_child(xquestion, "generalfeedback")
        # generalfeedback empty
        set_attribute(generalfeedback, "format", "html")
        new_child(generalfeedback, "text")
        # parameters
        params = OrderedDict("generalfeedback" => "1", "penalty" => "", "hidden" => "0", "penalty"=>".333",
                      "single" => "true", "shuffleanswers" => question.shuffle ? "true" : "false",
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

        node = new_child(xquestion, "shownumcorrect")

        # Show the answers
        for (posi,option) in enumerate(question.options)
            answer=new_child(xquestion, "answer")

            if question.right == posi
                fraction = "100"
            else
                fraction = "0"
            end

            set_attribute(answer, "fraction", fraction)
            set_attribute(answer, "format", "html")
            text = new_child(answer, "text")
            add_text(text, "$(option)")
            feedback = new_child(answer, "feedback")
            set_attribute(feedback, "format", "html")
            text = new_child(feedback, "text")
            add_text(text, "")
        end
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
    questions = QuestionUnique[]

    for line in readlines(io)
        line = strip(line)

        if (isempty(line))
            continue
        end

        mcat = match(r"^\*\s*(.*)$", line)

        if !isnothing(mcat)
            category = mcat.captures[1]
            push!(categories, category)

            if !isempty(question)
                if (right == -1)
                    throw("Error: neither option of question '$question' is right")
                end
                push!(questions, QuestionUnique(tag=category,
                                                question=question, options=options, right=right,
                                                shuffle=shuffle))
                shuffle = true
            end
        elseif !isempty(line) && !startswith(line, r"[+-]")
            question = line
            options = String[]
            right = -1
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

                if occursin(r"\b[ABCD]\b", line)
                    shuffle = false
                end
            end
        end
    end

    if (question != "")
        push!(questions, QuestionUnique(tag=category,
                                        question=question, options=options, right=right,
                                        shuffle=shuffle))
    end


    return  Quiz(categories=categories, uniques=questions)
end
