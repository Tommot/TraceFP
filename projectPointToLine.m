function q = projectPointToLine(point, P)
  % returns q the closest point to p on the line segment from A to B 
    
  % point at x=10000 (large enough to cover entire floorplan)
  A = [10000, P(1)*10000 + P(2)];
  B = [-10000, P(1)*-10000 + P(2)];
  
  % vector from A to B
  AB = (B-A);
  % squared distance from A to B
  AB_squared = dot(AB,AB);
  if(AB_squared == 0)
    % A and B are the same point
    q = A;
  else
    % vector from A to p
    Ap = (point-A);
    % from http://stackoverflow.com/questions/849211/
    % Consider the line extending the segment, parameterized as A + t (B - A)
    % We find projection of point p onto the line. 
    % It falls where t = [(p-A) . (B-A)] / |B-A|^2
    t = dot(Ap,AB)/AB_squared;
    if (t < 0.0) 
      % "Before" A on the line, just return A
      q = A;
    else if (t > 1.0) 
      % "After" B on the line, just return B
      q = B;
    else
      % projection lines "inbetween" A and B on the line
      q = A + t * AB;
    end
  end
end