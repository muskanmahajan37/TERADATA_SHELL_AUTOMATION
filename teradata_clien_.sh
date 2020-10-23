#!/bin/ksh 
# Copyright 2014 Teradata Corporation.
# All Rights Reserved.
# Teradata CONFIDENTIAL AND TRADE SECRET.
#
# File: tar_teradata_client_packages.sh                  15.10.00.00
#
# Description: Script to create a tar file of the Teradata Tools
#              and Utilities from the media for these platforms:
#              * AIX
#              * HP-UX
#              * Linux
#              * NCR MP-RAS UNIX
#              * Solaris (Sparc)
#              * Solaris (Opteron)
#
#
# History Revision:
# 15.10.00.00 04282014 PP121926 CLNTINS-4724 Update to 15.10
# 15.00.00.00 10312013 PP121926 CLNTINS-4207 Update to 15.00
# 14.10.00.01 01162013 PP121926 CLNTINS-3816 Add ThirdPartyLicenses-.txt support
# 14.10.00.00 05022012 PP121926 CLNTINS-3230 Remove package_size.sh.
# 14.00.00.03 05252011 PP121926 DR151210 Add TeraJDBC to all tars
# 14.00.00.02 05122011 PP121926 DR147885 Remove script name changed to
#                                        uninstall_ttu.sh.
# 14.00.00.01 04282011 PP121926 DR147885 Add TPTBASE, and remove papi
# 14.00.00.00 11242010 PP121926 DR145390 Update for HPUX/Linux new directories
# 13.10.01.01 08022010 PP121926 DR144518 Fix to add papi/tbld to tar
# 13.10.01.00 07062010 PP121926 DR141060 Add package_size.sh script.
# 13.10.00.00 09212009 PP121926 DR127863 Add TeraJDBC support.
# 13.10.00.00 09012009 PP121926 DR127863 Update for TTU13.10 support.
# 13.00.00.00 10282008 PP121926 DR121109 Update for TTU13 support.
# 01.00.00.01 05162008 PP121926 DR121109 Remove need for "tar" parameter
#                                        Add HOME to default dir.,
#                                        use /tmp if HOME is "/"
# 01.00.00.00  04-01-2008 PP121926 DR121109 Initial checkin
#
#

# Initialize Variables
# Set the initial values to variables here. 

# Include the UNIX main install script, .setup.sh
SETUPFILES=".setup.sh setup.bat MEDIALABEL uninstall_ttu.sh tar_teradata_client_packages.* ThirdPartyLicense*.txt "
DEPENDENCIES="TeraGSS cliv2 tdicu piom "
DEPENDENCY_TPTBASE="tptbase"

# Include the Solaris Sparc files for the "installer" program
SPARCFILES="Solaris/.cdtoc Solaris/Copyright Solaris/installer Solaris/README "
SPARCDIRS="Solaris/Docs Solaris/Misc Solaris/Patches Solaris/Tools "

VERSION="15.10.00.00"
TPTVERSION="1510"

OUTPUTDIR="$HOME"
if [ ${OUTPUTDIR} = "/" ]; then
  OUTPUTDIR="/tmp"
fi

P_1="$1"
P_2="$2"
P_3="$3"
ARGS="$*"

