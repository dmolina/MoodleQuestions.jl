# Server Mode

The package can be run in a server mode. 

Run the text file in the txt format, and return the XML file.

## Port

By default it is used the 8100, but you can define your own port.

## POST Parameters

- `penalty_boolean`: Penalty of wrong true/false questions. It is between 0 (not
  penalty) and 1 (one wrong remove one point), also it allow intermediate values 
  (as 0.5 => 2 wrong remove one point), ...
  
- `penalty_options`: Penalty of wrong questions with limited one. It is between 0 (not
  penalty) and 1 (one wrong remove one point), also it allow intermediate values 
  (as 0.5 => 2 wrong remove one point), ...
  
- `text`: Text in text format (see [`Format`](@ref format)).

## Return

- If there is only one category only one parameter is defined.
- If there are specified several categories, returns one Zip file, containing
  one XML file for category.
  
The XML Files can be imported in *Moodle* as *XML Moodle* format.

## API 

```@docs
serve_quiz(port)
```
