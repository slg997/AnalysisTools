#jq useful commands
#ref link 1: https://community.f5.com/t5/technical-articles/icontrol-rest-jq-cookbook-part-2-intermediate/ta-p/287437
#ref link 2: https://www.baeldung.com/linux/jq-command-json
#ref link 3: https://gist.github.com/olih/f7437fb6962fb3ee9fe95bda8d2c8fa4
#ref link 4: https://stedolan.github.io/jq/manual/#Invokingjq
#ref link 5: https://megamorf.gitlab.io/cheat-sheets/jq/
#ref link 6: https://hyperpolyglot.org/json

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

#Sort By
# -s converts to blob for sorting
cat file.json | jq -rs '.[] | sort_bv(.datetime)'

#Extras
#Apply functions to a single field
cat file.json | jq '.[] | [.actor,(.scopes|tostring|gsub("[\",]";"|"))] | join(",")'

#Remove new line and global replace strings 
cat file.json | jq '.[] | [.actor,(.scopes|tostring|sub("\\n";"")|gsub("[,|\"]";"|"))]'

#When parse requirement is long!
cat file.json | jq.exe -jr '.[] | .created_at,",",.user,",",.actor,",",.actor_id,",",.action,",",.actor_ip,",",.actor_ip_was,",",.actor_location,",",.actor_location_was.country_name,",",.actor_session,",",.application_id,",",.application_name,",",.category_type,",",.client_id,",",.controller_action,",",.from,",",.hashed_token,",",.method,",",.note,",",.operation,",",.oauth_access_id,",",.referrer,",",.request_category,",",.request_id,",",(.scopes|tostring|sub("\\n";"")|gsub("[,\"]";"|")),",",.server_id,",",.two_factor,",",.token_last_eight,",",.url,",",.user_agent,",",.user_id,",",.user_session_id,",",.associated_user_ids,",",.associated_user_logins,",",.org_id,"\r\n"'

#Extract SSL Certificate CN from ZoomEye json file
cat file.json | jq -r '. | .matches[] |[.timestamp,.ip,.portinfo.port,.portinfo.device,.portinfo.app,(.ssl|capture("CN=(?<cert>[a-z0-9\\.\\-\\_]+)") | .cert | tostring )] | join(",")'

#Use arguments
#Select item in time range
cat file.json | jq --arg s '2016-10-21T20:51' --arg e '2016-10-22T08:09' 'map(select(.created_at | . >= $s and . <= $e + "z"))'
#Arguments --arg s '2016-10-21T20:51' and --arg e '2016-10-22T08:09' define variables $s (start of date+time range) and $e (end of date+time range) respectively, for use inside the jq script.
#Function map() applies the enclosed expression to all the elements of the input array and outputs the results as an array, too.
#Function select() accepts a filtering expression: every input object is evaluated against the enclosed expression, and the input object is only passed out if the expression evaluates to a “truthy” value.
#Expression .created_at | . >= $s and . <= $e + "z" accesses each input object’s created_at property and sends its value to the comparison expression, which performs lexical comparison, which - due to the formatting of the date+time strings - amounts to chronological comparison.
#Note the trailing "z" appended to the range endpoint, to ensure that it matches all date+time strings in the JSON string that prefix-match the endpoint; e.g., endpoint 2016-10-22T08:09 should match 2016-10-22T08:09:01 as well as 2016-10-22T08:59.
#This lexical approach allows you to specify as many components from the beginning as desired in order to narrow or widen the date range; e.g. --arg s '2016-10-01' --arg e '2016-10-31' would match all entries for the entire month of October 2016.
