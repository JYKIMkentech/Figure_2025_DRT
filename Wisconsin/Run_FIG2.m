%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run_FIG2_modified_narrowLegend_D.m
% 목적: (a),(d) 투명도 적용 & 범례 색상 진하게 표시 + (d) 범례 폭 좁혀 간격 줄이기
%       + (e) SOC 축 눈금을 0.2 단위로 설정 및 박스 표시(box on)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;

%% ========== (0) Plot 스타일/배치 파라미터 ==========
% [A] Figure 크기
figWidth  = 18;  % [cm]
figHeight = 12;  % [cm]

% [B] 폰트/선 스타일
axisTickFontSize   = 6;   % 축 눈금 폰트 크기
axisLabelFontSize  = 6;   % 축 라벨 폰트 크기
legendFontSize     = 6;   % 범례 폰트 크기
annotationFontSize = 9;   % (a),(b),(c) 라벨 폰트
legendItemTokenSizeManual = [10, 6];  % 범례 심볼 크기(필요시)

% 선 굵기
lineWidthMeas = 1;
lineWidthEst  = 1;
lineWidthCurr = 1;
lineWidthSOC  = 1;

% [C] 색상 팔레트(기본) - 검정색(Black) [0 0 0]을 11번째로 추가
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
    0.45490, 0.46275, 0.47059;  % #10 (Gray tone)
    0.00000, 0.00000, 0.00000;  % #11 (Black)
];

% [D] 서브플롯 마진 조절
nRow = 2;
nCol = 3;
leftMargin   = 0.12;  
rightMargin  = 0.07;  
topMargin    = 0.12;  
bottomMargin = 0.14;  
gapX = 0.09;          
gapY = 0.16;          

% [E] Annotation 위치
annotationOffsetX = -0.06;   
annotationOffsetY = 1.11;    
annotationBoxW    = 0.03;  
annotationBoxH    = 0.03;  

% [F] Legend 'Position' (기본값)
legendPosA = [0.271 0.583 0.05 0.10];
legendPosB = [0.40 0.75 0.05 0.10];
legendPosC = [0.74 0.59 0.05 0.15];
legendPosE = [0.52 0.59 0.05 0.15];
legendPosF = [0.74 0.14 0.05 0.15];

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

%% (2) 예시 데이터 불러오기 (사용자 환경에 맞게 파일 경로 수정)
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
% -- 실제 데이터: 투명도, 범례 숨김
p1 = plot(t, V_meas, 'LineWidth', 0.2, ...
    'Color', [p_colors(1,:) 0.7], 'LineStyle','-', ...
    'HandleVisibility','off');  
hold on;
% -- 범례용 더미 선
p1_legend = plot(nan, nan, 'LineWidth', lineWidthMeas, ...
    'Color', p_colors(1,:), 'LineStyle','-', ...
    'DisplayName', 'Meas.V');

% -- 추정 데이터: 투명도, 범례 숨김
p2 = plot(t, V_drt,  'LineWidth', 1,  ...
    'Color', [p_colors(3,:) 0.9], 'LineStyle','--', ...
    'HandleVisibility','off');
% -- 범례용 더미 선
p2_legend = plot(nan, nan, 'LineWidth', lineWidthEst, ...
    'Color', p_colors(3,:), 'LineStyle','--', ...
    'DisplayName', 'Est.V');

ylabel('Voltage [V]', 'FontSize', axisLabelFontSize);

yyaxis right
p3 = plot(t, I, 'LineWidth', lineWidthCurr, ...
    'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName', 'Current');
ylabel('Current [A]', 'FontSize', axisLabelFontSize);

% Current 축 범위 예시
ylim([-6 12]);  
xlabel('Time [s]',    'FontSize', axisLabelFontSize);

yyaxis left;  set(gca, 'YColor','k','XColor','k','FontSize',axisTickFontSize);
yyaxis right; set(gca, 'YColor','k','XColor','k','FontSize',axisTickFontSize);

% legend에는 범례용 더미 + 실제 Current만
leg_a = legend([p1_legend p2_legend p3], 'Orientation','horizontal');
set(leg_a, 'Box','off', ...
           'FontSize', legendFontSize, ...
           'ItemTokenSize', legendItemTokenSizeManual, ...
           'Position', [0.088 0.58 0.4 0.05]);  % <-- 필요시 이 좌표값 조정

