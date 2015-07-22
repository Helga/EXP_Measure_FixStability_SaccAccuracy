function screenText(window,mytext,color,xy)
% Usage:  screenText(window,mytext,color,xy)
%
% Display text on screen.
% Center and right-justify the block if xy is not provided
%
% mytext MUST be in the following form:
%
% mytext{1} = 'text here';
% mytext{4} = 'more text here';
%
% or
% mytext = {'text here','','','more text here'};
%
% All text should be contained within mytext!
% If you skip positions in the array, it is the equivalent of skipping
% lines on the Screen.

if ~exist('color','var')
    color = 0;
end

winRect = Screen('Rect',window);
winWidth  = RectWidth(winRect);
winHeight = RectHeight(winRect);

th = RectHeight(Screen('TextBounds',window,'X'));

if ~exist('xy','var')
    [~, idx] = max(cellfun(@numel,mytext));
    tw = RectWidth(Screen('TextBounds', window, mytext{idx}));
    horiOffset = (winWidth-tw)/2;
    vertOffset = (winHeight-length(mytext)*th)/2;
else
    horiOffset = xy(1);
    vertOffset = xy(2);
end

for lineCount = 1:length(mytext)
    if ~isempty(mytext{lineCount})
        Screen('DrawText',window, ...
            mytext{lineCount}, ...
            horiOffset, ...                  % x-coord
            vertOffset+(lineCount-1)*th, ... % y-coord
            color);
    end
end

