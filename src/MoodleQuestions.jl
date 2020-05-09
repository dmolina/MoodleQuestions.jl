module MoodleQuestions

include("read_write.jl")

# Read from SWAD file
export read_swad
# Read from TXT file
export read_txt
# Save to Moodle
export save_to_moodle

# Export serve version
include("serve.jl")
export serve_quiz

end # module
