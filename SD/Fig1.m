%% DRT_plot_code_custom.m
clc; clear; close all;

%% ==================== (0) User-Defined Parameters =======================
% ---------------------------
% (A) Figure 크기 (half-width = 약 8.6cm)
% ---------------------------
figWidth  = 8.6;   % 가로 [cm]
figHeight = 8.6;   % 세로 [cm]

% ---------------------------
% (B) Subplot Margin/Size Parameters (normalized)
% ---------------------------
col1Left   = 0.13;  % 왼쪽 offset
subplotW   = 0.33;  % (a), (b)의 폭
marginH    = 0.13;  % (a)와 (b) 사이의 수평 간격
row1Bottom = 0.58;  % (a), (b) 서브플롯의 아래쪽
subplotH   = 0.35;  % (a), (b) 서브플롯의 높이
marginV    = 0.13;  % 위/아래 subplot 간 수직 간격
cWidth     = 0.79;  % (c)의 폭 (조정 가능)

% (c) 서브플롯의 아래 위치
row2Bottom = row1Bottom - subplotH - marginV;

% 실제 subplot Position
pos_ax1 = [col1Left                 row1Bottom subplotW subplotH]; 
pos_ax2 = [col1Left+subplotW+marginH row1Bottom subplotW subplotH];
pos_ax3 = [col1Left                 row2Bottom cWidth   subplotH];

% ---------------------------
% (C) Annotation offset ((a),(b),(c) 라벨)
% ---------------------------
annOffsetX = -0.13;   
annOffsetY =  0.03;   

% ---------------------------
% (D) Line / Font styles
% ---------------------------
lineWidthValue    = 1.5;   % 선 굵기
fillAlpha         = 0.3;   % fill 투명도
axisFontSize      = 8;     % 축 라벨/틱 폰트 크기
legendFontSize    = 6;     % 범례 폰트 크기
annotationFontSize = 9;    % (a),(b),(c) 라벨 폰트 크기
legendTokenSize   = 4;     % Legend 아이콘(박스/선) 간격(값 작을수록 더 작아짐)

% ---------------------------
% (E) Legend Positions (수동 설정)
% ---------------------------
% [left bottom width height] (normalized)
legendPosA = [0.12 0.83 0.15 0.10];  % (a)
legendPosB = [0.58 0.83 0.15 0.10];  % (b)
legendPosC = [0.67 0.11 0.25 0.10];  % (c)

% ---------------------------
% (F) Current / Voltage Label Offset
% ---------------------------
%  -> (c) subplot에서 축 라벨을 축과 더 가깝게 (혹은 멀게) 조정
currentLabelOffsetX = +0.05;  % 왼쪽 축 라벨 X 위치를 기존 대비 +0.05
voltageLabelOffsetX = -30;  % 오른쪽 축 라벨 X 위치를 기존 대비 -0.05
% 음수면 축 쪽으로 이동, 양수면 축 반대방향으로 이동

%% (1) Load Data
load('DRT_estimation_results.mat','drt_output');
% drt_output(1) = Unimodal (AS1_1per_new)
% drt_output(2) = Bimodal  (AS2_1per_new)

%% (2) Color table
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
color_scenario1 = p_colors(2,:); % 노랑 (Estimated gamma)
color_true      = [0 0 0];       % 검정 (True gamma)
color_curr      = p_colors(1,:); % 파랑 (Current)
color_uni_volt  = p_colors(3,:); % 빨강 (Unimodal Voltage)
color_bi_volt   = p_colors(4,:); % 초록 (Bimodal Voltage)

%% (3) Scenario 설정
s = 1;  % 시나리오 1만

%% (4) Figure 생성
figH = figure('Name','Unimodal vs. Bimodal (Scenario 1)','NumberTitle','off',...
    'Units','centimeters',...
    'Position',[3 3 figWidth figHeight],...
    'MenuBar','figure','ToolBar','figure',...
    'PaperUnits','centimeters',...
    'PaperSize',[figWidth figHeight],...
    'PaperPosition',[0 0 figWidth figHeight]);

% 폰트 기본값 (축, 레이블, 틱)
set(groot,'defaultAxesFontName','Arial');
set(groot,'defaultAxesFontSize',axisFontSize);

%% ------------------------------------------------------------------------
% (a) Subplot : Unimodal
%% ------------------------------------------------------------------------
ax1 = subplot('Position', pos_ax1);

theta_true_uni  = drt_output(1).theta_true;
gamma_true_uni  = drt_output(1).gamma_true;
theta_est_uni   = drt_output(1).scenario(s).theta_est;
gamma_est_uni   = drt_output(1).scenario(s).gamma_est;
gamma_lower_uni = drt_output(1).scenario(s).gamma_lower;
gamma_upper_uni = drt_output(1).scenario(s).gamma_upper;

fill([theta_est_uni; flipud(theta_est_uni)], ...
     [gamma_lower_uni; flipud(gamma_upper_uni)], ...
     color_scenario1, 'FaceAlpha',fillAlpha, 'EdgeColor','none',...
     'HandleVisibility','off');
hold on;

h_est_uni = plot(theta_est_uni, gamma_est_uni, ...
    'LineWidth',lineWidthValue, 'LineStyle','-', ...
    'Color', color_scenario1, ...
    'DisplayName','Est. \gamma');
h_true_uni = plot(theta_true_uni, gamma_true_uni, ...
    'LineWidth',lineWidthValue, 'LineStyle','-', ...
    'Color', color_true, ...
    'DisplayName','True \gamma');

xlabel('\theta','FontSize',axisFontSize);
ylabel('\gamma [\Omega]','FontSize',axisFontSize);  % gamma 단위 예시
set(ax1,'XColor','k','YColor','k','Box','on');
hold off;

