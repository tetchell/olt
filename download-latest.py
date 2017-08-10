#!/usr/bin/env python

import sys, urllib2, json, os
# BeautifulSoup is required. pip install beautifulsoup4
from bs4 import BeautifulSoup

# This script downloads the newest version of a package from bintray.

if len(sys.argv) != 4:
    print('Usage: ./bintray-dl-latest.py $username $apikey $packagepath')
    print('Package path must be in the form: subject/repo/package, eg tetchell/olt-sandbox/olt-nightly')
    exit(1)

# First, retrieve the package info JSON to see what version is newest.
package_info_url='https://api.bintray.com/packages/' + sys.argv[3]
req = urllib2.Request(package_info_url)

encoded_auth='Basic ' + (sys.argv[1] + ':' + sys.argv[2]).encode('base64').rstrip()
req.add_header('Authorization', encoded_auth)

json_resp = urllib2.urlopen(req).read()

jso = json.loads(json_resp)
latest_version = jso['latest_version']

if len(latest_version) == 0:
    print('Something went wrong reading the JSON response from ' + package_info_url + '\nContents:')
    print(json_resp)
    exit(1)

print('Latest version is ' + latest_version)

# The base of each download location is a simple html page with a list of files
# However the links use javascript, so wget -r is not sufficient
download_base_url='https://dl.bintray.com/{}/{}'.format(sys.argv[3], latest_version)
print('Fetching file list from ' + download_base_url)

req = urllib2.Request(download_base_url)
req.add_header('Authorization', encoded_auth)

file_list_page=urllib2.urlopen(req).read()

# Save the files into a dir named for the latest_version
dest_dir = latest_version
if not os.path.exists(dest_dir):
    os.makedirs(dest_dir)

# Parse the list for links each which includes a filename part of this package version
# Then download the files into the directory we just created
soup = BeautifulSoup(file_list_page, 'lxml')
for file in soup.find_all('a'):
    file_url = download_base_url + '/' + file.string

    req = urllib2.Request(file_url)
    req.add_header('Authorization', encoded_auth)
    file_contents = urllib2.urlopen(req).read()

    file_to_write = dest_dir + '/' + file.string
    f = open(file_to_write, 'w')
    f.write(file_contents)
    f.close()
    print('Successfully fetched ' + file_to_write)
