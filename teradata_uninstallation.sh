#!/bin/ksh 
#******************************************************************************
#*
#*    TITLE: uninstall_ttu.sh                                      15.10.00.02
#*                                              Remember to update SCRIPTVER!
#*
#*    Copyright Teradata Corporation 2009-2015.  All rights reserved.
#*
#*    This shell script is used to remove Teradata Client Packages
#*
#*    History:
#* 15.10.00.02 01282014 PP121926 CLNTINS-5221 Keep from removing database
#*                               packages, "teradata-" and "pde".
#* 15.10.00.01 12242014 PP121926 CLNTINS-5136 Add "all" parameter, only use
#*                                            if "priorto" is also set.
#* 15.10.00.00 04282014 PP121926 CLNTINS-4724 Update for TTU 15.10
#* 15.00.00.05 03052014 PP121926 CLNTINS-4614 Remove -w for HPUX grep.
#* 15.00.00.04 02262014 PP121926 CLNTINS-4605 Fix version number check
#*                                            to xx.xx.xx.xxx.
#* 15.00.00.03 01032013 PP121926 CLNTINS-4459 Fix name check for 15.00.
#* 15.00.00.02 11272013 PP121926 CLNTINS-4329 Recognize 3 digit version numbers
#* 15.00.00.01 11262013 PP121926 CLNTINS-4397 Reorder init_pkginfo if/else
#* 15.00.00.00 10312013 PP121926 CLNTINS-4207 Update for 15.00
#* 14.10.00.03 11262013 PP121926 CLNTINS-4397 Reorder init_pkginfo if/else
#* 14.10.00.02 06072013 PP121926 CLNTINS-4045 Set first field for check 
#* 14.10.00.01 05082013 PP121926 CLNTINS-4045 Do not remove teradata-jre,
#*                               or teradata-jdk, etc. 
#* 14.10.00.00 04092012 PP121926 CLNTINS-3467 Display version when executed
#*                                       not from the script.
#* 14.00.01.00 08262011 PP121926 CLNTINS-2524 Add menu selection to remove 
#*                                           individual packages.
#* 14.00.00.09 06232011 PP121926 DR151666 Add Solaris Fix: Extra sleep/y
#* 14.00.00.08 06162011 PP121926 DR151666 Add back pexp and pdtc for TPT1200
#* 14.00.00.07 06152011 PP121926 DR151644 Add arc and teradata_arc
#* 14.00.00.06 05122011 PP121926 DR147885 File name changed: uninstall_ttu.sh
#*                                        on the media.
#* 14.00.00.05 04272011 PP121926 DR147885 Add TPTBase and TPTStreams
#* 14.00.00.04 04142011 PP121926 DR147885 Sort the packages for removal
#* 14.00.00.03 04062011 PP121926 DR147885 Added support for tdwallet
#*                                        Simplified check for package names
#*                                        ignoring the numerical part.
#                                         
#* 14.00.00.02 03312011 PP121926 DR147818 Fixed necessary quote marks
#* 14.00.00.01 03292011 PP121926 DR147818 Change AIX get version line to
#*                                        match the setup.sh change.
#* 14.00.00.00 11182011 PP121926 DR147390 Add TTU 14.00 packages
#* 13.10.01.00 08232010 PP121926 DR143808 Add logging for package removal
#* 13.10.00.01 01052010 PP121926 DR127863 TTU 13.10 update for TPT
#* 13.10.00.00 07142009 PP121926 DR129036 TTU 13.10 additions
#* 13.00.00.02 08282008 PP121926 DR116663 Don't display packages that aren't
#*                                        removed when called from script.
#* 13.00.00.01 08272008 PP121926 DR116663 Remove TeraGSS from list for when
#*                                        the script is called from .setup.sh
#* 13.00.00.00 07292008 PP121926 DR114232 Remove arc, dul and dultape from
#*                                        being removed. Clean up text.
#* 00.00.03.14 03142007 PP121926 DR114232 Created this file
#* 00.00.06.12 06122007 PP121926 DR114232 Remove TUVT and tdodbcqm packages.
#* 00.00.06.14 06142007 PP121926 DR114232 Fix AIX oddness. Don't check for
#*                                        AIX packages.
#* 00.00.06.22 06222007 PP121926 DR114232 Add TPT9.0 packages. TTU90 became
#*                                        TTU12.0. This will catch test 
#*                                        machines that may have installed it
#* 00.00.08.13 08132007 PP121926 DR114232 Add section to check for leftover
#*                                        libraries: teragss, cliv2, tdicu
#*                                        piom, and tdodbc are the libraries
#*                                        checked.  
#* 00.00.11.07 11072007 PP121926 DR114232 Add missing papi packages.
#*
#******************************************************************************

#The version of the script
CRYEAR="2009-2015"
SCRIPTVER="15.10.00.02"

#Add TPT Versions - Remove numerical part for check
TPTVER_1200="c"  #c000
TPTVER_1300="d"  #d000
TPTVER_1310="da" #da00
TPTVER_1400="e"  #e000
TPTVER_1500="f"  #f000

#Set PRIORTO to be null, for package removal logic
PRIORTO=""

OS=`uname -s`

