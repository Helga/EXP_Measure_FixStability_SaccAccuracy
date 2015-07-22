function [cont, keycode] = getContinueResponse
%function [cont, keycode] = getContinueResponse
%  Call after giveInstruction

cont = 1;
[keydown, ~, keycode] = KbCheck;
while ~keydown
    [keydown, ~, keycode] = KbCheck;
end
if keycode(KbName('q'))
    cont = 0;
end
WaitSecs(0.1);
FlushEvents('KeyDown');