lgdA = legend([h_est_uni, h_true_uni],...
    'Location','none','FontSize',legendFontSize);
lgdA.Position      = legendPosA;
lgdA.Box           = 'off';
lgdA.ItemTokenSize = [legendTokenSize, legendTokenSize];

%% ------------------------------------------------------------------------
% (b) Subplot : Bimodal
%% ------------------------------------------------------------------------
ax2 = subplot('Position', pos_ax2);

theta_true_bi  = drt_output(2).theta_true;
gamma_true_bi  = drt_output(2).gamma_true;
theta_est_bi   = drt_output(2).scenario(s).theta_est;
gamma_est_bi   = drt_output(2).scenario(s).gamma_est;
gamma_lower_bi = drt_output(2).scenario(s).gamma_lower;
gamma_upper_bi = drt_output(2).scenario(s).gamma_upper;

fill([theta_est_bi; flipud(theta_est_bi)], ...
     [gamma_lower_bi; flipud(gamma_upper_bi)], ...
     color_scenario1, 'FaceAlpha',fillAlpha, 'EdgeColor','none',...
     'HandleVisibility','off');
hold on;

h_est_bi = plot(theta_est_bi, gamma_est_bi, ...
    'LineWidth',lineWidthValue, 'LineStyle','-', ...
    'Color', color_scenario1, ...
    'DisplayName','Est. \gamma');
h_true_bi = plot(theta_true_bi, gamma_true_bi, ...
    'LineWidth',lineWidthValue, 'LineStyle','-', ...
    'Color', color_true, ...
    'DisplayName','True \gamma');

xlabel('\theta','FontSize',axisFontSize);
ylabel('\gamma [\Omega]','FontSize',axisFontSize);
set(ax2,'XColor','k','YColor','k','Box','on');
hold off;

lgdB = legend([h_est_bi, h_true_bi],...
    'Location','none','FontSize',legendFontSize);
lgdB.Position      = legendPosB;
lgdB.Box           = 'off';
lgdB.ItemTokenSize = [legendTokenSize, legendTokenSize];

%% ------------------------------------------------------------------------
% (c) Subplot : Current & Voltage
%% ------------------------------------------------------------------------
ax3 = subplot('Position', pos_ax3);

time_1   = drt_output(1).scenario(s).t;
curr_1   = drt_output(1).scenario(s).I;
volt_uni = drt_output(1).scenario(s).V;
volt_bi  = drt_output(2).scenario(s).V;

yyaxis left
h_curr = plot(time_1, curr_1, ...
    'LineWidth',lineWidthValue, 'LineStyle','-', ...
    'Color', color_curr, ...
    'DisplayName','Current');
ylabel('Current (A)','FontSize',axisFontSize);
set(ax3,'YColor','k');  % 왼축 검정
% --- 축 라벨 위치 오프셋 적용 ---
posLeftLabel = get(ax3.YAxis(1).Label,'Position');  % [x, y, z]
posLeftLabel(1) = posLeftLabel(1) + currentLabelOffsetX; 
set(ax3.YAxis(1).Label,'Position',posLeftLabel);

yyaxis right
hold on;
h_uniV = plot(time_1, volt_uni, ...
    'LineWidth',lineWidthValue, 'LineStyle','-', ...
    'Color', color_uni_volt, ...
    'DisplayName','Unimodal Voltage');
h_biV  = plot(time_1, volt_bi, ...
    'LineWidth',lineWidthValue, 'LineStyle','-', ...
    'Color', color_bi_volt, ...
    'DisplayName','Bimodal Voltage');
ylabel('Voltage (V)','FontSize',axisFontSize);
set(ax3,'YColor','k');  % 오른축 검정
% --- 오른쪽 축 라벨 위치 오프셋 ---
posRightLabel = get(ax3.YAxis(2).Label,'Position');
posRightLabel(1) = posRightLabel(1) + voltageLabelOffsetX;
set(ax3.YAxis(2).Label,'Position',posRightLabel);

xlabel('Time (s)','FontSize',axisFontSize);
set(ax3,'XColor','k','Box','on');
hold off;

lgdC = legend([h_curr, h_uniV, h_biV], ...
    'Location','none','FontSize',legendFontSize);
lgdC.Position      = legendPosC;
lgdC.Box           = 'off';
lgdC.ItemTokenSize = [legendTokenSize, legendTokenSize];

%% ------------------------------------------------------------------------
% (5) Annotation : (a),(b),(c)
%% ------------------------------------------------------------------------
posA = get(ax1,'Position');
annotation('textbox',[posA(1)+annOffsetX, posA(2)+posA(4)+annOffsetY, 0.03, 0.03],...
    'String','(a)', 'FontSize',annotationFontSize, 'FontWeight','bold',...
    'EdgeColor','none','Color','k');

posB = get(ax2,'Position');
annotation('textbox',[posB(1)+annOffsetX, posB(2)+posB(4)+annOffsetY, 0.03, 0.03],...
    'String','(b)', 'FontSize',annotationFontSize, 'FontWeight','bold',...
    'EdgeColor','none','Color','k');

posC = get(ax3,'Position');
annotation('textbox',[posC(1)+annOffsetX, posC(2)+posC(4)+annOffsetY, 0.03, 0.03],...
    'String','(c)', 'FontSize',annotationFontSize, 'FontWeight','bold',...
    'EdgeColor','none','Color','k');

%% ================== (Optional) Figure 저장 =====================
% 1) 최신버전(R2020a+): 
exportgraphics(gcf, 'Figure_DRTPLOT.png','Resolution',300);
% 
% 2) 구버전:
%    set(gcf,'PaperPositionMode','auto');
%    print(gcf,'-dpng','Figure_DRTPLOT.png','-r300');
%


