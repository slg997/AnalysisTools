#jq useful commands
#ref link: https://community.f5.com/t5/technical-articles/icontrol-rest-jq-cookbook-part-2-intermediate/ta-p/287437

#Count a number of objects
jq '.items | length' file.json

#SELECT function outputs the input only when the condition in the argument is true.
jq '.[] | select(. == "value")' file.json

#Extract a property from a deeply nested object
jq '.entries[][][].Version.description' file.json

#The .entries[][][] yields the 5th level objects: e.g., "Build": {"description": "0.0.6"}. The to_entries function then generates an object with the key and value properties: The key is "Build" and the "value" is {"description":"0.0.6"} in this case. You can access the data by referencing .key and .value.description.
jq -r '.entries[][][] | to_entries[] | [.key, .value.description] | join("\t")' file.json

#SUB function. The first argument of the sub function is a from string and the second one is a to string. The argument separator is ; (semicolon). Note that you need to escape the literal backslash by another backslash (\\n). You can also use regular expressions.
jq -r '.apiRawValues.apiAnonymous | sub("\\n"; "\n")' file.json

#GSUB function. The first argument for gsub is a from string. Here, a regular expression ("matches either { or }") is used. The second argument is a to string. Here, any { or } is globally replaced with an empty string. Again, note that the argument separator is ;. You can use the sub command for global replacement by specifying the g (global) flag in the third argument.
jq -r '.fileBlacklistPathPrefix | split(" ") | .[] | gsub("{|}"; "")' file.json
  #jq -r '.fileBlacklistPathPrefix | split(" ") | .[] | sub("{|}"; ""; "g")' file.json

#Convert Unix epoch time
#Some time related property values are expressed in Unix epoch in microseconds (10-6).
jq -r '.lastUpdateMicros, .expirationMicros | ./(1000*1000) | todate' fiile.json
#The literal 1000*1000 looks ugly, but it is better than 1000000 (IMHO). If you prefer, you can use the pow function to compute 10 to the power of negative 6.
echo 1604039337667000 | jq '. * pow(10; -6) | todate'

#Extras
#Apply functions to a single field
cat file.json | jq '.[] | [.actor,(.scopes|tostring|gsub("[\",]";"|"))] | join(",")'

#Remove new line and global replace strings 
cat file.json | jq '.[] | [.actor,(.scopes|tostring|sub("\\n";"")|gsub("[,|\"]";"|"))]'

#When parse requirement is long!
cat file.json | jq.exe -jr '.[] | .created_at,",",.user,",",.actor,",",.actor_id,",",.action,",",.actor_ip,",",.actor_ip_was,",",.actor_location,",",.actor_location_was.country_name,",",.actor_session,",",.application_id,",",.application_name,",",.category_type,",",.client_id,",",.controller_action,",",.from,",",.hashed_token,",",.method,",",.note,",",.operation,",",.oauth_access_id,",",.referrer,",",.request_category,",",.request_id,",",(.scopes|tostring|sub("\\n";"")|gsub("[,\"]";"|")),",",.server_id,",",.two_factor,",",.token_last_eight,",",.url,",",.user_agent,",",.user_id,",",.user_session_id,",",.associated_user_ids,",",.associated_user_logins,",",.org_id,"\r\n"'



