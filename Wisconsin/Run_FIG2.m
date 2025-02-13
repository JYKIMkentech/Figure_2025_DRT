clc; clear; close all;

%% ========== (0) Plot 스타일/배치 파라미터 ==========

% [A] Figure 크기
figWidth  = 18;  % [cm]
figHeight = 12;  % [cm]

% [B] 폰트 사이즈
axisTickFontSize  = 4;   % 축 눈금 폰트 크기
axisLabelFontSize = 5;   % 축 라벨 폰트 크기
legendFontSize    = 6;   % 범례 폰트 사이즈

% 선 굵기
lineWidthMeas = 1;
lineWidthEst  = 1;
lineWidthCurr = 1;
lineWidthSOC  = 1;

% [C] 색상 팔레트
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

% [D] 서브플롯 배치 관련
nRow = 2;
nCol = 3;
leftMargin   = 0.08;  
rightMargin  = 0.03;  
topMargin    = 0.07;  
bottomMargin = 0.10;  
gapX = 0.05;          
gapY = 0.13;          

% [E] Annotation( (a), (b), (c)... ) 위치 지정
annotationOffsetX = -0.06;   
annotationOffsetY = 1.11;    
annotationBoxW    = 0.03;  
annotationBoxH    = 0.03;  

% (b)에서 R0 텍스트 위치(축 범위를 기준으로 비율)
R0_xOffset = -0.1;  
R0_yOffset = 0.2;   

% [F] Legend 'Position' 설정 (각 서브플롯별)
legendPosA = [0.23 0.58 0.10 0.15];
legendPosB = [0.40 0.75 0.10 0.10];
legendPosC = [0.69 0.58 0.10 0.15];
legendPosD = [0.07 0.1  0.10 0.15];
legendPosE = [0.52 0.58 0.10 0.15];
legendPosF = [0.69 0.10 0.10 0.15];

% [G] Legend 선 길이 (ItemTokenSize)
legendItemTokenSize = [3, 4];

%% ========== (1) Figure 생성 ==========

figure('Units','centimeters','Position',[3 3 figWidth figHeight]);

%% (1-1) 서브플롯 배치 계산
subplotWidth  = (1 - leftMargin - rightMargin - (nCol-1)*gapX) / nCol;
subplotHeight = (1 - topMargin - bottomMargin - (nRow-1)*gapY) / nRow;

pos = zeros(nRow*nCol,4);

row1_y = 1 - topMargin - subplotHeight;
pos(1,:) = [leftMargin,                       row1_y, subplotWidth, subplotHeight];  % (a)
pos(2,:) = [leftMargin+1*(subplotWidth+gapX), row1_y, subplotWidth, subplotHeight];  % (b)
pos(3,:) = [leftMargin+2*(subplotWidth+gapX), row1_y, subplotWidth, subplotHeight];  % (c)

row2_y = row1_y - subplotHeight - gapY;
pos(4,:) = [leftMargin,                       row2_y, subplotWidth, subplotHeight];  % (d)
pos(5,:) = [leftMargin+1*(subplotWidth+gapX), row2_y, subplotWidth, subplotHeight];  % (e)
pos(6,:) = [leftMargin+2*(subplotWidth+gapX), row2_y, subplotWidth, subplotHeight];  % (f)

%% (2) 예시 데이터 불러오기
load('G:\공유 드라이브\Battery Software Lab\Projects\DRT\Wisconsin_DRT\udds_data_soc_results.mat',...
     'udds_data_soc_results');
num_trips = length(udds_data_soc_results);

%% ============== (a) Trip 1 전압 비교 ==============
subplot('Position', pos(1,:));
trip_idx = 1;
t       = udds_data_soc_results(trip_idx).t;
V_meas  = udds_data_soc_results(trip_idx).V;
V_drt   = udds_data_soc_results(trip_idx).V_est;
I       = udds_data_soc_results(trip_idx).I;

yyaxis left
p1 = plot(t, V_meas, 'LineWidth', lineWidthMeas, ...
    'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName', 'Mea. V');