platforms() {
# List all of the available platforms.  With the media the only
# directories on the disk are those with the name of the platform
# containing the packages.  This should continue to be maintained.
# Also, this script shouldn't be on a Windows-Only disk.
# If that happens (except for the Query Director disk), a reminder
# is to be displayed noting that Windows is not supported by this script.

#If the file MEDIALABEL exists, display it as it is the label/name
#the Media (CD/DVD)  If not, exit..
if [ -f MEDIALABEL ]; then
    cat MEDIALABEL
  else
    echo "ERROR: Teradata Client Packages not found.  Please change to the directory"
    echo "       or disk where the Teradata packages are located, and rerun this script."
    exit 1
fi

echo ""
echo "The available platforms are:"

#List the Platforms

if [ -d "AIX" ]; then
  echo ""
  echo "aix"
fi

#For HP-UX MEDIA, tell the user to use "pa-risc" or "ia64" for the platform.
if [ -d "HP-UX" ]; then
  echo ""
  echo "HP-UX (one of the following):"
  if [ -d "HP-UX/pa-risc"  ]; then
    echo "pa-risc"
  fi
  if [ -d "HP-UX/ia64" ]; then
    echo "ia64"
  fi
fi

#For Linux MEDIA, tell the user to use 'i386-x8664' or 's390x' for the platform.
if [ -d "Linux" ]; then
  echo ""
  echo "Linux (one of the following):"
  if [ -d "Linux/i386-x8664" ]; then
    echo "i386"
  fi
  if [ -d "Linux/s390x" ]; then
    echo "s390x"
  fi
fi

#For Solaris MEDIA, tell the user to use 'sparc' or 'opteron' for the platform.
if [ -d "Solaris" ]; then
  echo ""
  echo "Solaris (one of the following):"
  if [ -d "Solaris/Sparc" ]; then
    echo "sparc"
  fi
  if [ -d "Solaris/Opteron" ]; then
    echo "opteron"
  fi
fi

# Check to see if a directory exists for each known Platform:
# AIX, HP-UX, Linux, MPRAS, Solaris/Sparc and Solaris/Opteron.
# And then list the directories there (which contain the packages).
# Windows is not supported as there is no way to easily
# break up Windows .cab files.
# Also, the extra code for Sparc/Opteron is there because of
# limitations with the DOS "dir" command not listing directories
# in directories.  UNIX would have no problem with that.

echo ""
echo "The available packages are:"
# Allow the second parameter ($2) to list only the packages for
# a specfic platform.  This will help with having huge lists.

case "$P_2" in
  a*|A*)
    echo "--- AIX Products"
    ls AIX
  ;;
  hp*|HP*)
    echo "--- HP-UX PA-RISC Products"
    ls HP-UX/pa-risc
    echo "--- HP-UX IA64 Products"
    ls HP-UX/ia64
  ;;
  pa*|PA*)
    echo "--- HP-UX PA-RISC Products"
    ls HP-UX/pa-risc
  ;;
  ia*|IA*)
    echo "--- HP-UX IA64 Products"
    ls HP-UX/ia64
  ;;
  lin*|LIN*)
    echo "--- Linux i386/x8664 Products"
    ls Linux/i386-x8664
    echo "--- Linux s390x Products"
    ls Linux/s390x
  ;;
  i386*|x8664*|I386*)
    echo "--- Linux i386/x8664 Products"
    ls Linux/i386-x8664
  ;;
  s390*|S390*)
    echo "--- Linux s390x Products"
    ls Linux/s390x
  ;;
  mp*|MP*)
    echo "--- MP-RAS Products"
    ls MPRAS
  ;;
  sp*|SP*)
    echo "--- Solaris Sparc Products"
    ls Solaris/Sparc
  ;;
  op*|OP*)
    echo "--- Solaris Opteron Products"
    ls Solaris/Opteron
  ;;
  solar*|SOLARI*)
    echo "--- Solaris Sparc Products"
    ls Solaris/Sparc
    echo ""
    echo "--- Solaris Opteron Products"
    ls Solaris/Opteron
  ;;
  tera*|Tera*)
    echo "--- TeraJDBC Product"
    echo "terajdbc"
  ;;
esac 

# If the second parameter is blank, just list all of the packages
# for the all of the platforms that exist.
if [ "$P_2" = "" ]; then
  if [ -d "AIX" ]; then
    echo "--- AIX Products"
    ls AIX
    echo ""
  fi
  if [ -d "HP-UX/pa-risc" ]; then
    echo "--- HP-UX PA-RISC Products"
    ls HP-UX/pa-risc
    echo ""
  fi
  if [ -d "HP-UX/ia64" ]; then
    echo "--- HP-UX IA64 Products"
    ls HP-UX/ia64
    echo ""
  fi
  if [ -d "Linux/i386-x8664" ]; then
    echo "--- Linux i386/x8664 Products"
    ls Linux/i386-x8664
    echo ""
  fi
  if [ -d "Linux/s390x" ]; then
    echo "--- Linux s390x Products"
    ls Linux/s390x
    echo ""
  fi
  if [ -d "MPRAS" ]; then
    echo "--- MP-RAS Products"
    ls MPRAS
    echo ""
  fi
  if [ -d "Solaris/Sparc" ]; then
    echo "--- Solaris Sparc Products"
    ls Solaris/Sparc
    echo ""
  fi
  if [ -d "Solaris/Opteron" ]; then
    echo "--- Solaris Opteron Products"
    ls Solaris/Opteron
    echo ""
  fi
  if [ -d "TeraJDBC" ]; then
    echo "--- TeraJDBC Product"
    echo "terajdbc"
    echo ""
  fi
fi

if [ -d "Windows" ]; then
  echo "--- Windows Products cannot be archived with this script."
fi
}