SYSTEMPACKAGESOUT="/tmp/ttu-systempackagesout-$$.out"

###############################################################################
# Function: display_usage
#
# Description: Diplays the usage for the script.
#
# Input : None
#
# Output: Displays how to use the script.
#
# Note  : None

display_usage ()
{
  echo ""
  echo "Usage: $0"
  echo ""
  echo "Parameters: nocheck | noremove | priorto nn.nn.nn.nn "
  echo ""
  echo " This script interactively removes Teradata Tools and Utilities packages."
  echo ""
  echo "Usage: $0 noremove "
  echo "       Executes the script without actually removing the packages."
  echo "       Useful for a test run to see what packages would be removed,"
  echo "       in what order, and the commands used to remove the packages."
  echo ""
  echo "Usage: $0 nocheck "
  echo "       Executes the script removing packages with \"Teradata\" in the"
  echo "       package name without checking against the list of known"
  echo "       Teradata Tools and Utilities packages."  
  echo ""
  echo "Usage: $0 priorto nn.nn.nn.nn "
  echo "       Execute the script removing only packages prior to the version"
  echo "       number passed, where the version number is in the above format."
  echo "       Example: $0 priorto $SCRIPTVER"
  echo ""
  echo "Usage: $0 priorto nn.nn.nn.nn all"
  echo "       Execute the script removing only packages prior to the version"
  echo "       number passed, and automatically remove all packages without"
  echo "       user interaction. Useful for scripts or silent uninstall."
  echo ""
}

###############################################################################
# Function: get_installed_package_version
#
# Description: Get the version of the package being installed
#
# Input: The path to the package file or directory
#
#
# Output: The version number of the package

get_installed_package_version ()
{
  case $PLATFORM in
    $NAME_LINUX)
      rpm -q $1 --queryformat "%{VERSION}"
      return 1
    ;;
    $NAME_AIX)
      if [ ! -f "$SYSTEMPACKAGESOUT" ]; then
        $PKGINFO > $SYSTEMPACKAGESOUT
      fi
      TMPVERSION=`grep -w $1 $SYSTEMPACKAGESOUT | awk -F: '{ print $3 }' | sort | head -1 | awk -F. '{ printf( "%02d.%02d.%02d.%02d" , $1, $2, $3, $4) }'`
      echo $TMPVERSION
      return 1
    ;;
    $NAME_HPUX)
      if [ ! -f "$SYSTEMPACKAGESOUT" ]; then
        $PKGINFO > $SYSTEMPACKAGESOUT
      fi
      TMPVERSION=`grep $1 $SYSTEMPACKAGESOUT | awk '{print $2}' | sort` 
      #Echo the version numbers back to the value that called this function
      echo $TMPVERSION
      #Return the number of version numbers sent back
      RET=`echo $TMPVERSION | wc -l`
      return $RET
    ;;
    $NAME_SOLARIS)
      #This method is slower: $PKGINFO -l $1 | grep VERSION | awk '{print $2}'
      $PKGINFO -x $1 | awk '{ print $2 }' | sort | head -1 
      return 1
    ;;
  esac
}       

###############################################################################
# Function: write_to_install_log_file
#
# Description: Creates an installation log file in /var/log/teradata/client
#
# Input: Install_Type, Install Phase, Package Name, Package Parameters, 
#        Package File/Dir, Return Code, Error output file, System install cmd.
#
# Output: The output is echoed to the file /var/log/teradata/client/install.log
#

write_to_install_logfile ()
{
  NOW=$(date +"%m-%d-%Y")
  LOG_DIRECTORY=/var/log/teradata/client
  LOG_FILE="$LOG_DIRECTORY/install-$NOW.log"
  LOG_DATE=`date +"%m-%d-%Y,%T"`
  INSTALL_TYPE=$1
  INSTALL_PHASE=$2
  PKG_NAME=$3
  PKG_VERSION=$4
  PKG_PARAM="-"
  PKG_FILE=$6
  RETURN_CODE=$7
  ERR_OUTFILE=$8
  PKGRM=$9
  MEDIA="-"    #Can't tell the TTU media name from uninstall
  RELNUM="-"

  if [ ! -d "$LOG_DIRECTORY" ]; then
    mkdir -p $LOG_DIRECTORY
  fi

  if [ ! -f "$LOG_FILE" ]; then
    MACHINE_NAME=`uname -n`
    printf "Teradata Client Utilities Installation Log File\n" > $LOG_FILE
    printf "Initially Created: $LOG_DATE\nSystem name=$MACHINE_NAME\n" >> $LOG_FILE
    printf "System type=$PLATFORM $BIT_PLATFORM $CHIP\n" >> $LOG_FILE
    printf "Date,Time,Type,Phase,Media,Package Name,Package Architecture,Package Version,Release Version,Script Version,Install Program,Parameters,Package Path/File,Return Code, Error File\n" >> $LOG_FILE
  fi

  printf "$LOG_DATE,$INSTALL_TYPE,$INSTALL_PHASE,$MEDIA,$PKG_NAME,-,$PKG_VERSION,$RELNUM,$SCRIPTVER,$PKGRM,-,$PKG_FILE,$RETURN_CODE,$ERR_OUTFILE\n" >> $LOG_FILE
}

