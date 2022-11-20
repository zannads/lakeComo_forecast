function outp = speed_constraint_check( r, h )
    % check the opening speed constraint of the bulkhead of Lake Como. in 24
    % hours release can't increase more than 240 if level < 0.8. in 24 hours
    % release can't increase more than 360 if level >= 0.8 & < 1.1.
    outp = sum( ( (r(2:end, :)-r(1:end-1,:))>240 & h(1:end-1,:)<0.8 ) | ( (r(2:end,:)-r(1:end-1,:))>360 & h(1:end-1,:)>=0.8 & h(1:end-1,:)<=1.1), 1 );
end