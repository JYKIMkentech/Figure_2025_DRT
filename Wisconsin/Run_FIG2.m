%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fig2_modified_subplots_configurable_DOTTED.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;

%% (0) USER-CONTROLLABLE SETTINGS

% Figure size
figWidth  = 20;  
figHeight = 12;

% Subplot layout
nRow = 2; 
nCol = 3;
leftMargin   = 0.12;
rightMargin  = 0.07;
topMargin    = 0.12;
bottomMargin = 0.14;
gapX = 0.09;
gapY = 0.16;

% (e)-subplot scaling
e_subplotWidthFactor  = 1.1;   % width multiplier
e_subplotHeightFactor = 1.1;   % height multiplier
e_subplotLeftShift    = -0.02; 

% Font sizes
axisTickFontSize   = 6;
axisLabelFontSize  = 6;
legendFontSize     = 6;
annotationFontSize = 9;
legendItemTokenSizeManual = [9, 6];

% (e)-subplot label font sizes & label offsets
e_axisLabelFontSize  = 7;
e_labelOffsetX       = 0;  
e_labelOffsetY       = 0;  
e_labelOffsetZ       = 0;  

% line widths
lineWidthMeas = 1.0;
lineWidthEst  = 1.0;
lineWidthCurr = 1.0;
lineWidthSOC  = 1.0;

% annotation position offsets
annotationOffsetX = -0.06;
annotationOffsetY = 1.11;
annotationBoxW    = 0.03;
annotationBoxH    = 0.03;

% Legend locations
legendLoc_a = 'best';
legendLoc_b = 'best';
legendLoc_c = [0.84 0.77 0.1 0.1];
legendLoc_d = 'best';
legendLoc_f = [0.84 0.32 0.1 0.1];

% A palette of colors for convenience
p_colors = [
    0.00000, 0.45098, 0.76078;  % #1 (blueish)
    0.93725, 0.75294, 0.00000;  % #2 (gold)
    0.80392, 0.32549, 0.29803;  % #3 (red-ish)
    0.12549, 0.52157, 0.30588;  % #4 (green)
    0.57255, 0.36863, 0.62353;  % #5 (purple)
    0.88235, 0.52941, 0.15294;  % #6 (orange)
    0.30196, 0.73333, 0.83529;  % #7 (light blue-cyan)
    0.93333, 0.29803, 0.59216;  % #8 (pinkish)
    0.49412, 0.38039, 0.28235;  % #9 (brownish)
    0.45490, 0.46275, 0.47059;  % #10 (gray)
    0.00000, 0.00000, 0.00000;  % #11 (black)
];

% Define colors for subplot (d) so that each trip’s meas/est share a hue
colorTrip1Meas = [0.0, 0.45, 0.76];     
colorTrip1Est  = colorTrip1Meas * 0.7;  

colorTrip5Meas  = [0.7,  0,    0   ];
colorTrip5Est   = [1.0,  0,    0   ];

colorTrip13Meas = [0,    0.7,  0.7 ];
colorTrip13Est  = [0,    1.0,  1.0 ];

%% (1) Create figure and compute subplot positions

figure('Units','centimeters','Position',[3 3 figWidth figHeight]);

subplotWidth  = (1 - leftMargin - rightMargin - (nCol-1)*gapX) / nCol;
subplotHeight = (1 - topMargin - bottomMargin - (nRow-1)*gapY) / nRow;

pos = zeros(nRow*nCol,4);

row1_y = 1 - topMargin - subplotHeight;
pos(1,:) = [leftMargin, row1_y, subplotWidth, subplotHeight];
pos(2,:) = [leftMargin+1*(subplotWidth+gapX), row1_y, subplotWidth, subplotHeight];
pos(3,:) = [leftMargin+2*(subplotWidth+gapX), row1_y, subplotWidth, subplotHeight];

row2_y = row1_y - subplotHeight - gapY;
pos(4,:) = [leftMargin, row2_y, subplotWidth, subplotHeight];
pos(5,:) = [leftMargin+1*(subplotWidth+gapX), row2_y, subplotWidth, subplotHeight];
pos(6,:) = [leftMargin+2*(subplotWidth+gapX), row2_y, subplotWidth, subplotHeight];

% (e) subplot size/position adjustments
pos(5,3) = pos(5,3) * e_subplotWidthFactor; 
pos(5,4) = pos(5,4) * e_subplotHeightFactor;
pos(5,1) = pos(5,1) + e_subplotLeftShift;   

%% (2) Load data (example only)
load('G:\공유 드라이브\Battery Software Lab\Projects\DRT\Wisconsin_DRT\udds_data_soc_results.mat',...
     'udds_data_soc_results');
