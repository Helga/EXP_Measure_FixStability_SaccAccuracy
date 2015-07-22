function giveInstruction(win,instruction,textColor,bgColor)
%function giveInstruction(win,instruction,textColor,bgColor)
%   Often pairs with getContinueReponse
WaitSecs(0.1);
FlushEvents('KeyDown');
Screen('FillRect',win,bgColor);
screenText(win,instruction,textColor);
Screen('Flip',win);
