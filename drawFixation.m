function drawFixation(windowPtr, p, half_l, color)

% wrote by HM 12/10/2013 

x = p(1)
y = p(2)
Screen('DrawLine',windowPtr,color,x-half_l, y, x+half_l, y, 2);
Screen('DrawLine',windowPtr,color,x, y-half_l, x, y+half_l, 2); 
