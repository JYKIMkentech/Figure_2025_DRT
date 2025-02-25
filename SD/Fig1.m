%% DRT_plot_code_custom.m
clc; clear; close all;

%% ==================== (0) User-Defined Parameters =======================
% (A) Figure 크기
figWidth  = 8.6;   
figHeight = 8.6;   

% (B) Subplot Margin/Size Parameters
col1Left   = 0.13;  
subplotW   = 0.33;  
marginH    = 0.13;  
row1Bottom = 0.58;  
subplotH   = 0.35;  
marginV    = 0.13;  
cWidth     = 0.79;  

row2Bottom = row1Bottom - subplotH - marginV;

pos_ax1 = [col1Left                  row1Bottom subplotW subplotH]; 
pos_ax2 = [col1Left+subplotW+marginH row1Bottom subplotW subplotH];
pos_ax3 = [col1Left                  row2Bottom cWidth   subplotH];

% (C) Annotation offset ((a),(b),(c) 라벨)
annOffsetX = -0.13;   
annOffsetY =  0.03;   

% (D) Line / Font styles
lineWidthValue     = 1;    
fillAlpha          = 0.3;  
axisFontSize       = 8;    
legendFontSize     = 6;    
annotationFontSize = 9;    
legendTokenSize    = 4;    

% (E) Legend Positions
legendPosA = [0.12 0.83 0.15 0.10];  
legendPosB = [0.58 0.83 0.15 0.10];  
legendPosC = [0.67 0.11 0.25 0.10];  

% (F) Current / Voltage Label Offset
currentLabelOffsetX = +0.05;  
voltageLabelOffsetX = -30;    

%% (1) Load Data
load('DRT_estimation_results.mat','drt_output');
% drt_output(1) = Unimodal
% drt_output(2) = Bimodal
% scenario(s).theta_est, gamma_avg, gamma_lower, gamma_upper 등 포함

%% (2) Color table
p_colors = [
    0.00000, 0.45098, 0.76078;  % #1 (Blue)
    0.93725, 0.75294, 0.00000;  % #2 (Yellow)
    0.80392, 0.32549, 0.29803;  % #3 (Red)
    0.12549, 0.52157, 0.30588;  % #4 (Green)
];
color_scenario1 = p_colors(2,:); % 노랑 (Estimated gamma)
color_true      = [0 0 0];       % 검정 (True gamma)
color_curr      = p_colors(1,:); % 파랑 (Current)
color_uni_volt  = p_colors(3,:); % 빨강 (Unimodal Voltage)
color_bi_volt   = p_colors(4,:); % 초록 (Bimodal Voltage)

%% (3) Scenario 설정
s = 1;  % 예시: 시나리오 1

%% (4) Figure 생성
figH = figure('Name','Unimodal vs. Bimodal (Scenario 1)','NumberTitle','off',...
    'Units','centimeters',...
    'Position',[3 3 figWidth figHeight],...
    'PaperUnits','centimeters',...
    'PaperSize',[figWidth figHeight],...
    'PaperPosition',[0 0 figWidth figHeight]);

set(groot,'defaultAxesFontName','Arial');
set(groot,'defaultAxesFontSize',axisFontSize);

%% ------------------------------------------------------------------------
% (a) Subplot : Unimodal
%% ------------------------------------------------------------------------
ax1 = subplot('Position', pos_ax1);

theta_true_uni  = drt_output(1).theta_true;
gamma_true_uni  = drt_output(1).gamma_true;
theta_est_uni   = drt_output(1).scenario(s).theta_est;
gamma_lower_uni = drt_output(1).scenario(s).gamma_lower;
gamma_upper_uni = drt_output(1).scenario(s).gamma_upper;
gamma_avg_uni   = drt_output(1).scenario(s).gamma_avg;

% -- UNC 영역 (회색)
h_fill_uni = fill([theta_est_uni; flipud(theta_est_uni)], ...
     [gamma_lower_uni; flipud(gamma_upper_uni)], ...
     [0.7 0.7 0.7], ...
     'FaceAlpha', fillAlpha, ...
     'EdgeColor','none', ...
     'DisplayName','UNC');
hold on;

% -- 추정 곡선 (Est. \gamma)
h_est_uni = plot(theta_est_uni, gamma_avg_uni, ...
    'LineWidth', lineWidthValue, ...
    'Color', color_scenario1, ...
    'DisplayName','Est. \gamma');

% -- 참값 곡선 (True \gamma)
h_true_uni = plot(theta_true_uni, gamma_true_uni, ...
    'LineWidth', lineWidthValue, ...
    'Color', color_true, ...
    'DisplayName','True \gamma');

xlabel('\theta','FontSize',axisFontSize);
ylabel('\gamma [\Omega]','FontSize',axisFontSize);
set(ax1,'XColor','k','YColor','k','Box','on');
hold off;

