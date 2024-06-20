#' see_file
#'
#' Allow to get the filename or its extension
#' 
#' @param string_ is the input string
#' @param index_ext is the occurence of the dot that separates the filename and its extension
#' @param ext is a boolean that if set to TRUE, will return the file extension and if set to FALSE, will return filename
#' @examples
#' 
#' print(see_file(string_="file.abc.xyz"))
#'
#' #[1] ".abc.xyz"
#'
#' print(see_file(string_="file.abc.xyz", ext=FALSE))
#'
#' #[1] "file"
#'
#' print(see_file(string_="file.abc.xyz", index_ext=2))
#' 
#' #[1] ".xyz"
#' 
#' @export

see_file <- function(string_, index_ext=1, ext=TRUE){

        file_as_vec <- unlist(str_split(string_, ""))

        index_point <- grep("\\.", file_as_vec)[index_ext]

        if (ext == TRUE){

                rtnl <- paste(file_as_vec[index_point:length(file_as_vec)], collapse="")

                return(rtnl)

        }else{

                rtnl <- paste(file_as_vec[1:(index_point-1)], collapse="")

                return(rtnl)

        }

}

#' see_inside
#'
#' Return a list containing all the column of the files in the current directory with a chosen file extension and its associated file and sheet if xlsx. For example if i have 2 files "out.csv" with 2 columns and "out.xlsx" with 1 column for its first sheet and 2 for its second one, the return will look like this: c(column_1, column_2, column_3, column_4, column_5, unique_separator, "1-2-out.csv", "3-3-sheet_1-out.xlsx", 4-5-sheet_2-out.xlsx)
#' @param pattern_ is a vector containin the file extension of the spreadsheets ("xlsx", "csv"...)
#' @param path_ is the path where are located the files
#' @param sep_ is a vector containing the separator for each csv type file in order following the operating system file order, if the vector does not match the number of the csv files found, it will assume the separator for the rest of the files is the same as the last csv file found. It means that if you know the separator is the same for all the csv type files, you just have to put the separator once in the vector.
#' @param unique_sep is a pattern that you know will never be in your input files
#' @param rec is a boolean allows to get files recursively if set to TRUE, defaults to TRUE 
#' If x is the return value, to see all the files name, position of the columns and possible sheet name associanted with, do the following: 
#' @export

see_inside <- function(pattern_, path_=".", sep_=c(","), unique_sep="#####", rec=FALSE){

        x <- c()

        for (i in 1:length(pattern_)){ 

                x <- append(x, list.files(path=path_, pattern=pattern_[i], recursive=rec))

        }

        rtnl <- list()

        rtnl2 <- c()

        sep_idx = 1
        
        for (i in 1:length(x)){

                file_as_vec <- unlist(str_split(x[i], ""))

                index_point <- grep("\\.", file_as_vec)[1]

                ext <- paste(file_as_vec[index_point:length(file_as_vec)], collapse="")

                if (ext == ".xlsx"){

                        allname <- getSheetNames(x[i]) 

                        for (t in 1:length(allname)){
                          
                                datf <- data.frame(read.xlsx(x[i], sheet=allname[t]))

                                rtnl <- append(rtnl, datf)

                                rtnl2 <- append(rtnl2, paste((length(rtnl)+1) , (length(rtnl)+ncol(datf)), x[i], allname[t], sep="-"))

                        }

                }else{
                  
                        datf <- data.frame(read.table(x[i], fill=TRUE, sep=sep_[sep_idx]))

                        rtnl <- append(rtnl, datf)

                        rtnl2 <- append(rtnl2, paste((length(rtnl)+1) , (length(rtnl)+ncol(datf)), x[i], sep="-"))

                        sep_idx = sep_idx + 1

                        if (sep_idx > length(sep_)){

                                sep_ <- append(sep_, sep_[length(sep_)])

                        }

                }

        }

        return(c(rtnl, unique_sep, rtnl2))

}