hold on;
p2 = plot(t, V_drt,  'LineWidth', lineWidthEst,  ...
    'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName', 'Est. V');
ylabel('Voltage [V]', 'FontSize', axisLabelFontSize);

yyaxis right
p3 = plot(t, I, 'LineWidth', lineWidthCurr, ...
    'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName', 'Current');
ylabel('Current [A]', 'FontSize', axisLabelFontSize);
xlabel('Time [s]', 'FontSize', axisLabelFontSize);

% 눈금 폰트 설정
yyaxis left;  set(gca, 'YColor','k','XColor','k', 'FontSize', axisTickFontSize);
yyaxis right; set(gca, 'YColor','k','XColor','k', 'FontSize', axisTickFontSize);

leg_a = legend([p1 p2 p3]);
set(leg_a, 'Position', legendPosA, 'FontSize', legendFontSize, ...
           'Box','off', 'ItemTokenSize', legendItemTokenSize);

annotation('textbox', [pos(1,1)+annotationOffsetX, ...
                       pos(1,2)+pos(1,4)*annotationOffsetY, ...
                       annotationBoxW, annotationBoxH], ...
           'String','(a)','FontSize',10,'FontWeight','bold','LineStyle','none');

%% =============== (b) Trip 1 DRT ===============
subplot('Position', pos(2,:));
theta_1 = udds_data_soc_results(trip_idx).theta_discrete;
gamma_1 = udds_data_soc_results(trip_idx).gamma_est;
R0_1    = udds_data_soc_results(trip_idx).R0_est;

plot(theta_1, gamma_1, 'LineWidth', 1.5, ...
    'Color', p_colors(8,:), 'LineStyle','-', 'DisplayName','DRT');
hold on;
xlabel('\theta = ln(\tau [s])', 'FontSize', axisLabelFontSize);
ylabel('\gamma [\Omega]', 'FontSize', axisLabelFontSize);

% R0 텍스트
str_R0 = sprintf('R_0 = %.3e \\Omega', R0_1);
xrange = xlim; yrange = ylim;
x_text = xrange(1) + R0_xOffset*(xrange(2)-xrange(1));
y_text = yrange(2) - R0_yOffset*(yrange(2)-yrange(1));
text(x_text, y_text, str_R0, 'FontSize', axisTickFontSize, ...
     'Interpreter','tex','Color','k');

set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

annotation('textbox', [pos(2,1)+annotationOffsetX,...
                       pos(2,2)+pos(2,4)*annotationOffsetY,...
                       annotationBoxW, annotationBoxH], ...
           'String','(b)','FontSize',10,'FontWeight','bold','LineStyle','none');

%% =========== (c) Trip 1 SOC 비교 ===========
subplot('Position', pos(3,:));
CC_1   = udds_data_soc_results(trip_idx).CC_SOC;
SOC1RC = udds_data_soc_results(trip_idx).SOC_1RC;
SOC2RC = udds_data_soc_results(trip_idx).SOC_2RC;
SOCDRT = udds_data_soc_results(trip_idx).SOC_DRT;

p1c = plot(t, CC_1,   'LineWidth', lineWidthSOC,...
    'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','CC'); hold on;
p2c = plot(t, SOC1RC, 'LineWidth', lineWidthSOC,...
    'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','1RC');
p3c = plot(t, SOC2RC, 'LineWidth', lineWidthSOC,...
    'Color', p_colors(2,:), 'LineStyle','-', 'DisplayName','2RC');
p4c = plot(t, SOCDRT, 'LineWidth', lineWidthSOC,...
    'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','DRT');

xlabel('Time [s]', 'FontSize', axisLabelFontSize);
ylabel('SOC', 'FontSize', axisLabelFontSize);

leg_c = legend([p1c p2c p3c p4c]);
set(leg_c, 'Position', legendPosC, 'FontSize', legendFontSize, ...
           'Box','off', 'ItemTokenSize', legendItemTokenSize);

