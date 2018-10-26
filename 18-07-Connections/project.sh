#!/bin/sh

ProgName=$(basename $0)
  
sub_help(){
    echo "Usage: $ProgName <subcommand> [options]\n"
    echo "Subcommands:"
    echo "    update  Updates the dependencies"
    echo "    clean   Removes dependencies before installing them"
    echo ""
}
  
sub_clean(){
    # Delete carthage dir
    rm Cartfile.resolved
    rm -rf ./Carthage
    sub_update
}
  
sub_update(){
    # Checkout Code
    carthage update --no-build

    # Generate Xcode project for Stencil
    (cd ./Carthage/Checkouts/XMLParsing/ && swift package generate-xcodeproj)

    # Build
    carthage build --platform macos --cache-builds
}
  
subcommand=$1
case $subcommand in
    "" | "-h" | "--help")
        sub_help
        ;;
    *)
        shift
        sub_${subcommand} $@
        if [ $? = 127 ]; then
            echo "Error: '$subcommand' is not a known subcommand." >&2
            echo "       Run '$ProgName --help' for a list of known subcommands." >&2
            exit 1
        fi
        ;;
esac