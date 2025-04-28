clc; clear; close all;

%% === 0) USER-CONTROLLED LAYOUT PARAMETERS ===================================
figWidth_cm    = 26;   % 전체 Figure 너비 (cm)
figHeight_cm   = 16;   % 전체 Figure 높이 (cm)
figPosX_cm     = 2;    % 모니터상 배치 (왼쪽 위치)
figPosY_cm     = 2;    % 모니터상 배치 (아래 위치)

% TiledLayout 관련 (Row=3, Col=4)
tileSpacingChoice = 'compact';  
tilePaddingChoice = 'compact';  

% 서브플롯 (a)~(l) annotation 위치
annotPos_a = [-0.2, 1.05];
annotPos_b = [-0.2, 1.05];
annotPos_c = [-0.2, 1.05];
annotPos_d = [-0.2, 1.05];
annotPos_e = [-0.2, 1.05];
annotPos_f = [-0.2, 1.05];
annotPos_g = [-0.2, 1.05];
annotPos_h = [-0.2, 1.05];
annotPos_i = [-0.2, 1.05];
annotPos_jkl = [-0.2, 1.05];  % (j,k,l)은 동일하게

% Legend 위치
legendPos_a = [0.02, 0.68, 0.3, 0.08];
legendPos_b = [0.185, 0.88, 0.3, 0.08];
legendPos_c = [0.43, 0.88, 0.3, 0.08];
legendPos_d = [0.665, 0.88, 0.3, 0.08];
legendPos_e = [0.02, 0.355, 0.3, 0.08];
legendPos_f = [0.185, 0.55, 0.3, 0.08];
legendPos_g = [0.43, 0.55, 0.3, 0.08];
legendPos_h = [0.665, 0.55, 0.3, 0.08];
legendPos_i = [0.02, 0.03, 0.3, 0.08];
legendPos_j = [0.185, 0.23, 0.3, 0.08];
legendPos_k = [0.43, 0.23, 0.3, 0.08];
legendPos_l = [0.665, 0.23, 0.3, 0.08];

% Legend ItemTokenSize 설정
legendTokenManualList = {
    [15,15], % (a)
    [15,15], % (b)
    [15,15], % (c)
    [15,15], % (d)
    [15,15], % (e)
    [15,15], % (f)
    [15,15], % (g)
    [15,15], % (h)
    [15,15], % (i)
    [15,15], % (j)
    [15,15], % (k)
    [15,15]  % (l)
};

%% === 추가) Legend 박스배경 투명도 설정 =======================================
legendAlpha = 0.7;  % 0이면 완전투명, 1이면 불투명

%% === 1) PREPARE DATA ========================================================
dataFolder = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_DRT\';
dataFile   = 'AS2_4per_new.mat';    % <-- AS2_4per_new 사용
load(fullfile(dataFolder, dataFile),'AS2_4per_new');
AS_data = AS2_4per_new;  % shorter name

% True gamma (bimodal)
trueFile = 'Gamma_bimodal.mat';     % <-- bimodal 가정
tmp_true = load(fullfile(dataFolder, trueFile));
theta_true = tmp_true.Gamma_bimodal.theta;
gamma_true = tmp_true.Gamma_bimodal.gamma;

%% === 2) STYLING PARAMETERS ==================================================
lineWidthValue     = 1;
fillAlpha          = 0.3;
axisFontSize       = 8;
legendFontSize     = 6;
annotationFontSize = 9;

% Color palette
p_colors = [
    0.00000, 0.44706, 0.74118;  % Blue
    0.93725, 0.75294, 0.00000;  % Yellow
    0.80392, 0.32549, 0.29803;  % Red
    0.12549, 0.52157, 0.30588;  % Green
];

subplotLabels = {'(a)','(b)','(c)','(d)','(e)','(f)', ...
                 '(g)','(h)','(i)','(j)','(k)','(l)'};

%% === 3) SCENARIOS & TYPE-GROUPS =============================================
scenarioList = [1, 5, 10]; % 3 scenarios (원하는 시나리오 인덱스로 수정 가능)

