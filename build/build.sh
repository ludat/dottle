#!/bin/sh
echo "#!/bin/sh" > build/result
chmod +x build/result
cat $(find src/ -regex '[a-zA-z_/\-]*.sh') >> build/result
