/*
MODULAR CONTRAST STRETCH WITH PROCESSING.JS.
MADE FOR WEBIFICATION INITIATIVE IN 2011
JET PROPULSION LAB
ALEX SMITH, ALEXANDER.SMITH@JPL.NASA.GOV
*/
   	PFont font;
	textSize(9);
    int redo = 1;
    int imagemade = 0;
    histEq histeq;
    PImage a;
    Stretch stretch;
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
	if(a.width > 0){
		
		//image(a, 0, 0,256,256);
		//stretch = new Stretch(a,height);
	}
    /*end enabling*/
    
    //stretch
    
}
void setDimensions(int w, int h){
	adjw = w+120;//w <= 256 ? 512 : w+256;
	adjh = h+256;//h <= 256 ? 512 : ;	
}
void redrawimage(String image_src, float imgw, float imgh){
	imgwidth = imgw;
	imgheight = imgh;
	
	redo=1;
	imagemade=0;
	
	a = requestImage(image_src);
}
void draw(){
	if(imagemade == 0 && a.width > 0){
		showLoading();
		stretch = new Stretch(a,height);
		imagemade=1;	
	}
	if(a.width > 0 && imagemade == 1){
	
	//fill(0);
   	//histeq.eqSlider();
   	//stretch
   	stretch.makeSliders();
   	
if(redo == 1){
	background(0);
	//image(a, 0, 0,a.width,a.height);
	stretch.Histogram();
	//histeq.make();
 }
 }
}
void mouseDragged(){
	//stretch
	
	float mx = in_place ? mouseX : mouseX-window.pageXOffset;
	float my = in_place ? mouseY : mouseY-window.pageYOffset;
	stretch.adjust(mx,my);
	
}
void mouseReleased(){
	//stretch
	float mx = in_place ? mouseX : mouseX-window.pageXOffset;
	float my = in_place ? mouseY : mouseY-window.pageYOffset;
	stretch.setStretch(mx,my);
	redo = 1;
}
boolean check_is_done(){
	if(is_done_loading) return true;
	return false;
}
void resetLoad(){
	is_done_loading = false;	
}

class Stretch{
	
	float mean,min,max,stddev,median;
	int colormax = 255;
	int colormin = 0;
	int ignore_below = 0;
	int imgmin = 0;
	int imgmax = 0;
	int wid;
	int hei;
	int[] hist;
	int has_stretched = 0;
	PImage img;
	string imgsrc;
	int parentheight;
	int hist_height = 216;
	float ellipse1_x,ellipse1_y, ellipse2_x,ellipse2_y;
	color ellipse1color = color(255,255,255);
	color ellipse2color = color(255,255,255);
	float mean;
	float st_dev;
	int max_histogram_pre_norm;
	int button_thresh = 40;
	
	Stretch(PImage im, float ph){
		img = im;
		parentheight = ph;
		ellipse1_x = img.width+60;
		ellipse1_y = 0;
		ellipse2_x = img.width+60;
		ellipse2_y = parentheight;
		
	}
	
