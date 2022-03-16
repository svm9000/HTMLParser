#############################################################################################
#############################################################################################
##                                                                                         ##
##   R-Code for parsing the contents of a set of URLs.                                     ## 
##          For each URL we return the text between the specified HTML tags                ##
##                                                                                         ##
##                                                                                         ##
#############################################################################################
#############################################################################################


#install set of packages if not installed already
list.of.packages <- c("rvest","dplyr","stringr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(rvest)
library(dplyr)
library(stringr)


parseURL=function(scraping_url,tag='#coverpage_nr_1 .coverpage_content'){
  # function to parse a URL string and return the cleaned text between the specified tag
  #
  # Args:
  #   scraping_url: The URL to parse
  #   tag         : The tag section to extract from the the URL page 
  #
  # Returns:
  #   The cleaned text between the specified tag
  
  scraping_url=read_html(scraping_url)
  body_text <- scraping_url%>%html_nodes(tag) 
              
  
  # clean up text between tags
  body_text <-    body_text                                             %>% 
                  #replace a new line feed with a space
                  str_replace_all(pattern = "\n"   , replacement = " ") %>%
                  #replace '^' with a space
                  str_replace_all(pattern = "[\\^]", replacement = " ") %>% 
                  #replaces " with a space
                  str_replace_all(pattern = "\"", replacement = " ")    %>%
                  #replaces one or more spaces with a space
                  str_replace_all(pattern = "\\s+", replacement = " ")  %>% 
                  #replace certain parts of the string as required with a space. Change as required
                  str_replace_all(pattern = c("<div class= coverpage_content >","</div>"), 
                                  replacement = "")                     %>%
                  str_trim(side = "both")
                  #uncomment the next line if you need to strip out any HTML tags in the final text
                  #%>%html_text() 
   
   #return the final cleansed text 
   return (body_text)
}

########################################################################################
#################################MAIN###################################################
########################################################################################

# start the timer
ptm <- proc.time()

#specify the input file location for the URL list
inputURLLocation="C:\\...\\urlList.csv"
#specify the output file location for the clean text
outputFileLocation="C:\\...\\outputTextR.csv"

#get list of urls to parse
scrapurls <- read.csv(file=inputURLLocation, header=TRUE, sep=",")


#create a dynamic vector to hold the cleaned text from the parseURL function
out=NULL
#loop through each URL and extract the relevant cleaned text string that is placed in the out vector
for (i in 1:dim(scrapurls)[1]){
  #returns the first element of the parsed string, as there may be multiple instances of some tags. 
  #change the [1] part as required
  out[i]=parseURL(toString(scrapurls$EnterURLs[i]))[1]
}


#output the final file with the cleaned text in csv format 
write.csv(data.frame(list(InputUrls=scrapurls$EnterURLs,CleanText=out))
                          , file = outputFileLocation
                          , row.names = FALSE)


# end the timer and output execution time
cat("--- Seconds to execute main ---",(proc.time() - ptm)[3])
