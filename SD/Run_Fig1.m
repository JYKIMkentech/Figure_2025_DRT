%% DRT_plot_code_custom_4percent.m
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

%% (1) Load Data (4% Noise: Unimodal vs Bimodal)
data_path = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_DRT\';
load(fullfile(data_path, 'AS1_1per_new.mat'), 'AS1_1per_new');  % Unimodal 4%
load(fullfile(data_path, 'AS2_1per_new.mat'), 'AS2_1per_new');  % Bimodal 4%
load(fullfile(data_path, 'Gamma_unimodal.mat'), 'Gamma_unimodal');
load(fullfile(data_path, 'Gamma_bimodal.mat'),  'Gamma_bimodal');

% 시나리오 인덱스 지정 (1~10 중 하나)
scenario_idx = 1;  % 예: 첫 번째 시나리오

%% ==================== (2) Extract data =======================
% -- Unimodal (4% noise)
theta_est_uni   = AS1_1per_new(scenario_idx).theta;
gamma_avg_uni   = AS1_1per_new(scenario_idx).gamma_avg;
gamma_lower_uni = AS1_1per_new(scenario_idx).gamma_lower;
gamma_upper_uni = AS1_1per_new(scenario_idx).gamma_upper;
time_uni        = AS1_1per_new(scenario_idx).t;
curr_uni        = AS1_1per_new(scenario_idx).I;
volt_uni        = AS1_1per_new(scenario_idx).V;

% -- Bimodal (4% noise)
theta_est_bi   = AS2_1per_new(scenario_idx).theta;
gamma_avg_bi   = AS2_1per_new(scenario_idx).gamma_avg;
gamma_lower_bi = AS2_1per_new(scenario_idx).gamma_lower;
gamma_upper_bi = AS2_1per_new(scenario_idx).gamma_upper;
time_bi        = AS2_1per_new(scenario_idx).t;    % 보통 time은 동일한 경우가 많지만, 여기서는 별도 변수
curr_bi        = AS2_1per_new(scenario_idx).I;
volt_bi        = AS2_1per_new(scenario_idx).V;

% -- True gamma (Unimodal vs Bimodal)
theta_true_uni = Gamma_unimodal.theta(:);
gamma_true_uni = Gamma_unimodal.gamma(:);

theta_true_bi = Gamma_bimodal.theta(:);
gamma_true_bi = Gamma_bimodal.gamma(:);

%% ==================== (3) Color table =======================
p_colors = [
    0.00000, 0.45098, 0.76078;  % #1 (Blue)
    0.93725, 0.75294, 0.00000;  % #2 (Yellow)
    0.80392, 0.32549, 0.29803;  % #3 (Red)
    0.12549, 0.52157, 0.30588;  % #4 (Green)
];
color_scenario = p_colors(2,:);  % 노랑 (Estimated gamma)
color_true     = [0 0 0];        % 검정 (True gamma)
color_curr     = p_colors(1,:);  % 파랑 (Current)
color_uni_volt = p_colors(3,:);  % 빨강 (Unimodal Voltage)
color_bi_volt  = p_colors(4,:);  % 초록 (Bimodal Voltage)

%% ==================== (4) Make Figure =======================
figH = figure('Name','Unimodal vs. Bimodal (4% Noise)','NumberTitle','off',...
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

% UNC 영역 (회색)
h_fill_uni = fill([theta_est_uni; flipud(theta_est_uni)], ...
     [gamma_lower_uni; flipud(gamma_upper_uni)], ...
     [0.7 0.7 0.7], ...
     'FaceAlpha', fillAlpha, ...
     'EdgeColor','none', ...
     'DisplayName','UNC');
hold on;

% 추정 곡선 (Est. \gamma)
h_est_uni = plot(theta_est_uni, gamma_avg_uni, ...
    'LineWidth', lineWidthValue, ...
    'Color', color_scenario, ...
    'DisplayName','Est. \gamma (4%)');

% 참값 곡선 (True \gamma)
h_true_uni = plot(theta_true_uni, gamma_true_uni, ...
    'LineWidth', lineWidthValue, ...
    'Color', color_true, ...
    'DisplayName','True \gamma');

xlabel('\theta = ln(\tau [s])', 'FontSize', axisFontSize);
ylabel('\gamma [\Omega]','FontSize',axisFontSize);
set(ax1,'XColor','k','YColor','k','Box','on');
hold off;

% Legend (왼쪽)
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

% UNC 영역 (회색)
h_fill_bi = fill([theta_est_bi; flipud(theta_est_bi)], ...
     [gamma_lower_bi; flipud(gamma_upper_bi)], ...
     [0.7 0.7 0.7], ...
     'FaceAlpha', fillAlpha, ...
     'EdgeColor','none', ...
     'DisplayName','UNC');
hold on;

% 추정 곡선 (Est. \gamma)
h_est_bi = plot(theta_est_bi, gamma_avg_bi, ...
    'LineWidth', lineWidthValue, ...
    'Color', color_scenario, ...
    'DisplayName','Est. \gamma (4%)');

% 참값 곡선 (True \gamma)
h_true_bi = plot(theta_true_bi, gamma_true_bi, ...
    'LineWidth', lineWidthValue, ...
    'Color', color_true, ...
    'DisplayName','True \gamma');

xlabel('\theta = ln(\tau [s])', 'FontSize', axisFontSize);
ylabel('\gamma [\Omega]','FontSize',axisFontSize);
set(ax2,'XColor','k','YColor','k','Box','on');
hold off;

% Legend (오른쪽)
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

% 4% Unimodal/Bimodal 시나리오에서 time이 다를 수도 있으나,
% 여기서는 같은 길이라고 가정 (time_uni와 time_bi가 동일하다고 가정)
% 만약 달라서 겹쳐 그리기 원하면 interp1 등을 이용해 동일 시간축으로 맞춰야 함
time_plot = time_uni;  % 그냥 unimodal 측 시간축 쓰는 예
curr_plot = curr_uni;  % unimodal 전류 (만약 bimodal과 다르면 병행해서 그리고 싶을 수도 있음)

yyaxis left
h_curr = plot(time_plot, curr_plot, ...
    'LineWidth', lineWidthValue, 'LineStyle','-', ...
    'Color', color_curr, ...
    'DisplayName','Current');
ylabel('Current (A)','FontSize',axisFontSize);
set(ax3,'YColor','k');  % 왼축 검정

% 왼축 라벨 위치 조정
posLeftLabel = get(ax3.YAxis(1).Label,'Position'); 
posLeftLabel(1) = posLeftLabel(1) + currentLabelOffsetX; 
set(ax3.YAxis(1).Label,'Position',posLeftLabel);

yyaxis right
hold on;
h_uniV = plot(time_uni, volt_uni, ...
    'LineWidth', lineWidthValue, 'LineStyle','-', ...
    'Color', color_uni_volt, ...
    'DisplayName','Voltage, Unimodal');
h_biV  = plot(time_bi, volt_bi, ...
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

% Legend (c)
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
exportgraphics(gcf, 'Figure_Compare_4percent.png','Resolution',300);
% 또는:
% set(gcf,'PaperPositionMode','auto');
% print(gcf,'-dpng','Figure_Compare_4percent.png','-r300');