###############################################################################
# Function: uninstall
#
# Description: Replaces PKGRM for the install command
#
# Input: Package name, install parameters, install file/path
#
# Output: None
#

uninstall ()
{
  NOW=$(date +"%m-%d-%Y")
  PACKAGE_NAME=$1
  VERSION=$2
  input=$3
  INSTALL_FILE="-"
  RETURN_CODE="-"
  ERR_TEXT="-"
  ERR_FILE="/var/log/teradata/client/install-errorout-$PACKAGE_NAME-$NOW.$$"
  TEMP_FILE="/tmp/ttu-temp.$$"
  INSTALL_PATH="-"

  #Check to see if the package is a product dependency, and "All" packages
  #weren't selected, but a single package. 
  if [ "$input" != "a" ]; then
    case $PACKAGE_NAME in
    Tera*|tdicu*|cli*|piom*|tptbase)
      printf "$PACKAGE_NAME - $VERSION is a product dependency.\n"
      printf "Are you sure you wish to remove it? [Y/N] >"
      read INPUT
      if [ ! "$INPUT" = "Y" ] && [ ! "$INPUT" = "y" ]; then 
        echo "Not removing: $PACKAGE_NAME - $VERSION."
        return 0
      fi
    ;;
    esac
  fi

  echo "Removing: $pkg - $VERSION"
  write_to_install_logfile Uninstall Start "$PACKAGE_NAME" "$VERSION" "$PKGRM" "$INSTALL_FILE" $RETURN_CODE $ERR_TEXT "$PKGRM"

  if [ "$PKGTYPE" = "pkgadd" ]; then   #Solaris asks questions
    (sleep 1;echo y;sleep 1;echo y;sleep 1; echo y;sleep 1;echo y)|$PKGRM "$PACKAGE_NAME" 2> $TEMP_FILE
    RETURN_CODE=$?
  elif [ "$PKGTYPE" = "swinstall" ]; then #HP-UX needs to specify the version
    $PKGRM "$PACKAGE_NAME,r=$VERSION" 2> $TEMP_FILE
    RETURN_CODE=$?
  else
    $PKGRM "$PACKAGE_NAME" 2> $TEMP_FILE
    RETURN_CODE=$?
  fi

  #If the return code is NULL, set to "-".
  if [ -z "$RETURN_CODE" ]; then
    RETURN_CODE="-"
  fi
  if [ "$RETURN_CODE" = 0 ] && [ ! "$input" = "a" ]; then
    VERSIONARRAY[$input-1]="removed"
  fi
  if [ "$RETURN_CODE" = 1 ]; then
    case $PACKAGE_NAME in
    Tera*)
      printf "The TeraGSS package failed to remove.  Remove other versions of\n"
      printf "this product before removing $PACKAGE_NAME $VERSION.\n"
    ;;
    esac 
  fi
  #If there's an output file and the return code isn't 0, then set the err file
  #and put that information into the logfile.
  if [ -f "$TEMP_FILE" ] && [ "$RETURN_CODE" != "0" ]; then
    ERR_TEXT=$ERR_FILE
    echo "$PACKAGE_NAME, $VERSION, $PKGRM $INSTALL_PARAMETER $INSTALL_FILE" >> $ERR_FILE
    echo "*******************************************************************************" >> $ERR_FILE
    cat $TEMP_FILE >> $ERR_FILE
    echo "*******************************************************************************" >> $ERR_FILE
    cat $TEMP_FILE 
    if [ -f "$TEMP_FILE" ]; then
      rm $TEMP_FILE
    fi
  fi
  write_to_install_logfile Uninstall Finish "$PACKAGE_NAME" "$VERSION" "$PKGTYPE" "-" $RETURN_CODE $ERR_TEXT "$PKGRM"
  if [ -f "$TEMP_FILE" ]; then
    rm $TEMP_FILE
  fi
}

###############################################################################
# Function: display_fullinfo
#
# Description: Displays all of the information on all of the packages selected.
#
# Input : None
#
# Output: None
#
# Note  : None

display_fullinfo ()
{
#Each platform gives more information for all of the packages.

echo "The following Teradata Tools and Utilities are installed:"
$PKGFULLINFO ${PACKAGEARRAY[*]} | more
}

###############################################################################
# Function: display_help
#
# Description: Displays a brief help display about the program.
#              Different from display_usage, as it gives more explanation
#              inside of the script itself.
#
# Input : None
#
# Output: None
#
# Note  : None

display_help ()
{
  echo ""
  echo "This script will remove all Teradata Tools and Utilities packages."
  echo "It looks for packages with \"Teradata\" in the package name and"
  echo "checks it against a list of known Teradata Tools and Utilities"
  echo "packages. Please review the list for appropriate packages that"
  echo "should be removed."
  sleep 4
}

###############################################################################
# Function: display_packages
#
# Description: Gives a brief display of the packages to remove.
#
# Input : None
#
# Output: None
#
# Note  : None

