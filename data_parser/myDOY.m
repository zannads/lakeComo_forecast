function doy = myDOY( t )
%MYDOY Summary of this function goes here
%   Detailed explanation goes here

doy = day( t, 'dayofyear' );

leapYears = unique( t.Year(mod(t.Year, 4) == 0) )';
isInLeapYear2mod = t >= datetime( leapYears, 2, 29 ) & t <= datetime( leapYears, 12, 31 ); 
isInLeapYear2mod = any( isInLeapYear2mod, 2);

doy( isInLeapYear2mod ) = doy( isInLeapYear2mod )-1;

end