#' fold_rec2 
#' 
#' Allow to find the directories and the subdirectories with a specified end and start depth value from a path. This function might be more powerfull than file_rec because it uses a custom algorythm that does not nee to perform a full recursive search before tuning it to only find the directories with a good value of depth. Depth example: if i have dir/dir2/dir3, dir/dir2b/dir3b, i have a depth equal to 3
#' @param xmax is the depth value
#' @param xmin is the minimum value of depth
#' @param pathc is the reference path, from which depth value is equal to 1
#' @export

fold_rec2 <- function(xmax, xmin=1, pathc="."){

        pathc2 <- pathc

        ref <- list.dirs(pathc, recursive=FALSE)

        exclude_temp <- c()

        print(exclude_temp)

        exclude_f <- c("#")

        while (sum(exclude_f == ref) < length(ref)){

                if (length(grep("#", exclude_f)) > 0){

                        exclude_f <- c()

                }

                t = 1

                alf <- c("##")

                while (t <= xmax & length(alf) > 0){

                        alf <- list.dirs(pathc, recursive=FALSE)

                        exclude_idx <- c()

                        if (length(exclude_temp) > 0){

                                for (i in 1:length(exclude_temp)){  

                                        in_t <- match(TRUE, exclude_temp[i] == alf)

                                        if (is.na(in_t) == FALSE){

                                                exclude_idx <- append(exclude_idx, in_t)

                                        }

                                } 

                        }

                        if (length(exclude_idx) > 0){ alf <- alf[-exclude_idx] }

                        if (length(alf) > 0 & t < xmax){

                                pathc <- alf[1]

                        }

                        t = t + 1

                }

                exclude_temp <- append(exclude_temp, pathc)

                ret_pathc <- pathc

                pathc <- paste(unlist(str_split(pathc, "/"))[1:str_count(pathc, "/")], collapse="/")

                if (pathc == pathc2){ exclude_f <- append(exclude_f, ret_pathc) }
                
        }

        ret <- grep(TRUE, (str_count(exclude_temp, "/") < xmin))

        if (length(ret) > 0){

                return(exclude_temp[-ret])

        }else{

                return(exclude_temp)

        }

}

#' fold_rec
#'
#' Allow to get all the files recursively from a path according to an end and start depth value. If you want to have an other version of this function that uses a more sophisticated algorythm (which can be faster), check file_rec2. Depth example: if i have dir/dir2/dir3, dir/dir2b/dir3b, i have a depth equal to 3
#' @param xmax is the end depth value
#' @param xmin is the start depth value
#' @param pathc is the reference path 
#' @export

fold_rec <- function(xmax, xmin=1, pathc="."){

        vec <- list.dirs(pathc, recursive=TRUE)

        rtnl <- c()

        print(vec)

        for (i in 1:length(vec)){

                if (str_count(vec[i], "/") <= xmax & str_count(vec[i], "/") >= xmin){

                        rtnl <- append(rtnl, vec[i])

                }

        }

        return(rtnl)

}

#' get_rec 
#'
#' Allow to get the value of directorie depth from a path.
#'
#' @param pathc is the reference path
#' example: if i have dir/dir2/dir3, dir/dir2b/dir3b, i have a depth equal to 3
#' @export

get_rec <- function(pathc="."){

        vec <- list.dirs(pathc, recursive=TRUE)

        rtnl <- c()

        for (i in 1:length(vec)){

                rtnl <- append(rtnl, str_count(vec[i], "/"))

        }

        return(max(rtnl))

}

#' list_files
#' 
#' A list.files() based function addressing the need of listing the files with extension a or or extension b ...
#'
#' @param pathc is the path, can be a vector of multiple path because list.files() supports it.
#' @param patternc is a vector containing all the exensions you want
#' @export

list_files <- function(patternc, pathc="."){

       rtnl <- c()

       for (i in 1:length(patternc)){

               rtnl <- append(rtnl, list.files(path=pathc, pattern=patternc[i]))

       }

       return(sort(rtnl))

}

