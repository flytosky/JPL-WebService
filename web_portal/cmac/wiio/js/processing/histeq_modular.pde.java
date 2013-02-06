/*
MODULAR CONTRAST STRETCH WITH PROCESSING.JS.
MADE FOR WEBIFICATION INITIATIVE IN 2011
JET PROPULSION LAB
ALEX SMITH, ALEXANDER.SMITH@JPL.NASA.GOV
*/
   	PFont font;
	textSize(9);
    int redo = 1;
    histEq histeq;
    PImage a;
    int imagemade = 0;
    Stretch stretch;
    //w10n.modularImage is set in the jQuery and carries along our image from the DOM.
    String imgsrc = "";
    float imgwidth,imgheight;
	boolean is_done_loading = false;
	int adjw = 512;
	int adjh = 512;
    
void setup(){
    size(adjw,adjh);  
   	background(0);
    colorMode(RGB, 255);  
    /*enable to show image without histeq*/
    
    a = requestImage(imgsrc);
    
    /*end enabling*/
    
    //ENABLE HISTEQ methods here;
    //histeq = new histEq(a,width*0.8,height);
    //stretch = new Stretch(imgsrc,height);
}
void setDimensions(int w, int h){
	adjw = w+120;//w <= 256 ? 512 : w+256;
	adjh = h+256;//h <= 256 ? 512 : ;	
}
void redrawimage(String modImgPath, float imgw, float imgh){
	imgwidth = imgw;
	imgheight = imgh;
	
	redo=1;
	imagemade=0;
	a = requestImage(modImgPath);
}

void draw(){

	if(imagemade == 0){
		histeq = new histEq(a,width-50,height);
		imagemade = 1;
	}
	if(a.width > 0 && imagemade == 1){
	//image(a, 0, 0,256,256);
	//fill(0);
	
   	histeq.eqSlider();
   	
if(redo == 1){
	//stretch.Histogram();
	histeq.make();
 }
 }
}
void mouseDragged(){
	//eqslider
	float mx = in_place ? mouseX : mouseX-window.pageXOffset;
	float my = in_place ? mouseY : mouseY-window.pageYOffset;
	histeq.adjust(mx,my);
	
	
}
void mouseReleased(){
	
	float mx = mouseX-window.pageXOffset;
	float my = mouseY-window.pageYOffset;
	//moved inside setEq: histeq.calculateHistogram();
	histeq.setEq(my/height,mx);
	
	//moved in setEq as well: redo = 1;
	
}
boolean check_is_done(){
	if(is_done_loading) return true;
	return false;
}
void resetLoad(){
	is_done_loading = false;	
}

class histEq{
	float mean;
	int padding = 20;
    float meancalc = 0;
    int mean_div = 0;
    float multiplier_eq = 0.5;
    int colors = 256;
    int maxval_w; //this is the X position of the maximum value on the histogram
    int[] hist = new int[255];  
    String imgsrc;
    PImage a; 
    String display_text = '100%'; 
    float ellipse_x,ellipse_y;
    float parentheight = height;
    int hist_height = 216;
    int max_histogram_pre_norm;
    color ellipsecolor = color(255,255,255);
    
