"""
Allow to work as a server
"""

using HTTP
using ZipFile
using Sockets
# using Base64

using MoodleQuestions
using SimpleTranslations

"""
get_params(req::HTTP.Request)

Returns the POST parameters in a Dictionary.
"""
function get_params(req::HTTP.Request)
    data = String(req.body)
    params = Dict{String,String}()

    headers = filter(x->x[1] == "Content-Type", req.headers)
    # Check there is content-type
    if (isempty(headers))
        content_type = ""
    else
        content_type = only(headers)[2]
    end

    if (content_type == "application/x-www-form-urlencoded")
        pairs = split.(split(data, "&"), Ref("="))
        params = Dict(name => HTTP.URIs.unescapeuri(value) for (name, value) in pairs)
    elseif (startswith(content_type, "multipart/form-data"))
        body = IOBuffer(data)

        # First line is the stopping line
        stopping_line = replace(readline(body), "-" => "")

        while(!eof(body))
            line = readline(body)
            text_head = r"Content-Disposition: form-data; name=\"(.*)\""
            m = match(text_head, line)

            if !isnothing(m)
                name = m.captures[1]
                _ = readline(body)
                line = readline(body)
                value = ""

                if (!occursin(stopping_line, line))
                    value = "$(line)"
                end

                while (!eof(body) && !occursin(stopping_line, line))
                    line = readline(body)

                    if (!occursin(stopping_line, line))
                        value *= "\n$(line)"
                    end
                end

                params[name] = value
            end
        end
    end
    return params
end

"""
replace_accent(string)

Return the string without accents (for XML filename saving).
"""
function replace_accent(string)
    string = replace(string, "á" => "a")
    string = replace(string, "é" => "e")
    string = replace(string, "í" => "i")
    string = replace(string, "ó" => "o")
    string = replace(string, "ú" => "u")
    return string
end

function response_error(msg)
    return HTTP.Response(500, [],  body=msg)
end

function handle(req::HTTP.Request)
    params = get_params(req)
    penalty_boolean = tryparse(Float32, get(params, "penalty_boolean", "0"))
    penalty_options = tryparse(Float32, get(params, "penalty_options", "0"))

    language = get(params, "language", "es")
    set_language!(language)

    if (isnothing(penalty_boolean) || isnothing(penalty_options))
        return response_error
    end

    content = get(params, "text", "")

    try
       quiz = read_txt(IOBuffer(content))
       dir = mktempdir()
    # Save quiz to temp dir
    save_to_moodle(quiz, joinpath(dir, "quiz.xml"), penalty_options=penalty_options, penalty_boolean=penalty_boolean)
    # Get list
    files = readdir(dir, join=true)

    if length(files) == 1
        fname = files[1]
        content_type = "application/xml"
    else
        fname = joinpath(dir, "quiz.zip")
        zipfile = ZipFile.Writer(fname)

        for fname in files
            nameinzip = replace_accent(basename(fname))
            fileinzip = ZipFile.addfile(zipfile, nameinzip)
            open(fname) do file
                data = read(file, String)
                write(fileinzip, data)
            end
        end

        close(zipfile)
        content_type = "application/zip"
    end

    filename = basename(fname)

    open(fname) do file
        content = read(file, String)
        headers = ["Pragma" => "public", "Expires" => "0", "Content-Description" => "File Transfer",
                    "Content-type" => content_type, "Content-Transfer-Encoding" => "binary",
               "Content-Length" => "$(sizeof(content))", "Content-Disposition" => "attachment; filename=\"$(filename)\""]
        return HTTP.Response(200, headers, body=content)
    end

    catch e
        if (:msg in propertynames(e))
            return response_error(e.msg)
        else
            @show e
            return response_error("Unknown error")
        end
    end
end

"""
serve_quiz(port)

Run the text file in the txt format, and return the XML file.
If there is only one category only one parameter is defined.

serve_quiz(port)
"""
function serve_quiz(port = 8100)
    fmessages = joinpath(dirname(pathof(MoodleQuestions)), "messages.ini")
    loadmsgs!(fmessages, strict_mode=true)
    HTTP.serve(handle, Sockets.getipaddr(), port)
    # router = HTTP.Router()
    # HTTP.register!(router, "POST", "/*", handle)
    # HTTP.serve(router, Sockets.getipaddr(), port)
end

function test_serve(port = 8080)
    open("/tmp/recibido.zip", "w") do io
        HTTP.request("POST", "http://127.0.0.1:$port/send", Dict("ver"=>"texto"), response_stream=io)
    end
end
