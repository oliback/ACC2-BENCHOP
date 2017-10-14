function [ S1, S2, S3, K, T, r, sig, Bm ] = parse_parameters( args, prob, S1d, S2d, S3d, Kd, Td, rd, sigd, Bmd )
% This function is for parsing arguments to the problems.
% The d in input arguments means default.
% Order of parameters in args does not matter, except that they are
% directly after the problem they are relevant to. /Anders Schanche

% First, the default parameters is set, the function should require them.
S1 = S1d;
S2 = S2d;
S3 = S3d;
K = Kd;
T = Td;
r = rd;
sig = sigd;
Bm = Bmd;

for i=1:length(args)
    if strcmp(args(i), prob)
        % problem found, parse parameters
        for j=1:8
            %TODO: fix the issue of looping too long, think if it passes
            %over into the next problems parameters for example.
            if any(~cellfun('isempty', strfind(args(i+j), "S1")))
                S1 = sscanf(extractAfter(args(i+j), "S1="), '%d');
            elseif any(~cellfun('isempty', strfind(args(i+j), "S2")))
                S2 = sscanf(extractAfter(args(i+j), "S2="), '%d');
            elseif any(~cellfun('isempty', strfind(args(i+j), "S3")))
                S3 = sscanf(extractAfter(args(i+j), "S3="), '%d');
            elseif any(~cellfun('isempty', strfind(args(i+j), "K")))
                K = sscanf(extractAfter(args(i+j), "K="), '%d');
            elseif any(~cellfun('isempty', strfind(args(i+j), "T")))
                T = sscanf(extractAfter(args(i+j), "T="), '%d');
            elseif any(~cellfun('isempty', strfind(args(i+j), "r")))
                r = sscanf(extractAfter(args(i+j), "r="), '%d');
            elseif any(~cellfun('isempty', strfind(args(i+j), "sig")))
                sig = sscanf(extractAfter(args(i+j), "sig="), '%d');
            elseif any(~cellfun('isempty', strfind(args(i+j), "Bm")))
                %Bm is used as a multiplier with K outside of the function.
                Bm = sscanf(extractAfter(args(i+j), "Bm="), '%d');
            else
                % no more parameters found, break out of loop.
                break;
            end
        end
    end
end

end

