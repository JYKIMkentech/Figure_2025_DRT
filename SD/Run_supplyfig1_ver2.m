clc; clear; close all;

%% === 0) USER-CONTROLLED LAYOUT PARAMETERS ===================================
figWidth_cm    = 26;   % 전체 Figure 너비 (cm)
figHeight_cm   = 16;   % 전체 Figure 높이 (cm)
figPosX_cm     = 2;    % 모니터상 배치 (왼쪽 위치)
figPosY_cm     = 2;    % 모니터상 배치 (아래 위치)

% TiledLayout 관련 (Row=3, Col=4)
tileSpacingChoice = 'compact';  % {'none','compact','loose'}
tilePaddingChoice = 'compact';  % {'none','compact','loose'}

% --------------------------
%  (a)~(i) annotation 위치
% --------------------------
annotPos_a = [0.02, 0.90];
annotPos_b = [0.02, 0.90];
annotPos_c = [0.02, 0.90];
annotPos_d = [0.02, 0.90];
annotPos_e = [0.02, 0.90];
annotPos_f = [0.02, 0.90];
annotPos_g = [0.02, 0.90];
annotPos_h = [0.02, 0.90];
annotPos_i = [0.02, 0.90];

% (j)~(l)은 필요한 경우 별도 지정
annotPos_jkl = [0.02, 0.90];  % 일단 동일하게 사용

% --------------------------
%  (a)~(i) legend 위치
%    -> Units='normalized' 기준 [left, bottom, width, height]
% --------------------------
legendPos_a = [0.03, 0.68, 0.3, 0.08];
legendPos_b = [0.3, 0.86, 0.3, 0.08];
legendPos_c = [0.6, 0.8, 0.3, 0.08];
legendPos_d = [0.6, 0.8, 0.3, 0.08];
legendPos_e = [0.03, 0.355, 0.3, 0.08];
legendPos_f = [0.6, 0.8, 0.3, 0.08];
legendPos_g = [0.6, 0.8, 0.3, 0.08];
legendPos_h = [0.6, 0.8, 0.3, 0.08];
legendPos_i = [0.03, 0.03, 0.3, 0.08];

% j,k,l에 대해서도 수동 위치 지정
legendPos_j = [0.2, 0.1, 0.3, 0.08];  % <--- 필요시 원하는 위치로 수정
legendPos_k = [0.2, 0.1, 0.3, 0.08];  % <--- 필요시 원하는 위치로 수정
legendPos_l = [0.2, 0.1, 0.3, 0.08];  % <--- 필요시 원하는 위치로 수정

% --------------------------
%  Legend ItemTokenSize(굵기/간격)을
%  (a)~(l) 서브플롯별로 따로 지정하고 싶을 때:
% --------------------------
legendTokenManualList = {
    [30,18], % (a)
    [20,16], % (b)
    [25,15], % (c)
    [30,18], % (d)
    [30,18], % (e)
    [25,20], % (f)
    [30,15], % (g)
    [35,18], % (h)
    [30,18], % (i)
    [30,18], % (j)
    [30,18], % (k)
    [30,18]  % (l)
};

%% === 1) PREPARE DATA ========================================================
dataFolder = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_DRT\';
dataFile   = 'AS1_4per_new.mat'; % Contains types A,B,C,D,E,F,G,H, etc.
load(fullfile(dataFolder, dataFile),'AS1_4per_new');
AS_data = AS1_4per_new;  % shorter name

% True gamma
trueFile = 'Gamma_unimodal.mat';
tmp_true = load(fullfile(dataFolder, trueFile));
theta_true = tmp_true.Gamma_unimodal.theta;
gamma_true = tmp_true.Gamma_unimodal.gamma;

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
    % 필요한 경우 더 추가
];

% Subplot label strings (a,b,c... up to l)
subplotLabels = {'(a)','(b)','(c)','(d)','(e)','(f)', ...
                 '(g)','(h)','(i)','(j)','(k)','(l)'};

%% === 3) SCENARIOS & TYPE-GROUPS =============================================
scenarioList = [1, 5, 10]; % 3 scenarios

typeGroup_dt    = {'A','D','E','F'};
legendLabels_dt = {'dt=0.1','dt=0.2','dt=1','dt=2'};

typeGroup_dur    = {'A','G','H'};
legendLabels_dur = {'Dur=1000','Dur=500','Dur=250'};

typeGroup_N    = {'A','B','C'};
legendLabels_N = {'N=201','N=101','N=21'};

%% === 4) MAKE A 3×4 FIGURE LAYOUT ============================================
figure('Name','CompareAll','Color','w','Units','centimeters',...
       'Position',[figPosX_cm figPosY_cm figWidth_cm figHeight_cm]);

tiledlayout(3,4,'TileSpacing',tileSpacingChoice,'Padding',tilePaddingChoice);