	histEq(PImage img, float elx, float ely){
		a = img;
		ellipse_x = elx;
    	ellipse_y = ely*multiplier_eq;
    	multiplier_eq += multiplier_eq;
	}
	void make(){
		
		background(0);
		fill(255);
	   	stroke(255);
	   	ellipse(ellipse_x,ellipse_y,20,20);
	   	noStroke();
	   	noFill();
	   	noStroke();
	   	
	   	
	   
	   	
	   	
		if(a.width > 0){
		/*
		if(a.height > Math.floor(256)){
			a.width = (256/a.height)*a.width;
			a.height = Math.floor(256);
		}*/
		image(a, 0, 0,a.width,a.height);
		
	    // Normalize the histogram to values between 0 and "height"  

		 //equalize
		 int w = a.width;
		 int h = a.height;
		 int M = w * h; // total number of image pixels
		 int K = 256; // number of intensity values
		 calculateHistogram();
		 // compute the cumulative histogram:
		 for (int j = 1; j < hist.length; j++) {
		 hist[j] = hist[j-1] + hist[j];
		 }
		
		 // equalize the image:
		 for (int v = 0; v < h; v++) {
		 for (int u = 0; u < w; u++) {
		 int a2 = brightness(get(u, v));
		 int b = Math.round((hist[a2] * (K-1) / M)*multiplier_eq);
		 b = b > 255 ? 255 : b;
		 
		 set(u, v, color(b,b,b));
		 
		 }
		 
		 if(v == h-1){
		 setTimeout(function(){hideLoading();is_done_loading = true;},1000);
		 	//hideLoading();
		 }
		 }
		  calculateHistogram();
		 
		 
		     // Find the largest value in the histogram  
		    float maxval = 0;  
		    for (int i=0; i<colors; i++) {  
		      if(hist[i] > maxval) {  
		        maxval = hist[i];
		        max_histogram_pre_norm = maxval;
		        maxval_w = i;  
		      }    
		    }  
		 
		    //normalize
		        for (int i=0; i<256; i++) {  
		      hist[i] = int(hist[i]/maxval * hist_height);  
		    }  
		    
		    
				int padding = 40;
				int padding_bottom = 30;
				//draw the histogram
				stroke(color(255,255,255));
				line(5,parentheight+5,5,parentheight-256);
				line(5,parentheight-5,256+padding,parentheight-5);
				//X values on legend
				for(int x=0; x<=254;x+=5){
					int lx = x+padding;
					if(x%10 == 0){
						
						line(lx,parentheight,lx,parentheight-10);
						if(x != 250){
						pushMatrix();
							translate(lx-5,parentheight-11);
							rotate(PI/2);
							textAlign(RIGHT);
							text(x,0,0);
						popMatrix();
						}
						else{
						pushMatrix();
							translate(255+padding-5,parentheight-11);
							rotate(PI/2);
							textAlign(RIGHT);
							text("255",0,0);
						popMatrix();
						}
					}
					else{
					
						line(lx,parentheight-3,lx,parentheight-6);
						
					}
				}
				//last line
				line(256+padding,parentheight,256+padding,parentheight-10);
				
				//ok now time for Y values on legend
				int iterations = 0;
				for(int y=0;y<=220;y+=22){
					int ly = y+padding;
					
					
						line(0,parentheight-5-y-25,10,parentheight-5-y-25);
						if(y != 250){
						pushMatrix();
							textAlign(LEFT);
							String txt = Math.floor(iterations*(max_histogram_pre_norm/10));
							text(txt,10,parentheight-5-y-15);
						popMatrix();
						}

					iterations++;
				}
				
		    
		    
		      //background(255,120,0);
		    stroke(color(145,212,17)); 
		    for (int i=0; i<colors; i++) {
		    	  
		    	for(int hh=height;hh>=height-hist[i];hh--){
		    	
		      		int linex = i+padding;
				  line(linex, parentheight-padding_bottom, linex, parentheight-padding_bottom-hist[i]);  
		      } 
		    }  
		    stroke(color(0,255,0));
		    
		    stroke(255);
		    
		    // TODO: calculate mean, stdev, min max etc...
		    
		    for(int i=0;i<colors;i++){
		    	if(hist[i] != 0){
		    	meancalc += hist[i];
		    	mean_div++;
		    	
		    	}
		    }
		    
		    mean = meancalc/mean_div;
		 	redo = 0;
		 	
		 }
	}
	void calculateHistogram(){
	
	// Calculate the histogram  
		hist = new int[255];
	    for (int i=0; i<=a.width; i++) {  
	      for (int j=0; j<=a.height; j++) {  
	        hist[int(brightness(get(i, j)))]++; 
	        //console.log(brightness(get(i, j)));  
	      }  
	    } 
	    
	}
	void adjust(float mx, float my){
		if(mx > (ellipse_x-20) && mx < (ellipse_x + 20)){
		ellipsecolor = color(145,212,17);
		ellipse_y = my;
		ellipse_y = ellipse_y >= height-padding ? height-padding : (ellipse_y < padding ? padding : ellipse_y);
		display_text = Math.round((ellipse_y-padding)/(height*((height-(padding*2))/height))*200)+' %';
		multiplier_eq = ((ellipse_y-padding)/(height*((height-(padding*2))/height))*2);
		//(multiplier_eq);
		}
		
	}
	void setEq(float mxpercent, float mx){
		//multiplier_eq = mxpercent*2;
		
		float my = mxpercent*height;
		
		if(mx >= ellipse_x-50 && mx <= ellipse_x+50 && my <= ellipse_y+50 && my >= ellipse_y-50){
			showLoading();
			setTimeout(function(){
			calculateHistogram();
			redo=1;
			},200);
		}
		ellipsecolor = color(255,255,255);
	}
	void eqSlider(){
		
		fill(0,50);
		noStroke();
		rect(ellipse_x-20,0,ellipse_x+20,height);
		noFill();
		stroke(120);
		line(ellipse_x-1,padding,ellipse_x-1,height-padding);
		fill(ellipsecolor);
	   	ellipse(ellipse_x,ellipse_y,20,20);
	   	noFill();
	   	noStroke();
	   	fill(color(145,212,17));
		text(display_text,ellipse_x+15,ellipse_y+5);
		noFill();
		noStroke();
	}
}