#!/bin/bash
# source: https://gist.github.com/TheIndifferent/8573be7b18c2fdcf772f

set -x
set -e

readonly TIP_VERSION='4.2.0'

function checkWorkspaceVar()
{
  echo 'Checking "$WORKSPACE" variable...'

  if [ -z "$WORKSPACE" ] ; then
    echo -n 'WORKSPACE variable is empty, setting to current dir: '
    export WORKSPACE="$( pwd )"
    echo "$WORKSPACE"
  else
    echo "WORKSPACE variable is already set to '$WORKSPACE'"
  fi
}

function downloadJavaHelp()
{
  echo -n 'Checking for downloaded javahelp...'
  if [ -d 'jh2.0' ] ; then
    echo ' found.'
  else
    echo ' not found, downloading:'
    rm -f javahelp2_0_05.zip
    wget 'https://github.com/glub/secureftp/raw/master/contrib/javahelp2_0_05.zip'
    unzip -o javahelp2_0_05.zip
  fi
  export JAVAHELP_HOME="$( cd jh2.0/javahelp && pwd )"
}

function downloadJUnit()
{
  echo -n 'Checking for downloaded junit...'
  if [ -s 'junit/junit.jar' ] ; then
    echo ' found.'
  else
    echo ' not found, downloading:'
    ( mkdir -p 'junit' && cd 'junit' && rm -rf * && wget 'http://repo1.maven.org/maven2/junit/junit/4.8.2/junit-4.8.2.jar' && mv junit-4.8.2.jar junit.jar )
  fi
  export JUNIT_HOME="$( cd junit && pwd )"
  export JUNIT_JAR="$JUNIT_HOME"/junit.jar
}

function downloadTestNG()
{
  echo -n 'Checking for downloaded testng...'
  if [ -s 'testng/testng.jar' ] ; then
    echo ' found.'
  else
    echo ' not found, downloading:'
    ( rm -rf testng && mkdir testng && cd testng && wget 'http://central.maven.org/maven2/org/testng/testng/6.8/testng-6.8.jar' && mv testng-6.8.jar testng.jar && wget 'https://raw.githubusercontent.com/cbeust/testng/testng-6.8/LICENSE.txt')
  fi
  export TESTNG_HOME="$( cd testng && pwd )"
  export TESTNG_JAR="$TESTNG_HOME"/testng.jar
}

function downloadJCov()
{
  echo -n 'Checking for downloaded JCov...'
  if [ -d 'jcov' ] ; then
    echo 'found'
  else
    echo 'Downloading latest jcov...'
    rm -rf jcov*
    wget 'https://adopt-openjdk.ci.cloudbees.com/view/OpenJDK%20code-tools/job/jcov/lastSuccessfulBuild/artifact/jcov-2.0-beta-1.tar.gz'
    tar -zxvf jcov-2.0-beta-1.tar.gz
    mv JCOV_BUILD jcov
    mv jcov/jcov_2.0 jcov/lib
  fi
  export JCOV_HOME="$( cd jcov && pwd )"
}

function downloadAsmTools()
{
  echo -n 'Checking for downloaded AsmTools...'
  if [ -d 'asmtools' ] ; then
    echo 'found'
  else
    echo 'Downloading latest asmtools...'
    rm -rf asmtools*
    wget 'https://adopt-openjdk.ci.cloudbees.com/view/OpenJDK%20code-tools/job/asmtools/lastSuccessfulBuild/artifact/asmtools-6.0.tar.gz'
    tar -xzvf asmtools-6.0.tar.gz
    ## tar contains zip for some reason:
    unzip -o asmtools-6.0.zip
    mv asmtools-6.0 asmtools
  fi
  export ASMTOOLS_HOME="$( cd asmtools && pwd )"
}

function downloadJTHarness()
{
  echo -n 'Checking for downloaded JTHarness...'
  if [ -d 'jtharness' ] ; then
    echo 'found'
  else
    echo 'Downloading latest jtharness...'
    rm -rf jtharness*
    wget 'https://adopt-openjdk.ci.cloudbees.com/view/OpenJDK/job/jtharness/lastSuccessfulBuild/artifact/jtharness-4.6.tar.gz'
    tar -zxvf jtharness-4.6.tar.gz
  fi
  export JTHARNESS_HOME="$( cd jtharness && pwd )"
}