% (b), (c), (d), (f), (g), (h), (j), (k), (l) 에서는
% 레전드만 "라인+스퀘어" 표시, 실제 플롯은 "라인만" 표시
subplotsMarkerLegend = {'(b)','(c)','(d)','(f)','(g)','(h)','(j)','(k)','(l)'};

labelIdx = 1;  % subplotLabels 인덱스

%% === 5) LOOP OVER ROWS (SCENARIOS) ==========================================
for iRow = 1:3
    sn = scenarioList(iRow);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (A) Column #1: Waveforms for this scenario (DUAL Y-AXIS)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax1 = nexttile;
    hold(ax1,'on'); box(ax1,'on');
    ax1.FontSize = axisFontSize;
    ax1.XColor = 'k';
    ax1.YColor = 'k';

    % -- Real data from AS1_4per_new(sn).t, .I, .V --
    tPlot = AS_data(sn).t;
    iPlot = AS_data(sn).I;  % Left axis
    vPlot = AS_data(sn).V;  % Right axis

    yyaxis left
    ax1.YAxis(1).Color = 'k';
    h1 = plot(tPlot, iPlot, 'Color', p_colors(1,:), 'LineWidth',1,...
              'DisplayName','Current');
    ylabel('Current (A)','FontSize',axisFontSize,'Color','k');

    yyaxis right
    ax1.YAxis(2).Color = 'k';
    h2 = plot(tPlot, vPlot, 'Color', p_colors(3,:), 'LineWidth',1,...
              'DisplayName','Voltage');
    ylabel('Voltage (V)','FontSize',axisFontSize,'Color','k');

    xlabel('Time (s)','FontSize',axisFontSize,'Color','k');

    % 레전드
    lgd = legend([h1,h2],{'Current','Voltage'}, ...
           'FontSize',legendFontSize,'Orientation','horizontal','Box','off');
    lgd.ItemTokenSize = legendTokenManualList{labelIdx};

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
        otherwise,  posA = annotPos_jkl;  % j,k,l도 여기 사용
    end
    text(posA(1), posA(2), thisLabel, 'Units','normalized',...
         'FontSize',annotationFontSize,'FontWeight','bold','Color','k');
    labelIdx = labelIdx + 1;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % (B) Column #2: dt effect for this scenario
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax2 = nexttile;
    hold(ax2,'on'); box(ax2,'on');
    ax2.FontSize = axisFontSize;
    ax2.XColor = 'k';
    ax2.YColor = 'k';

    thisLabel = subplotLabels{labelIdx};
    % 이 서브플롯이 "레전드만 라인+마커"를 써야 하는지 여부
    markerInLegendOnly = ismember(thisLabel, subplotsMarkerLegend);

    % 시뮬레이션 데이터 필터: typeGroup_dt & scenario=sn
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

        % (1) UNC 영역 fill -- 실제 플롯용 (handle off)
        fill([theta_est; flipud(theta_est)], ...
             [gamma_lower; flipud(gamma_upper)], ...
             p_colors(cidx,:), 'FaceAlpha',fillAlpha,'EdgeColor','none',...
             'HandleVisibility','off');

        % (2) 실제 평균 라인 -- 플롯에만 표시 (handle off)
        plot(theta_est, gamma_avg, 'LineWidth',lineWidthValue,...
             'Color', p_colors(cidx,:), 'HandleVisibility','off');

        % (3) 레전드용 "더미" line+marker
        if ~addedType(cidx)
            if markerInLegendOnly
                % 레전드에만 라인+사각마커
                plot(NaN, NaN, 'LineWidth',lineWidthValue,...
                     'Color', p_colors(cidx,:), ...
                     'Marker','s','MarkerFaceColor', p_colors(cidx,:), ...
                     'DisplayName', legendLabels_dt{cidx});
            else
                % (a), (e), (i) 같은 경우는 그냥 라인(마커 없음)
                plot(NaN, NaN, 'LineWidth',lineWidthValue,...
                     'Color', p_colors(cidx,:), ...
                     'DisplayName', legendLabels_dt{cidx});
            end
            addedType(cidx) = true;
        end
    end

    % UNC 범례(회색 면)도 실제 fill은 이미 그렸으므로, 레전드 표시는 더미로
    if markerInLegendOnly
        % UNC도 사각마커로 하고 싶다면:
        plot(NaN,NaN,'s','MarkerFaceColor',[0.5,0.5,0.5],'LineWidth',1,...
            'DisplayName','UNC');
    else
        % 아니면 기존처럼 patch 모양으로 레전드에 표시하고 싶다면:
        fill(NaN,NaN,[0.5,0.5,0.5],'FaceAlpha',fillAlpha,'EdgeColor','none',...
             'DisplayName','UNC');
    end

    % True 라인도 마찬가지로 실제 플롯 + 레전드 핸들 분리
    % (1) 실제 라인
    plot(theta_true, gamma_true, 'k-','LineWidth',1, 'HandleVisibility','off');
    % (2) 레전드용 더미
    if markerInLegendOnly
        % True도 마커 표시하려면:
        plot(NaN,NaN,'k-s','MarkerFaceColor','k','LineWidth',1,...
             'DisplayName','True');
    else
        plot(NaN,NaN,'k-','LineWidth',1,'DisplayName','True');
    end

    xlabel('$\theta = \ln(\tau\,[\mathrm{s}])$','Interpreter','latex',...
           'FontSize',axisFontSize,'Color','k');
    ylabel('$\gamma~(\Omega)$','Interpreter','latex','FontSize',axisFontSize,...
           'Color','k');

    lgd2 = legend('Box','off','FontSize',legendFontSize);
    lgd2.ItemTokenSize = legendTokenManualList{labelIdx};

    switch thisLabel
        case '(a)'
            set(lgd2,'Location','none','Units','normalized','Position',legendPos_a);
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
    % (C) Column #3: dur effect for this scenario
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax3 = nexttile;
    hold(ax3,'on'); box(ax3,'on');
    ax3.FontSize = axisFontSize;
    ax3.XColor = 'k';
    ax3.YColor = 'k';

    thisLabel = subplotLabels{labelIdx};
    markerInLegendOnly = ismember(thisLabel, subplotsMarkerLegend);

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
             p_colors(cidx,:), 'FaceAlpha',fillAlpha,'EdgeColor','none',...
             'HandleVisibility','off');

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

    if markerInLegendOnly
        plot(NaN,NaN,'s','MarkerFaceColor',[0.5,0.5,0.5],'LineWidth',1,...
            'DisplayName','UNC');
    else
        fill(NaN,NaN,[0.5,0.5,0.5],'FaceAlpha',fillAlpha,'EdgeColor','none',...
             'DisplayName','UNC');
    end
    % True 라인
    plot(theta_true, gamma_true, 'k-','LineWidth',1, 'HandleVisibility','off');
    if markerInLegendOnly
        plot(NaN,NaN,'k-s','MarkerFaceColor','k','LineWidth',1,...
             'DisplayName','True');
    else
        plot(NaN,NaN,'k-','LineWidth',1,'DisplayName','True');
    end

    xlabel('$\theta = \ln(\tau\,[\mathrm{s}])$','Interpreter','latex',...
           'FontSize',axisFontSize,'Color','k');
    ylabel('$\gamma~(\Omega)$','Interpreter','latex','FontSize',axisFontSize,...
           'Color','k');

    lgd3 = legend('Box','off','FontSize',legendFontSize);
    lgd3.ItemTokenSize = legendTokenManualList{labelIdx};

    switch thisLabel
        case '(a)'
            set(lgd3,'Location','none','Units','normalized','Position',legendPos_a);
        case '(b)'
            set(lgd3,'Location','none','Units','normalized','Position',legendPos_b);
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
    % (D) Column #4: N effect for this scenario
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax4 = nexttile;
    hold(ax4,'on'); box(ax4,'on');
    ax4.FontSize = axisFontSize;
    ax4.XColor = 'k';
    ax4.YColor = 'k';

    thisLabel = subplotLabels{labelIdx};
    markerInLegendOnly = ismember(thisLabel, subplotsMarkerLegend);

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
             p_colors(cidx,:), 'FaceAlpha',fillAlpha,'EdgeColor','none',...
             'HandleVisibility','off');

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

    if markerInLegendOnly
        plot(NaN,NaN,'s','MarkerFaceColor',[0.5,0.5,0.5],'LineWidth',1,...
            'DisplayName','UNC');
    else
        fill(NaN,NaN,[0.5,0.5,0.5],'FaceAlpha',fillAlpha,'EdgeColor','none',...
             'DisplayName','UNC');
    end
    plot(theta_true, gamma_true, 'k-','LineWidth',1, 'HandleVisibility','off');
    if markerInLegendOnly
        plot(NaN,NaN,'k-s','MarkerFaceColor','k','LineWidth',1,...
             'DisplayName','True');
    else
        plot(NaN,NaN,'k-','LineWidth',1,'DisplayName','True');
    end

    xlabel('$\theta = \ln(\tau\,[\mathrm{s}])$','Interpreter','latex',...
           'FontSize',axisFontSize,'Color','k');
    ylabel('$\gamma~(\Omega)$','Interpreter','latex','FontSize',axisFontSize,...
           'Color','k');

    lgd4 = legend('Box','off','FontSize',legendFontSize);
    lgd4.ItemTokenSize = legendTokenManualList{labelIdx};

    switch thisLabel
        case '(a)'
            set(lgd4,'Location','none','Units','normalized','Position',legendPos_a);
        case '(b)'
            set(lgd4,'Location','none','Units','normalized','Position',legendPos_b);
        case '(c)'
            set(lgd4,'Location','none','Units','normalized','Position',legendPos_c);
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
end

%% === 6) OPTIONAL: SAVE THE FIGURE ============================================
% exportgraphics(gcf,'CompareAll_3x4.png','Resolution',300);

