#jq useful commands


#SELECT function outputs the input only when the condition in the argument is true.
jq '.[] | select(. == "value")' file.json

#Extract a property from a deeply nested object
jq '.entries[][][].Version.description' file.json

#The .entries[][][] yields the 5th level objects: e.g., "Build": {"description": "0.0.6"}. The to_entries function then generates an object with the key and value properties: The key is "Build" and the "value" is {"description":"0.0.6"} in this case. You can access the data by referencing .key and .value.description.
jq -r '.entries[][][] | to_entries[] | [.key, .value.description] | join("\t")'
