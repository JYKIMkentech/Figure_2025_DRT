%% ========================================================================
%  CompareAll_3x4_NOISE_LOOP.m   (rev-03b, 2025-08-02)
%  ------------------------------------------------------------------------
%  • 노이즈 1 %, 2 %, 4 %, 5 % 데이터(AS1_*per_new.mat)를 차례로 불러와
%    3×4 레이아웃 Figure(4 개)를 생성
%  • 그림과 *.fig 둘 다 저장 (파일명: CompareAll_3x4_<noise>.png / .fig)
%  • Figure 창은 닫지 않고 남겨 둠
%  ------------------------------------------------------------------------
%  변경 이력
%   2025-07-26  legendPosList 추가, 각 subplot 개별 위치 지정
%   2025-08-02  글씨체 산세리프 upright 로 통일 (tex interpreter)
%              helper 함수 styleAxis( ) 추가 - 파일 맨 끝에 배치
%   2025-08-02b Current·Voltage 축·라벨 색상 모두 검은색으로 통일
%  ------------------------------------------------------------------------
%% ========================================================================

clc; clear; close all;

%% === 0) USER-CONTROLLED LAYOUT PARAMETERS ==================================
figWidth_cm    = 26;
figHeight_cm   = 16;
figPosX_cm     = 2;
figPosY_cm     = 2;

tileSpacingChoice = 'compact';
tilePaddingChoice = 'compact';

annotPos  = [-0.22, 1.05];              % subplot 라벨 위치

legendPosList = {                       % 12개 subplot legend 좌표
   [0.02, 0.68, 0.30, 0.08], [0.29, 0.88, 0.30, 0.08], ...
   [0.53, 0.88, 0.30, 0.08], [0.77, 0.88, 0.30, 0.08], ...
   [0.02, 0.355,0.30, 0.08], [0.29, 0.55, 0.30, 0.08], ...
   [0.53, 0.55, 0.30, 0.08], [0.77, 0.55, 0.30, 0.08], ...
   [0.02, 0.03, 0.30, 0.08], [0.29, 0.23, 0.30, 0.08], ...
   [0.53, 0.23, 0.30, 0.08], [0.77, 0.23, 0.30, 0.08]};
legendTokenManualList = repmat({[15,15]}, 1, 12);
legendAlpha = 0.7;

%% === 1) DATA PATH & TRUE GAMMA ============================================
dataFolder = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_DRT\';
trueFile   = 'Gamma_unimodal.mat';
tmp_true   = load(fullfile(dataFolder, trueFile));
theta_true = tmp_true.Gamma_unimodal.theta;
gamma_true = tmp_true.Gamma_unimodal.gamma;

%% === 2) STYLING PARAMETERS =================================================
lineWidthValue     = 1;
fillAlpha          = 0.3;
axisFontSize       = 8;
legendFontSize     = 6;
annotationFontSize = 9;

p_colors = [
   0.00000, 0.44706, 0.74118;
   0.93725, 0.75294, 0.00000;
   0.80392, 0.32549, 0.29803;
   0.12549, 0.52157, 0.30588];

subplotLabels = {'(a)','(b)','(c)','(d)','(e)','(f)',...
                 '(g)','(h)','(i)','(j)','(k)','(l)'};

%% === 3) SCENARIOS & TYPE-GROUPS ===========================================
scenarioList   = [1, 5, 10];

typeGroup_dt     = {'A','D','E','F'};
legendLabels_dt  = {'dt=0.1','dt=0.2','dt=1','dt=2'};

typeGroup_dur    = {'A','G','H'};
legendLabels_dur = {'Dur=1000','Dur=500','Dur=250'};

typeGroup_N      = {'A','B','C'};
legendLabels_N   = {'N=201','N=101','N=21'};

subplotsMarkerLegend = {'(b)','(c)','(d)','(f)','(g)','(h)','(j)','(k)','(l)'};

