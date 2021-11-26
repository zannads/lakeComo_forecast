function outputArg = isprobForecast(inputArg1)
%ISPROBFORECAST returns true if the input is a probForecast class.

    outputArg = strcmp( class( inputArg1), probForecast.type );
end

