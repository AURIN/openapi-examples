#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Example Python 2 program for accessing the AURIN Open API.
# Author: Robert Hutton <rhutton@unimelb.edu.au>
#
# This exmple code is Licensed CC0 1.0 (Public Domain):
# https://creativecommons.org/publicdomain/zero/1.0/
#
# For more information on the AURIN Open API and to apply for access, see:
# http://docs.aurin.org.au/aurin-portal-access-registration/aurin-api/
#
# The AURIN Open API implements the OGC Catalog Service; specification is here:
# http://www.opengeospatial.org/standards/cat
#
# This example code demonstrates the following operations:
# * GetCapabilities on the metadata service
# * List the available datasets and their licenses
# * Query the attributes of a dataset
# * Return the first feature from a dataset
#
# You will need to put your AURIN OpenAPI username and password into the
# openapi.cfg file.

import ConfigParser
import urllib2
from lxml import etree

# Import authentication parameters from the config file
config = ConfigParser.RawConfigParser()
config.read('openapi.cfg')

username=config.get('Auth', 'username')
password=config.get('Auth', 'password')

# Submit an authenticated request to the AURIN Open API
def openapi_request(url):

    # create an authenticated HTTP handler and submit URL
    password_manager = urllib2.HTTPPasswordMgrWithDefaultRealm()
    password_manager.add_password(None, url, username, password)
    auth_manager = urllib2.HTTPBasicAuthHandler(password_manager)
    opener = urllib2.build_opener(auth_manager)
    urllib2.install_opener(opener)

    req = urllib2.Request(url)
    handler = urllib2.urlopen(req)

    #print handler.getcode()
    #print handler.headers.getheader('content-type')
    #print handler.read(1000)

    return handler.read()

# Get the capabilities of the metadata service
url = 'http://openapi.aurin.org.au/csw?request=GetCapabilities&service=CSW'
xml = openapi_request(url)
root = etree.fromstring(xml)
print '================ CAPABILITIES ================'
print etree.tostring(root, pretty_print=True)

# Get a list of all available datasets and their licences
url='http://openapi.aurin.org.au/csw?request=GetRecords&service=CSW&version=2.0.2&typeNames=csw:Record&elementSetName=full&resultType=results&constraintLanguage=CQL_TEXT&constraint_language_version=1.1.0&maxRecords=1000'
xml = openapi_request(url)
root = etree.fromstring(xml)
print '================ DATASETS ================'
print 'Query URL: '+url
#print etree.tostring(root, pretty_print=True)
for dataset in root.findall(".//csw:Record", root.nsmap):
    print '================ DATASET ================'
    #print etree.tostring(dataset, pretty_print=True)
    print 'Dataset: '+dataset.find(".//dc:title", root.nsmap).text
    print dataset.find(".//dc:rights", root.nsmap).text

# Query the attributes of the first dataset
dataset = root.findall(".//dc:title", root.nsmap)[0].text
url = 'http://openapi.aurin.org.au/wfs?request=DescribeFeatureType&service=WFS&version=1.1.0&typeName='+dataset
print '================ DATASET PROPERTIES ================'
print 'Query URL: '+url
xml = openapi_request(url)
root = etree.fromstring(xml)
print etree.tostring(root, pretty_print=True)

# Get the first feature (row) of the first dataset
url = 'http://openapi.aurin.org.au/wfs?request=GetFeature&service=WFS&version=1.1.0&TypeName='+dataset+'&MaxFeatures=1'
print '================ FIRST FEATURE ================'
print 'Query URL: '+url
xml = openapi_request(url)
root = etree.fromstring(xml)
print etree.tostring(root, pretty_print=True)
