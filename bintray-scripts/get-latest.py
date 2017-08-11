#!/usr/bin/env python

# This script gets the ID of the newest version for a given package on bintray.

import sys, json, urllib2

if len(sys.argv) != 4:
    print('Usage: ./get-latest.py $username $api_key $package_path')
    print('Package path must be in the form: subject/repo/package, eg tetchell/olt-sandbox/olt-nightly')
    exit(1)

# First, retrieve the package info JSON to see what version is newest.
package_info_url = 'https://api.bintray.com/packages/' + sys.argv[3]
req = urllib2.Request(package_info_url)

encoded_auth = 'Basic ' + (sys.argv[1] + ':' + sys.argv[2]).encode('base64').rstrip()
req.add_header('Authorization', encoded_auth)

json_resp = urllib2.urlopen(req).read()

jso = json.loads(json_resp)
latest_version = jso['latest_version']

if len(latest_version) == 0:
    print('Something went wrong reading the JSON response from ' + package_info_url + '\nContents:')
    print(json_resp)
    exit(1)

print(latest_version)
