#' @name tracking_api_token
#' @title Install a Tracking API token to your .Renviro without the need to reference the token directly in each call.
#' @description This function adds a Tracking API token to your .Renviron file so it can be called securely without being stored in your code. After you have run this function, the token can be called by running Sys.getenv("TRACKING_API_TOKEN").
#' @param token Specifies the API token that was provided to you by the Tracking Program as a quoted string (e.g., "C6016D98-CGCA-495D-BF0B-EAAE20BADD98"). A token can be acquired by emailing, trackingsupport(AT)cdc.gov. Further information available at https://ephtracking.cdc.gov/apihelp. 
#' @param overwrite Allows you to overwrite an existing TRACKING_API_TOKEN stored in your .Renviron file. Defaults to TRUE.
#' @param install Allows you to store the token in your .Renviron file for use in future sessions. Defaults to TRUE.
#' @examples \dontrun{
#' 
#' tracking_api_token("XXXXXXXXXXXXXXXXX")
#' 
#' #After you run this function, reload your environment so you can use the token without restarting R.
#' readRenviron("~/.Renviron")
#' }
#' 
#' @references This function and accompanying documentation were adapted from the tidycensus package with very little modification.
#' Walker K, Herman M (2023). tidycensus: Load US Census Boundary and Attribute Data as 'tidyverse' and 'sf'-Ready Data Frames. 
#' R package version 1.3.2, https://walker-data.com/tidycensus/.
#' @export
#' 



#this code was adapted within very little change from the tidycensus package, https://walker-data.com/tidycensus/reference/TRACKING_API_TOKEN.html
# Walker K, Herman M (2023). tidycensus: Load US Census Boundary and Attribute Data as 'tidyverse' and 'sf'-Ready Data Frames. R package version 1.3.2, https://walker-data.com/tidycensus/.

tracking_api_token <- function (token, overwrite = TRUE, install = TRUE) 
{
  if (install) {
    home <- Sys.getenv("HOME")
    renv <- file.path(home, ".Renviron")
    if (file.exists(renv)) {
      file.copy(renv, file.path(home, ".Renviron_backup"))
    }
    if (!file.exists(renv)) {
      file.create(renv)
    }
    else {
      if (isTRUE(overwrite)) {
        message("Your original .Renviron will be backed up and stored in your R HOME directory if needed.")
        oldenv = read.table(renv, stringsAsFactors = FALSE)
        newenv <- oldenv[-grep("TRACKING_API_TOKEN", oldenv), 
        ]
        write.table(newenv, renv, quote = FALSE, sep = "\n", 
                    col.names = FALSE, row.names = FALSE)
      }
      else {
        tv <- readLines(renv)
        if (any(grepl("TRACKING_API_TOKEN", tv))) {
          stop("A TRACKING_API_TOKEN already exists. You can overwrite it with the argument overwrite=TRUE", 
               call. = FALSE)
        }
      }
    }
    keyconcat <- paste0("TRACKING_API_TOKEN='", token, "'")
    write(keyconcat, renv, sep = "\n", append = TRUE)
    message("Your API token has been stored in your .Renviron and can be accessed by Sys.getenv(\"TRACKING_API_TOKEN\"). \nTo use now, restart R or run `readRenviron(\"~/.Renviron\")`")
    return(token)
  }
  else {
    message("To install your API token for use in future sessions, run this function with `install = TRUE`.")
    Sys.setenv(TRACKING_API_TOKEN = token)
  }
}