# This is the main tarring function.  The meat of this script.
#
tar_function () {
# The 2rd variable starts the package list. If "all" or blank, then tar
# all files for a particular platform.
if [ "$P_2" = ""  ]; then PACKAGES="ALL"
  fi
if [ "$P_2" = "all" ]; then PACKAGES="ALL"
  fi

#If the file MEDIALABEL exists, display it as it is the label/name
#the Media (CD/DVD or otherwise).

if [ -f MEDIALABEL ]; then 
    cat MEDIALABEL
  else 
    echo "ERROR: Teradata Client Packages not found.  Please change to the directory"
    echo "       or disk where the Teradata packages are located, and rerun this script."
    exit 1
 fi

# Get the value from the file MEDIALABEL, put it in a temporary string,
# replaces the spaces with "-", remove the "/"s and replace triple "---"
# with a single dash.  Then lower case it and set the final result
# to a value called MEDIALABEL

# Read the information in the file MEDIALABEL into the variable tmpstr
read tmpstr <MEDIALABEL

# Replace all spaces with dashes "-"
tmpstr=`echo "$tmpstr" | sed -e "s/ /-/g"`

# Replace the / (in "Load/Unload") with a dash.
tmpstr=`echo "$tmpstr" | sed -e "s/\//-/g"`

# Replace triple dashes with a single dash.
tmpstr=`echo "$tmpstr" | sed -e "s/---/-/g"`

# Now set the variable MEDIALABEL to be tmpstr in lowercase.
MEDIALABEL=$(echo $tmpstr | tr [A-Z] [a-z])

# Go through each platform possibility.  If on UNIX this could be a case
# which would cover any combination of "aix" "AIX" etc.
# Just being as flexible as we can here. 
# The set for DEPEND could have used PLATFORM for the path, but for
# some reason the DOS script wouldn't allow it to be set.
# Hard coding it here ensures that it is set for DEPEND.
case "$P_1" in
  a*|A*)
    PLATFORM=AIX
    PLATFORMDIR=AIX
    DEPEND="AIX/TeraGSS* AIX/cliv2* AIX/tdicu* "
    if [ -d "AIX/piom" ]; then
      DEPEND="$DEPEND AIX/piom* "
    fi
    if [ -d "AIX/tptbase$TPTVERSION" ]; then
	    DEPEND="$DEPEND AIX/$DEPENDENCY_TPTBASE*"
    fi
  ;;
  ia*|IA*)
    PLATFORM=HPUX-ia64
    PLATFORMDIR="HP-UX/ia64"
    DEPEND="${PLATFORMDIR}/TeraGSS* ${PLATFORMDIR}/cliv2* ${PLATFORMDIR}/tdicu* "
    if [ -d "${PLATFORMDIR}/piom" ]; then
      DEPEND="$DEPEND ${PLATFORMDIR}/piom* "
    fi
    if [ -d "${PLATFORMDIR}/tptbase$TPTVERSION" ]; then
	    DEPEND="$DEPEND ${PLATFORMDIR}/$DEPENDENCY_TPTBASE*"
    fi
  ;;
  pa*|PA*)
    PLATFORM=HPUX-pa-risc
    PLATFORMDIR="HP-UX/pa-risc"
    DEPEND="${PLATFORMDIR}/TeraGSS* ${PLATFORMDIR}/cliv2* ${PLATFORMDIR}/tdicu* "
    if [ -d "${PLATFORMDIR}/piom" ]; then
      DEPEND="$DEPEND ${PLATFORMDIR}/piom* "
    fi
    if [ -d "${PLATFORMDIR}/tptbase$TPTVERSION" ]; then
	    DEPEND="$DEPEND ${PLATFORMDIR}/$DEPENDENCY_TPTBASE*"
    fi
  ;;
  s390*|S390*)
    PLATFORM=Linux-s390x
    PLATFORMDIR="Linux/s390x"
    DEPEND="${PLATFORMDIR}/TeraGSS* ${PLATFORMDIR}/cliv2* ${PLATFORMDIR}/tdicu* "
    if [ -d "${PLATFORMDIR}/piom" ]; then
      DEPEND="$DEPEND ${PLATFORMDIR}/piom* "
      echo "DEPEND=$DEPEND"
    fi
    if [ -d "${PLATFORMDIR}/tptbase$TPTVERSION" ]; then
	    DEPEND="$DEPEND ${PLATFORMDIR}/$DEPENDENCY_TPTBASE*"
    fi
  ;;
  i386*|x8664*|I386*)
    PLATFORM=Linux-i386
    PLATFORMDIR="Linux/i386-x8664"
    DEPEND="${PLATFORMDIR}/TeraGSS* ${PLATFORMDIR}/cliv2* ${PLATFORMDIR}/tdicu* "
    if [ -d "${PLATFORMDIR}/piom" ]; then
      DEPEND="$DEPEND ${PLATFORMDIR}/piom* "
      echo "DEPEND=$DEPEND"
    fi
    if [ -d "${PLATFORMDIR}/tptbase$TPTVERSION" ]; then
	    DEPEND="$DEPEND ${PLATFORMDIR}/$DEPENDENCY_TPTBASE*"
    fi
  ;;
  mp*|MP*)
    PLATFORM=MPRAS
    PLATFORMDIR="MPRAS"
    DEPEND="${PLATFORMDIR}/TeraGSS* ${PLATFORMDIR}/cliv2* ${PLATFORMDIR}/tdicu* "
    if [ -d "${PLATFORMDIR}/piom" ]; then
      DEPEND="$DEPEND ${PLATFORMDIR}/piom* "
    fi
    if [ -d "${PLATFORMDIR}/tptbase$TPTVERSION" ]; then
	    DEPEND="$DEPEND ${PLATFORMDIR}/$DEPENDENCY_TPTBASE*"
    fi
  ;;
  sp*|SP*)
    PLATFORM=Solaris-Sparc
    PLATFORMDIR="Solaris/Sparc"
    DEPEND="$PLATFORMDIR/TeraGSS* $PLATFORMDIR/cliv2* $PLATFORMDIR/tdicu* "
    if [ -d "$PLATFORMDIR/piom" ]; then
      DEPEND="$DEPEND $PLATFORMDIR/piom* "
    fi
    if [ -d "$PLATFORMDIR/tptbase$TPTVERSION" ]; then
	    DEPEND="$DEPEND $PLATFORMDIR/$DEPENDENCY_TPTBASE*"
    fi
  ;;
  op*|OP*)
    PLATFORM=Solaris-Opteron
    PLATFORMDIR="Solaris/Opteron"
    DEPEND="${PLATFORMDIR}/TeraGSS* ${PLATFORMDIR}/cliv2* ${PLATFORMDIR}/tdicu* "
    if [ -d "${PLATFORMDIR}/piom" ]; then
      DEPEND="$DEPEND ${PLATFORMDIR}/piom* "
    fi
    if [ -d "${PLATFORMDIR}/tptbase$TPTVERSION" ]; then
	    DEPEND="$DEPEND ${PLATFORMDIR}/$DEPENDENCY_TPTBASE*"
    fi
  ;;
  # Set the platform, but don't set the dependencies as they won't be needed.
  tera*|Tera*)
    PLATFORM=TeraJDBC
    DEPEND=""
    SETUPFILES=""
  ;;
 *) 
  echo "Error: The PLATFORM is not set. '$P_1' is not a correct value."
  exit 1
