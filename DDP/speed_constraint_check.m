function outp = speed_constraint_check( r, h )
    outp = sum( ( (r(2:end, :)-r(1:end-1,:))>240 & h(1:end-1,:)<0.8 ) | ( (r(2:end,:)-r(1:end-1,:))>360 & h(1:end-1,:)>=0.8 & h(1:end-1,:)<=1.1), 1 );
end