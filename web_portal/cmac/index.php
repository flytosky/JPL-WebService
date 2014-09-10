<?php require_once("./header.php") ?>

<h1>
Parallel Web Services for Data Preparation and Data Analysis
</h1>
<h3>
Summer School 2014, JPL Center for Climate Sciences
</h3>

<br />

<img src="http://climatesciences.jpl.nasa.gov/system/pages/images/16/medium/8703587212_446f000243_z.jpg" alt="NASA Earth missions, 2013" >

<p>
This web portal provides a user access to a scientific system that we developed for the NASA CMAC (Computational Modeling Algorithms and Cyberinfrastructure) project. The scientific system enables multi-aspect physics-based and phenomenon-oriented model performance evaluations and diagnoses through the comprehensive and synergistic use of multiple observational data, reanalysis data, and model outputs.  The system streamlined and structured long and complex steps involved in processing multi-source heterogeneous datasets, and enhanced the computational efficiency and data-volume handling capacity for the large-volume data analysis problem. We developed a parallel, distributed web-service oriented system to achieve this goal. The developed system supports the following operations:
</p>

<ul>
<li>
Apply mathematical operations (e.g. apply algebraic, logical, and calculus operations).
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
</ul>

<?php require_once("./footer.php") ?>
