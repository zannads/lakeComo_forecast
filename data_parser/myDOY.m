function doy = myDOY( t )
%MYDOY doy = myDOY( t ) transform a datetime array to a numeric array with
%the day of the year. The difference with respect of using day( t,
%'dayofyear' ) is the handling of the leap year.
% In this case the leap day is still numbered as 59, like the 28th of
% february. Thus, doy will allways be included between 1 and 365
t = t(:);
% input check is done inside the function day
doy = day( t, 'dayofyear' );

%% transformation to my definition

% extract all the leap years in the seires in a horizontal array
leapYears = unique( t.Year(mod(t.Year, 4) == 0) )';
% get the indexes on the array t of the days that need to be subtracted by
% one day
isInLeapYear2mod = t >= datetime( leapYears, 2, 29 ) & t <= datetime( leapYears, 12, 31 ); 
% compress for all leap years
isInLeapYear2mod = any( isInLeapYear2mod, 2);

% remove 1 for all the day for which is necessary
doy( isInLeapYear2mod ) = doy( isInLeapYear2mod )-1;

end

