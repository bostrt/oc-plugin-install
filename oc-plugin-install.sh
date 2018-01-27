#!/bin/bash
filename=`mktemp`
workdir=`mktemp -d`
url=$1

if [[ $url == '' ]]; then
  echo 'No plugin URL specified.'
  exit
fi

# Download file 
curl -L -s -o $filename $url
if [[ $? != 0 ]]; then
  echo 'Failed to download '$file
  exit
fi

# Decompression
mime=`file -i $filename`
if [[ $mime =~ application/x-(gzip|tar) ]]; then
  tar xf $filename -C $workdir
elif [[ $mime =~ application/zip ]]; then
  unzip -q $filename -d $workdir
fi

# Location plugin.yaml.
locations=`find $workdir -type f -name plugin.yaml | wc -l`
if [[ $locations == 0 ]]; then
  echo 'Cannot install plugin. No plugin.yaml found.'
  exit
elif [[ $locations > 1 ]]; then
  echo 'Cannot install plugin. More than one plugin.yaml found.'
fi

pluginyaml=`find $workdir -type f -name plugin.yaml`

# Extract plugin name
pluginname=`grep ^name $pluginyaml | cut -f 2 -d ' ' | tr -d '"'`

# Create plugin directory
mkdir -p $HOME/.kube/plugins/$pluginname

# Copy over files inside same directory as plugin.yaml
cp -p -r $(dirname $pluginyaml)/* $HOME/.kube/plugins/$pluginname

# Cleanup
rm $filename
rm -r $workdir
