# MoodleQuestions

![Documentation](https://github.com/dmolina/MoodleQuestions.jl/workflows/Documentation/badge.svg)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://dmolina.github.io/MoodleQuestions.jl/dev)
[![Build Status](https://travis-ci.com/dmolina/MoodleQuestions.jl.svg?branch=master)](https://travis-ci.com/dmolina/MoodleQuestions.jl)
[![Coverage](https://codecov.io/gh/dmolina/MoodleQuestions.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/dmolina/MoodleQuestions.jl)
[![DOI](https://zenodo.org/badge/249694680.svg)](https://zenodo.org/badge/latestdoi/249694680)

This package manager questions for the [Moodle educational
tool](https://moodle.org/).

This package was created by my own usage, so the functionality is initially
reduced. Due to the covid-19, the classrooms are getting more virtual at my
University, and the moodle is getting more usage.

Create Questions in Moodle is a bit tedious, so I have created a import function
from a text file. 

## Limitations

This package is currently limited to multichoice and truefalse questions.

## Installation

Like other Julia packages, you may checkout MoodleQuestions from official repo, as

```julia
using Pkg;  Pkg.add("MoodleQuestions")
```

This package is expecting to be included. Until now you can do:

```julia
Pkg.add("https://github.com/dmolina/MoodleQuestions")
```

## Import functionality

It is able to read SWAD (swad.ugr.es) and a text file format. 

The functionality of import is done by functions:

```julia
function read_txt(fname::AbstractString)::Quiz
```

when fname is the input data, and return a Quiz structure. 
fname must be in the format described in next section.

```julia
read_swad(fname::AbstractString)::Quiz
```

when fname is the input data, and return a Quiz structure. 

## Input text file format

This package is able to read a text file. The format has been designed to be as
simple and readable as possible. 

```text
* Category 1

Text of question

- Option 1
+ Option 2
- Option 3
```

The sentences starting with *\** is a new category, with the name.

The sentences without *\**, *+*, or *-* are the text of the question. It is
expected to be from only one line.

The sentences starting with *-* or *+* and the different answers for the
previous question. The *-* means that the answer is false, and the *+* means
that the sentence is the right answer.

The answers in the question are shuffle, except when one of the word of *A*,
*B*, ... is used. 

## Export functionality

It is able to export to the MoodleXML format. 

This functionality is done by function 

```julia
save_to_moodle(quiz::Quiz, template::AbstractString)
```

When template is the output filename (with .xml extension). 

Actually, due to problem importing in moodle, it creates a XML file for each
category. Thus, if template is "output.xml" and the Quiz has categories "Cat1"
and "Cat2", the output will be "output_Cat1.xml" with the questions of category
*Cat1* and "output_Cat2.xml" with the questions in category *Cat2**.

# Main program

This package can be used to create a main program to create questions from a
text file. The function could be similar tool

```julia
using MoodleQuestions

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
```