display_packages ()
{
    i=0
    case $OS in
    AIX)
      SEP="-F."
    ;;
    *Linux*) 
      SEP="-F-"
    ;;
    esac
    for pkg in ${PACKAGEARRAY[*]}
    do
      PACKAGENAME=`echo ${pkg} | awk $SEP '{print $1 }'`
      printf "%2s. %-21s - ${VERSIONARRAY[$i]}\n" $(($i +1 )) ${PACKAGENAME} 
      ((i=$i+1))
    done
}

###############################################################################
# Function: order_packages
#
# Description: Orders the packages in the order to correctly remove based on
#              dependencies, etc.
#
# Input : None
#
# Output: None
#
# Note  : This function is the most important for MP-RAS and Solaris
#         Sparc/Solaris Opteron packaging as packages that other packages
#         have a dependency on won't be removed if dependent products are
#         still installed.  AIX, HPUX, and Linux can remove dependent packages
#         if given certain parameters that ignore dependencies.

order_packages ()
{
#Listed are the TPT package names that are dependencies for others.
#These should be removed first before the Teradata CLI dependencies.

#Add TPT Packages - Dependency packages
TPT_DEP_PKGS="tptbase pdatacon tbuild pdtc tbld posl picu papi posl${TPTVER_1200}"
TPT_DEP_PKGS="$TPT_DEP_PKGS tbld${TPTVER_1200} papi${TPTVER_1200} picu${TPTVER_1200} tbld${TPTVER_1300} papi${TPTVER_1300} picu${TPTVER_1300} tbld${TPTVER_1310} papi${TPTVER_1310} tbld${TPTVER_1400} papi${TPTVER_1400}"

#We have a lot of client packages to search through.  In order to not run into
#any long line issues (1024 character lines, for example), we'll just dump 
#all the packages we know about into a single file and search through that.  

#This will contain all of the dependencies in the correct order.
DEP_PKG_ORDER="$TPT_DEP_PKGS piom cliv tdicu TeraGSS"
echo $DEP_PKG_ORDER > $TMPFILE

#Main Client Packages
echo "fastld mload fastexp tpump sqlpp tdodbc tdodbc cobpp mqaxsmod" >> $TMPFILE
echo "npaxsmod jmsaxsmod qrydir sockclient bteq tdwallet arc teradata_arc" >> $TMPFILE

#Teradata Warehouse Builder packages before TTU5.0
echo "pipc tbuild pdatacon pcommon pselect pinsert pexport pload" >> $TMPFILE
echo "pupdate pstream pddl podbc pcnvflod pcnvmlod pcnvtpmp" >> $TMPFILE
echo "pcnvfexp pmlinop twbvi" >> $TMPFILE

#Teradata Warehouse Builder - TTU5.0 - TTU 8.2
echo "pdtc posl psel pins pexp plod pupd pstm pddl podbc posc" >> $TMPFILE

#Teradata Parallel Transporter - TTU12.0
echo "plod${TPTVER_1200} pddl${TPTVER_1200} pstm${TPTVER_1200}"  >> $TMPFILE
echo "pupd${TPTVER_1200} pins${TPTVER_1200} psel${TPTVER_1200}"  >> $TMPFILE
echo "posc${TPTVER_1200} podbc${TPTVER_1200} pexp${TPTVER_1200} pdtc${TPTVER_1200}" >> $TMPFILE

#Teradata Parallel Transporter - TTU13.0
echo "plod${TPTVER_1300} pupd${TPTVER_1300} pexp${TPTVER_1300} pstm${TPTVER_1300} pdtc${TPTVER_1300}" >> $TMPFILE

#DR127863 TTU 13.1 additions - Add 13.10 packages.
echo "plod${TPTVER_1310} pupd${TPTVER_1310} pexp${TPTVER_1310} pstm${TPTVER_1310} pdtc${TPTVER_1310}" >> $TMPFILE

#Teradata Parallel Transporter TTU14.00 - Pre Consolidation
echo "plod${TPTVER_1400} pupd${TPTVER_1400} pexp${TPTVER_1400} pstm${TPTVER_1400}" >> $TMPFILE

#Teradata Parallel Transporter TTU14.00 - Post Consolidation
echo "tptstream" >> $TMPFILE

#Copy necessary information to the DEBUGFILE
if [ "${DEBUG}" ];then
  echo "*** Known Teradata Tools and Utilities Packages" > $DEBUGFILE
  cat $TMPFILE >> $DEBUGFILE
  echo "*** " >> $DEBUGFILE
  echo "*** Initial set to remove" >> $DEBUGFILE
  echo $PACKAGES >> $DEBUGFILE
  echo "*** Debug file is located at $DEBUGFILE"
fi

#Clear out this variable if this function is to be reused.
NEWPACKAGE=""

#Loop to put the packages into NEWPACKAGE. Check for valid Teradata
#Client packages against the known list in the $TMPFILE

TOTALPACKAGES=`echo $PACKAGES | awk '{ print NF}'`
COUNT=0
if [ "${DEBUG}" ]; then
  echo "TOTAL=$TOTALPACKAGES, PACKAGES=$PACKAGES"
fi

set -A TMPPACKAGEARRAY $PACKAGES

while [[ $COUNT -lt $TOTALPACKAGES ]]
  do
    pkg=${TMPPACKAGEARRAY[$COUNT]}
    printf "." #Print a . for every loop...
    ### Get the name of the package from the package list without a 
    #   version number attached to it.
    #Take the package name, the first field, remove all numbers and dots,
    #and then remove any "-" at the end of the variable
    check=`echo $pkg | awk -F'[.-]' '{ print $1 }' | sed 's/[0-9.]*//g' | sed s'/-$//'`
    #Because we need teradata_arc, but don't want TeraGSS_linux, etc. just
    #check if the first part is TeraGSS, and use that for the check value.
    case $check in
      TeraGSS*)
        check="TeraGSS"
      ;;
    esac 
    if [ "${DEBUG}" ]; then
      echo "check=$check, pkg=$pkg"
    fi
    version=`get_installed_package_version $pkg` 
    totalreturned="$?"
    for versionnum in $version
    do
      #No non-digits - turns 13.00.00.00 to 13000000 for comparison later
      #Removed: Only checks for xx.xx.xx.xx: checkversion=`echo $versionnum | sed 's#[^0-9]##g'` 
      #Added  : Allows for 3 digit fourth fields, xx.xx.xx.xxx or xx.xx.xx.xx.
      checkversion=`echo $versionnum | awk -F. '{ printf "%2d%02d%02d%03d", $1, $2, $3, $4 }'`
      if [ "${DEBUG}" ]; then
        echo "pkg=$pkg, version=$versionnum, checkversion=$checkversion, PRIORTO=$PRIORTO"
      fi

      unset VERSIONOK
      #If checkversion is less than PRIORTO, then okay to remove
      if [ "$checkversion" -lt "$PRIORTO" ]; then
        VERSIONOK="1"
      fi
      #If PRIORTO is null, and hasn't been set, then it's okay to remove as well
      if [ -z "$PRIORTO" ]; then
        VERSIONOK="1"
      fi

      #Verify packages that are allowed to be removed and add to NEWPACKAGE
      if [ "$(grep -i -c "${check}" $TMPFILE )" != 0 ] &&  \
        [ "${VERSIONOK}" ] ; then
        NEWPACKAGE="$NEWPACKAGE $pkg,$versionnum" #Add the package, if known.
      else
        if [ "${NOCHECK}" ]; then		#Add the package, regardless.
          NEWPACKAGE="$NEWPACKAGE $pkg,$versionnum" 
        fi
        if [ "${CALLED_FROM_SCRIPT}" != 1 ] && [ ! "${NOCHECK}" ] \
           && [ "$DEBUG" ]; then 
            #Called from script, don't remove
            printf "\n* '$pkg ($versionnum)' will not be removed. Remove manually if desired.\n"
        fi
      fi
      (( COUNT=$COUNT + $totalreturned))
    done
