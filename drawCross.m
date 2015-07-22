function drawCross(windowPtr, p, half_l, color)

% wrote by HM 12/10/2013 
%draws a X at the center of rec on the screen , size is in pixels
x = p(1);
y = p(2);
Screen('DrawLine',windowPtr,color,x - half_l,y- half_l,x+ half_l,y+ half_l,2);
Screen('DrawLine',windowPtr,color,x - half_l,y+half_l,x+ half_l,y-half_l,2); 