%% === 4) LOOP OVER NOISE LEVELS ============================================
noiseLevels = {'1per','2per','4per','5per'};

for nIdx = 1:numel(noiseLevels)
    noiseTag = noiseLevels{nIdx};
    dataFile = ['AS1_' noiseTag '_new.mat'];

    matData = load(fullfile(dataFolder, dataFile));
    varName = fieldnames(matData);
    AS_data = matData.(varName{1});

    figure('Name',['CompareAll_' noiseTag],'Color','w','Units','centimeters', ...
           'Position',[figPosX_cm figPosY_cm figWidth_cm figHeight_cm]);
    tiledlayout(3,4,'TileSpacing',tileSpacingChoice,'Padding',tilePaddingChoice);

    labelIdx = 1;

    %% === 5) ROW LOOP ======================================================
    for iRow = 1:numel(scenarioList)
        sn = scenarioList(iRow);

        % ------------------------------ (A) Waveforms ----------------------
        ax1 = nexttile;  hold(ax1,'on'); box(ax1,'on');
        styleAxis(ax1, axisFontSize);

        tPlot = AS_data(sn).t;  iPlot = AS_data(sn).I;  vPlot = AS_data(sn).V;

        yyaxis left
        h1 = plot(tPlot, iPlot,'Color',p_colors(1,:), ...
                  'LineWidth',1,'DisplayName','Current');
        ylabel('Current (A)','Interpreter','tex','Color','k'); ylim([-4 4]);
        ax1.YAxis(1).Color = 'k';              % 왼쪽 y-axis 검정

        yyaxis right
        h2 = plot(tPlot, vPlot,'Color',p_colors(3,:), ...
                  'LineWidth',1,'DisplayName','Voltage');
        ylabel('Voltage (V)','Interpreter','tex','Color','k');
        ax1.YAxis(2).Color = 'k';              % 오른쪽 y-axis 검정

        xlabel('Time (s)','Interpreter','tex','Color','k');

        lgd = legend([h1,h2],'FontSize',legendFontSize, ...
                     'Orientation','horizontal','Box','off');
        lgd.ItemTokenSize = legendTokenManualList{labelIdx};
        set(lgd,'Location','none','Units','normalized', ...
                 'Position',legendPosList{labelIdx});
        try
            lgd.BoxFace.ColorType = 'truecoloralpha';
            lgd.BoxFace.ColorData = uint8(255*[1;1;1;legendAlpha]);
        end

        text(annotPos(1),annotPos(2),subplotLabels{labelIdx}, ...
             'Units','normalized','FontSize',annotationFontSize,'FontWeight','bold');
        labelIdx = labelIdx + 1;

        % ------------------------------ (B) dt effect ----------------------
        ax2 = nexttile; hold(ax2,'on'); box(ax2,'on'); styleAxis(ax2,axisFontSize);

        thisLabel = subplotLabels{labelIdx};
        markerInLegendOnly = ismember(thisLabel, subplotsMarkerLegend);

        plot(theta_true,gamma_true,'k-','LineWidth',1,'HandleVisibility','off');

        selData   = AS_data(ismember({AS_data.type},typeGroup_dt) & [AS_data.SN]==sn);
        addedType = false(1,numel(typeGroup_dt));
        for d = 1:numel(selData)
            cidx = find(strcmp(typeGroup_dt,selData(d).type));
            theta_est   = selData(d).theta;
            gamma_avg   = selData(d).gamma_avg;
            gamma_lower = selData(d).gamma_lower;
            gamma_upper = selData(d).gamma_upper;

            fill([theta_est; flipud(theta_est)], ...
                 [gamma_lower; flipud(gamma_upper)], ...
                 p_colors(cidx,:),'FaceAlpha',fillAlpha,'EdgeColor','none', ...
                 'HandleVisibility','off');
            plot(theta_est,gamma_avg,'LineWidth',lineWidthValue, ...
                 'Color',p_colors(cidx,:),'HandleVisibility','off');

            if ~addedType(cidx)
                if markerInLegendOnly
                    plot(NaN,NaN,'Marker','s','MarkerFaceColor',p_colors(cidx,:), ...
                         'LineWidth',lineWidthValue,'Color',p_colors(cidx,:), ...
                         'DisplayName',legendLabels_dt{cidx});
                else
                    plot(NaN,NaN,'LineWidth',lineWidthValue,'Color',p_colors(cidx,:), ...
                         'DisplayName',legendLabels_dt{cidx});
                end
                addedType(cidx) = true;
            end
        end
        plot(NaN,NaN,'k-','LineWidth',1,'DisplayName','True');

        xlabel('\theta = ln(\tau [s])','Interpreter','tex','Color','k');
        ylabel('\gamma (\Omega)','Interpreter','tex','Color','k');

        lgd2 = legend('Box','off','FontSize',legendFontSize);
        lgd2.ItemTokenSize = legendTokenManualList{labelIdx};
        set(lgd2,'Location','none','Units','normalized', ...
                 'Position',legendPosList{labelIdx});
        try
            lgd2.BoxFace.ColorType = 'truecoloralpha';
            lgd2.BoxFace.ColorData = uint8(255*[1;1;1;legendAlpha]);
        end

        text(annotPos(1),annotPos(2),thisLabel,'Units','normalized', ...
             'FontSize',annotationFontSize,'FontWeight','bold');
        labelIdx = labelIdx + 1;

        % ------------------------------ (C) dur effect ---------------------
        ax3 = nexttile; hold(ax3,'on'); box(ax3,'on'); styleAxis(ax3,axisFontSize);

        thisLabel = subplotLabels{labelIdx};
        markerInLegendOnly = ismember(thisLabel, subplotsMarkerLegend);

        plot(theta_true,gamma_true,'k-','LineWidth',1,'HandleVisibility','off');

        selData   = AS_data(ismember({AS_data.type},typeGroup_dur) & [AS_data.SN]==sn);
        addedType = false(1,numel(typeGroup_dur));
        for d = 1:numel(selData)
            cidx = find(strcmp(typeGroup_dur,selData(d).type));
            theta_est   = selData(d).theta;
            gamma_avg   = selData(d).gamma_avg;
            gamma_lower = selData(d).gamma_lower;
            gamma_upper = selData(d).gamma_upper;

            fill([theta_est; flipud(theta_est)], ...
                 [gamma_lower; flipud(gamma_upper)], ...
                 p_colors(cidx,:),'FaceAlpha',fillAlpha,'EdgeColor','none', ...
                 'HandleVisibility','off');
            plot(theta_est,gamma_avg,'LineWidth',lineWidthValue, ...
                 'Color',p_colors(cidx,:),'HandleVisibility','off');

            if ~addedType(cidx)
                if markerInLegendOnly
                    plot(NaN,NaN,'Marker','s','MarkerFaceColor',p_colors(cidx,:), ...
                         'LineWidth',lineWidthValue,'Color',p_colors(cidx,:), ...
                         'DisplayName',legendLabels_dur{cidx});
                else
                    plot(NaN,NaN,'LineWidth',lineWidthValue,'Color',p_colors(cidx,:), ...
                         'DisplayName',legendLabels_dur{cidx});
                end
                addedType(cidx) = true;
            end
        end
        plot(NaN,NaN,'k-','LineWidth',1,'DisplayName','True');

        xlabel('\theta = ln(\tau [s])','Interpreter','tex','Color','k');
        ylabel('\gamma (\Omega)','Interpreter','tex','Color','k');

        lgd3 = legend('Box','off','FontSize',legendFontSize);
        lgd3.ItemTokenSize = legendTokenManualList{labelIdx};
        set(lgd3,'Location','none','Units','normalized', ...
                 'Position',legendPosList{labelIdx});
        try
            lgd3.BoxFace.ColorType = 'truecoloralpha';
            lgd3.BoxFace.ColorData = uint8(255*[1;1;1;legendAlpha]);
        end

        text(annotPos(1),annotPos(2),thisLabel,'Units','normalized', ...
             'FontSize',annotationFontSize,'FontWeight','bold');
        labelIdx = labelIdx + 1;

        % ------------------------------ (D) N effect -----------------------
        ax4 = nexttile; hold(ax4,'on'); box(ax4,'on'); styleAxis(ax4,axisFontSize);

        thisLabel = subplotLabels{labelIdx};
        markerInLegendOnly = ismember(thisLabel, subplotsMarkerLegend);

        plot(theta_true,gamma_true,'k-','LineWidth',1,'HandleVisibility','off');

        selData   = AS_data(ismember({AS_data.type},typeGroup_N) & [AS_data.SN]==sn);
        addedType = false(1,numel(typeGroup_N));
        for d = 1:numel(selData)
            cidx = find(strcmp(typeGroup_N,selData(d).type));
            theta_est   = selData(d).theta;
            gamma_avg   = selData(d).gamma_avg;
            gamma_lower = selData(d).gamma_lower;
            gamma_upper = selData(d).gamma_upper;

            fill([theta_est; flipud(theta_est)], ...
                 [gamma_lower; flipud(gamma_upper)], ...
                 p_colors(cidx,:),'FaceAlpha',fillAlpha,'EdgeColor','none', ...
                 'HandleVisibility','off');
            plot(theta_est,gamma_avg,'LineWidth',lineWidthValue, ...
                 'Color',p_colors(cidx,:),'HandleVisibility','off');

            if ~addedType(cidx)
                if markerInLegendOnly
                    plot(NaN,NaN,'Marker','s','MarkerFaceColor',p_colors(cidx,:), ...
                         'LineWidth',lineWidthValue,'Color',p_colors(cidx,:), ...
                         'DisplayName',legendLabels_N{cidx});
                else
                    plot(NaN,NaN,'LineWidth',lineWidthValue,'Color',p_colors(cidx,:), ...
                         'DisplayName',legendLabels_N{cidx});
                end
                addedType(cidx) = true;
            end
        end
        plot(NaN,NaN,'k-','LineWidth',1,'DisplayName','True');

        xlabel('\theta = ln(\tau [s])','Interpreter','tex','Color','k');
        ylabel('\gamma (\Omega)','Interpreter','tex','Color','k');

        lgd4 = legend('Box','off','FontSize',legendFontSize);
        lgd4.ItemTokenSize = legendTokenManualList{labelIdx};
        set(lgd4,'Location','none','Units','normalized', ...
                 'Position',legendPosList{labelIdx});
        try
            lgd4.BoxFace.ColorType = 'truecoloralpha';
            lgd4.BoxFace.ColorData = uint8(255*[1;1;1;legendAlpha]);
        end

        text(annotPos(1),annotPos(2),thisLabel,'Units','normalized', ...
             'FontSize',annotationFontSize,'FontWeight','bold');
        labelIdx = labelIdx + 1;
    end  % ---------------- row loop 끝 --------------------------------------

    %% === 6) SAVE FIGURE ====================================================
    outName = ['CompareAll_3x4_' noiseTag];
    exportgraphics(gcf,[outName '.png'],'Resolution',300);
    savefig(gcf,[outName '.fig']);
end  % ---------------- noise loop 끝 ----------------------------------------

%% ========================================================================
%  Local function  : 공통 축 서식
% ========================================================================
function styleAxis(ax, axisFontSize)
    if ispc
        ax.FontName = 'Arial';      % Windows
    else
        ax.FontName = 'Helvetica';  % macOS / Linux
    end
    ax.FontSize             = axisFontSize;
    ax.TickLabelInterpreter = 'tex';
    ax.XColor = 'k';  ax.YColor = 'k';
    ax.LineWidth = 0.75;
end


