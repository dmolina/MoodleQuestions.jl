using MoodleQuestions

function main(ARGS)
    @show ARGS
    @show length(ARGS)

    if length(ARGS)<2
        println(stderr, "usage: textfile outputfile")
        return
    end

    if length(ARGS)==3
        penalty = parse(Float32, ARGS[3])
    else
        penalty = 0.0
    end

    fname = ARGS[1]
    foutput = ARGS[2]

    if !isfile(fname)
        println("Error, the file '$fname' does not exist")
        return
    end

    quiz = read_txt(fname)
    save_to_moodle(quiz, foutput, penalty_options=penalty, penalty_boolean=penalty)
end

isinteractive() || main(ARGS)
