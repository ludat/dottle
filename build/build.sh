#!/bin/sh

printf "#!/bin/sh\n\n" > build/result
cat $(find src/utils/ -regex '[a-zA-z_/\-]*.sh') >> build/result
cat $(find src/extensions/ -regex '[a-zA-z_/\-]*.sh') >> build/result
cat src/help.sh src/main.sh >> build/result

chmod +x build/result
