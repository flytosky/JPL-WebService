<?php require_once("./header.php") ?>

<h1>
Climate Model Diagnostic Analyzer
</h1>
<h4>
2015 JPL Center for Climate Sciences Summer School: 
Using Satellite Observations to Advance Climate Models
</h4>

<br />

<img src="images/satellite.jpg" alt="NASA Earth missions" height="290" width="400" />
<img src="images/cm.jpg" alt="Climate Model" height="290" width="400" />

<ol>

<h3><li>Introduction</h3>
<p>
Climate Model Diagnostic Analyzer (CMDA) is a repository of web services for 
multi-aspect physics-based and phenomenon-oriented climate model performance evaluation and diagnosis 
through the comprehensive and synergistic use of multiple observational data, reanalysis data, and model outputs. 
This repository is specially customized to support the 2015 JPL Center for Climate Sciences Summer School.
The theme of the summer school is Using Satellite Observations to Advance Climate Models.
This repository provides datasets and analysis tools for the students to use for their group research projects. 
</p>
<p>
These web services let users display, analyze, and download Earth science data interactively. 
These tools help scientists quickly examine data to identify specific features, e.g. trends, geographical distributions, etc., 
and determine whether a further study is needed. All of the tools are designed and implemented to be general 
so that data from models, observation, and reanalysis are processed and displayed in a unified way to facilitate 
fair comparisons. The services prepare and display analyzed data, and allow users to download the analyzed output data at the end. 

</p>
</li>

<h3><li>CMDA Service Descriptions</h3> 
<ol type="a">
<h4><li> Two-dimensional variable services</h4>
<ul>
<li>
Map:
This services displays a two dimensional variable as a colored longitude and latitude map with values represented by a color scheme. Longitude and latitude ranges can be specified to magnify a specific region.
</li>
<li>
Zonal mean:
This service plots the zonal mean value of a two-dimensional variable as a function of the latitude in terms of an X-Y plot.
</li>
<li> 
Time series:
This service displays the average of a two-dimensional variable over the specific region as function of time as an X-Y plot. 
</li>
</ul>
</li>
<h4><li> Three-dimensional variable services</h4>
<ul>
<li>
Map of a two dimensional slice: 
This service displays a two-dimensional slice of a three-dimensional variable at a specific altitude as a colored longitude and latitude map with values represented by a color scheme.
</li>
<li>
Zonal mean:
This service computes and displays the zonal mean of the specified three-dimensional variable as a colored altitude-latitude map.
</li>
<li>
Vertical profile:
This service computes the area weighted average of a three-dimensional variable over the specified region and display the average as function of pressure level (altitude) as an X-Y plot.
</li>
</ul>
<h4><li> Multivariable diagnostic services</h4>
<ul>
<li>
Difference of two variables:
This service displays the differences between the two variables, which can be either a two dimensional variable or a slice of a three-dimensional variable at a specified altitude as colored longitude and latitude maps
</li>
<li>
Scatter and histogram plots of two variables:
This service displays the scatter plot (X-Y plot) between two specified variables and the histograms of the two variables. The number of samples can be specified and the correlation is computed. The two variables can be either a two-dimensional variable or a slice of a three-dimensional variable at a specific altitude.
</li>
<li>
Conditional sampling with one variable:
This service lets user to sort a physical quantity of two or dimensions according to the values of another variable (environmental condition, e.g. SST) which may be a two-dimensional variable or a slice of a three-dimensional variable at a specific altitude. For a two dimensional quantity, the plot is displayed an X-Y plot, and for a two-dimensional quantity, plot is displayed as a colored-map.
</li>
<li>
Conditional sampling with two variables:
This service sorts one variable called sampled variable by the values of two variables called sampling variables and displays the averaged value of the sampled variable in color as a function of the bin value of the two sampling variables in X-Y axis. There are overlaid contours which show the number of samples in each of the two sampling variable bin.
</li>
<li>
Time-lagged correlation map:
This service generates a time-lagged correlation map between two specified variables. The two variables can be either a two-dimensional variable or a slice of a three-dimensional variable at a specific pressure level.
</li>
<li>
Regrid and download:
This service regrids a variable from a dataset according to the lat/lon/plev specified by the user, and mades the regridded data downloadable by the user. 
</li>
<li>
Dataset search:
This service searches datasets available in the server with models/instruments and variables as search criteria. The datasets found to meet the search criteria are displayed with its time coverage, variable long name and variable units. 
</li>
</ul>
</li>
</ol>

</li>

<h3><li>Tips for using CMDA Services</h3>
<ul>
<li>
To study climatology, a longer temporal range should be used to average out some short-term variations. 
</li>
<li>
Service automatically checks data availability. It can be used to find available temporal range. 
</li>
<li>
When a requiested data time range exceeds what is available, only the available data time range will be used. Pay attention to the actual data time range used.
</li>
<li>
The tools are designed so that seasonal variations can be studies by selecting specific months. 
</li>
<li>
Use maps to find spatial variations. Choose a longitude/latitude range to specify a region
</li>
<li>
Use zonal mean to study meridional variations and transportation.
</li>
<li>
Use time series to look for temporal variations and trends.
</li>
<li>
Use scatter plot to study the relationship between physical quantities.  The number of sample option allows one to smooth the data.
</li>
<li>
Use histogram plot to study the probability density distributions of physical quantities. 
</li>
<li>
Use difference plot to compare between models, observations, and reanalysis.
</li>
<li>
Use the sophisticated conditional sampling tools to examine data relation in physical variable space. It is crucial to use an appropriate set of bin boundaries to achieve meaningful results. 
</li>
<li>
Logarithmic scale can be very useful for examine data that has a large range. 
</li>
<li>
NaN is displayed as “white” color for positive semi-definite quantities and “black” for data with both positive and negative values.
</li>
<li>
Download analyzed data for future usage.
</li>
</ul>

</li>

<h3><li>Datasets supported by CMDA</h3>
<ul>
<li> CMDA provides observational datasets, reanalysis datasets, and climate model outputs.
<li> Model outputs are obtained from the Coupled Model Intercomparison Project Phase 5 (CMIP5) project. The model datasets conform to the requirements of CMIP5 data standard. 
<li> Most of our observational data are provided by the NASA/Obs4MIPs project, where the observational data sets are published on the Earth System Grid Federation (http://esg-datanode.jpl.nasa.gov) using the same format as the CMIP5 model data sets to facilitate a direct comparison between the observation and model. 
<li> Reanalysis data are obtained from ECMWF and are prepared by applying an editing script to the original reanalysis data downloaded from ECMWF to meet a few basic CMIP5 requirements. 
<li> The CMDA analysis tools treat the datasets uniformly among model outputs, observational data and reanalysis data to facilitate a fair comparison.
</ul>
</li>

<h3> <li><a href="./cmda_services.php">CMDA Analytics Services</a></li>
</h3>

<h3> <li><a href="./group_research_topics.php">Group Research Topics</a></li>
</h3>

<?php require_once("./footer.php") ?>