typeGroup_dt    = {'A','D','E','F'};
legendLabels_dt = {'dt=0.1','dt=0.2','dt=1','dt=2'};

typeGroup_dur    = {'A','G','H'};
legendLabels_dur = {'Dur=1000','Dur=500','Dur=250'};

typeGroup_N    = {'A','B','C'};
legendLabels_N = {'N=201','N=101','N=21'};

%% === 4) MAKE A 3×4 FIGURE LAYOUT ============================================
figure('Name','CompareAll_AS2','Color','w','Units','centimeters',...
       'Position',[figPosX_cm figPosY_cm figWidth_cm figHeight_cm]);

tiledlayout(3,4,'TileSpacing',tileSpacingChoice,'Padding',tilePaddingChoice);

% (b), (c), (d), ... 등에서만 Marker를 Legend로 빼서 보여주고 싶으면
% 아래 리스트를 사용 (원 코드와 동일하게 유지)
subplotsMarkerLegend = {'(b)','(c)','(d)','(f)','(g)','(h)','(j)','(k)','(l)'};
labelIdx = 1;

%% === 5) LOOP OVER ROWS (SCENARIOS) ==========================================
for iRow = 1:3
    sn = scenarioList(iRow);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % (A) Column #1: Waveforms (dual y-axis)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax1 = nexttile;
    hold(ax1,'on'); box(ax1,'on');
    ax1.FontSize = axisFontSize;
    ax1.XColor = 'k';
    ax1.YColor = 'k';

    tPlot = AS_data(sn).t;
    iPlot = AS_data(sn).I;  
    vPlot = AS_data(sn).V;  

    yyaxis left
    ax1.YAxis(1).Color = 'k';
    h1 = plot(tPlot, iPlot, 'Color', p_colors(1,:), 'LineWidth',1,...
              'DisplayName','Current');
    ylabel('Current (A)','FontSize',axisFontSize,'Color','k');
    ylim([-4 4]);

    yyaxis right
    ax1.YAxis(2).Color = 'k';
    h2 = plot(tPlot, vPlot, 'Color', p_colors(3,:), 'LineWidth',1,...
              'DisplayName','Voltage');
    ylabel('Voltage (V)','FontSize',axisFontSize,'Color','k');

    xlabel('Time (s)','FontSize',axisFontSize,'Color','k');

    ylim([-10 10]);

    lgd = legend([h1,h2],{'Current','Voltage'}, ...
           'FontSize',legendFontSize,'Orientation','horizontal','Box','off');
    lgd.ItemTokenSize = legendTokenManualList{labelIdx};

    % Legend 위치
    thisLabel = subplotLabels{labelIdx};
    switch thisLabel
        case '(a)'
            set(lgd,'Location','none','Units','normalized','Position',legendPos_a);
        case '(b)'
            set(lgd,'Location','none','Units','normalized','Position',legendPos_b);
        case '(c)'
            set(lgd,'Location','none','Units','normalized','Position',legendPos_c);
        case '(d)'
            set(lgd,'Location','none','Units','normalized','Position',legendPos_d);
        case '(e)'
            set(lgd,'Location','none','Units','normalized','Position',legendPos_e);
        case '(f)'
            set(lgd,'Location','none','Units','normalized','Position',legendPos_f);
        case '(g)'
            set(lgd,'Location','none','Units','normalized','Position',legendPos_g);
        case '(h)'
            set(lgd,'Location','none','Units','normalized','Position',legendPos_h);
        case '(i)'
            set(lgd,'Location','none','Units','normalized','Position',legendPos_i);
        case '(j)'
            set(lgd,'Location','none','Units','normalized','Position',legendPos_j);
        case '(k)'
            set(lgd,'Location','none','Units','normalized','Position',legendPos_k);
        case '(l)'
            set(lgd,'Location','none','Units','normalized','Position',legendPos_l);
    end

    % Legend 박스배경 투명도
    try
        lgd.BoxFace.ColorType = 'truecoloralpha';
        lgd.BoxFace.ColorData = uint8(255*[1;1;1;legendAlpha]);
    catch
        warning('Legend alpha not supported in this MATLAB version.');
    end

    % annotation
    switch thisLabel
        case '(a)', posA = annotPos_a;
        case '(b)', posA = annotPos_b;
        case '(c)', posA = annotPos_c;
        case '(d)', posA = annotPos_d;
        case '(e)', posA = annotPos_e;
        case '(f)', posA = annotPos_f;
        case '(g)', posA = annotPos_g;
        case '(h)', posA = annotPos_h;
        case '(i)', posA = annotPos_i;
        otherwise,  posA = annotPos_jkl;
    end
    text(posA(1), posA(2), thisLabel, 'Units','normalized',...
         'FontSize',annotationFontSize,'FontWeight','bold','Color','k');

    labelIdx = labelIdx + 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (B) Column #2: dt effect
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax2 = nexttile;
    hold(ax2,'on'); box(ax2,'on');
    ax2.FontSize = axisFontSize;
    ax2.XColor = 'k';
    ax2.YColor = 'k';

    thisLabel = subplotLabels{labelIdx};
    markerInLegendOnly = ismember(thisLabel, subplotsMarkerLegend);

    % (1) True 선을 맨 먼저 그려서 뒤로 보냄 (Legend에서는 감춤)
    plot(theta_true, gamma_true, 'k-', 'LineWidth',1, 'HandleVisibility','off');

    matchIdx = false(size(AS_data));
    for k = 1:numel(AS_data)
        if ismember(AS_data(k).type, typeGroup_dt) && (AS_data(k).SN == sn)
            matchIdx(k) = true;
        end
    end
    selData = AS_data(matchIdx);

    addedType = false(1,numel(typeGroup_dt));
    for d = 1:numel(selData)
        tname       = selData(d).type;
        cidx        = find(strcmp(typeGroup_dt, tname));
        theta_est   = selData(d).theta;
        gamma_avg   = selData(d).gamma_avg;
        gamma_lower = selData(d).gamma_lower;
        gamma_upper = selData(d).gamma_upper;

        % Shaded 영역 (confidence interval)
        fill([theta_est; flipud(theta_est)], ...
             [gamma_lower; flipud(gamma_upper)], ...
             p_colors(cidx,:), 'FaceAlpha',fillAlpha, ...
             'EdgeColor','none','HandleVisibility','off');

        % 평균 곡선
        plot(theta_est, gamma_avg, 'LineWidth',lineWidthValue,...
             'Color', p_colors(cidx,:), 'HandleVisibility','off');

        % Legend용 (처음 등장할 때만)
        if ~addedType(cidx)
            if markerInLegendOnly
                plot(NaN, NaN, 'LineWidth',lineWidthValue,...
                     'Color', p_colors(cidx,:), ...
                     'Marker','s','MarkerFaceColor', p_colors(cidx,:), ...
                     'DisplayName', legendLabels_dt{cidx});
            else
                plot(NaN, NaN, 'LineWidth',lineWidthValue,...
                     'Color', p_colors(cidx,:), ...
                     'DisplayName', legendLabels_dt{cidx});
            end
            addedType(cidx) = true;
        end
    end

    % (3) Legend에는 "True"를 추가(NaN 핸들)
    if markerInLegendOnly
        plot(NaN, NaN, 'k-', 'LineWidth',1, 'DisplayName','True');
    else
        plot(NaN, NaN, 'k-', 'LineWidth',1, 'DisplayName','True');
    end

    xlabel('$\theta = \ln(\tau\,[\mathrm{s}])$','Interpreter','latex',...
           'FontSize',axisFontSize,'Color','k');
    ylabel('$\gamma~(\Omega)$','Interpreter','latex',...
           'FontSize',axisFontSize,'Color','k');

    lgd2 = legend('Box','off','FontSize',legendFontSize);
    lgd2.ItemTokenSize = legendTokenManualList{labelIdx};

    switch thisLabel
        case '(b)'
            set(lgd2,'Location','none','Units','normalized','Position',legendPos_b);
        case '(c)'
            set(lgd2,'Location','none','Units','normalized','Position',legendPos_c);
        case '(d)'
            set(lgd2,'Location','none','Units','normalized','Position',legendPos_d);
        case '(e)'
            set(lgd2,'Location','none','Units','normalized','Position',legendPos_e);
        case '(f)'
            set(lgd2,'Location','none','Units','normalized','Position',legendPos_f);
        case '(g)'
            set(lgd2,'Location','none','Units','normalized','Position',legendPos_g);
        case '(h)'
            set(lgd2,'Location','none','Units','normalized','Position',legendPos_h);
        case '(i)'
            set(lgd2,'Location','none','Units','normalized','Position',legendPos_i);
        case '(j)'
            set(lgd2,'Location','none','Units','normalized','Position',legendPos_j);
        case '(k)'
            set(lgd2,'Location','none','Units','normalized','Position',legendPos_k);
        case '(l)'
            set(lgd2,'Location','none','Units','normalized','Position',legendPos_l);
    end

    try
        lgd2.BoxFace.ColorType = 'truecoloralpha';
        lgd2.BoxFace.ColorData = uint8(255*[1;1;1;legendAlpha]);
    catch
        warning('Legend alpha not supported in this MATLAB version.');
    end

    switch thisLabel
        case '(b)', posA = annotPos_b;
        case '(c)', posA = annotPos_c;
        case '(d)', posA = annotPos_d;
        case '(e)', posA = annotPos_e;
        case '(f)', posA = annotPos_f;
        case '(g)', posA = annotPos_g;
        case '(h)', posA = annotPos_h;
        case '(i)', posA = annotPos_i;
        otherwise,  posA = annotPos_jkl;
    end
    text(posA(1), posA(2), thisLabel, 'Units','normalized',...
         'FontSize',annotationFontSize,'FontWeight','bold','Color','k');
    labelIdx = labelIdx + 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (C) Column #3: dur effect
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax3 = nexttile;
    hold(ax3,'on'); box(ax3,'on');
    ax3.FontSize = axisFontSize;
    ax3.XColor = 'k';
    ax3.YColor = 'k';

    thisLabel = subplotLabels{labelIdx};
    markerInLegendOnly = ismember(thisLabel, subplotsMarkerLegend);

    % (1) True 선을 맨 먼저 그려서 뒤로 보냄 (Legend에서는 감춤)
    plot(theta_true, gamma_true, 'k-', 'LineWidth',1, 'HandleVisibility','off');

    matchIdx = false(size(AS_data));
    for k = 1:numel(AS_data)
        if ismember(AS_data(k).type, typeGroup_dur) && (AS_data(k).SN == sn)
            matchIdx(k) = true;
        end
    end
    selData = AS_data(matchIdx);

    addedType = false(1,numel(typeGroup_dur));
    for d = 1:numel(selData)
        tname       = selData(d).type;
        cidx        = find(strcmp(typeGroup_dur, tname));
        theta_est   = selData(d).theta;
        gamma_avg   = selData(d).gamma_avg;
        gamma_lower = selData(d).gamma_lower;
        gamma_upper = selData(d).gamma_upper;

        fill([theta_est; flipud(theta_est)], ...
             [gamma_lower; flipud(gamma_upper)], ...
             p_colors(cidx,:), 'FaceAlpha',fillAlpha, ...
             'EdgeColor','none','HandleVisibility','off');
        plot(theta_est, gamma_avg, 'LineWidth',lineWidthValue,...
             'Color', p_colors(cidx,:), 'HandleVisibility','off');

        if ~addedType(cidx)
            if markerInLegendOnly
                plot(NaN, NaN, 'LineWidth',lineWidthValue,...
                     'Color', p_colors(cidx,:), ...
                     'Marker','s','MarkerFaceColor', p_colors(cidx,:), ...
                     'DisplayName', legendLabels_dur{cidx});
            else
                plot(NaN, NaN, 'LineWidth',lineWidthValue,...
                     'Color', p_colors(cidx,:), ...
                     'DisplayName', legendLabels_dur{cidx});
            end
            addedType(cidx) = true;
        end
    end

    % (3) Legend에는 "True"를 추가(NaN 핸들)
    if markerInLegendOnly
        plot(NaN, NaN, 'k-', 'LineWidth',1, 'DisplayName','True');
    else
        plot(NaN, NaN, 'k-', 'LineWidth',1, 'DisplayName','True');
    end

    xlabel('$\theta = \ln(\tau\,[\mathrm{s}])$','Interpreter','latex',...
           'FontSize',axisFontSize,'Color','k');
    ylabel('$\gamma~(\Omega)$','Interpreter','latex',...
           'FontSize',axisFontSize,'Color','k');

    lgd3 = legend('Box','off','FontSize',legendFontSize);
    lgd3.ItemTokenSize = legendTokenManualList{labelIdx};

    switch thisLabel
        case '(c)'
            set(lgd3,'Location','none','Units','normalized','Position',legendPos_c);
        case '(d)'
            set(lgd3,'Location','none','Units','normalized','Position',legendPos_d);
        case '(e)'
            set(lgd3,'Location','none','Units','normalized','Position',legendPos_e);
        case '(f)'
            set(lgd3,'Location','none','Units','normalized','Position',legendPos_f);
        case '(g)'
            set(lgd3,'Location','none','Units','normalized','Position',legendPos_g);
        case '(h)'
            set(lgd3,'Location','none','Units','normalized','Position',legendPos_h);
        case '(i)'
            set(lgd3,'Location','none','Units','normalized','Position',legendPos_i);
        case '(j)'
            set(lgd3,'Location','none','Units','normalized','Position',legendPos_j);
        case '(k)'
            set(lgd3,'Location','none','Units','normalized','Position',legendPos_k);
        case '(l)'
            set(lgd3,'Location','none','Units','normalized','Position',legendPos_l);
    end

    try
        lgd3.BoxFace.ColorType = 'truecoloralpha';
        lgd3.BoxFace.ColorData = uint8(255*[1;1;1;legendAlpha]);
    catch
        warning('Legend alpha not supported in this MATLAB version.');
    end

    switch thisLabel
        case '(c)', posA = annotPos_c;
        case '(d)', posA = annotPos_d;
        case '(e)', posA = annotPos_e;
        case '(f)', posA = annotPos_f;
        case '(g)', posA = annotPos_g;
        case '(h)', posA = annotPos_h;
        case '(i)', posA = annotPos_i;
        otherwise,  posA = annotPos_jkl;
    end
    text(posA(1), posA(2), thisLabel, 'Units','normalized',...
         'FontSize',annotationFontSize,'FontWeight','bold','Color','k');
    labelIdx = labelIdx + 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (D) Column #4: N effect
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax4 = nexttile;
    hold(ax4,'on'); box(ax4,'on');
    ax4.FontSize = axisFontSize;
    ax4.XColor = 'k';
    ax4.YColor = 'k';

    thisLabel = subplotLabels{labelIdx};
    markerInLegendOnly = ismember(thisLabel, subplotsMarkerLegend);

    % (1) True 선을 맨 먼저 그려서 뒤로 보냄 (Legend에서는 감춤)
    plot(theta_true, gamma_true, 'k-', 'LineWidth',1, 'HandleVisibility','off');

    matchIdx = false(size(AS_data));
    for k = 1:numel(AS_data)
        if ismember(AS_data(k).type, typeGroup_N) && (AS_data(k).SN == sn)
            matchIdx(k) = true;
        end
    end
    selData = AS_data(matchIdx);

    addedType = false(1,numel(typeGroup_N));
    for d = 1:numel(selData)
        tname       = selData(d).type;
        cidx        = find(strcmp(typeGroup_N, tname));
        theta_est   = selData(d).theta;
        gamma_avg   = selData(d).gamma_avg;
        gamma_lower = selData(d).gamma_lower;
        gamma_upper = selData(d).gamma_upper;

        fill([theta_est; flipud(theta_est)], ...
             [gamma_lower; flipud(gamma_upper)], ...
             p_colors(cidx,:), 'FaceAlpha',fillAlpha, ...
             'EdgeColor','none','HandleVisibility','off');
        plot(theta_est, gamma_avg, 'LineWidth',lineWidthValue,...
             'Color', p_colors(cidx,:), 'HandleVisibility','off');

        if ~addedType(cidx)
            if markerInLegendOnly
                plot(NaN, NaN, 'LineWidth',lineWidthValue,...
                     'Color', p_colors(cidx,:), ...
                     'Marker','s','MarkerFaceColor', p_colors(cidx,:), ...
                     'DisplayName', legendLabels_N{cidx});
            else
                plot(NaN, NaN, 'LineWidth',lineWidthValue,...
                     'Color', p_colors(cidx,:), ...
                     'DisplayName', legendLabels_N{cidx});
            end
            addedType(cidx) = true;
        end
    end

    % (3) Legend에는 "True"를 추가(NaN 핸들)
    if markerInLegendOnly
        plot(NaN, NaN, 'k-', 'LineWidth',1, 'DisplayName','True');
    else
        plot(NaN, NaN, 'k-', 'LineWidth',1, 'DisplayName','True');
    end

    xlabel('$\theta = \ln(\tau\,[\mathrm{s}])$','Interpreter','latex',...
           'FontSize',axisFontSize,'Color','k');
    ylabel('$\gamma~(\Omega)$','Interpreter','latex',...
           'FontSize',axisFontSize,'Color','k');

    lgd4 = legend('Box','off','FontSize',legendFontSize);
    lgd4.ItemTokenSize = legendTokenManualList{labelIdx};

    switch thisLabel
        case '(d)'
            set(lgd4,'Location','none','Units','normalized','Position',legendPos_d);
        case '(e)'
            set(lgd4,'Location','none','Units','normalized','Position',legendPos_e);
        case '(f)'
            set(lgd4,'Location','none','Units','normalized','Position',legendPos_f);
        case '(g)'
            set(lgd4,'Location','none','Units','normalized','Position',legendPos_g);
        case '(h)'
            set(lgd4,'Location','none','Units','normalized','Position',legendPos_h);
        case '(i)'
            set(lgd4,'Location','none','Units','normalized','Position',legendPos_i);
        case '(j)'
            set(lgd4,'Location','none','Units','normalized','Position',legendPos_j);
        case '(k)'
            set(lgd4,'Location','none','Units','normalized','Position',legendPos_k);
        case '(l)'
            set(lgd4,'Location','none','Units','normalized','Position',legendPos_l);
    end

    try
        lgd4.BoxFace.ColorType = 'truecoloralpha';
        lgd4.BoxFace.ColorData = uint8(255*[1;1;1;legendAlpha]);
    catch
        warning('Legend alpha not supported in this MATLAB version.');
    end

    switch thisLabel
        case '(d)', posA = annotPos_d;
        case '(e)', posA = annotPos_e;
        case '(f)', posA = annotPos_f;
        case '(g)', posA = annotPos_g;
        case '(h)', posA = annotPos_h;
        case '(i)', posA = annotPos_i;
        otherwise,  posA = annotPos_jkl;
    end
    text(posA(1), posA(2), thisLabel, 'Units','normalized',...
         'FontSize',annotationFontSize,'FontWeight','bold','Color','k');
    labelIdx = labelIdx + 1;

end

%% === 6) OPTIONAL: SAVE FIGURE ===============================================
outName = 'CompareAll_AS2_3x4';   % 파일 이름 (확장자 제외)

% PNG (300 dpi)
exportgraphics(gcf, [outName '.png'], 'Resolution', 300);

% FIG  ← 추가된 부분
savefig(gcf, [outName '.fig']);         % MATLAB 자체 형식도 함께 저장
