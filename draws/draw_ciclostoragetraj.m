time = datetime(1999,1,1):1:datetime(2019,1,1);
fullSim.f = figure('WindowButtonDownFcn', @synchronize_axis_XLim, 'WindowState','fullscreen');
fullSim.tl = tiledlayout(2,1);
fullSim.tl.TileSpacing = 'compact';
fullSim.tl.Padding = 'compact';
fullSim.lev = nexttile;
fullSim.rel = nexttile;

%
cycloSim.f = figure('WindowButtonDownFcn', @synchronize_axis_XLim);
cycloSim.tl = tiledlayout(2,1);
cycloSim.tl.TileSpacing = 'compact';
cycloSim.tl.Padding = 'compact';
cycloSim.lev = nexttile;
cycloSim.rel = nexttile;

% DDP
ciclevlo = ciclostationary( moving_average(array2timetable(levelsol869918, 'RowTimes', time(1:end-1)', 'VariableNames', {'level'} )) );
plot(cycloSim.lev, 1:365, [ciclevlo{274:365, "mu"}; ciclevlo{1:273, "mu"}], 'Linewidth', 1.5, 'Color', 'k' );
xticks(cycloSim.lev, [1, 32, 62, 93, 124, 152, 183, 213, 244, 274, 305, 336] );
%xticklabels(cycloSim.lev, { 'O', 'N', 'D', 'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S' } )
xticklabels(cycloSim.lev, {});
xlim(cycloSim.lev, [0, 366] )
%xlabel(cycloSim.lev, 'Day of the year', 'FontSize', labFSize  )
ylabel(cycloSim.lev, 'Level [m]', 'FontSize', labFSize )
grid(cycloSim.lev, 'on');
hold(cycloSim.lev, 'on');

ciclevlo = ciclostationary( moving_average(array2timetable(releasesol869918, 'RowTimes', time(1:end-1)', 'VariableNames', {'level'} )) );
plot(cycloSim.rel, 1:365, [ciclevlo{274:365, "mu"}; ciclevlo{1:273, "mu"}], 'Linewidth', 1.5, 'Color', 'k' );
xticks(cycloSim.rel, [1, 32, 62, 93, 124, 152, 183, 213, 244, 274, 305, 336] );
xticklabels(cycloSim.rel, { 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep' } )
xlim(cycloSim.rel, [0, 366] )
xlabel(cycloSim.rel, 'Day of the year', 'FontSize', labFSize )
ylabel(cycloSim.rel, 'Release [m^3/s]', 'FontSize', labFSize )
grid(cycloSim.rel, 'on');
hold(cycloSim.rel, 'on');

plot(fullSim.lev, time, [levelsol869918;nan], 'LineWidth', 1.5, 'Color', 'k' );
xlabel(fullSim.lev, 'Day of the year', 'FontSize', labFSize  )
ylabel(fullSim.lev, 'Level [m]', 'FontSize', labFSize  )
grid(fullSim.lev, 'on');
hold(fullSim.lev, 'on');

plot(fullSim.rel, time, [releasesol869918;nan], 'LineWidth', 1.5, 'Color', 'k' );
xlabel(fullSim.rel, 'Day of the year', 'FontSize', labFSize )
ylabel(fullSim.rel, 'Release [m^3/s]', 'FontSize', labFSize )
grid(fullSim.rel, 'on');
hold(fullSim.rel, 'on');

% sol86 is
%J = [4.45, 1.082067011416135e+03, 9.85];

%%
% EMODPSol =
for jdx = 1:length(sols)
    EMODPSol = sols(jdx);
    solnumber = getN(EMODPSol.reference);
    if solMD(jdx)
        mdc = model_lakecomo_autoSelect( EMODPSol.settings_file );
    else
        mdc = model_lakecomo( EMODPSol.settings_file );
    end
    [J, h, r] = mdc.evaluate( extract_params( EMODPSol, solnumber ) );
    %
    ls = solsLS(jdx);
    cl = solsCol(jdx,:);
    
    ciclevlo = ciclostationary( moving_average(array2timetable(h, 'RowTimes', time', 'VariableNames', {'level'} )) );
    plot(cycloSim.lev, 1:365, [ciclevlo{274:365, "mu"}; ciclevlo{1:273, "mu"}], 'Linewidth', 1.5, 'LineStyle', ls, 'Color', cl); %1st october 274
    
    ciclevlo = ciclostationary( moving_average(array2timetable(r, 'RowTimes', time(1:end-1)', 'VariableNames', {'level'} )) );
    plot(cycloSim.rel, 1:365, [ciclevlo{274:365, "mu"}; ciclevlo{1:273, "mu"}], 'Linewidth', 1.5, 'LineStyle', ls, 'Color', cl); %1st october 274
   
    plot(fullSim.lev, h, 'LineWidth', 3, 'LineStyle', ls, 'Color', cl);
    
    plot(fullSim.rel, r, 'LineWidth', 3, 'LineStyle', ls, 'Color', cl);
    clear EMODPSol
end
%%
% squared between 91 and 283 -> 1.75 and '-'
styD = [':', '-'];
thiD = [1.5, 1.5];

plot(cycloSim.rel, 1:10, aggregateddemand( 274:283 )+22, 'LineWidth', 1.5, 'Color', 'r', 'LineStyle', '-' ) %1st to 10th october
plot(cycloSim.rel, 11:92, aggregateddemand(284:365)+22, 'LineWidth', 1.5, 'Color', 'r', 'LineStyle', ':' )  %11th october to 31st dec
plot(cycloSim.rel, 93:182, aggregateddemand(1:90)+22, 'LineWidth', 1.5, 'Color', 'r', 'LineStyle', ':' )    %1st jan to 1st april
plot(cycloSim.rel, 183:365, aggregateddemand(91:273)+22, 'LineWidth', 1.5, 'Color', 'r', 'LineStyle', '-' ) % 1st april
cycloSim.leg = legend(cycloSim.rel, [{'POP'},solsName,{'Demand'}] );

timeS = datetime(1999,1,1)+(0:(length(h)-1));
timeM = ones( size(timeS) );
timeD = myDOY(timeS);
timeM( timeD>90 & timeD<284 ) = 2;
timeT = diff(timeM);
st_idx = 1;
end_idx = find(timeT~=0,1,'first');
while ~isempty(end_idx)
    plot(fullSim.rel, st_idx:end_idx, 22+aggregateddemand(timeD(st_idx:end_idx)), 'LineWidth', thiD(timeM(st_idx)), 'Color', 'r', 'LineStyle', styD(timeM(st_idx)));
    
    st_idx = end_idx+1;
    timeT(end_idx) = 0;
    end_idx = find(timeT~=0,1,'first');
end
end_idx = length(h);
plot(fullSim.rel, st_idx:end_idx, 22+aggregateddemand(timeD(st_idx:end_idx)), 'LineWidth', thiD(timeM(st_idx)), 'Color', 'r', 'LineStyle', styD(timeM(st_idx)));

fullSim.leg = legend(fullSim.rel, [{'POP'},solsName,{'','Demand'}] );
clear st_idx end_idx timeS timeT timeD timeM stYD thiD
%%

function solnum = getN( rSet )
    rSet( rSet(:,1)>=5 | rSet(:,3) < 7 | rSet(:,3) > 13 ,2) = inf;
    
    [~, solnum] = min( rSet(:,2) );
end

function synchronize_axis_XLim(~, ~)
    cfig = gcf;
    if isa(cfig.Children, 'matlab.graphics.layout.TiledChartLayout' )
        % diamo per scontato almeno due assi
        axisMask = false( size( cfig.Children.Children ) );
        for idx = 1:length(axisMask)
            axisMask(idx) = isa(cfig.Children.Children(idx), 'matlab.graphics.axis.Axes' );
        end
        ref_idx = find( axisMask, 1, 'last'); % the first plot is usually at the end
        axisMask(ref_idx) = false; % don't copy the informations here
        for idx = 1:length(axisMask)
            if axisMask(idx)
                xlim( cfig.Children.Children(idx), cfig.Children.Children(ref_idx).XLim );
            end
        end
    end
end