% -- Legend: (Est. \gamma, True \gamma, UNC) 순서
lgdA = legend([h_est_uni, h_true_uni, h_fill_uni], ...
    'Est. \gamma','True \gamma','UNC',...
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
gamma_lower_bi = drt_output(2).scenario(s).gamma_lower;
gamma_upper_bi = drt_output(2).scenario(s).gamma_upper;
gamma_avg_bi   = drt_output(2).scenario(s).gamma_avg;

% -- UNC 영역 (회색)
h_fill_bi = fill([theta_est_bi; flipud(theta_est_bi)], ...
     [gamma_lower_bi; flipud(gamma_upper_bi)], ...
     [0.7 0.7 0.7], ...
     'FaceAlpha', fillAlpha, ...
     'EdgeColor','none', ...
     'DisplayName','UNC');
hold on;

% -- 추정 곡선 (Est. \gamma)
h_est_bi = plot(theta_est_bi, gamma_avg_bi, ...
    'LineWidth', lineWidthValue, ...
    'Color', color_scenario1, ...
    'DisplayName','Est. \gamma');

% -- 참값 곡선 (True \gamma)
h_true_bi = plot(theta_true_bi, gamma_true_bi, ...
    'LineWidth', lineWidthValue, ...
    'Color', color_true, ...
    'DisplayName','True \gamma');

xlabel('\theta','FontSize',axisFontSize);
ylabel('\gamma [\Omega]','FontSize',axisFontSize);
set(ax2,'XColor','k','YColor','k','Box','on');
hold off;

% -- Legend: (Est. \gamma, True \gamma, UNC) 순서
lgdB = legend([h_est_bi, h_true_bi, h_fill_bi], ...
    'Est. \gamma','True \gamma','UNC',...
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
    'LineWidth', lineWidthValue, 'LineStyle','-', ...
    'Color', color_curr, ...
    'DisplayName','Current');
ylabel('Current (A)','FontSize',axisFontSize);
set(ax3,'YColor','k');  % 왼축 검정

% 왼축 라벨 조금 오른쪽 이동
posLeftLabel = get(ax3.YAxis(1).Label,'Position'); 
posLeftLabel(1) = posLeftLabel(1) + currentLabelOffsetX; 
set(ax3.YAxis(1).Label,'Position',posLeftLabel);

yyaxis right
hold on;
h_uniV = plot(time_1, volt_uni, ...
    'LineWidth', lineWidthValue, 'LineStyle','-', ...
    'Color', color_uni_volt, ...
    'DisplayName','Voltage, Unimodal');
h_biV  = plot(time_1, volt_bi, ...
    'LineWidth', lineWidthValue, 'LineStyle','-', ...
    'Color', color_bi_volt, ...
    'DisplayName','Voltage, Bimodal');
ylabel('Voltage (V)','FontSize',axisFontSize);
set(ax3,'YColor','k');  % 오른축 검정

% 오른축 라벨 위치 조정
posRightLabel = get(ax3.YAxis(2).Label,'Position');
posRightLabel(1) = posRightLabel(1) + voltageLabelOffsetX;
set(ax3.YAxis(2).Label,'Position',posRightLabel);

xlabel('Time (s)','FontSize',axisFontSize);
set(ax3,'XColor','k','Box','on');
hold off;

% Legend (c) : Current, Unimodal Voltage, Bimodal Voltage
lgdC = legend([h_curr, h_uniV, h_biV], ...
    'Location','none','FontSize',legendFontSize);
lgdC.Position      = legendPosC;
lgdC.Box           = 'off';
lgdC.ItemTokenSize = [legendTokenSize, legendTokenSize];

%% ------------------------------------------------------------------------
% (5) Annotation : (a),(b),(c)
%% ------------------------------------------------------------------------
posA = get(ax1,'Position');
annotation('textbox',...
    [posA(1)+annOffsetX, posA(2)+posA(4)+annOffsetY, 0.03, 0.03], ...
    'String','(a)', 'FontSize',annotationFontSize, 'FontWeight','bold', ...
    'EdgeColor','none','Color','k');

posB = get(ax2,'Position');
annotation('textbox',...
    [posB(1)+annOffsetX, posB(2)+posB(4)+annOffsetY, 0.03, 0.03], ...
    'String','(b)', 'FontSize',annotationFontSize, 'FontWeight','bold', ...
    'EdgeColor','none','Color','k');

posC = get(ax3,'Position');
annotation('textbox',...
    [posC(1)+annOffsetX, posC(2)+posC(4)+annOffsetY, 0.03, 0.03], ...
    'String','(c)', 'FontSize',annotationFontSize, 'FontWeight','bold', ...
    'EdgeColor','none','Color','k');

%% ================== (Optional) Figure 저장 =====================
exportgraphics(gcf, 'Figure_DRTPLOT.png','Resolution',300);
% or:
% set(gcf,'PaperPositionMode','auto');
% print(gcf,'-dpng','Figure_DRTPLOT.png','-r300');
