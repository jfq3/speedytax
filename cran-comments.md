## Third resubmission (version 1.0.3)

Thank you for the suggested changes. I explain my implementation of each below. I changed the version to 1.0.3 to reflect the changes I made.

1. Responding to: Please always write package names, software names and API (application programming interface) names in single quotes in title and description.
e.g: --> 'phyloseq', ...
Please note that package names are case sensitive.

I made the following changes:
   All instances of phyloseq or Phyloseq to 'phyloseq'
   RDP Classifier to 'RDP Classifier'
   vsearch sintax to 'vsearch sintax'
   QIIME2 to 'QIIME2'
   Added 'USEARCH sintax'
   Added decfinitions of the acronyms QIIME and RDP.
   I have also added references to the programs within each function, providing more details for the user.

Responding to: Please add \value to .Rd files regarding exported methods and explain the functions results in the documentation. 

Done.

Responding to: \dontrun{} should only be used if the example really cannot be executed (e.g. because of missing additional software, missing API keys, ...) by the user. That's why wrapping examples in \dontrun{} adds the comment ("# Not run:") as a warning for the user. Does not seem necessary. 
Please replace \dontrun with \donttest.

I agree that \dontrun{} is not necessary and I have removed all instances of \dontrun{}. All of the examples do work using system.file() to access the necessary input.

Responding to: Please add small files needed for the examples or vignette in the inst/extdata subfolder of your package and use system.file() to get the correct package path.

The example files were and are in inst/extdata; Per your request, I now use system.file to access them for the examples within each function Rd file. Using system.file made lines in the manual too long, so I had to shorten the file names.
I retained the function read_tax_example() (which I previoulsy used to access the files in the examples) because I could not build  the README.md file without it. Retaining it will also allow users who follow the README to recreate the example in README. This function is now properly documented.

## Second Resubmission (version 1.0.2)

1. In this resubmission I have addressed the note regarding "License stub records with missing/empty fields" I have changed Year to YEAR in the LICENSE file.

2. I changed the version number from 1.0.1 to 1.0.2 to reflect this change.

I believe the one remaining note CRAN generates is because this is a new submission.

## First Resubmission

This is a resubmission. In this version I have:

1. To address the note, I edited the LICENSE file to include only two lines, the first for the year, and the second for the copyright holder. I also included a LICENSE.md file with the text of the license, but this is listed in .Rbuildignore.

2. To address the warning, I changed the bitwise OR operator | to the logical OR operator || in fix_qiime2_domain_C.cpp.

3. Changed the version from 1.0.0 to 1.0.1 to reflect these changes.

## R CMD check results (new submission)

0 errors | 0 warnings | 1 note

