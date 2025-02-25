%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run_FIG2_modified.m - (b)는 Parula 첫 번째 색상, (a)는 범례 상하공백 축소
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;

%% ========== (0) Plot 스타일/배치 파라미터 ==========

% [A] Figure 크기
figWidth  = 18;  % [cm]
figHeight = 12;  % [cm]

% [B] 폰트/선 스타일
axisTickFontSize   = 7;   % 축 눈금 폰트 크기
axisLabelFontSize  = 9;   % 축 라벨 폰트 크기
legendFontSize     = 6;   % 범례 폰트 크기
annotationFontSize = 9;   % (a),(b),(c) 라벨 폰트

% 선 굵기
lineWidthMeas = 1;
lineWidthEst  = 1;
lineWidthCurr = 1;
lineWidthSOC  = 1;

% [C] 색상 팔레트(기본)
p_colors = [
    0.00000, 0.45098, 0.76078;  % #1 (Blue)
    0.93725, 0.75294, 0.00000;  % #2 (Yellow)
    0.80392, 0.32549, 0.29803;  % #3 (Red)
    0.12549, 0.52157, 0.30588;  % #4 (Green)
    0.57255, 0.36863, 0.62353;  % #5
    0.88235, 0.52941, 0.15294;  % #6
    0.30196, 0.73333, 0.83529;  % #7
    0.93333, 0.29803, 0.59216;  % #8
    0.49412, 0.38039, 0.28235;  % #9
    0.45490, 0.46275, 0.47059   % #10
];

% [D] 서브플롯 마진 조절 (서브플롯 크기 ↓, 간격 및 바깥 여백 ↑)
nRow = 2;
nCol = 3;
leftMargin   = 0.12;  
rightMargin  = 0.07;  
topMargin    = 0.12;  
bottomMargin = 0.14;  
gapX = 0.08;          
gapY = 0.16;          

% [E] Annotation 위치
annotationOffsetX = -0.06;   
annotationOffsetY = 1.11;    
annotationBoxW    = 0.03;  
annotationBoxH    = 0.03;  

% (b) R0 텍스트 위치
R0_xOffset = 0.1;  
R0_yOffset = 0.2;   

% [F] Legend 'Position' 설정
% (a) 부분 범례 위치/크기를 살짝 조정하여 상하공백 축소
legendPosA = [0.23 0.59 0.05 0.10]; % <-- 높이 0.10으로 변경 (기존 0.15)
legendPosB = [0.40 0.75 0.05 0.10];
legendPosC = [0.72 0.59 0.05 0.15];
legendPosD = [0.13 0.13 0.05 0.15];
legendPosE = [0.52 0.59 0.05 0.15];
legendPosF = [0.72 0.14 0.05 0.15];

% [G] Legend 선 길이 (ItemTokenSize) - 범례 내부 간격
legendItemTokenSize = [2, 2];  % <-- [2, 2]로 축소 (기존 [2,3])

%% ========== (1) Figure 생성 ==========
figure('Units','centimeters','Position',[3 3 figWidth figHeight]);

%% (1-1) 서브플롯 위치 계산
subplotWidth  = (1 - leftMargin - rightMargin - (nCol-1)*gapX) / nCol;
subplotHeight = (1 - topMargin - bottomMargin - (nRow-1)*gapY) / nRow;

pos = zeros(nRow*nCol,4);

row1_y = 1 - topMargin - subplotHeight;
pos(1,:) = [leftMargin,                       row1_y, subplotWidth, subplotHeight];
pos(2,:) = [leftMargin+1*(subplotWidth+gapX), row1_y, subplotWidth, subplotHeight];
pos(3,:) = [leftMargin+2*(subplotWidth+gapX), row1_y, subplotWidth, subplotHeight];

row2_y = row1_y - subplotHeight - gapY;
pos(4,:) = [leftMargin,                       row2_y, subplotWidth, subplotHeight];
pos(5,:) = [leftMargin+1*(subplotWidth+gapX), row2_y, subplotWidth, subplotHeight];
pos(6,:) = [leftMargin+2*(subplotWidth+gapX), row2_y, subplotWidth, subplotHeight];

%% (2) 예시 데이터 불러오기 (사용자 환경에 맞게 경로 수정 필요)
load('G:\공유 드라이브\Battery Software Lab\Projects\DRT\Wisconsin_DRT\udds_data_soc_results.mat',...
     'udds_data_soc_results');
num_trips = length(udds_data_soc_results);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (a) Trip 1 전압 비교
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(1,:));
trip_idx = 1;
t       = udds_data_soc_results(trip_idx).t;
V_meas  = udds_data_soc_results(trip_idx).V;
V_drt   = udds_data_soc_results(trip_idx).V_est;
I       = udds_data_soc_results(trip_idx).I;

