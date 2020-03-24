using QuestionsMoodle

function main(ARGS)
    if length(ARGS)!=2
        println(stderr, "usage: textfile outputfile")
        return
    end

    fname = ARGS[1]
    foutput = ARGS[2]

    if !isfile(fname)
        println("Error, the file '$fname' does not exist")
        return
    end

    quiz = read_txt(fname)
    save_to_moodle(quiz, foutput)
end

isinteractive() || main(ARGS)