done

#Loop through each package in the list at $TMPFILE
#and if the package name is in the PKGORDER list, use sed to remove
#it from any place in the string, and place it at the end of the string.

if [ "$NEWPACKAGE" != "" ]; then 
  if [ -f "$TMPFILE" ]; then
    rm $TMPFILE
  fi
  #Create the TMPFILE, with all packages on a single line
  for TOFILE in $NEWPACKAGE
  do
    printf "." #Print a . for every loop...
    echo $TOFILE >> $TMPFILE.sort
  done
  #Order the packages in alphabetical order
  sort $TMPFILE.sort > $TMPFILE
  rm $TMPFILE.sort
 
  #Loop through the packages listed in the variable of package dependency order
  #Not all of these packages are installed, but when they exist, we want to put
  #the package at the end of the list so that piom, cliv2, tdicu, and TeraGSS
  #are removed last.
  for pkg in $DEP_PKG_ORDER
    do
      printf "." #Print a . for every loop...
      #Is the package found in the TMPFILE (list of installed packages)?
      SORTPKG=`grep -i $pkg $TMPFILE`
      if [ "$?" = "0" ]; then
        #Dump the installed packages list *without* that package to TMPFILE.1
        grep -i -v $pkg $TMPFILE > $TMPFILE.1
        #Dump the installed packages list *with* that package to TMPFILE.1
        #This orders the dependenc products to the end of the list.
        grep -i $pkg $TMPFILE >> $TMPFILE.1
        #Move the output back to TMPFILE for the next loop
        mv $TMPFILE.1 $TMPFILE
      fi
    done
  #Set PACKAGES to have all the files from TMPFILE
  PACKAGES=`cat $TMPFILE`

  #Create two arrays with the package names and the version number
  for PACKAGEVER in $PACKAGES
  do
    printf "." #Print a . for every loop...
    PACKAGEARRAY[${#PACKAGEARRAY[@]}]=`echo $PACKAGEVER | awk -F, '{ print $1 }'`
    VERSIONARRAY[${#VERSIONARRAY[@]}]=`echo $PACKAGEVER | awk -F, '{ print $2 }'`
  done

  #Output the packages to the DEBUGFILE
  if [ "${DEBUG}" ];then
    echo "" >> $DEBUGFILE
    echo "Final package order" >> $DEBUGFILE
    cat $TMPFILE >> $DEBUGFILE
  fi
else
  #If there aren't any packages to remove, just set PACKAGES to empty.
  PACKAGES=""
fi

  if [ -f "$TMPFILE" ]; then
    rm $TMPFILE
  fi
}

###############################################################################
# Function: remove_packages
#
# Description: 
#
# Input : None
#
# Output: None
#
# Note  : None

remove_packages ()
{
input="$1"
if [ "$input" = "a" ];then
  i=0
  for pkg in ${PACKAGEARRAY[*]}
  do
    if [ "${NOREMOVE}" ]; then
       #This is to test the script without actually removing packages
       echo "--- Package not removed > $PKGRM $pkg - VERSION=${VERSIONARRAY[$i]}"
     else
       if [ "${VERSIONARRAY[$i]}" = "removed" ]; then
         echo "$pkg has already been removed."
       else
         #Call uninstall function, pass the package name, the version, and input
         uninstall "$pkg" "${VERSIONARRAY[$i]}" "$input" 
       fi
     fi
  i=$(($i+1))
  done
else
  if [ "$input" -gt $((${#PACKAGEARRAY[@]})) ] || [ "$input" -lt 1 ]; then
    echo "$input is not a valid menu number."
    return 1
  fi
  pkg=${PACKAGEARRAY[$input-1]}
  if [ "${VERSIONARRAY[$input-1]}" = "removed" ]; then
    echo "$pkg has already been removed."
    return 1
  fi
  if [ "${NOREMOVE}" ]; then
    #This is to test the script without actually removing packages
    echo "--- Package not removed > $PKGRM $pkg - VERSION=${VERSIONARRAY[$input-1]}"
  else
    #Call uninstall function, pass the package name, the version, and the input
    uninstall "$pkg" "${VERSIONARRAY[$input-1]}" "$input" 
  fi
fi

}
###############################################################################
# Function: init_pkginfo
#
# Description: 
#
# Input : None
#
# Output: None
#
# Note  : None

init_pkginfo ()
{
###############################################################################
#Determine which packaging software to use.

PACKAGESOUT="/tmp/ttu-remove-packages-$$.out"
if [ -f "/usr/sbin/installp" ]; then
  ########################This is for AIX
  PLATFORM=$NAME_AIX
  PKGTYPE="installp"
  PKGINFO="/bin/lslpp -l -c" #-c returns a single colon separated line
  PKGFULLINFO="/bin/lslpp -L"
  PKGRM="/usr/sbin/installp -u -g"
  $PKGINFO > $PACKAGESOUT
  PACKAGES=`cat $PACKAGESOUT | grep -i $PKGSTRING | grep "/usr/lib" | awk -F: '{ print $2 }'`
  NPAXSMOD=`cat $PACKAGESOUT | grep -i -w npaxsmod | grep "/usr/lib" | awk -F: '{ print $2 }' | sort | head -1`
  SQLPP=`cat $PACKAGESOUT | grep -i -w sqlpp | grep "/usr/lib" | awk -F: '{ print $2 }' | sort | head -1`
elif [ -f "/bin/rpm" ]; then
  ########################This is for Linux RPM
  PLATFORM=$NAME_LINUX
  PKGTYPE="rpm"
  PKGINFO="/bin/rpm -qa"
  PKGFULLINFO="/bin/rpm -qi"
  PKGRM="/bin/rpm -e -v --nodeps"  # Add --test and it won't remove pkgs.
  $PKGINFO --queryformat='%{NAME}-%{VERSION} %{SUMMARY}\n' > $PACKAGESOUT
  PACKAGES=`cat $PACKAGESOUT | grep -i $PKGSTRING | grep -v 'teradata-' | grep -v -w 'pde' | awk '{print $1}'`
  NPAXSMOD=`cat $PACKAGESOUT | grep -i -w npaxsmod | awk '{print $1}' | sort | head -1`
  SQLPP=`cat $PACKAGESOUT | grep -i -w sqlpp | awk '{print $1}' | sort | head -1`
elif [ -f "/usr/sbin/swinstall" ]; then
  ########################This is for HP-UX
  PLATFORM=$NAME_HPUX
  PKGTYPE="swinstall"
  PKGINFO="/usr/sbin/swlist"
  PKGFULLINFO="/usr/sbin/swlist"
  PKGRM="/usr/sbin/swremove -x enforce_dependencies=false" #Add -p to test.
  $PKGINFO > $PACKAGESOUT
  PACKAGES=`cat $PACKAGESOUT | grep -i $PKGSTRING | awk '{ print $1 }' | sort -A`
  NPAXSMOD=`cat $PACKAGESOUT | grep -i npaxsmod | awk '{ print $1 }' | sort | head -1`
  SQLPP=`cat $PACKAGESOUT | grep -i sqlpp | awk '{ print $1 }' | sort | head -1`
elif [ -f "/usr/bin/pkginfo" ] || [ -f "/usr/sbin/pkginfo" ]; then
  ########################This is for MP-RAS and Solaris Sparc/Opteron
  PLATFORM=$NAME_SOLARIS
  PKGTYPE="pkgadd"
  PKGINFO="pkginfo"
  PKGFULLINFO="pkginfo -l"
  PKGRM="pkgrm" 
  $PKGINFO > $PACKAGESOUT
  PACKAGES=`cat $PACKAGESOUT | grep -i $PKGSTRING | awk '{ print $2 }'`
  NPAXSMOD=`cat $PACKAGESOUT | grep -i -w npaxsmod | awk '{ print $2 }' | sort | head -1`
  SQLPP=`cat $PACKAGESOUT | grep -i -w sqlpp | awk '{ print $2 }' | sort | head -1`
fi

###############################################################################
#This is because the "Title" for Named Pipes Access Module doesn't have
#Teradata in it and neither does SQLPP: Pre TTU12.0

echo $PACKAGES > $PACKAGESOUT
if [ "${NPAXSMOD}" ] && [ "$(grep -c "npaxsmod" $PACKAGESOUT)" = 0 ]; then
    #Adding $NPAXSMOD...
    PACKAGES="$NPAXSMOD $PACKAGES"
fi
if [ "${SQLPP}" ] && [ "$(grep -c "sqlpp" $PACKAGESOUT)" = 0 ]; then
    #Adding $SQLPP...
    PACKAGES="$SQLPP $PACKAGES"
fi

#Remove leading whitespace
echo $PACKAGES | sed 's/^[ ]*//' > $PACKAGESOUT
PACKAGES=`cat $PACKAGESOUT`
rm $PACKAGESOUT
}

###############################################################################
# Function: check_for_leftover_libraries
#
# Description: Checks for libraries that may be left over in /usr/lib for
#              the packages: TeraGSS, TDICU, CLIv2, PIOM, and TDODBC.
#              These may occur in broken package installation, and rarely.
#              The script offers to move the files from the original name
#              to add "teradata-remove-script.old" so that it doesn't interfere
#              with future Teradata Client installation.  
#              The function checks for both .so and .sl files as well as
#              for files or softlinks.
#
# Input : None
#
# Output: None
#
# Note  : None

check_for_leftover_libraries ()
{
#TeraGSS Libraries
LIBRARIES="libgssp2ldap libgssp2td1 libgssp2td2 libtdgss libtdstcl libloadtdgss "
#CLIv2, Piom
LIBRARIES="$LIBRARIES libcliv2 libtdusr libpm "

#TDICU
LIBRARIES="$LIBRARIES libicudatatd libicui18ntd libicuiotd libiculetd libiculxtd libicuuctd "

#ODBC
LIBRARIES="$LIBRARIES libtdsso libodbc libodbcinst libtdparse "

FILELIST=""

#For 64-bit HPUX extension, and shared object extension on all other UNIXes.
EXT="so"
for file in $LIBRARIES 
do
if [ -f "/usr/lib/$file.$EXT" ] || [ -L "/usr/lib/$file.$EXT" ]; then
  FILELIST="$FILELIST /usr/lib/$file.$EXT"
fi
done

#For the 32-bit HP extension
EXT="sl"
for file in $LIBRARIES 
do
if [ -f "/usr/lib/$file.$EXT" ] || [ -L "/usr/lib/$file.$EXT" ]; then
  FILELIST="$FILELIST /usr/lib/$file.$EXT"
fi
done

if [ "$FILELIST" ]; then
  echo ""
  echo "NOTICE: Teradata Library files or softlinks were found in /usr/lib:"
  for file in $FILELIST
  do
    echo "    $file"
  done
  echo ""
  echo "These files/softlinks may be the result of broken package uninstall"
  echo "and could interfere with future Teradata Tooles and Utilities installations."
  echo "They could also exist as a result of current installed packages."
  echo ""
  echo "Would you like to move these files to <filename>.teradata-package-remove.old"
  echo "in order to prevent this conflict? [Y/N] (default N):"
  read INPUT
  if [ "$INPUT" = "Y" ] || [ "$INPUT" = "y" ]; then
    for file in $FILELIST
    do
      if [ "${NOREMOVE}" ]; then
          #This is to test the script without actually removing packages
          echo "---- File not moved : $file"
      else
         echo "Moving $file to $file-teradata-package-remove.old"
         mv $file $file-teradata-package-remove.old
      fi
    done
    echo "To permanently remove these files execute the command:"
    echo "    $ rm /usr/lib/*-teradata-package-remove.old"
  else
    echo "The following listed files have not been moved: "
    for file in $FILELIST
    do
      echo "    $file"
    done
  fi
fi
}

###############################################################################
# Function: cleanup
#
# Description: Cleanup files before exiting
#
# Input : None
#
# Output: None
#
# Note  : None

cleanup ()
{
#Clean up TMPFILE
if  [ ! -n "${DEBUG}" ];then
  if [ -f "$TMPFILE" ]; then
    rm $TMPFILE
  fi
  if [ -f "$SYSTEMPACKAGESOUT" ]; then
    rm $SYSTEMPACKAGESOUT
  fi
fi
echo ""
}

###############################################################################
# Start initial script beginning
###############################################################################

#Loop through passed variables and set values
while [ $# -gt 0 ]
do
  case "$1" in
    h|help)
        display_usage
        cleanup
        exit 1
     ;;
    debug)  
        echo "*** debug option set."
        DEBUG=1
    ;;
    nocheck)
        echo "*** nocheck option set."
        echo "*** Will not check packages against known list of TTU packages."
        echo "*** Use this option with care."
        NOCHECK=1
    ;;
    noremove)
        echo "*** noremove option set."
        echo "*** Will not remove listed packages from the system."
        NOREMOVE=1
    ;;
    script)
        CALLED_FROM_SCRIPT=1
    ;;
    a|all)
        REMOVE_ALL=1
    ;;
    priorto)
        #Set the value for PRIORTO, to remove packages earlier than this ver #
        shift
        case $1 in 
          *[!0-9.]*) 
            echo "Parameter passed ($1) is not numeric. Parameter for 'priorto'" 
            echo "should be in the form xx.xx.xx.xx, such as $SCRIPTVER."
            cleanup
            exit 1
          ;;
        esac
        echo "Removing packages prior to version $1."
        PRIORTO=`echo $1 | awk -F. '{ printf "%2d%02d%02d%03d", $1, $2, $3, $4 }'`
        if [ "$PRIORTO" -gt 99999999999 ]; then
          echo "Error: Provided version number too large: $1"
          exit 1
        fi
    ;;
    *) break;;
  esac
  shift
