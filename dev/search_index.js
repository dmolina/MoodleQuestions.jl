var documenterSearchIndex = {"docs":
[{"location":"formato/#format","page":"Instructions","title":"Format","text":"","category":"section"},{"location":"formato/","page":"Instructions","title":"Instructions","text":"The syntax is very simple, in text mode. Spaces are not taken in accounr.  They are composed of the following types of questions:","category":"page"},{"location":"formato/#Questions-with-Options-(Only-and-multiple)","page":"Instructions","title":"Questions with Options (Only and multiple)","text":"","category":"section"},{"location":"formato/","page":"Instructions","title":"Instructions","text":"The short questions are listed without any initial symbol. After each question,  there are the different possible options, preceded each one with a - or +.  The option with + is the true one, the other ones are false.","category":"page"},{"location":"formato/","page":"Instructions","title":"Instructions","text":"Example:","category":"page"},{"location":"formato/","page":"Instructions","title":"Instructions","text":"The koronavirus is the virus, and the illness is called:Sleep.\nCovid-19.\nCold.","category":"page"},{"location":"formato/","page":"Instructions","title":"Instructions","text":"By default the question is expected to have only one paragraph. If it is not the case, it can be surround by symbol `.","category":"page"},{"location":"formato/","page":"Instructions","title":"Instructions","text":"Example:","category":"page"},{"location":"formato/","page":"Instructions","title":"Instructions","text":"`Who said the following question:\"I have no special talent. I am only passionately curious.\"Descartes.\nAlbert Einstein.\nPlato.","category":"page"},{"location":"formato/#True/False-questions","page":"Instructions","title":"True/False questions","text":"","category":"section"},{"location":"formato/","page":"Instructions","title":"Instructions","text":"The true/false questions are described with a sentence finished in - (if the  right answer is False) or finished in + i(if the right answer is True).","category":"page"},{"location":"formato/","page":"Instructions","title":"Instructions","text":"Example:","category":"page"},{"location":"formato/","page":"Instructions","title":"Instructions","text":"Confinement is recommended to avoid spreading the coronavirus. +The use of masks is not recommended. -","category":"page"},{"location":"formato/#Essay-Questions","page":"Instructions","title":"Essay Questions","text":"","category":"section"},{"location":"formato/","page":"Instructions","title":"Instructions","text":"The Essay Questions are which the student must complete a short text that will be qualified by the teacher. They are add with a sentence surround by parentheses.","category":"page"},{"location":"formato/","page":"Instructions","title":"Instructions","text":"Example:","category":"page"},{"location":"formato/","page":"Instructions","title":"Instructions","text":"(Why the confinement reduce the spread of the virus)","category":"page"},{"location":"formato/#Categories","page":"Instructions","title":"Categories","text":"","category":"section"},{"location":"formato/","page":"Instructions","title":"Instructions","text":"Categories are groups of questions, they are marked with an asterisk and the name before the questions in that category. They are optionals. For each category, it would be generated an XML file that should be imported in Moodle as XML Moodle format.","category":"page"},{"location":"server/#Server-Mode","page":"Server Mode","title":"Server Mode","text":"","category":"section"},{"location":"server/","page":"Server Mode","title":"Server Mode","text":"The package can be run in a server mode. ","category":"page"},{"location":"server/","page":"Server Mode","title":"Server Mode","text":"Run the text file in the txt format, and return the XML file.","category":"page"},{"location":"server/#Port","page":"Server Mode","title":"Port","text":"","category":"section"},{"location":"server/","page":"Server Mode","title":"Server Mode","text":"By default it is used the 8100, but you can define your own port.","category":"page"},{"location":"server/#POST-Parameters","page":"Server Mode","title":"POST Parameters","text":"","category":"section"},{"location":"server/","page":"Server Mode","title":"Server Mode","text":"penalty_boolean: Penalty of wrong true/false questions. It is between 0 (not penalty) and 1 (one wrong remove one point), also it allow intermediate values  (as 0.5 => 2 wrong remove one point), ...\npenalty_options: Penalty of wrong questions with limited one. It is between 0 (not penalty) and 1 (one wrong remove one point), also it allow intermediate values  (as 0.5 => 2 wrong remove one point), ...","category":"page"},{"location":"server/","page":"Server Mode","title":"Server Mode","text":"text: Text in text format (see Format).\nlanguage: Language for the messages errors. In spanish by default.","category":"page"},{"location":"server/#Return","page":"Server Mode","title":"Return","text":"","category":"section"},{"location":"server/","page":"Server Mode","title":"Server Mode","text":"If there is only one category only one parameter is defined.\nIf there are specified several categories, returns one Zip file, containing one XML file for category.","category":"page"},{"location":"server/","page":"Server Mode","title":"Server Mode","text":"The XML Files can be imported in Moodle as XML Moodle format.","category":"page"},{"location":"server/#API","page":"Server Mode","title":"API","text":"","category":"section"},{"location":"server/","page":"Server Mode","title":"Server Mode","text":"serve_quiz(port)","category":"page"},{"location":"server/#MoodleQuestions.serve_quiz-Tuple{Any}","page":"Server Mode","title":"MoodleQuestions.serve_quiz","text":"serve_quiz(port)\n\nRun the text file in the txt format, and return the XML file. If there is only one category only one parameter is defined.\n\nserve_quiz(port)\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = MoodleQuestions","category":"page"},{"location":"#MoodleQuestions","page":"Home","title":"MoodleQuestions","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package manager questions for the Moodle educational tool.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This package was created by my own usage, so the functionality is initially reduced. Due to the covid-19, the classrooms are getting more virtual at my University, and the moodle is getting more usage.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Create Questions in Moodle is a bit tedious, so I have created a import function from a text file. ","category":"page"},{"location":"#Limitations","page":"Home","title":"Limitations","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package is currently limited to multichoice and truefalse questions.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Like other Julia packages, you may checkout QuestionsMoodle from official repo, as","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Pkg;  Pkg.add(\"MoodleQuestions\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"This package is expecting to be included. Until now you can do:","category":"page"},{"location":"","page":"Home","title":"Home","text":"Pkg.add(\"https://github.com/dmolina/MoodleQuestions\")","category":"page"},{"location":"#Import-functionality","page":"Home","title":"Import functionality","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"It is able to read SWAD (swad.ugr.es) and a text file format. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"The functionality of import is done by functions:","category":"page"},{"location":"","page":"Home","title":"Home","text":"function read_txt(fname::AbstractString)::Quiz","category":"page"},{"location":"","page":"Home","title":"Home","text":"when fname is the input data, and return a Quiz structure.  fname must be in the format described in next section.","category":"page"},{"location":"","page":"Home","title":"Home","text":"read_swad(fname::AbstractString)::Quiz","category":"page"},{"location":"","page":"Home","title":"Home","text":"when fname is the input data, and return a Quiz structure. ","category":"page"},{"location":"#Input-text-file-format","page":"Home","title":"Input text file format","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package is able to read a text file. The format has been designed to be as simple and readable as possible. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"* Category 1\n\nText of question\n\n- Option 1\n+ Option 2\n- Option 3","category":"page"},{"location":"","page":"Home","title":"Home","text":"The sentences starting with *** is a new category, with the name.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The sentences without **, *+, or - are the text of the question. It is expected to be from only one line.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The sentences starting with - or + and the different answers for the previous question. The - means that the answer is false, and the + means that the sentence is the right answer.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The answers in the question are shuffle, except when one of the word of A, B, ... is used. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"In Instructions you can see more details.","category":"page"},{"location":"#Export-functionality","page":"Home","title":"Export functionality","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"It is able to export to the MoodleXML format. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"This functionality is done by function ","category":"page"},{"location":"","page":"Home","title":"Home","text":"save_to_moodle(quiz::Quiz, template::AbstractString)","category":"page"},{"location":"","page":"Home","title":"Home","text":"When template is the output filename (with .xml extension). ","category":"page"},{"location":"","page":"Home","title":"Home","text":"Actually, due to problem importing in moodle, it creates a XML file for each category. Thus, if template is \"output.xml\" and the Quiz has categories \"Cat1\" and \"Cat2\", the output will be \"outputCat1.xml\" with the questions of category Cat1 and \"outputCat2.xml\" with the questions in category *Cat2**.","category":"page"},{"location":"#Main-program","page":"Home","title":"Main program","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package can be used to create a main program to create questions from a text file. The function could be similar tool","category":"page"},{"location":"","page":"Home","title":"Home","text":"using MoodleQuestions\n\nfunction main(ARGS)\n    if length(ARGS)!=2\n        println(stderr, \"usage: textfile outputfile\")\n        return\n    end\n\n    fname = ARGS[1]\n    foutput = ARGS[2]\n\n    if !isfile(fname)\n        println(\"Error, the file '$fname' does not exist\")\n        return\n    end\n\n    quiz = read_txt(fname)\n    save_to_moodle(quiz, foutput)\nend\n\nisinteractive() || main(ARGS)","category":"page"},{"location":"#API","page":"Home","title":"API","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [MoodleQuestions]","category":"page"},{"location":"#MoodleQuestions.create_header_question_moodle","page":"Home","title":"MoodleQuestions.create_header_question_moodle","text":"Create the header of a question for Moodle\n\ncreateheaderquestion_moodle(xroot, tag, type)\n\n\n\n\n\n","category":"function"},{"location":"#MoodleQuestions.get_params-Tuple{HTTP.Messages.Request}","page":"Home","title":"MoodleQuestions.get_params","text":"get_params(req::HTTP.Request)\n\nReturns the POST parameters in a Dictionary.\n\n\n\n\n\n","category":"method"},{"location":"#MoodleQuestions.read_swad-Tuple{AbstractString}","page":"Home","title":"MoodleQuestions.read_swad","text":"read_swad(fname::AbstractString)::Quiz\n\nRead a XML documentation from SWAD and return a Quiz answer\n\n\n\n\n\n","category":"method"},{"location":"#MoodleQuestions.read_txt-Tuple{AbstractString}","page":"Home","title":"MoodleQuestions.read_txt","text":"Read the text file to create the Quiz\n\nread_txt(fname)\n\n\n\n\n\n","category":"method"},{"location":"#MoodleQuestions.read_txt-Tuple{IO}","page":"Home","title":"MoodleQuestions.read_txt","text":"Read the text file to create the Quiz\n\nread_txt(io::IO)\n\n\n\n\n\n","category":"method"},{"location":"#MoodleQuestions.replace_accent-Tuple{Any}","page":"Home","title":"MoodleQuestions.replace_accent","text":"replace_accent(string)\n\nReturn the string without accents (for XML filename saving).\n\n\n\n\n\n","category":"method"},{"location":"#MoodleQuestions.replace_utf8-Tuple{AbstractString}","page":"Home","title":"MoodleQuestions.replace_utf8","text":"Replace the symbols in iso-9110 (Windows) to UTF-8.\n\nreplace_utf(text::AbstractString)\n\n\n\n\n\n","category":"method"},{"location":"#MoodleQuestions.save_to_moodle_category-Tuple{MoodleQuestions.Quiz,AbstractString}","page":"Home","title":"MoodleQuestions.save_to_moodle_category","text":"Save the quiz into a group of categories.\n\nsave_to_moodle(quiz::Quiz, category::AbstractString)\n\n\n\n\n\n","category":"method"},{"location":"#MoodleQuestions.serve_quiz","page":"Home","title":"MoodleQuestions.serve_quiz","text":"serve_quiz(port)\n\nRun the text file in the txt format, and return the XML file. If there is only one category only one parameter is defined.\n\nserve_quiz(port)\n\n\n\n\n\n","category":"function"},{"location":"#MoodleQuestions.txt_to_moodle","page":"Home","title":"MoodleQuestions.txt_to_moodle","text":"Save the questions in a file as a XML Moodle Question\n\ntxt_to_moodle(fname::AbstractString, template::AbstractString)\n\n\n\n\n\n","category":"function"}]
}
