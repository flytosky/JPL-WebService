<?php require_once("./header.php") ?>

<h1>
Parallel Web Services for Data Preparation and Data Analysis
</h1>
<h3>
Summer School 2014, JPL Center for Climate Sciences
</h3>

<br />

<img src="http://climatesciences.jpl.nasa.gov/system/pages/images/16/medium/8703587212_446f000243_z.jpg" alt="NASA Earth missions, 2013" >

<ol>

<li>
Introduction 
<p>
Parallel Web-Service Climate Model Diagnostic Analyzer provides web services for multi-aspect physics-based and phenomenon-oriented climate model performance evaluation and diagnosis through the comprehensive and synergistic use of multiple observational data, reanalysis data, and model outputs. It is based on parallel Python and distributed web service technologies.
</p>
</li>

<li>
Summary of analysis tools in service 

<p>
Web-based analysis tools let users display, analyze, and download earth science data interactively. The source data files are required to conform to the Coupled Model Inter-comparison Project Phase 5 (CMIP5) data format (<a href="http://cmip-pcmdi.llnl.gov/cmip5/output_req.html">http://cmip-pcmdi.llnl.gov/cmip5/output_req.html</a>) so that output data from CMIP5 models and NASA observational data published via Obs4MIPS project can be directly used by our services. Our tools help scientists quickly examine data to identify specific features, e.g. trends, geographical distributions, etc., and determine whether a further study is needed. All of the tools are designed and implemented to be general so that data from models, observation, and reanalysis are processed and displayed in a unified way to facilitate fair comparisons. The services prepare and display data as a colored map or an X-Y plot and allow users to download these data. Basic visual capabilities include 1) displaying two-dimensional variable as a map, zonal mean, and time series 2) displaying three-dimensional variable’s zonal mean, a two-dimensional slice at a specific altitude, and a vertical profile. General analysis can be done using the difference, scatter plot, and conditional sampling services. All the tools support display options for using linear or logarithmic scales and allow users to specify a temporal range and months in a year.
</p>
</li>

<li>
Service descriptions 
<ol type="a">
<li>
Two dimensional variable services
<ol type="i">
<li>
Map of two-dimensional variable
This services displays a two dimensional variable as a colored longitude and latitude map with values represented by a color scheme. Longitude and latitude ranges can be specified to magnify a specific region.
</li>
<li>
Two dimensional variable zonal mean
This service plots the zonal mean value of a two-dimensional variable as a function of the latitude in terms of an X-Y plot.
</li>
<li>
Two dimensional variable time series
This service displays the average of a two-dimensional variable over the specific region as function of time as an X-Y plot. 
</li>
</ol>
</li>
<li>
Three dimensional variable services
<ol type="i">
<li>
Map of a two dimensional slice 
This service displays a two-dimensional slice of a three-dimensional variable at a specific altitude as a colored longitude and latitude map with values represented by a color scheme.
</li>
<li>
Zonal mean
Zonal mean of the specified three-dimensional variable is computed and displayed as a colored altitude-latitude map.
</li>
<li>
Vertical profile
Compute the area weighted average of a three-dimensional variable over the specified region and display the average as function of pressure level (altitude) as an X-Y plot.
</li>
</ol>
<li>
General services
<ol type="i">
<li>
Difference of two variables
Display the differences between the two variables, which can be either a two dimensional variable or a slice of a three-dimensional variable at a specified altitude as colored longitude and latitude maps
</li>
<li>
Scatter plots of two variables
This services display the scatter plot (X-Y plot) between two specified variables. The number of samples can be specified and the correlation is computed. The two variables can be either a two-dimensional variable or a slice of a three-dimensional variable at a specific altitude.
</li>
<li>
Conditional sampling
This service lets user to sort a physical quantity of two or dimensions according to the values of another variable (environmental condition, e.g. SST) which may be a two-dimensional variable or a slice of a three-dimensional variable at a specific altitude. For a two dimensional quantity, the plot is displayed an X-Y plot, and for a two-dimensional quantity, plot is displayed as a colored-map.
</li>
</ol>
</li>
</ol>

</li>

<li>
Tips for using these tools
<ul>
<li>
The tools are designed so that seasonal variations can be studies by selecting specific months. 
</li>
<li>
To study climatology, a longer temporal range should be used to average out some short-term variations. 
</li>
<li>
Service automatically checks data availability. It can be used to find available temporal range. 
</li>
<li>
When data range exceeds what is available, only the available data range will be used. Pay attention to the actually data range used.
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
Difference plots is useful for comparisons between models, observations, and reanalysis.
</li>
<li>
Use the sophisticated conditional sampling tools to examine data relation in physical variable space. It is crucial to use an appropriate set of bin boundaries to achieve meaningful results. 
</li>
<li>
Logarithmic scale can be very useful for examine data that has large range. 
</li>
<li>
NaN is displayed as “white” color for positive semi-definite quantities and “black” for data with both positive and negative values.
</li>
<li>
Download data for future usage.
</li>
</ul>

</li>


<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/twoDimMap.html">2D Variable Map Service</a>.
</p>
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/twoDimZonalMean.html">2D Variable Zonal Mean Service</a>.
</p>
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/twoDimTimeSeries.html">2D Variable Time Series Service</a>.
</p>
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/twoDimSlice3D.html">3D Variable 2D Slice Service</a>.
</p>
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/threeDimZonalMean.html">3D Variable Zonal Mean Service</a>.
</p>
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/threeDimVarVertical.html">3D Variable Average Vertical Profile Service</a>.
</p>
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/scatterPlot2Vars.html">Scatter Plot of Two Variables Service</a>.
</p>
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/diffPlot2Vars.html">Difference Plot of Two Variables Service</a>.
</p>
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/conditionalSampling.html">Conditional Sampling Service</a>.
</p>
<ol>

<?php require_once("./footer.php") ?>
