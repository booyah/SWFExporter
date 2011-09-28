SWFExporter
-----------

SWFExporter exports vector graphics data from SWF files to alternative formats using the [as3swf library][as3swf].

[as3swf]: http://github.com/claus/as3swf

Copyright (c) 2011 Booyah, Inc.

Brian Chapados <brian.chapados@booyah.com>


## Overview

SWFExporter is an Adobe Air App that uses the [as3swf library][as3swf] to extract vector graphics data from SWF files.
The app is intended to be run on .SWF files that represent individual graphics that would otherwise be
converted to PNG files.  The app currently exports vector graphics data to a JSON format, suitable for processing
by other tools.  The output format type can be changed by instantiating a different [as3swf][] exporter class in
the app source code (SWFConverter.as).


## Installation

Clone the project, and pull down as3swf as a submodule:

    git submodule init
    git submodule update

### Project layout

* `flash` contains source for Flex / FlashBuilder project
* `vendor` contains submodule for [as3swf][] project

Create an SWFExporter project in Flash Builder at point it at the contents of the `flash` folder.
Build & Run the project.


## Usage

1. Select a directory containing .swf files
2. Click 'Convert'
3. JSON files are written to the same directory, with the '.swf' extension replaced by '.json'


### Command-line interface

For convenient use from within build scripts, the app also has a command line interface:

    $ /Applications/SWFExtractor.app/Contents/MacOS/SWFExporter -h
    2011-09-28 15:55:05.106 SWFExporter[42956:707] NSDocumentController Info.plist warning: The values of CFBundleTypeRole entries must be 'Editor', 'Viewer', 'None', or 'Shell'.
    printUsage
    usage: SWFExporter -o <dir> [-i <dir>] <SWF Files...>
      convert SWF files to JSON format
    -h					print this help message
    -o <directory>		output dir for JSON files
    -i <directory> 		input dir containing SWF files to convert


## Caveats

SWFExporter has only been test on Mac OSX, on a limited subset of SWF files.  If you find bugs, patches are welcome.