function downloadJCommander()
{
  echo -n 'Checking for downloaded jcommander...'
  if [ -s 'jcommander/jcommander.jar' ] ; then
    echo ' found.'
  else
    echo ' not found, downloading:'
    ( rm -rf 'jcommander' && mkdir 'jcommander' && cd 'jcommander' && wget 'http://repo1.maven.org/maven2/com/beust/jcommander/1.7/jcommander-1.7.jar' && mv jcommander-1.7.jar jcommander.jar )
  fi
}

function downloadXalan()
{
  echo -n 'Checking for downloaded Xalan...'
  if [ -d 'xalan' ] ; then
    echo ' found.'
  else
    echo ' not found, downloading:'
    ( rm -rf 'xalan' && mkdir 'xalan' && cd 'xalan' && wget 'http://central.maven.org/maven2/xalan/xalan/2.7.2/xalan-2.7.2.jar' && mv xalan-2.7.2.jar xalan.jar && wget 'http://central.maven.org/maven2/xalan/serializer/2.7.2/serializer-2.7.2.jar' && mv serializer-2.7.2.jar serializer.jar )
  fi
  export XALANHOME="$( cd xalan && pwd )"
}

function downloadAnt()
{
  echo -n 'Checking for downloaded Ant...'
  if [ -d 'ant' ] ; then
    echo ' found.'
  else
    echo ' not found, downloading:'
    ( rm -rf 'ant' && mkdir -p 'ant/lib' && cd 'ant/lib' && wget 'http://central.maven.org/maven2/org/apache/ant/ant/1.8.4/ant-1.8.4.jar' && mv ant-1.8.4.jar ant.jar )
  fi
  export ANTHOME="$( cd ant && pwd )"
}

function clearWorkspace()
{
  echo 'Cleaning workspace before the build...'
  rm -rf *.zip *.tar.gz

  unset JAVATEST_HOME

  echo 'Deletion previous build dist...'
  rm -rf build dist
}

buildJTReg()
{
  echo "Building $1..."
  (
   versionNumber=$2
   buildNumber=$3
   echo "VersionNumber:" ${versionNumber}
   echo "BuildNumber:" ${buildNumber}
   make -C make
#   ant -v -f make/build.xml \
#   -Djunit.jar=./junit/junit.jar \
#   -Dtestng.jar=./testng/testng.jar \
#   -Djavatest.home=$JTHARNESS_HOME \
#   -Djavatest.jar=$JTHARNESS_HOME/lib/javatest.jar \
#   -Djavahelp.home=./jh2.0 \
#   -Djhall.jar=./jh2.0/javahelp/lib/jhall.jar \
#   -Djh.jar=./jh2.0/javahelp/lib/jh.jar \
#   -Dbuild.version=${versionNumber} \
#   -Dbuild.number=${buildNumber} \
#   -Djcov.home=$JCOV_HOME
#   cd dist
#   cp $WORKSPACE/jcommander/jcommander.jar  $WORKSPACE/dist/jtreg/lib
#   tar -cvf jtreg.tar jtreg
#   gzip -9 jtreg.tar
#   mv jtreg.tar.gz $WORKSPACE/jtreg-$versionNumber-$buildNumber.tar.gz
  )
}

buildJTRegTip()
{
  hg checkout tip
  hg pull -u
  buildJTReg "the tip" "$TIP_VERSION" "tip"
}

buildJTRegLastTag()
{
  tagName=$(hg tags | grep jtreg | head -1 | gawk '{ print $1 }')
  versionAndBuildNumber=$(echo ${tagName}| awk '{split($0,a,"jtreg"); print a[2]}')
  versionNumber=$(echo ${versionAndBuildNumber} | awk '{split($0,a,"-"); print a[1]}')
  buildNumber=$(echo ${versionAndBuildNumber} | awk '{split($0,a,"-"); print a[2]}')
  hg checkout "$tagName"

  buildJTReg "last tag" "$versionNumber" "$buildNumber"
}

checkWorkspaceVar

echo 'Downloading build dependencies...'
downloadJCommander
downloadJavaHelp
downloadJUnit
downloadTestNG
downloadJCov
downloadAsmTools
downloadJTHarness
downloadXalan
downloadAnt
clearWorkspace

# ubuntu
#export JDK15HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
# fedora
export JDK15HOME=/usr/lib/jvm/java-1.8.0-openjdk
echo 'Starting build process...'
#buildJTRegTip
#buildJTRegLastTag
make -C make
echo '...finished with build process.'
