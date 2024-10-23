#!/usr/bin/env sh
echo 'string(TIMESTAMP current_date "%H;%M;%S" UTC)' > script
echo 'execute_process(COMMAND ${CMAKE_COMMAND} -E echo "${current_date}")' >> script
val=$(cmake -P script)
./set-variable.sh TS $val
echo 'string(TIMESTAMP current_date "%Y" UTC)' > script
echo 'execute_process(COMMAND ${CMAKE_COMMAND} -E echo "${current_date}")' >> script
val=$(cmake -P script)
./set-variable.sh TS_YEAR $val
echo 'string(TIMESTAMP current_date "%m" UTC)' > script
echo 'execute_process(COMMAND ${CMAKE_COMMAND} -E echo "${current_date}")' >> script
val=$(cmake -P script)
./set-variable.sh TS_MONTH $val
echo 'string(TIMESTAMP current_date "%d" UTC)' > script
echo 'execute_process(COMMAND ${CMAKE_COMMAND} -E echo "${current_date}")' >> script
val=$(cmake -P script)
./set-variable.sh TS_DAY $val
