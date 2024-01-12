#' @title Identifying Scripts
#' @description
#' This function detects if the script is a latinate or not.
#' @param input character string
#' @keywords internal
#'
#' @return A character string indicating if it's a latinate or not.
#'
IS <- function(input) {  # stands for Identify Script

  # see Unicode sets at https://en.wikipedia.org/wiki/List_of_Unicode_characters
  # Example of Greek and Coptic: grepl("[\u0370-\u03FF]", "Ελευθερία ή Θάνατος")
  # Some scripts that are latin-like are used in col. 2 of geonames,
  # like Vietnamese

  # input is the search string that the user provided
  # function to check if the search string is in one of the
  # common non-Latinate scripts that are not in col. 2 (the default look-up column)
  # but in col. 4 (alternate names) of geonames;
  # note that Latin-like scripts, even very derived ones like Vietnamese,
  # will be in column 2









  result <- "likely.latin"
  # likely.latin is the default, which will be overridden if characters from some
  # other common script is identified
  # the following are unicode ranges for the non-latinate script blocks,
  # also followed by the hexadecimals converted to integers for check of typos
  # (conversion done using, e.g. sprintf("%d", 0x0370))
  Greek.Coptic <- "[\u0370-\u03FF]"              #   880- 1023
  Cyrillic <- "[\u0400-\u04FF]"                  #  1024- 1279
  Armenian <- "[\u0530-\u058F]"                  #  1328- 1423
  Hebrew <- "[\u0590-\u05F4]"                    #  1424- 1524
  Arabic <- "[\u0600-\u06FF]"                    #  1536- 1791
  Syriac <- "[\u0700-\u074F]"                    #  1792- 1871
  Devanagari <- "[\u0900-\u097F]"                #  2304- 2431
  Bengali.Assamese <- "[\u0980-\u09FE]"          #  2432- 2558
  Gurmukhi <- "[\u0A00-\u0A76]"                  #  2560- 2678
  Gujarati <- "[\u0A80-\u0AFF]"                  #  2688- 2815
  Oriya <- "[\u0B00-\u0B77]"                     #  2816- 2935
  Tamil <- "[\u0B80-\u0BFA]"                     #  2944- 3066
  Telugu <- "[\u0C00-\u0C7F]"                    #  3072- 3199
  Kannada <- "[\uC80-\uCF3]"                     #  3200- 3315
  Malayalam <- "[\u0D00-\u0D7F]"                 #  3328- 3455
  Sinhala <- "[\u0D81-\u0DF4]"                   #  3457- 3572
  Georgian <- "[\u10A0-\u10FF]"                  #  4256- 4351
  Geez.Ethiopian <- "[\u1200-\u137C]"            #  4608- 4988
  Mongolian <- "[\u1800-\u18AA]"                 #  6144- 6314
  Hiragana <- "[\u3040-\u309F]"                  # 12352-12447
  Katakana <- "[\u30A0-\u30FF]"                  # 12448-12543
  Hangul <- "[\uAC00-\uD7AF]"                    # 44032-55215
  Hangul.Jamo <- "[\u1100-\u11FF]"               #  4352- 4607
  Hangul.Compatibility.Jamo <- "[\u3130-\u318E]" # 12592-12686
  # integer range for Chinese ideographs corresponding to ["\u4E00–\u9FFF"]
  non.latin <- c(Greek.Coptic, Cyrillic, Armenian, Hebrew, Arabic,
                 Syriac, Devanagari, Bengali.Assamese, Gurmukhi,
                 Gujarati, Oriya, Tamil, Telugu, Kannada, Malayalam,
                 Sinhala, Georgian, Geez.Ethiopian, Mongolian,
                 Hiragana, Katakana, Hangul, Hangul.Jamo,
                 Hangul.Compatibility.Jamo)
  script.names <- c("Greek or Coptic", "Cyrillic", "Armenian", "Arabic",
                    "Hebrew", "Syriac", "Devanagari", "Bengali/Assamese", "Gurmukhi",
                    "Gujarati", "Oriya", "Tamil", "Telugu", "Kannada", "Malayalam",
                    "Sinhala", "Georgian", "Geez/Ethiopian", "Mongolian",
                    "Japanese", "Japanese", "Hangul", "Hangul",
                    "Hangul")
  CJK.range <- 19968:40959
  for (i in 1:length(non.latin)) {
    find.non.latin <- grepl(non.latin[i], input)
    if (find.non.latin[1]==TRUE) {
      message("You entered one or more ", script.names[i],
            " characters, so the alternate names column of geonames will be used.\n")
      result <- "non.latinate"
      return(result)
    }
  }
  # in case the other non-Latinate systems weren't identified,
  # Chinese will be tried
  if (result=="likely.latin") {
    int.values <- utf8ToInt(input)
    if (sum(int.values %in% CJK.range) > 0) {
      message("You entered one or more Chinese characters, so the alternate names column of geonames will be used.\n")
      result <- "non.latinate"
    }
  }
  return(result)
}