annotation('textbox', ...
   [pos(1,1)-0.06, pos(1,2)+pos(1,4)*1.11, 0.03, 0.03], ...
   'String','(a)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (b) Trip 1 DRT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(2,:));
theta_1 = udds_data_soc_results(trip_idx).theta_discrete;
gamma_1 = udds_data_soc_results(trip_idx).gamma_est;

plot(theta_1, gamma_1, 'LineWidth', 1.2, ...
    'Color', p_colors(1,:), ... 
    'LineStyle','-');
hold on;
xlabel('\theta = ln(\tau [s])', 'FontSize', axisLabelFontSize);
ylabel('\gamma [\Omega]',       'FontSize', axisLabelFontSize);
set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

annotation('textbox', ...
   [pos(2,1)-0.06, pos(2,2)+pos(2,4)*1.11, 0.03, 0.03], ...
   'String','(b)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (c) Trip 1 SOC 비교 (+ True SOC = 회색)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(3,:));
CC_1    = udds_data_soc_results(trip_idx).CC_SOC;
SOC1RC  = udds_data_soc_results(trip_idx).SOC_1RC;
SOC2RC  = udds_data_soc_results(trip_idx).SOC_2RC;
SOCDRT  = udds_data_soc_results(trip_idx).SOC_DRT;
SOCtrue = udds_data_soc_results(trip_idx).True_SOC;

p1c = plot(t, CC_1,   'LineWidth', lineWidthSOC, ...
    'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','CC'); hold on;
p2c = plot(t, SOC1RC, 'LineWidth', lineWidthSOC, ...
    'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','1RC');
p3c = plot(t, SOC2RC, 'LineWidth', lineWidthSOC, ...
    'Color', p_colors(2,:), 'LineStyle','-', 'DisplayName','2RC');
p4c = plot(t, SOCDRT, 'LineWidth', lineWidthSOC, ...
    'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','DRT');
% True SOC: 회색(#10)
p5c = plot(t, SOCtrue, 'LineWidth', lineWidthSOC, ...
    'Color', p_colors(10,:), 'LineStyle','-', 'DisplayName','True SOC');

xlabel('Time [s]', 'FontSize', axisLabelFontSize);
ylabel('SOC',      'FontSize', axisLabelFontSize);

leg_c = legend([p1c p2c p3c p4c p5c]);
set(leg_c, 'Position', [0.74 0.59 0.05 0.15], ...
           'FontSize', legendFontSize,...
           'Box','off', ...
           'ItemTokenSize', legendItemTokenSizeManual);

set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

annotation('textbox', ...
   [pos(3,1)-0.06, pos(3,2)+pos(3,4)*1.11, 0.03, 0.03], ...
   'String','(c)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (d) Trip 전체 전압 비교
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

% -- 실제 데이터(투명도), 범례 숨김
plot(full_t, full_V, ...
    'Color', [p_colors(1,:) 0.5], ...
    'LineWidth', 0.2, ...
    'LineStyle','-', ...
    'HandleVisibility','off');
hold on;
% -- 범례용 더미 선
p1d_legend = plot(nan, nan, ...
    'Color', p_colors(1,:), ...
    'LineWidth', 1, ...
    'LineStyle','-', ...
    'DisplayName','Meas. V');

% -- 추정 데이터(투명도), 범례 숨김
plot(full_t, full_Vdrt, ...
    'Color', [p_colors(3,:) 0.3], ...
    'LineWidth', 1, ...
    'LineStyle','--', ...
    'HandleVisibility','off');
% -- 범례용 더미 선
p2d_legend = plot(nan, nan, ...
    'Color', p_colors(3,:), ...
    'LineWidth', 1, ...
    'LineStyle','--', ...
    'DisplayName','Est. V');

ylabel('Voltage [V]', 'FontSize', axisLabelFontSize);
xlabel('Time [s]',    'FontSize', axisLabelFontSize);
set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

% (d) 범례 위치/크기
leg_d = legend([p1d_legend p2d_legend]);
set(leg_d, 'Position', [0.275 0.33 0.035 0.07], ...
           'FontSize', legendFontSize,...
           'Box','off', ...
           'ItemTokenSize', legendItemTokenSizeManual);

annotation('textbox', ...
   [pos(4,1)-0.06, pos(4,2)+pos(4,4)*1.11, 0.03, 0.03], ...
   'String','(d)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (e) Trip 전체 3D DRT - Parula
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(5,:));
hold on;
box on;  % (e)에서 박스 on 적용

numTripsToPlot = num_trips - 1;
cmap = parula(numTripsToPlot);  
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
          'LineWidth', 1, ...
          'Color', cmap(s,:), ...
          'DisplayName', sprintf('Trip %d',s));
end

xlabel('SOC', 'FontSize', axisLabelFontSize);
ylabel('\theta = ln(\tau [s])', 'FontSize', axisLabelFontSize);
zlabel('\gamma [\Omega]',       'FontSize', axisLabelFontSize);
view(135, 30);
set(gca, 'FontSize', axisTickFontSize, ...
         'YColor','k','XColor','k','ZColor','k');
grid on;

% 0~1 구간을 0.2 단위로 Tick 표시
xlim([0,1]);
set(gca, 'XTick', 0:0.2:1);

zlim([0 0.2]);

annotation('textbox', ...
   [pos(5,1)-0.06, pos(5,2)+pos(5,4)*1.11, 0.03, 0.03], ...
   'String','(e)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (f) Trip 전체 SOC 비교 (True SOC = 회색)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot('Position', pos(6,:));
full_t2   = [];
full_cc   = [];
full_1rc  = [];
full_2rc  = [];
full_drt  = [];
full_true = [];

for s = 1:numTripsToPlot
    full_t2   = [full_t2;   udds_data_soc_results(s).Time_duration];
    full_cc   = [full_cc;   udds_data_soc_results(s).CC_SOC];
    full_1rc  = [full_1rc;  udds_data_soc_results(s).SOC_1RC];
    full_2rc  = [full_2rc;  udds_data_soc_results(s).SOC_2RC];
    full_drt  = [full_drt;  udds_data_soc_results(s).SOC_DRT];
    full_true = [full_true; udds_data_soc_results(s).True_SOC];
end

p1f = plot(full_t2, full_cc,   'LineWidth', lineWidthSOC,...
    'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','CC'); hold on;
p2f = plot(full_t2, full_1rc,  'LineWidth', lineWidthSOC,...
    'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','1RC');
p3f = plot(full_t2, full_2rc,  'LineWidth', lineWidthSOC,...
    'Color', p_colors(2,:), 'LineStyle','-', 'DisplayName','2RC');
p4f = plot(full_t2, full_drt,  'LineWidth', lineWidthSOC,...
    'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','DRT');
% True SOC: 회색(#10)
p5f = plot(full_t2, full_true, 'LineWidth', lineWidthSOC, ...
    'Color', p_colors(10,:), 'LineStyle','-', 'DisplayName','True SOC');

xlabel('Time [s]', 'FontSize', axisLabelFontSize);
ylabel('SOC',      'FontSize', axisLabelFontSize);
xtickformat('%.0f');

leg_f = legend([p1f p2f p3f p4f p5f]);
set(leg_f, 'Position', [0.74 0.14 0.05 0.15], ...
           'FontSize', legendFontSize,...
           'Box','off', ...
           'ItemTokenSize', legendItemTokenSizeManual);

set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

annotation('textbox', ...
   [pos(6,1)-0.06, pos(6,2)+pos(6,4)*1.11, 0.03, 0.03], ...
   'String','(f)','FontSize',annotationFontSize,...
   'FontWeight','bold','LineStyle','none');

%% ========== 화면과 동일하게 내보내기 위해 렌더러 설정 ==========

% ──────────────────────────────────────────────────────────────────────────
% ① Figure의 Renderer를 opengl/zbuffer로 설정 (투명도/알파 채널 반영)
% ② InvertHardcopy='off'로 화면 색상 그대로 유지
% ③ exportgraphics (혹은 print)로 내보내기
% ──────────────────────────────────────────────────────────────────────────

set(gcf, 'Renderer', 'opengl');       % 또는 'zbuffer'
set(gcf, 'InvertHardcopy', 'off');    % 화면 색/투명도 유지
set(gcf, 'GraphicsSmoothing', 'on');  % (필요 시) 안티에일리어싱

% 최종 파일로 내보내기
exportgraphics(gcf, 'Fig2.png', 'Resolution',300);