done 

#CLNTINS-3467 - Display the version when executed not from the .setup.sh script.
if [ "${CALLED_FROM_SCRIPT}" != 1 ]; then
  echo "Teradata Tools and Utilities UNIX Uninstall                       v.$SCRIPTVER"  
  echo "Copyright ${CRYEAR}. Teradata Corporation. All Rights Reserved."
fi

###############################################################################
#Initialise some main variables
PKGSTRING="Teradata"

QUERYMSG1="f. Display the full package information on the packages listed."
QUERYMSG2="a. Remove all of the above software."
QUERYMSG3="h. Display help information."
QUERYMSG4="q. Quit the package remove script."
QUERYMSG="Enter one or more selections (separated by space): "
TMPFILE="/tmp/ttu-remove-$$.out"
DEBUGFILE="/tmp/ttu-remove-debug-$$.out"

NAME_AIX="AIX"
NAME_HPUX="HPUX"
NAME_LINUX="Linux"
NAME_SOLARIS="Solaris"

###############################################################################
#Setup the packaging variables and fill in the PACKAGES variable
init_pkginfo

#Showing what the package removal type/program is.
echo "Package Removal Type: $PKGTYPE"

#Order the packages so dependencies are removed, also validate packages
order_packages 

if [ "${REMOVE_ALL}" = 1 ]  && [ -z "$PRIORTO" ]; then
  printf "\nNote: Ignoring \"all\" parameter option, as \"priorto\" option has not been set.\n"