yyaxis left
p1 = plot(t, V_meas, 'LineWidth', lineWidthMeas, ...
    'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName', 'Meas. V');
hold on;
p2 = plot(t, V_drt,  'LineWidth', lineWidthEst,  ...
    'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName', 'Est. V');
ylabel('Voltage [V]', 'FontSize', axisLabelFontSize);

yyaxis right
p3 = plot(t, I, 'LineWidth', lineWidthCurr, ...
    'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName', 'Current');
ylabel('Current [A]', 'FontSize', axisLabelFontSize);
xlabel('Time [s]',    'FontSize', axisLabelFontSize);

yyaxis left;  set(gca, 'YColor','k','XColor','k','FontSize',axisTickFontSize);
yyaxis right; set(gca, 'YColor','k','XColor','k','FontSize',axisTickFontSize);

leg_a = legend([p1 p2 p3]);
set(leg_a, 'Position', legendPosA, ...
           'FontSize', legendFontSize, ...
           'Box','off', ...
           'ItemTokenSize', legendItemTokenSize); 

annotation('textbox', ...
   [pos(1,1)+annotationOffsetX, pos(1,2)+pos(1,4)*annotationOffsetY, ...
    annotationBoxW, annotationBoxH], ...
   'String','(a)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (b) Trip 1 DRT (색상 Parula 첫 번째로 지정)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(2,:));
theta_1 = udds_data_soc_results(trip_idx).theta_discrete;
gamma_1 = udds_data_soc_results(trip_idx).gamma_est;
R0_1    = udds_data_soc_results(trip_idx).R0_est;

% Parula 팔레트에서 첫 번째 색상 추출
cmap_b = parula(64);
plot(theta_1, gamma_1, 'LineWidth', lineWidthMeas, ...
    'Color', cmap_b(1,:), ...  % Parula 첫 번째 색상
    'LineStyle','-');
hold on;
xlabel('\theta = ln(\tau [s])', 'FontSize', axisLabelFontSize);
ylabel('\gamma [\Omega]',       'FontSize', axisLabelFontSize);

% R0 텍스트
str_R0 = sprintf('R_0 = %.3e \\Omega', R0_1);
xrange = xlim; yrange = ylim;
x_text = xrange(1) + R0_xOffset*(xrange(2)-xrange(1));
y_text = yrange(2) - R0_yOffset*(yrange(2)-yrange(1));
text(x_text, y_text, str_R0, ...
     'FontSize', axisTickFontSize, 'Interpreter','tex','Color','k');

set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

annotation('textbox', ...
   [pos(2,1)+annotationOffsetX, pos(2,2)+pos(2,4)*annotationOffsetY, ...
    annotationBoxW, annotationBoxH], ...
   'String','(b)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (c) Trip 1 SOC 비교
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(3,:));
CC_1   = udds_data_soc_results(trip_idx).CC_SOC;
SOC1RC = udds_data_soc_results(trip_idx).SOC_1RC;
SOC2RC = udds_data_soc_results(trip_idx).SOC_2RC;
SOCDRT = udds_data_soc_results(trip_idx).SOC_DRT;

p1c = plot(t, CC_1,   'LineWidth', lineWidthSOC, ...
    'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','CC'); hold on;
p2c = plot(t, SOC1RC, 'LineWidth', lineWidthSOC, ...
    'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','1RC');
p3c = plot(t, SOC2RC, 'LineWidth', lineWidthSOC, ...
    'Color', p_colors(2,:), 'LineStyle','-', 'DisplayName','2RC');
p4c = plot(t, SOCDRT, 'LineWidth', lineWidthSOC, ...
    'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','DRT');

xlabel('Time [s]', 'FontSize', axisLabelFontSize);
ylabel('SOC',      'FontSize', axisLabelFontSize);

leg_c = legend([p1c p2c p3c p4c]);
set(leg_c, 'Position', legendPosC, ...
           'FontSize', legendFontSize,...
           'Box','off', ...
           'ItemTokenSize', legendItemTokenSize);

set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

annotation('textbox', ...
   [pos(3,1)+annotationOffsetX, pos(3,2)+pos(3,4)*annotationOffsetY, ...
    annotationBoxW, annotationBoxH], ...
   'String','(c)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (d) Trip 전체 전압 비교 - Marker & Dashed Line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(4,:));
full_t    = [];
full_V    = [];
full_Vdrt = [];

for s = 1:num_trips-1
    full_t    = [full_t;    udds_data_soc_results(s).Time_duration];
    full_V    = [full_V;    udds_data_soc_results(s).V];
    full_Vdrt = [full_Vdrt; udds_data_soc_results(s).V_est];
end

% --- Meas. V: 파랑 + 마커 + 실선
p1d = plot(full_t, full_V, ...
    'Color', p_colors(1,:), ...
    'LineWidth', 1.2, ...
    'LineStyle','-', ...
    'Marker','o','MarkerSize',3, ...
    'MarkerIndices', 1:500:length(full_t), ... % 마커 간격
    'DisplayName','Meas. V');
hold on;

% --- Est. V: 빨강 + 점선
p2d = plot(full_t, full_Vdrt, ...
    'Color', p_colors(3,:), ...
    'LineWidth', 1.2, ...
    'LineStyle','--', ...
    'DisplayName','Est. V');

ylabel('Voltage [V]', 'FontSize', axisLabelFontSize);
xlabel('Time [s]',    'FontSize', axisLabelFontSize);
set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

leg_d = legend([p1d p2d]);
set(leg_d, 'Position', legendPosD, ...
           'FontSize', legendFontSize,...
           'Box','off', ...
           'ItemTokenSize', legendItemTokenSize);

annotation('textbox', ...
   [pos(4,1)+annotationOffsetX, pos(4,2)+pos(4,4)*annotationOffsetY, ...
    annotationBoxW, annotationBoxH], ...
   'String','(d)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (e) Trip 전체 3D DRT - Parula
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(5,:));
hold on;

numTripsToPlot = num_trips - 1;
cmap = parula(numTripsToPlot);  % Parula 컬러맵을 사용해 그라디언트 색 지정
soc_mid_all = zeros(numTripsToPlot,1);

for s = 1:numTripsToPlot
    soc_vals = udds_data_soc_results(s).SOC_DRT;
    soc_mid_all(s) = mean(soc_vals);
end

for s = 1:numTripsToPlot
    sox   = soc_mid_all(s);
    thvec = udds_data_soc_results(s).theta_discrete;
    gmvec = udds_data_soc_results(s).gamma_est;

    plot3(sox*ones(size(thvec)), thvec, gmvec,...
          'LineWidth', 1.2, ...
          'Color', cmap(s,:), ...   % Parula에서 s번째 색
          'DisplayName', sprintf('Trip %d',s));
end

xlabel('SOC', 'FontSize', axisLabelFontSize);
ylabel('\theta = ln(\tau [s])', 'FontSize', axisLabelFontSize);
zlabel('\gamma [\Omega]',       'FontSize', axisLabelFontSize);
view(135, 30);
set(gca, 'FontSize', axisTickFontSize, ...
         'YColor','k','XColor','k','ZColor','k');

annotation('textbox', ...
   [pos(5,1)+annotationOffsetX, pos(5,2)+pos(5,4)*annotationOffsetY, ...
    annotationBoxW, annotationBoxH], ...
   'String','(e)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (f) Trip 전체 SOC 비교
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(6,:));
full_t2   = [];
full_cc   = [];
full_1rc  = [];
full_2rc  = [];
full_drt  = [];

for s = 1:numTripsToPlot
    full_t2  = [full_t2;  udds_data_soc_results(s).Time_duration];
    full_cc  = [full_cc;  udds_data_soc_results(s).CC_SOC];
    full_1rc = [full_1rc; udds_data_soc_results(s).SOC_1RC];
    full_2rc = [full_2rc; udds_data_soc_results(s).SOC_2RC];
    full_drt = [full_drt; udds_data_soc_results(s).SOC_DRT];
end

p1f = plot(full_t2, full_cc,  'LineWidth', lineWidthSOC,...
    'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','CC'); hold on;
p2f = plot(full_t2, full_1rc, 'LineWidth', lineWidthSOC,...
    'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','1RC');
p3f = plot(full_t2, full_2rc, 'LineWidth', lineWidthSOC,...
    'Color', p_colors(2,:), 'LineStyle','-', 'DisplayName','2RC');
p4f = plot(full_t2, full_drt, 'LineWidth', lineWidthSOC,...
    'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','DRT');

xlabel('Time [s]', 'FontSize', axisLabelFontSize);
ylabel('SOC',      'FontSize', axisLabelFontSize);
xtickformat('%.0f');

leg_f = legend([p1f p2f p3f p4f]);
set(leg_f, 'Position', legendPosF, ...
           'FontSize', legendFontSize,...
           'Box','off', ...
           'ItemTokenSize', legendItemTokenSize);

set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

annotation('textbox', ...
   [pos(6,1)+annotationOffsetX, pos(6,2)+pos(6,4)*annotationOffsetY, ...
    annotationBoxW, annotationBoxH], ...
   'String','(f)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%% 최종 그래픽 내보내기
exportgraphics(gcf, 'Fig2.png','Resolution',300);



