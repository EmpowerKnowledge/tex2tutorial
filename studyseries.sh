#!/usr/bin/env bash

usage(){
	echo "Usage: $0 [-f] file.tex [-w] webConfig.cfg [-e] epubConfig.cfg [-s] studyseries/"
    echo "	The following options are available:"
    echo ""
    echo "	-c"
    echo "		cleans the dist directory"
    echo "	-w [REQUIRED]"
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
    rm -fr dist/epub dist/pdf dist/web/*.html dist/web/*.css dist/web/*.png
}

buildPdf() {
    local fileName=$1
    pdflatex -enable-write18 -synctex=-1 --interaction=nonstopmode -max-print-line=120 $fileName
    pdflatex -enable-write18 -synctex=-1 --interaction=nonstopmode -max-print-line=120 $fileName
    mkdir -p dist/pdf
    mv *.pdf dist/pdf/${fileName%.*}.pdf
}

buildWeb(){
    local fileName=$1; local configFile=$2;
    make4ht -u -c $configFile -d dist/web/ $fileName
    #./beautifyHtml.py -f dist/web/${fileName%.*}.html
}

cleanWeb(){
    rm -f *.4tc *.4ct *.idv *.lg *.tmp *.xref *.aux *.dvi *.log *.css *.html *.epub *.ncx *.opf *.png *.out *.toc
}

buildEpub() {
    local fileName=$1; local configFile=$2;
    tex4ebook $fileName
    mv ${fileName%.*}-epub dist/epub
}

OPTIND=1         # Reset in case getopts has been used previously in the shell.
output_file=""

while getopts "h?c?f:w:e:s:" opt; do
    case "$opt" in
    h|\?)
        usage
        exit 0
        ;;
    f)  output_file=$OPTARG
        ;;
    c|\?)
        clean
        exit 0
        ;;
    w)  config_file_web=$OPTARG
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
    buildEpub $output_file $config_file_epub
    cleanWeb
fi