num_trips = length(udds_data_soc_results);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (a) Trip #5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(1,:)); box on;
trip_idx = 5;
t      = udds_data_soc_results(trip_idx).t;
V_meas = udds_data_soc_results(trip_idx).V;
V_drt  = udds_data_soc_results(trip_idx).V_est;
I      = udds_data_soc_results(trip_idx).I;

yyaxis left
h1 = plot(t, V_meas,...
    'LineWidth', lineWidthMeas,...
    'Color', p_colors(1,:),...
    'LineStyle','-',...
    'DisplayName','Meas.V');
hold on;

% --- Est.V를 dotted(:)로 표시 ---
h2 = plot(t, V_drt, ...
    'Color', p_colors(3,:),...
    'LineStyle',':', ...    % dotted
    'LineWidth',1.2,...
    'DisplayName','Est.V');

ylabel('Voltage [V]','FontSize', axisLabelFontSize);
ylim([3.8 4.01]); 
yticks(3.8:0.1:4.0);

yyaxis right
h3 = plot(t, I,...
    'LineWidth', lineWidthCurr,...
    'Color', p_colors(4,:),...
    'LineStyle','-',...
    'DisplayName','Current');
ylabel('Current [A]','FontSize', axisLabelFontSize);
ylim([-4 10]);

xlabel('Time [s]','FontSize', axisLabelFontSize);
xlim([0 100]);
yyaxis left;  set(gca,'FontSize',axisTickFontSize,'YColor','k','XColor','k');
yyaxis right; set(gca,'FontSize',axisTickFontSize,'YColor','k','XColor','k');

leg_a = legend([h1 h2 h3],'Location',legendLoc_a,'Orientation','horizontal');
set(leg_a,'FontSize',legendFontSize,'Box','off',...
    'ItemTokenSize',legendItemTokenSizeManual);

