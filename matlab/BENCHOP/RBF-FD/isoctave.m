% Credit goes to Anderson Winkler.
% This file was just slightly modified by Anders Schanche
% simple function to check if code is ran with octave or not
% _____________________________________
% Anderson Winkler - Apr/2016
% http://octave.1599824.n4.nabble.com/gammainc-no-small-outputs-td4676577.html

function y = isoctave
persistent isoct;
if isempty(isoct)
    isoct = exist('OCTAVE_VERSION','builtin') ~= 0;
end
y = isoct;