	void Histogram(){
	hist = new int[256];
	//img = requestImage(imgsrc);
		if(img.width > 0){
			
				hei = img.height;
				wid = img.width;
				/*
				if(img.height > 256){
				img.width = (256/img.height)*img.width;
				img.height = Math.floor(256);
				
				}*/
			hei=img.height;
			wid=img.width;
				if(has_stretched == 0){
					image(img, 0, 0,img.width,img.height);
				}
				//image(img, 0, 0,img.width,img.height);
				// Calculate the histogram  
				for (int i=0; i<wid; i++) {  
				  for (int j=0; j<hei-1; j++) {  
				  
				    hist[int(brightness(get(i, j)))]++;   
				  }  
				}   
				  
				// Find the largest value in the histogram  
				float maxval = 0; 
				int mv; 
				for (int i=0; i<256; i++) {  
				 
				  if(hist[i] > maxval) {  
				  	mv = i;
				    maxval = hist[i];  
				    max_histogram_pre_norm = maxval;
				  }    
				}  
				
				// Find the smallest color# in the histogram  
				  
				for (int i=0; i<256; i++) {  
				  
				  //find the smallest value in the histogram   
				  if(hist[i] > ignore_below && imgmin == 0){
				  	imgmin = i;
				  	ellipse1_y = imgmin/256*parentheight;
				  }
				}  
				
				//largest color # in histogram
				for(int i = 255; i >=0; i--){
				  
				  
				  if(hist[i] > ignore_below && imgmax == 0) {  
				  
				    imgmax = i;  
				    ellipse2_y = imgmax/256*parentheight;
				  } 
				}
				
				
				// Normalize the histogram to values between 0 and "height"  
				for (int i=0; i<wid; i++) {  
				  hist[i] = int(hist[i]/maxval * hist_height);  
				  
				}  
				
				if(has_stretched == 1){  
				drawHistogram();
				}
				  if(has_stretched == 0){
				  
				  	doStretch();
				  	//calculateMean();
				  }
				  else{
				  
				  }
				  
				  
				
			}
			
		//endif img.width
		hideLoading();
		is_done_loading = true;
		redo = 0;
		}
	void drawHistogram(){
			pushMatrix();
			translate(0,0,0);
				int padding = 40;
				int padding_bottom = 30;
				//draw the histogram
				stroke(color(255,255,255));
				fill(color(255,255,255));
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
				
				stroke(color(145,212,17));
				strokeWeight(1);
				
				for (int i=0; i<256; i++) {  
				  linex = i+padding;
				  line(linex, parentheight-padding_bottom, linex, parentheight-padding_bottom-hist[i]);  
				}  
			popMatrix();	
	}
	void calculateMean(){
		int repcount = 0;
		int minimum = 256;
		int maximum = 0;
		for(int i=0;i<img.width;i++){
			for(int j=0;j<img.height;j++){
				int tempcolor = int(brightness(get(i,j)));
				if(tempcolor <= minimum){minimum = tempcolor;}
				if(tempcolor >= maximum){maximum = tempcolor;}
				mean += tempcolor;
				repcount++;
			}
		}
		
		mean = mean/repcount;
		double slope = (255-0)/(maximum-minimum);
		double offset = 255-(slope*maximum);
		//console.log('slope:'+(float)slope);
		//console.log('offset:'+(float)offset);
		//console.log('testmax'+maximum);
		//console.log('testmin'+minimum);
		//console.log('repcount'+repcount);
		//console.log('mean '+mean);
		//console.log('max '+imgmax);
		//console.log('min '+imgmin);
		//console.log('histlength: '+hist.length);
		/*
		for(int i=0;i<width;i++){
			for(int j=0;j<height;j++){
				int tempcolor = int(brightness(get(i,j)));
				int col = Math.round(slope*tempcolor+offset);
				//console.log(col);
				set(i,j,color(col,col,col));
			}
		}
		*/
	}
	void doStretch(){
		int a = colormin;
		int b = colormax;
		int c = imgmin;
		int d = imgmax;
		for(i=0;i<img.width;i++){
			for(j=0;j<img.height;j++){
				int pixin = int(brightness(get(i, j)));
				int pixout = Math.ceil((pixin-imgmin) * ((colormax-colormin)/(imgmax-imgmin)) + colormin);
				pixout = pixout >= 255 ? 255: (pixout <= 0 ? 0 : pixout);
				set(i,j,color(pixout,pixout,pixout));
				
			}
		}
		has_stretched = 1;
		Histogram();
	}
	void adjust(float mx, float my){
		
			
			if(mx > (ellipse1_x-button_thresh) && mx < (ellipse1_x + button_thresh) && my > (ellipse1_y-button_thresh) && my < (ellipse1_y+button_thresh)){
				ellipse1_y = my;
				
				imgmin = Math.round((my/parentheight)*256);
				ellipse1color = color(145,212,17);
			}
			else{ellipse1color = color(255,255,255);}
			if(mx > (ellipse2_x-button_thresh) && mx < (ellipse2_x + button_thresh) && my > (ellipse2_y-button_thresh) && my < (ellipse2_y+button_thresh)){
				ellipse2_y = my;
				imgmax = Math.round((my/parentheight)*256);
				ellipse2color = color(145,212,17);
			}
			else{ellipse2color = color(255,255,255);}
			//image(img, 0, 0,256,256);
		}
	void setStretch(float mx,float my){
		//multiplier_eq = mx;
		if(mx > (ellipse1_x-button_thresh) && mx < (ellipse1_x + button_thresh) && my > (ellipse1_y-button_thresh) && my < (ellipse1_y+button_thresh)){
		doSet();
		}
		if(mx > (ellipse2_x-button_thresh) && mx < (ellipse2_x + button_thresh) && my > (ellipse2_y-button_thresh) && my < (ellipse2_y+button_thresh)){
		doSet();		
		}
	}
	void doSet(float my){
		showLoading();
		has_stretched = 0;
		ellipse1color = color(255,255,255);
		ellipse2color = color(255,255,255);	
	}
	void makeSliders(){
		textAlign(LEFT);
		fill(0,50);
		noStroke();
		rect(ellipse1_x-20,0,ellipse1_x+20,parentheight);
		
		noFill();
		stroke(255);
		line(ellipse1_x-1,0,ellipse1_x-1,parentheight);
		fill(ellipse1color);
	   	ellipse(ellipse1_x,ellipse1_y,20,20);
	   	fill(color(145,212,17));
	   	text((String)imgmin, ellipse1_x+15,ellipse1_y+5);
	   	noFill();
	   	noStroke();
	   	//2nd ellipse
	   	fill(ellipse2color);
	   	ellipse(ellipse2_x,ellipse2_y,20,20);
	   	fill(color(145,212,17));
	   	text((String)imgmax, ellipse2_x+15,ellipse2_y+5);
	   	noFill();
	   	noStroke();
	}
	
}