annotation('textbox',...
   [pos(1,1)+annotationOffsetX, ...
    pos(1,2)+pos(1,4)*annotationOffsetY,...
    annotationBoxW, annotationBoxH],...
   'String','(a)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (b) Trip #5 DRT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(2,:)); box on;
theta_5       = udds_data_soc_results(trip_idx).theta_discrete(:);
gamma_avg_5   = udds_data_soc_results(trip_idx).gamma_avg(:);
gamma_lower_5 = udds_data_soc_results(trip_idx).gamma_lower(:);
gamma_upper_5 = udds_data_soc_results(trip_idx).gamma_upper(:);

hf = fill([theta_5; flipud(theta_5)],...
          [gamma_lower_5; flipud(gamma_upper_5)],...
          p_colors(1,:));
set(hf,'FaceAlpha',0.2,'EdgeColor','none','HandleVisibility','off');
hold on;

plot(theta_5, gamma_avg_5, 'LineWidth',1.2,'Color',p_colors(1,:),'HandleVisibility','off');
plot(NaN,NaN,'LineWidth',1.2,'LineStyle','-',...
    'Color',p_colors(1,:),'Marker','s','MarkerFaceColor',p_colors(1,:),...
    'DisplayName','Est.\gamma');

xlabel('\theta = ln(\tau [s])','Interpreter','tex','FontSize',axisLabelFontSize);
ylabel('\gamma [\Omega]','FontSize',axisLabelFontSize);

set(gca,'FontSize',axisTickFontSize,'YColor','k','XColor','k');
yticks(0:0.02:0.12)
xlim([-1 6]);

leg_b = legend('Location',legendLoc_b,'Box','off','FontSize',legendFontSize);
set(leg_b, 'ItemTokenSize', [10, 4]);

annotation('textbox',...
   [pos(2,1)+annotationOffsetX, ...
    pos(2,2)+pos(2,4)*annotationOffsetY,...
    annotationBoxW, annotationBoxH],...
   'String','(b)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) Trip #5 SOC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(3,:)); box on;
CC_5    = udds_data_soc_results(trip_idx).CC_SOC;
SOC1RC  = udds_data_soc_results(trip_idx).SOC_1RC;
SOC2RC  = udds_data_soc_results(trip_idx).SOC_2RC;
SOCDRT  = udds_data_soc_results(trip_idx).SOC_DRT;
SOCtrue = udds_data_soc_results(trip_idx).True_SOC;
t_5     = udds_data_soc_results(trip_idx).t;

p1c = plot(t_5, CC_5,   'LineWidth', lineWidthSOC, 'Color', p_colors(1,:), 'DisplayName','CC'); hold on;
p2c = plot(t_5, SOC1RC, 'LineWidth', lineWidthSOC, 'Color', p_colors(3,:), 'DisplayName','1RC');
p3c = plot(t_5, SOC2RC, 'LineWidth', lineWidthSOC, 'Color', p_colors(2,:), 'DisplayName','2RC');
p4c = plot(t_5, SOCDRT, 'LineWidth', lineWidthSOC, 'Color', p_colors(4,:), 'DisplayName','DRT');
p5c = plot(t_5, SOCtrue,'LineWidth', lineWidthSOC, 'Color', p_colors(10,:),'DisplayName','True SOC');

xlabel('Time [s]','FontSize',axisLabelFontSize);
ylabel('SOC','FontSize',axisLabelFontSize);
set(gca,'FontSize',axisTickFontSize,'YColor','k','XColor','k');
yticks(0.66:0.04:0.78)

leg_c = legend([p1c p2c p3c p4c p5c],'Location',legendLoc_c);
set(leg_c,'FontSize',legendFontSize,'Box','off','ItemTokenSize',legendItemTokenSizeManual);

annotation('textbox',...
   [pos(3,1)+annotationOffsetX, ...
    pos(3,2)+pos(3,4)*annotationOffsetY,...
    annotationBoxW, annotationBoxH],...
   'String','(c)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (d) Compare V for Trip1,5,13
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(4,:)); box on;
tripList = [1, 5, 13];
legItems = gobjects(1,6);

%-- Trip1 색상 정의(더 연하게 만들거나 채도 낮추기)
colorTrip1Meas = [0.0, 0.45, 0.76];               % 진한 파란색
colorTrip1Est  = 1 - 0.5*(1 - colorTrip1Meas);    % 파란색을 50% 정도 '화이트'에 섞어 밝게

%-- Trip5 색상 정의
colorTrip5Meas = [0.70, 0.00, 0.00];              % 진한 빨간색
colorTrip5Est  = 1 - 0.5*(1 - colorTrip5Meas);    % 50% 더 연하게

%-- Trip13 색상 정의
colorTrip13Meas = [0.00, 0.70, 0.70];             % 청록 계열
colorTrip13Est  = 1 - 0.5*(1 - colorTrip13Meas);  % 50% 더 연하게

%--- Trip1
idx = tripList(1);
t1 = udds_data_soc_results(idx).t;
v1_meas = udds_data_soc_results(idx).V;
v1_drt  = udds_data_soc_results(idx).V_est;

% Meas.V(1) : 원색+굵은 실선
legItems(1) = plot(t1, v1_meas, ...
   'LineWidth', 1,...
   'Color', colorTrip1Meas,...
   'LineStyle','-',...
   'DisplayName','Meas.V(1)');
hold on;

% Est.V(1) : 밝은색+점선
legItems(2) = plot(t1, v1_drt, ...
   'LineWidth', 1.0,...
   'Color', colorTrip1Est,...
   'LineStyle',':',...
   'DisplayName','Est.V(1)');

%--- Trip5
idx = tripList(2);
t5 = udds_data_soc_results(idx).t;
v5_meas = udds_data_soc_results(idx).V;
v5_drt  = udds_data_soc_results(idx).V_est;

legItems(3) = plot(t5, v5_meas,...
   'LineWidth', 1,...
   'Color', colorTrip5Meas,...
   'LineStyle','-',...
   'DisplayName','Meas.V(5)');

legItems(4) = plot(t5, v5_drt,...
   'LineWidth', 1.0,...
   'Color', colorTrip5Est,...
   'LineStyle',':',...
   'DisplayName','Est.V(5)');

%--- Trip13
idx = tripList(3);
t13 = udds_data_soc_results(idx).t;
v13_meas = udds_data_soc_results(idx).V;
v13_drt  = udds_data_soc_results(idx).V_est;

legItems(5) = plot(t13, v13_meas,...
   'LineWidth', 1,...
   'Color', colorTrip13Meas,...
   'LineStyle','-',...
   'DisplayName','Meas.V(13)');

legItems(6) = plot(t13, v13_drt,...
   'LineWidth', 1.0,...
   'Color', colorTrip13Est,...
   'LineStyle',':',...
   'DisplayName','Est.V(13)');

xlabel('Time [s]','FontSize', axisLabelFontSize);
ylabel('Voltage [V]','FontSize', axisLabelFontSize);
xlim([0 1500]);
ylim([3.17 4.3]);
set(gca,'FontSize',axisTickFontSize,'YColor','k','XColor','k');

% Legend: (실선 3개, 점선 3개 순)
leg_d = legend([legItems(1), legItems(3), legItems(5), ...
                legItems(2), legItems(4), legItems(6)], ...
               'Orientation','horizontal','NumColumns',3,...
               'Location', legendLoc_d);
set(leg_d,'Box','off','FontSize',legendFontSize-2,...
          'ItemTokenSize',legendItemTokenSizeManual);

annotation('textbox',...
   [pos(4,1)+annotationOffsetX, ...
    pos(4,2)+pos(4,4)*annotationOffsetY,...
    annotationBoxW, annotationBoxH],...
   'String','(d)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (e) 3D DRT: set theta range to [-1,6]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(5,:)); box on;

numTripsToPlot = num_trips - 6;  % or however many you'd like
bigCmap = parula(64);           
idxCmap = round(linspace(1,64,numTripsToPlot));

% 예시: 각 trip의 mid-SOC 계산
soc_mid_all = zeros(numTripsToPlot,1);
for s = 1:numTripsToPlot
    soc_vals = udds_data_soc_results(s).SOC_DRT;
    soc_mid_all(s) = mean(soc_vals);
end

% 3D plot
for s = 1:numTripsToPlot
    sox   = soc_mid_all(s);
    thvec = udds_data_soc_results(s).theta_discrete;
    gmvec = udds_data_soc_results(s).gamma_est;
    thisColor = bigCmap(idxCmap(s),:);  
    plot3( sox*ones(size(thvec)), thvec, gmvec,...
           'LineWidth',1,'Color',thisColor,...
           'DisplayName',sprintf('Trip %d',s));
    hold on;
end

hx = xlabel('SOC','FontSize', e_axisLabelFontSize+1);
hy = ylabel('\theta = ln(\tau [s])','Interpreter','tex','FontSize', e_axisLabelFontSize+1);
hz = zlabel('\gamma [\Omega]','FontSize', e_axisLabelFontSize+1);

% (Optional) 라벨 위치 조정 (예시)
posX = get(hx, 'Position');  
posX(1) = posX(1)-0.1; 
posX(2) = posX(2)+9;  
set(hx, 'Position', posX, 'Rotation', 23);

posY = get(hy, 'Position');
posY(1) = posY(1)+0.3;      
posY(2) = posY(2)-7;
set(hy, 'Position', posY, 'Rotation', -18);

view(135,30);
xticks(0.2:0.2:1);
zlim([0 0.1]); grid on;
ylim([-1 6]); 

annotation('textbox',...
    'Units','normalized',...
    'Position',[0.363, 0.46, 0.03, 0.03], ...
    'String','(e)',...
    'FontSize',annotationFontSize,...
    'FontWeight','bold',...
    'LineStyle','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (f) Full SOC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(6,:)); box on;
full_t2   = [];
full_cc   = [];
full_1rc  = [];
full_2rc  = [];
full_drt  = [];
full_true = [];

% 간단 예시: 여러 Trip의 SOC를 이어붙이기
for s = 1:numTripsToPlot
    full_t2   = [full_t2;   udds_data_soc_results(s).Time_duration];
    full_cc   = [full_cc;   udds_data_soc_results(s).CC_SOC];
    full_1rc  = [full_1rc;  udds_data_soc_results(s).SOC_1RC];
    full_2rc  = [full_2rc;  udds_data_soc_results(s).SOC_2RC];
    full_drt  = [full_drt;  udds_data_soc_results(s).SOC_DRT];
    full_true = [full_true; udds_data_soc_results(s).True_SOC];
end

plot(full_t2, full_cc,   'LineWidth', lineWidthSOC, 'Color', p_colors(1,:), ...
    'DisplayName','CC'); hold on;
plot(full_t2, full_1rc,  'LineWidth', lineWidthSOC, 'Color', p_colors(3,:), ...
    'DisplayName','1RC');
plot(full_t2, full_2rc,  'LineWidth', lineWidthSOC, 'Color', p_colors(2,:), ...
    'DisplayName','2RC');
plot(full_t2, full_drt,  'LineWidth', lineWidthSOC, 'Color', p_colors(4,:), ...
    'DisplayName','DRT');
plot(full_t2, full_true, 'LineWidth', lineWidthSOC, 'Color', p_colors(10,:),...
    'DisplayName','True SOC');

xlabel('Time [s]','FontSize', axisLabelFontSize);
ylabel('SOC','FontSize', axisLabelFontSize);
xtickformat('%.0f');
set(gca,'FontSize',axisTickFontSize,'YColor','k','XColor','k');

leg_f = legend('Location',legendLoc_f);
set(leg_f,'FontSize',legendFontSize,'Box','off','ItemTokenSize',legendItemTokenSizeManual);

annotation('textbox',...
   [pos(6,1)+annotationOffsetX, ...
    pos(6,2)+pos(6,4)*annotationOffsetY,...
    annotationBoxW, annotationBoxH],...
   'String','(f)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%% Match screen appearance, export
set(gcf,'Renderer','opengl');
set(gcf,'InvertHardcopy','off');
set(gcf,'GraphicsSmoothing','on');

% PNG로 저장
exportgraphics(gcf,'Fig2.png','Resolution',300);

% FIG 파일도 저장
savefig(gcf,'Fig2.fig');




