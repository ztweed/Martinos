Zachary Tweed
June 2016
Reference dicument for my code

In this document, I will attempt to explain the purpose and usage of the code I have written for processing and analyzing Sava's data. I tried to comment the scripts and functions as best I could, but hopefully this will fill in any gaps. If any further questions arise, feel free to contact me at tweed.z@husky.neu.edu or ztweed@gmail.com. 

All files can be found in the following directory:
autofs/cluster/MOD/OCTOPuS/zachary/Processing

Note: I spent a significant amount of time working to generate a denser mesh, and subsequently, run Louis' simulation on this mesh to improve the quality of our data. The results can be found in the simResultsZach folder. Within this folder, the folder simNoMap contains results when the simulation was run from scratch on the dense mesh I generated. The folder simWithMap contains the results achieved when a function was utilized to map po2 and oxygenation data from our old, sparse mesh onto the new, denser one. See 5) below for more details.

I will discuss the following files:
1)  simSetup.m
2)  Generate_Mesh_ROI_20110408.m
3)  advection_SS_20110408_ZT.m
4)  sim_VANfem_Run_LG_reversal_OC_output_IN_PROGRESS_ZT.m
5)  po2Map2Closest.m
6)  po2Countour.m
7)  dist2vessel.m
8)  pO2VascDist.m
9)  krogh.m
10) pO2vDist.m


1) simSetup.m
This useful function loads in relevant po2 data and mesh files and performs most of the preprocessing necessary to use subsequent scripts (it is the first line of code 
in many cases). By default, it works on the orignal 18 second simulations we had, but can be modified if necessary. Simply provide the mouse ID (a date, such as 20110408), the cmro2 and depth constraints and the function will load the appropriate files, gather po2 and vasculature from the specified depth range, and plot them, both individually and overlaid. All important variables are saved to the workspace for easy access. Optional pair-value arguments include plane (xy, yz or xz...but xy is by far the most useful) and threshold (represents the vascular intensity threshold so that only values above the threshold are used...default is 15 (out of 32)). See 'help simSetup' for more info.


2) Generate_Mesh_ROI_20110408.m
This is the first of a few functions I used that were written by Louis Gagnon, formerly of the Martinos Center. This script generates the PO2 meshes we used in our analysis. Specifically, I used it to generate a denser mesh to improve our analyses. Other than setting my own parameters (lines 54-56), I didn't edit the code at all. It may be tempting to modify the ROI parameters at the start of the script in order to save computing time, but I was only able to get it to work when the full (as is) ROI was used. Not exactly sure why, though. The full process, including simulation, is time-consuming, but it works.


3) advection_SS_20110408_ZT.m
Written by Louis, this is the main function in charge of the CBF simulations we use for analysis. The code is a bit difficult to follow, but I tried to comment where I could. It sets several experimental parameters before sending the operation to a helper function (see item 4). The only changes I made were to utilize po2 values from previous simulations to map to the points from the newly generated, denser mesh. This can be found in lines 99 through 105. Utilizing this mapping seems to allow po2 to settle faster, thus reducing the necessary duration of the simulation.


4) sim_VANfem_Run_LG_reversal_OC_output_IN_PROGRESS_ZT.m
Again written by Louis, this helper function utilizes the finite element method to solve for O2 diffusion and advection in the simulation. This code was untouched by me.


5) po2Map2Closest.m
Given two meshes and po2 data, this function maps the po2 (c variable) and oxygenation (cg and cbg variables) data from the first mesh onto the second. For each new mesh node, po2 values are simply mapped to the new node from the nearest node to it in the old mesh. Two meshes should be input, as well as a simulation result file (i.e.: 20110408_PC_SS_OC_2.0_8000ms.mat)


6) po2Countour.m
A relatively straightforward script, this allows you to visualize po2 maps for several different cmro2 values in the same mouse. The same can be accomplished with multiple runs of simSetup, but this does it all in one shot.


7) dist2vessel.m
This script calculates the distance to the closest large arteriole (>= 15 um in diameter) for each tissue node in the manually-selected ROI. Each node's distance is then plotted against its po2 value. Then, we create a linear fit to observe the slope for all nodes within 15 um of a large arteriole. The idea is that we can perform this for several cmro2 values and compare them after (see compareSlopes.m for this), and use it a reletive metric to estimate cmro2 if cmro2 is unknown. The ROI chosen should include most of the plotted arteriolar nodes, but should be fairly small compared to the full field of view. To compare, it is important that the ROI is the same across all cmro2 values, so it may be handy to comment lines 102-108 for this.


8) pO2VascDist.m
Here, we create a fit to Krogh's equation (see item 9) based on po2 v. distance from a diving arteriole to estimate cmro2. A triangular ROI is manually selected. The first point should be at the center of a diving arteriole, and the next two create the legs of a triangle, and all points inside this triangle are used for analysis. CMRO2 and tissue radius (see the Krogh model) are represented by the output variables m0 and rt, respectively. The fitting is a rather fickle mechanism, so sometimes you'll get results that are spot on, and sometimes they'll make no sense at all. But after working with it for a bit, you'll get a sense of what tends to work well and what doesn't. 


9) krogh.m
This is the helper function that creates the fit to Krogh's equation using a custom fit. The constants d and alpha (diffusivity and solubility) foudn in the code are my best guess at these values, and there could be discrepancy. Overall, it tends to work well with pO2VascDist.m. Typing 'help krogh' would be quite informative, as well.


10) pO2vDist.m
Plots po2 against distance from the center of a diving arteriole, which is manually selected. The operation is performed on all tissue nodes instead of restricting it to an ROI.
