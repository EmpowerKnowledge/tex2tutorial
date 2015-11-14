#!/usr/bin/env bash

usage(){
	echo "Usage: $0 [-f] file.tex [-c] webConfig.cfg [-e] epubConfig.cfg [-s] studyseries/"
    echo "	The following options are available:"
    echo ""
    echo "	-c [REQUIRED]"
    echo "		Config file for Make4HT"
    echo "	-f [REQUIRED]"
    echo "		TeX main file"
    echo "	-e [REQUIRED]"
    echo "		Config file for TeX4Ebook"
    echo "	-s [REQUIRED]"
    echo "		Relative Path to Study Series Make4HT Styles"
    echo "	-h"
    echo "		Print this message"
	exit 1
}

makeSymlink() {
    ABS_PATH=`cd "$1"; pwd`
    (cd ~/texmf/tex/latex/ && rm -f $1 && ln -s $ABS_PATH studyseries)
}

clean() {
    rm -fr dist/epub dist/pdf
    find dist/web/ -not -name package.json -delete
}

buildPdf() {
    local fileName=$1
    xelatex -enable-write18 -synctex=-1 -max-print-line=120 $fileName
    xelatex -enable-write18 -synctex=-1 -max-print-line=120 $fileName
    mkdir -p dist/pdf
    mv helloworld.pdf dist/pdf/${fileName%.*}.pdf
}

buildWeb(){
    local fileName=$1; local configFile=$2;
    make4ht -c $configFile -d dist/web/ $fileName
}

cleanWeb(){
    rm -f *.4tc *.4ct *.idv *.lg *.tmp *.xref *.aux *.dvi *.log *.css *.html *.epub *.ncx *.opf
}

buildEpub() {
    local fileName=$1; local configFile=$2;
    tex4ebook $fileName
    mv ${fileName%.*}-epub dist/epub
}

OPTIND=1         # Reset in case getopts has been used previously in the shell.
output_file=""

while getopts "h?f:c:e:s:" opt; do
    case "$opt" in
    h|\?)
        usage
        exit 0
        ;;
    f)  output_file=$OPTARG
        ;;
    c)  config_file_web=$OPTARG
        ;;
    e)  config_file_epub=$OPTARG
        ;;
    s)  study_series_folder=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

if [[ -z "$output_file" || -z "$config_file_web" || -z "$config_file_epub" || -z "$study_series_folder" ]]
  then
    usage
    exit 0
  else
    makeSymlink $study_series_folder
    clean
    buildPdf $output_file
    buildWeb $output_file $config_file_web
    cleanWeb
    buildEpub $output_file $config_file_epub
    cleanWeb
fi