esac 

if [ "$PLATFORM" = "TeraJDBC" ]; then
  echo "Product: $PLATFORM"
else
  echo "Platform: $PLATFORM"
fi
 
#Add TeraJDBC to all platforms
if [ -d "TeraJDBC" ]; then
  TERAJDBC=TeraJDBC
fi

#echo "DEPENDENCIES : $DEPEND"
#echo "SETUPFILES   : $SETUPFILES"

echo ""
echo "Default Path and Output File:"
if [ "$PLATFORM" = "TeraJDBC" ]; then
  echo "${OUTPUTDIR}/teradata-client-terajdbc.tar"
else
  echo "${OUTPUTDIR}/teradata-client-${PLATFORM}-${MEDIALABEL}.tar"
fi
echo ""
echo "Hit [Enter] to accept the default save path ($OUTPUTDIR), or enter a"
echo "different save directory : "
read -r NEWPATH 

if [ "$NEWPATH" = "" ]; then
  NEWPATH=${OUTPUTDIR}
else
  # Try to create the directory, just in case it doesn't exist.
  mkdir $NEWPATH 2> /dev/null
fi

if [ "$PLATFORM" = "TeraJDBC" ]; then
  TAROUT="${NEWPATH}/teradata-client-terajdbc.tar"
else
  TAROUT="${NEWPATH}/teradata-client-${PLATFORM}-${MEDIALABEL}.tar"
fi

# Try creating a file at TAROUT to make sure it's not being written to
# a read-only file location.  Yes, we will overwrite whatever file is at
# that location.  This is what we want, for now.
echo "Test File" > $TAROUT
if [ -f  $TAROUT ]; then
    echo "Output File: $TAROUT"
    rm $TAROUT
  else
    echo "ERROR: $TAROUT cannot be written."
    echo "Please rerun using a different path."
    exit 1
fi

# Clear the following variable
INDIVIDUAL_PACKAGES=""

