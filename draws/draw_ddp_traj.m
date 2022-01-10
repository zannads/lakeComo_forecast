figure;
plot( sim_s );
hold on;
plot( LakeComo.level2storage( 1.1*ones(1, n_t) ) );
plot( LakeComo.level2storage( -0.2*ones(1, n_t) ) );

figure;
plot(sim_r);
hold on;
plot( e);
plot( repmat( comoDemand, yy, 1));
plot( mef )