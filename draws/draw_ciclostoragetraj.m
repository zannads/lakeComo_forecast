time = datetime(1999,1,1):1:datetime(2019,1,1);
f1 = figure;
t1 = tiledlayout(2,1);
lev = nexttile;
rel = nexttile;

%
f2 = figure;
t2 = tiledlayout(2,1);
ciclev = nexttile;
cicrel = nexttile;

% DDP
axes(ciclev);
ciclevlo = ciclostationary( moving_average(array2timetable(levelsol869918, 'RowTimes', time(1:end-1)', 'VariableNames', {'level'} )) );
plot( 1:365, [ciclevlo{274:365, "mu"}; ciclevlo{1:273, "mu"}], 'Linewidth', 3, 'Color', 'k' );
xticks( [1, 32, 62, 93, 124, 152, 183, 213, 244, 274, 305, 336] );
xticklabels( { 'O', 'N', 'D', 'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S' } )
xlim( [0, 366] )
xlabel( 'Day of the year', 'FontSize', labFSize  )
ylabel( 'Level [m]', 'FontSize', labFSize )
grid on

axes(cicrel);
ciclevlo = ciclostationary( moving_average(array2timetable(releasesol869918, 'RowTimes', time(1:end-1)', 'VariableNames', {'level'} )) );
plot( 1:365, [ciclevlo{274:365, "mu"}; ciclevlo{1:273, "mu"}], 'Linewidth', 3, 'Color', 'k' );
xticks( [1, 32, 62, 93, 124, 152, 183, 213, 244, 274, 305, 336] );
xticklabels( { 'O', 'N', 'D', 'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S' } )
xlim( [0, 366] )
xlabel( 'Day of the year', 'FontSize', labFSize )
ylabel( 'Release [m^3/s]', 'FontSize', labFSize )
grid on


axes(lev);
plot( time, [levelsol869918;nan], 'LineWidth', 3, 'Color', 'k' );
xlabel( 'Day of the year', 'FontSize', labFSize  )
ylabel( 'Level [m]', 'FontSize', labFSize  )
axes(rel);
plot( time, [releasesol869918;nan], 'LineWidth', 3, 'Color', 'k' );
xlabel( 'Day of the year', 'FontSize', labFSize )
ylabel( 'Release [m^3/s]', 'FontSize', labFSize )
% sol86 is 
%J = [4.45, 1.082067011416135e+03, 9.85];

%%
% EMODPSol = 
for jdx = 1:length(sols)
    EMODPSol = sols(jdx);
solnumber = getN(EMODPSol.reference);
mdc = model_lakecomo( EMODPSol.settings_file );
[J, h, r] = mdc.evaluate( extract_params( EMODPSol, solnumber ) );
J
%
ls = solLS(jdx);
cl = solsCol(jdx,:);

axes(ciclev);
hold on
ciclevlo = ciclostationary( moving_average(array2timetable(h, 'RowTimes', time', 'VariableNames', {'level'} )) );
%plot( 1:365, [ciclevlo{274:365, "mu"}; ciclevlo{1:273, "mu"}], 'Linewidth', 2 ); %1st october 274
plot( 1:365, [ciclevlo{274:365, "mu"}; ciclevlo{1:273, "mu"}], 'Linewidth', 3, 'LineStyle', ls, 'Color', cl); %1st october 274
axes(cicrel);
hold on
ciclevlo = ciclostationary( moving_average(array2timetable(r, 'RowTimes', time(1:end-1)', 'VariableNames', {'level'} )) );
%plot( 1:365, [ciclevlo{274:365, "mu"}; ciclevlo{1:273, "mu"}], 'Linewidth', 2 ); %1st october 274
plot( 1:365, [ciclevlo{274:365, "mu"}; ciclevlo{1:273, "mu"}], 'Linewidth', 3, 'LineStyle', ls, 'Color', cl); %1st october 274
axes(lev);
hold on
%plot(h, 'LineWidth', 2);
plot(h, 'LineWidth', 3, 'LineStyle', ls, 'Color', cl);
axes(rel);
hold on
%plot(r, 'LineWidth', 2);
plot(r, 'LineWidth', 3, 'LineStyle', ls, 'Color', cl);
clear EMODPSol
end
%%
% squared between 91 and 283
axes(cicrel);
plot( 1:10, aggregateddemand( 274:283 ), 'LineWidth', 1.5, 'Color', 'r', 'LineStyle', '-' ) %1st to 10th october
plot( 11:92, aggregateddemand(284:365), 'LineWidth', 1.75, 'Color', 'r', 'LineStyle', ':' )  %11th october to 31st dec
plot( 93:182, aggregateddemand(1:90), 'LineWidth', 1.75, 'Color', 'r', 'LineStyle', ':' )    %1st jan to 1st april
plot( 183:365, aggregateddemand(91:273), 'LineWidth', 1.5, 'Color', 'r', 'LineStyle', '-' ) % 1st april
cicLeg = legend( [{'POP'},solsName,{'Demand'}] );
%%

function solnum = getN( rSet )
    rSet( rSet(:,1)>=5 | rSet(:,3) < 7 | rSet(:,3) > 13 ,2) = inf;
    
    [~, solnum] = min( rSet(:,2) );
end
