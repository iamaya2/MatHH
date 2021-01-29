# MatHH: A Matlab-based Hyper-Heuristic framework
---
This repository contains a description of `MatHH`, a framework developed in Matlab for coding and testing hyper-heuristics.

## Required packages
In order to properly use `MatHH`, the following packages are required:

- `Utils`: a set of diverse utility functions to better organize the code; available at: [Github](https://github.com/iamaya2/Utils)
- *Problem domains:* different packages can be developed/used for providing domain-specific capabilities. So far, the following packages have been tested:
   - `JSSP-Matlab-OOP`: an object-oriented class for handling Job-Shop scheduling problems; available at: [Github](https://github.com/iamaya2/JSSP-Matlab-OOP)

### File organization
Seeking to facilitate the maintenance of the required packages, the root folder of each package should be located at the same level. Hence, the following structure is suggested:

```
\JSSP-Matlab-OOP
\MatHH
   \src
\Utils
   \distance
   ...
```   
   
***Note**: remember you can use `addpath(genpath(pathString))` for temporarily adding these packages to Matlab's search path, so that you can put your codes in different folders.*
