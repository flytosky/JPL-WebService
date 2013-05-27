<?php require_once("./header.php") ?>

<h1>
Parallel Web Services for Data Preparation and Data Analysis
</h1>
<h3>
A NASA CMAC funded project
</h3>

<p>
This web portal provides a user access to a scientific system that we developed for the NASA CMAC (Computational Modeling Algorithms and Cyberinfrastructure) project. The scientific system enables multi-aspect physics-based and phenomenon-oriented model performance evaluations and diagnoses through the comprehensive and synergistic use of multiple observational data, reanalysis data, and model outputs.  The system streamlined and structured long and complex steps involved in processing multi-source heterogeneous datasets, and enhanced the computational efficiency and data-volume handling capacity for the large-volume data analysis problem. We developed a parallel, distributed web-service oriented system to achieve this goal. The developed system provides the following key capabilities:
</p>

<ol>
<li>
<i>Parallel web-service data preparation of observation data and model outputs for model-data intercomparisons</i>, supporting the following operations:
</li>

<ul>
<li>
Change data format (e.g. change a HDF file to a NetCDF file).
</li>
<li>
Subset data conditionally by time, space, and variable (e.g. select tropical summer water vapor data).
</li>
<li>
Concatenate data from multiple files (e.g. collect precipitation rate from year 2000 to 2005).
</li>
<li>
Change horizontal and vertical coordinates (e.g. change height to pressure level).
</li>
<li>
Average and regrid the temporal and spatial resolution (e.g. monthly 1x1 degree averaged values).
</li>
<li>
Co-locate and interpolate multi-source outputs to match time and locations (e.g. co-locate MODIS footprint data with CloudSat footprint data).
</li>
<li>
Convert variable units (e.g. convert cloud water content from the density unit (mg/m3) to the mass fraction unit (mg/kg)).
</li>
<li>
Check data format.
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="http://cmacws.jpl.nasa.gov:8083/">CMIP5 Checker Service</a>.
</p>
<p>
<small>
<a href="http://cmacws.jpl.nasa.gov:8080/cmac/obs4MIPs_Dataset_Requirements_v1.pdf">obs4MIPs Dataset Requirements</a>.
</small>
</p>
<p>
<small>
<a href="http://cmacws.jpl.nasa.gov:8080/cmac/obs4MIPs_Global_Attributes_Requirements.pdf">obs4MIPs Global Attributes Requirements</a>.
</small>
</p>
</li>
<li>
Format data.
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="http://cmacws.jpl.nasa.gov:8081/">CMIP5 Formatter Service</a>.
</p>
</li>
</ul>

<li>
<i>Parallel web-service data analysis for model performance evaluation and diagnosis</i>, supporting the following operations:
</li>

<ul>
<li>
Apply mathematical operations (e.g. apply algebraic, logical, and calculus operations).
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/twoDimMap.html">2D Variable Map Service</a>.
</p>
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/twoDimTimeSeries.html">2D Variable Time Series Service</a>.
</p>
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/scatterPlot2Vars.html">Scatter Plot of Two Variables Service</a>.
</p>
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/twoDimZonalMean.html">2D Variable Zonal Mean Service</a>.
</p>
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/threeDimZonalMean.html">3D Variable Zonal Mean Service</a>.
</p>
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/threeDimVarAverage.html">3D Variable Average Profile Service</a>.
</p>
<p>
<img src="images/service.jpeg" alt="service" height="60" width="60">
<a href="/cmac/web/threeDimVarSliceMap.html">3D Variable Slice Map Service</a>.
</p>
</li>
<li>
Apply statistical operations (e.g. calculate standard deviation and correlation).
</li>
<li>
Assess probability density function  (PDF) distributions of the data (e.g. estimate the PDF of total water content in the stratocumulus regions).
</li>
<li>
Analyze cluster distributions of the data (e.g. identify the number of clusters for the cloud classifications or scene classifications).
</li>
<li>
Sampling multi-variables conditionally based on phenomena and physics (e.g. select cloud water content data in non-convective and non-precipitation conditions).
</li>
<li>
Sort data by a given variable condition (e.g. sort cloud water path data in order of precipitation rate). 
</li>
</ul>

</ol>

<?php require_once("./footer.php") ?>
