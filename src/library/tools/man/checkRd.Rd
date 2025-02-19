% File src/library/tools/man/checkRd.Rd
% Part of the R package, https://www.R-project.org
% Copyright 2008-2023 R Core Team
% Distributed under GPL 2 or later

\name{checkRd}
\alias{checkRd}
\title{ Check an Rd Object }
\description{
  Check an help file or the output of the \code{\link{parse_Rd}} function.
}
\usage{
checkRd(Rd, defines = .Platform$OS.type, stages = "render",
        unknownOK = TRUE, listOK = TRUE, ..., def_enc = FALSE)
}
\arguments{
  \item{Rd}{ a filename or \code{Rd} object to use as input. }
  \item{defines}{ string(s) to use in \verb{#ifdef} tests. }
  \item{stages}{ at which stage (\code{"build"}, \code{"install"}, or
    \code{"render"}) should \verb{\Sexpr} macros be executed? See the
    notes below.}
  \item{unknownOK}{ unrecognized macros are treated as errors if
    \code{FALSE}, otherwise warnings. }
  \item{listOK}{ unnecessary non-empty braces (e.g., around text, not as
    an argument) are treated as errors if \code{FALSE}, otherwise
    warnings (\dQuote{Lost braces}).}
  \item{\dots}{ additional parameters to pass to \code{\link{parse_Rd}} when
    \code{Rd} is a filename.  One that is often useful is \code{encoding}.}
  \item{def_enc}{logical: has the package declared an encoding, so tests
    for non-ASCII text are suppressed?}
}
\details{
  \code{checkRd} performs consistency checks on an Rd file, confirming that
  required sections are present, etc.

  It accepts a filename for an Rd file, and will use
  \code{\link{parse_Rd}} to parse it before applying the checks.  If so,
  warnings from \code{parse_Rd} are collected, together with those from
  the internal function \code{prepare_Rd}, which does the
  \verb{#ifdef} and \verb{\Sexpr} processing, drops sections that
  would not be rendered or are duplicated (and should not be) and
  removes empty sections.

  An Rd object is passed through \code{prepare_Rd}, but it may already
  have been (and installed Rd objects have).

  Warnings are given a \sQuote{level}: those from \code{prepare_Rd} have
  level 0.  These include
  \tabular{l}{
    \verb{\Sexpr} expects R code; found \ldots\cr
    Unprocessed \sQuote{\var{stage}} macro from \var{stage}-stage \verb{\Sexpr}\cr
    All text must be in a section\cr
    Only one \var{tag name} section is allowed: the first will be used\cr
    docType \var{type} is unrecognized\cr
    Section \var{name} is unrecognized and will be dropped\cr
    Dropping empty section \var{name}\cr
  }
  \code{checkRd} itself can show
  \tabular{rl}{
    7 \tab Tag \var{tag name} not recognized\cr
    7 \tab Unrecognized format: \ldots\cr
    7 \tab \verb{\tabular} format must be simple text\cr
    7 \tab Unrecognized \verb{\tabular} format: \ldots\cr
    7 \tab Only \var{n} columns allowed in this table\cr
    7 \tab Tag \var{tag name} is invalid in a \var{block name} block\cr
    7 \tab \verb{\method} not valid outside a code block\cr
    7 \tab Tag \verb{\method} is only valid in \verb{\usage}\cr
    7 \tab Tag \verb{\dontrun} is only valid in \verb{\examples}\cr
    7 \tab Invalid email address: \ldots\cr
    7 \tab Invalid URL: \ldots\cr
    5 \tab \verb{\name} should not contain !, | or @\cr
    5 \tab \verb{\item} in \var{block name} must have non-empty label\cr
    3 \tab Empty section \var{tag name}\cr
    -1 \tab \verb{\name} should only contain printable ASCII characters\cr
    -1 \tab Non-ASCII contents without declared encoding\cr
    -1 \tab Non-ASCII contents in second part of \verb{\enc}\cr
    -1 \tab Escaped LaTeX specials: \ldots\cr
 -1|-3 \tab Lost braces \dots\cr
    -3 \tab Tag \verb{\ldots} is invalid in a code block\cr
    -5 \tab \verb{\title} should not end in a period\cr
  }
  and variations with \verb{\method} replaced by \verb{\S3method} or
  \verb{\S4method}, \verb{\dontrun} replaced by \verb{\donttest} or
  \verb{\dontshow}, and \verb{\title} replaced by \verb{\section} or
  \verb{\subsection} name.
  (Some instances of \dQuote{Lost braces} are uprated to level -1,
  currently only during \command{R CMD check} with option
  \option{--as-cran}.)
  %or if environment variable \env{_R_CHECK_RD_NOTE_LOST_BRACES_}
  %is set to a true value.

  Note that both \code{prepare_Rd} and \code{checkRd} have tests for an
  empty section: that in \code{checkRd} is stricter (essentially that
  nothing is output).
}
\value{
  This may fail through an \R error, but otherwise warnings are
  collected as returned as an object of class \code{"checkRd"}, a
  character vector of messages.  This class has a \code{print} method
  which only prints unique messages, and has argument \code{minlevel}
  that can be used to select only more serious messages.  (This is set
  to \code{-1} in \command{R CMD check}.)

  Possible fatal errors are those
  from \code{!unknownOK} or \code{!listOK},
  from invalid \verb{\if} or \verb{\ifelse} conditions,
  %or non-VERB (e.g., COMMENT) parsed input for \verb{\out} or
  %\verb{\href} (first argument),
  from running the parser (e.g., a
  non-existent file, unclosed quoted string, non-ASCII input without a
  specified encoding, an invalid value for an \verb{\Sexpr} option),
  or from \code{prepare_Rd} (multiple
  \verb{\Rdversion} declarations, invalid \verb{\encoding} or
  \verb{\docType} or \verb{\name} sections, and missing or duplicate
  \verb{\name} or \verb{\title} sections),
  including errors from parsing/running code from \verb{\Sexpr} macros
  (if covered by \code{stages}).
}
\author{
  Duncan Murdoch, Brian Ripley
}
\seealso{
  \code{\link{parse_Rd}}, \code{\link{Rd2HTML}}.
}
\examples{
## parsed Rd from the installed version of _this_ help file
rd <- Rd_db("tools")[["checkRd.Rd"]]
\donttest{rd}% avoid reference output
stopifnot(length(checkRd(rd)) == 0)  # there should be no issues

## make up \\tabular issues
bad <- r"(\name{bad}\title{bad}\description{\tabular{p}{1 \tab 2}})"
(res <- checkRd(parse_Rd(textConnection(bad))))
stopifnot(length(res) > 0)
}
\keyword{utilities}
\keyword{documentation}
