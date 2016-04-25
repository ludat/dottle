#!/bin/sh

{
printf "#!/bin/sh\n\n"
cat $(find src/ -mindepth 2 -regex '[a-zA-z_/\-]*.sh')
cat src/help.sh src/main.sh
} > build/result.sh

chmod +x build/result.sh

printf "compilation result was written to build/result.sh\n"
