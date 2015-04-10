function bool = is_parallel( v1, v2, tolerance )
%IS_PARALLEL Summary of this function goes here
%   Detailed explanation goes here
%   is_parallel( v1, v2, tolerance )
%   v1: the first vector
%   v2: the second vector
%   thershold: the maximum inclined angle to count the two lines as
%   parallel, in degree
    theta = acosd(dot(v1, v2) / (norm(v1) * norm(v2)));
    if (theta < tolerance || theta > 180-tolerance)
        bool = true;
    else
        bool = false;
    end
end

