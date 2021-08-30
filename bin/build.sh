#!/usr/bin/env sh
set -e

# Make necessary directories
mkdir -p $npm_package_config_build_dir/contents/code
mkdir -p $npm_package_config_build_dir/contents/config
mkdir -p $npm_package_config_build_dir/contents/ui

# Compile source into the form usable from QML
echo "Compiling typescript..."
npx tsc --outDir $npm_package_config_build_dir/contents/code/

# Rename all js files to mjs, because TypeScript cannot do that (https://github.com/Microsoft/TypeScript/issues/18442)
# We need to to that in order to use Javascripts modules from Qt
find $npm_package_config_build_dir/contents/code/ -name "*.js" -exec bash -c 'mv "$1" "${1%.js}".mjs' - '{}' \;

# Fix the import statements (replace .js to .mjs, or add .mjs extention)
find $npm_package_config_build_dir/contents/code/ -name "*.mjs" -exec sed -i '/^import/s/\(\.js\)*";*$/.mjs";/g' {} +

# Copy resources to the build directory with correct paths
cp -v res/config.ui $npm_package_config_build_dir/contents/ui/config.ui
cp -v res/popup.qml $npm_package_config_build_dir/contents/ui/popup.qml
cp -v res/main.qml $npm_package_config_build_dir/contents/ui/main.qml
cp -v res/config.xml $npm_package_config_build_dir/contents/config/main.xml

# Copy and update metadata
METADATA_FILE=$npm_package_config_build_dir/metadata.desktop
PROJECT_REV=$(git rev-parse HEAD | cut -b-7)

cp -v res/metadata.desktop $METADATA_FILE
sed -i "s/\$VER/$npm_package_version/" $METADATA_FILE
sed -i "s/\$REV/$PROJECT_REV/" $METADATA_FILE