set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

annotation('textbox', [pos(3,1)+annotationOffsetX,...
                       pos(3,2)+pos(3,4)*annotationOffsetY,...
                       annotationBoxW, annotationBoxH], ...
           'String','(c)','FontSize',10,'FontWeight','bold','LineStyle','none');

%% ========= (d) Trip 전체 전압 비교 =========
subplot('Position', pos(4,:));
full_t    = [];
full_V    = [];
full_Vdrt = [];

for s = 1:num_trips-1
    full_t    = [full_t;    udds_data_soc_results(s).Time_duration];
    full_V    = [full_V;    udds_data_soc_results(s).V];
    full_Vdrt = [full_Vdrt; udds_data_soc_results(s).V_est];
end

p1d = plot(full_t, full_V, 'LineWidth', lineWidthMeas,...
    'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','Mea. V');
hold on;
p2d = plot(full_t, full_Vdrt, 'LineWidth', lineWidthEst,...
    'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','Est. V');
ylabel('Voltage [V]', 'FontSize', axisLabelFontSize);
xlabel('Time [s]', 'FontSize', axisLabelFontSize);

set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

leg_d = legend([p1d p2d]);
set(leg_d, 'Position', legendPosD, 'FontSize', legendFontSize, ...
           'Box','off', 'ItemTokenSize', legendItemTokenSize);

annotation('textbox', [pos(4,1)+annotationOffsetX,...
                       pos(4,2)+pos(4,4)*annotationOffsetY,...
                       annotationBoxW, annotationBoxH], ...
           'String','(d)','FontSize',10,'FontWeight','bold','LineStyle','none');

%% =========== (e) Trip 전체 3D DRT ===========
subplot('Position', pos(5,:)); 
hold on;
soc_mid_all = zeros(num_trips,1);
for s = 1:num_trips-1
    soc_vals = udds_data_soc_results(s).SOC_DRT;
    soc_mid_all(s) = mean(soc_vals);
end

for s = 1:num_trips-1
    sox   = soc_mid_all(s);
    thvec = udds_data_soc_results(s).theta_discrete;
    gmvec = udds_data_soc_results(s).gamma_est;
    plot3(sox*ones(size(thvec)), thvec, gmvec,...
          'LineWidth', 1.2, 'Color', p_colors(mod(s-1,10)+1,:), ...
          'DisplayName', sprintf('Trip %d',s));
end

xlabel('SOC', 'FontSize', axisLabelFontSize);
ylabel('\theta = ln(\tau [s])', 'FontSize', axisLabelFontSize);
zlabel('\gamma [\Omega]', 'FontSize', axisLabelFontSize);
view(135, 30);
set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k','ZColor','k');

annotation('textbox', [pos(5,1)+annotationOffsetX,...
                       pos(5,2)+pos(5,4)*annotationOffsetY,...
                       annotationBoxW, annotationBoxH], ...
           'String','(e)','FontSize',10,'FontWeight','bold','LineStyle','none');

%% =========== (f) Trip 전체 SOC 비교 ===========
subplot('Position', pos(6,:));
full_t2   = [];
full_cc   = [];
full_1rc  = [];
full_2rc  = [];
full_drt  = [];

for s = 1:num_trips-1
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
ylabel('SOC', 'FontSize', axisLabelFontSize);
xtickformat('%.0f');  % x축 정수 표기

leg_f = legend([p1f p2f p3f p4f]);
set(leg_f, 'Position', legendPosF, 'FontSize', legendFontSize, ...
           'Box','off', 'ItemTokenSize', legendItemTokenSize);

set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

annotation('textbox', [pos(6,1)+annotationOffsetX,...
                       pos(6,2)+pos(6,4)*annotationOffsetY,...
                       annotationBoxW, annotationBoxH], ...
           'String','(f)','FontSize',10,'FontWeight','bold','LineStyle','none');

%% 최종 그래픽 내보내기
exportgraphics(gcf, 'Fig2.png','Resolution',300);