fi

#The variable PACKAGES should have a list of packages in it, if it doesn't
#then just exit.  There's nothing more to be done here.
if [ "${PACKAGES}" ]; then
  echo ""
  echo "The following packages are installed:"
  display_packages
else
  echo "No Teradata Tools and Utilities packages to remove."
  #Previously would exit, but now let's check for library files just in case.
  #Check for possible leftover files.
  #Check for possible leftover files, but not if called from a script. (See $1)
  if [ "${CALLED_FROM_SCRIPT}" != 1 ]; then
    check_for_leftover_libraries
  fi
  cleanup
  exit 1
fi

#Automatically remove all packages, but only if PRIORTO has been set.
if [ "${REMOVE_ALL}" = 1 ]  && [ ! -z "$PRIORTO" ]; then
  remove_packages a
  cleanup
  exit 0
fi

echo ""
echo $QUERYMSG1
echo $QUERYMSG2
echo $QUERYMSG3
echo $QUERYMSG4
echo ""
printf "${QUERYMSG}"

while read ans
do
  for input in $ans
  do
    if [ "$input" ]; then
      case $input in
        [nNqQ]*) echo "Exiting...";cleanup;exit 1;;
        [aA]*) remove_packages a;cleanup;exit 1;; 
        [fF]*) display_fullinfo;;
        [hH]) display_help;;
        *[1234567890]) remove_packages $input;;
        *);;
      esac
    fi
  done
  echo ""
  echo "The following packages are installed:"
  display_packages
  echo ""
  echo $QUERYMSG1
  echo $QUERYMSG2
  echo $QUERYMSG3
  echo $QUERYMSG4
  echo ""
  printf "${QUERYMSG}"
done

#Get a list of the packages again so we can verify that the packages have
#been removed.  If not, display what packages are still on the system.
#This should be a rare occurrence, but if it happens it's not the end of
#the world.  The administrator is be able to manually remove those
#packages or just run the script again.  If there is a problem with the
#packages that prevent them from being removed, then it is an administration
#problem that is beyond the scope of this script.

init_pkginfo

if [ "${PACKAGES}" ] && [ "${CALLED_FROM_SCRIPT}" != 1 ]; then
  echo ""
  if [ "${DEBUG}" ];then
    echo "PACKAGES='$PACKAGES'"
  fi
  echo "These Teradata packages still remain on the system:"
  display_packages
  echo "This message may display if current TTU packages are installed."
  echo ""
fi

#Check for possible leftover files, but not of called from a script. (See $1)
if [ "${CALLED_FROM_SCRIPT}" != 1 ]; then
  check_for_leftover_libraries
fi

