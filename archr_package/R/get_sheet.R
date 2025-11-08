#' @name get_sheet
#' @title Get Google Sheet Download Link
#' @description
#' Let's write a quick function for grabbing a specific google sheet using its share link.
#' 
#' @param docid ID for that overall Google document. (Optional. Must supply either `url` or `docid`)
#' @param gid sheet ID for that specific sheet (1 google sheets contains multiple sheets)
#' @param url view-allowed Google Sheets share link (Optional. Must supply either `url` or `docid`)
#' 
#' @importFrom dplyr `%>%`
#' @importFrom stringr str_remove
#' 
#' @export
get_sheet = function(url = NULL, docid = NULL, gid = 0){

  # Example values
  # url = "https://docs.google.com/spreadsheets/d/LONG_DOCUMENT_ID_HERE/edit?usp=sharing"
  # gid = 0

  # If the url is provided, but docid is not, extract the document id.
  if(!is.null(url) & is.null(docid)){
    docid = url %>% stringr::str_remove("[/]edit.*") %>% stringr::str_remove(".*[/]d[/]")
  }
  # Generate the base
  base = paste0("https://docs.google.com/spreadsheets/d/", docid, "/")
  # Make the download link
  output = base %>% paste0("export?format=csv") %>% paste0("&gid=", gid)
  return(output)
}