#Start at the 2nd value in the variable list. This is the list passed
#on the command line.
i=2

for value in $ARGS;do
  if [[ $i -gt 2 ]]; then
    case $value in 
    piom*|PIOM*) echo "---$value already included"
    ;;
    tdicu*|TDICU*) echo "---$value already included"
    ;;
    Tera*|tera*) echo "---$value already included"
    ;;
    cliv2|cli*) echo "---$value already included"
    ;;
    *) 
    INDIVIDUAL_PACKAGES="${INDIVIDUAL_PACKAGES} ${PLATFORMDIR}/${value}*"
    ;;
   esac 
  fi
  (( i+=1 ))
done

  if [ "$PACKAGES" = "ALL" ]; then
    echo "---Archiving all packages for $P_1."
    echo "tar cvf $TAROUT $PLATFORMDIR $TERAJDBC $SETUPFILES"
    tar cvf $TAROUT $PLATFORMDIR $TERAJDBC $SETUPFILES
  else
    echo "---Archiving setupfiles and dependency packages for $P_1"
    if [ "$P_1" = "sparc" ] && [ -f "Solaris/installer" ]; then
      echo "---Adding Pre-TTU13.0 Solaris Sparc files..."
      echo "tar cvf $TAROUT $DEPEND $SETUPFILES $SPARCFILES $SPARCDIRS $TERAJDBC $INDIVIDUAL_PACKAGES"
      tar cvf $TAROUT $DEPEND $SETUPFILES $SPARCFILES $SPARCDIRS $TERAJDBC $INDIVIDUAL_PACKAGES 
    else
      echo "tar cvf $TAROUT $DEPEND $TERAJDBC $SETUPFILES $INDIVIDUAL_PACKAGES"
      tar cvf $TAROUT $DEPEND $TERAJDBC $SETUPFILES $INDIVIDUAL_PACKAGES
    fi
  fi

which gzip > /dev/null 2>&1
if [ "$?" != 0 ]; then
    echo ""
    echo "Notice: The executable 'gzip' is not found. Download from www.gzip.org for this"
    echo "        platform to automatically compress the output tar file to a gzip file."
    echo ""
    echo "The file has been saved at:"
    echo "  $TAROUT"
    echo ""
else
  gzip $TAROUT
  if [ "$?" != 0 ]; then
    echo ""
    echo "The file has been saved at:"
    echo "  $TAROUT"
    echo ""
  else 
    echo ""
    echo "The file has been saved at:"
    echo "  $TAROUT.gz"
    echo ""
  fi
fi
}

help () {
echo "Usage: $0 list"
echo "       $0 list {platform}"
echo "       $0 {platform} [{package1} {package2} ...]"
echo ""
echo "Parameters:"
echo ""
echo "commands         : help, list, {platform} [{package1} {package2} ...]"
echo " help            : Display this help message."
echo " list            : List the available platforms and packages from the media."
echo " list {platform} : List the packages available for the specified platform."
echo " {platform}      : Available platforms: aix, ia64, pa-risc, i386, s390x,"
echo "                   opteron, sparc, or terajdbc for the TeraJDBC product."
echo "                   Create the tar file for the supplied platform and include"
echo "                   all required dependency packages or individual packages."
echo " {package}       : Specify the packages available on this media for the"
echo "                   specific platform.  The parameter 'all' (or blank) will"
echo "                   include all available packages.  To specify individual"
echo "                   packages, list the packages separated by a space."
echo "                   Example: $0 i386 bteq fastld"
echo ""
echo "The dependencies will automatically be included and do not need to"
echo "be listed individually.  The following packages are included:"
echo "---$DEPENDENCIES"
}

#main
echo "***************************************************************************"
echo "*               Tar Teradata Client Packages v.$VERSION                *"
echo "***************************************************************************"

case $1 in
  aix*|AIX*)          tar_function;;  # AIX
  ia*|IA*)            tar_function;;  # HP-UX
  pa*|PA*)            tar_function;;  # HP-UX
  s390*|S390*)        tar_function;;  # Linux
  i386*|x8664*|I386*) tar_function;;  # Linux
  mp*|MP*)            tar_function;;  # NCR MP-RAS
  sparc*|SPARC*)      tar_function;;  # Solaris Sparc
  opt*|OPT*)          tar_function;;  # Solaris Opteron
  tera*|Tera*|JDBC)   tar_function;;  # TeraJDBC Product
  lis*)           platforms;;     # list available platforms and packages
  help)           help;;          # Display help
  *)              platforms;;     # No input/blank display platforms.
esac

