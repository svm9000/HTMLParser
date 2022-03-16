"""

Description: Creates a link into Excel to parse the contents of a set of URLs. 
	     For each URL we return the text between the specified HTML tags


"""
from __future__ import division
import sys
import numpy as np
import xlwings as xw
import urllib2
from bs4 import BeautifulSoup



def replace_all(text, dic=None):
    """define a function to replace multiple elements of the search string

    Keyword arguments:
    text -- is the text string to be parsed 
    dic  -- is the dictionary with the {key:value} or {find:replace} entities in the string
    """

    if dic is not None:
        for i, j in dic.iteritems():
            text = text.replace(i, j)
	
    return text


def parseHTML(s,findTag,attrs=None,repl=None):
    """define a function to extract particular components/tags from an HTML string 

    Keyword arguments:
    s        -- is the instance of the BeautifulSoup object 
    findTag  -- is the HTML tag to parse
    attrs    -- are other components of the tag to parse,
                usually entered in as a dictionary {key:value}, i.e { "class" : "coverpage_content" } 
    repl     -- are the key words (key) to replace (value) from the final parsed HTML entered in as a dictionary {key:value},
                i.e. {'<div class="coverpage_content">':''}
    """

    
    return [replace_all(str(tag),repl) for tag in s.find_all(findTag,attrs)]
	
def main():
   
 
    #get the number of URLs from the first sheet of the Excel workbook
    NumURls=int(xw.Book.caller().sheets[0].range('NumURLs').value)

    for rw in xrange(NumURls):

	#extract the next url from the first sheet of the Excel workbook
    	_url= xw.Book.caller().sheets[0].range(rw+2,1).value

	#if we have a valid url then extract its contents 
	if _url is not None:

		#open the url and read in its contents
    		content = urllib2.urlopen(_url).read()
    		#print content
    		soup = BeautifulSoup(content)

		
			
    		xw.Book.caller().sheets[0].range(rw+2,2).value= parseHTML ( s=soup
  									   ,findTag="div"
								           ,attrs={ "class" : "coverpage_content" }
							                   ,repl={'<div class="coverpage_content">':'', '</div>':''}
   								          )
