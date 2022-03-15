function [outputArg1,outputArg2] = print_R2(R2,X, c_v)
    %UNTITLED4 Summary of this function goes here
    %   Detailed explanation goes here
   R2 = R2(:,1);
   X = X(:,1);
   X(isnan(R2))=[];
   R2(isnan(R2))=[];
    
   figure;
    bar( [R2(1); diff(R2)] );
    hold on;
    plot( R2, '-ok' );
    ylim([0,1]);
    grid on
    xticklabels( c_v(X));
end

