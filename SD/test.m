%% ========================================================================
%  CompareAll_3x4_NOISE_LOOP.m  (updated)
%  ------------------------------------------------------------------------
%  • 노이즈 1 %, 2 %, 4 %, 5 % 데이터(AS1_*per_new.mat)를 차례로 불러와
%    3×4 레이아웃 Figure(4 개)를 생성
%  • 그림과 *.fig 둘 다 저장 (파일명: CompareAll_3x4_<noise>.png / .fig)
%  • Figure 창은 닫지 않고 남겨 둠
%  ------------------------------------------------------------------------
%  변경 사항 (2025‑07‑26):
%    └ legendPos_a~l 를 cell array(legendPosList)에 모아
%      모든 subplot 이 각자 지정된 위치를 사용하도록 수정
%  ------------------------------------------------------------------------
%% ========================================================================

clc; clear; close all;

%% === 0) USER‑CONTROLLED LAYOUT PARAMETERS ==================================
figWidth_cm    = 26;   
figHeight_cm   = 16;   
figPosX_cm     = 2;    
figPosY_cm     = 2;    

tileSpacingChoice = 'compact';  
tilePaddingChoice = 'compact';  

% annotation 위치
annotPos_a   = [-0.22, 1.05];
annotPos_b   = [-0.22, 1.05];
annotPos_c   = [-0.22, 1.05];
annotPos_d   = [-0.22, 1.05];
annotPos_e   = [-0.22, 1.05];
annotPos_f   = [-0.22, 1.05];
annotPos_g   = [-0.22, 1.05];
annotPos_h   = [-0.22, 1.05];
annotPos_i   = [-0.22, 1.05];
annotPos_jkl = [-0.22, 1.05];

% Legend 위치(개별 변수)
legendPos_a = [0.02, 0.68, 0.3, 0.08];
legendPos_b = [0.29, 0.88, 0.3, 0.08];
legendPos_c = [0.53, 0.88, 0.3, 0.08];
legendPos_d = [0.77, 0.88, 0.3, 0.08];
legendPos_e = [0.02, 0.355, 0.3, 0.08];
legendPos_f = [0.29, 0.55, 0.3, 0.08];
legendPos_g = [0.53, 0.55, 0.3, 0.08];
legendPos_h = [0.77, 0.55, 0.3, 0.08];
legendPos_i = [0.02, 0.03, 0.3, 0.08];
legendPos_j = [0.29, 0.23, 0.3, 0.08];
legendPos_k = [0.53, 0.23, 0.3, 0.08];
legendPos_l = [0.77, 0.23, 0.3, 0.08];

% --- NEW: legend position 리스트 -------------------------------------------
legendPosList = {legendPos_a, legendPos_b, legendPos_c, legendPos_d, ...
                 legendPos_e, legendPos_f, legendPos_g, legendPos_h, ...
                 legendPos_i, legendPos_j, legendPos_k, legendPos_l};

% legend 토큰 크기(12개 subplot 공통)
legendTokenManualList = repmat({[15,15]}, 1, 12);

% legend box 투명도
legendAlpha = 0.7;            % 0 = 투명 ~ 1 = 불투명

%% === 1) DATA PATH & TRUE GAMMA =============================================
dataFolder = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_DRT\';

trueFile = 'Gamma_unimodal.mat';
tmp_true  = load(fullfile(dataFolder, trueFile));
theta_true = tmp_true.Gamma_unimodal.theta;
gamma_true = tmp_true.Gamma_unimodal.gamma;

%% === 2) STYLING PARAMETERS ==================================================
lineWidthValue     = 1;
fillAlpha          = 0.3;
axisFontSize       = 8;
legendFontSize     = 6;
annotationFontSize = 9;

% 색상 팔레트
p_colors = [
     0.00000, 0.44706, 0.74118;   % Blue
     0.93725, 0.75294, 0.00000;   % Yellow
     0.80392, 0.32549, 0.29803;   % Red
     0.12549, 0.52157, 0.30588    % Green
];

subplotLabels = {'(a)','(b)','(c)','(d)','(e)','(f)',...
                 '(g)','(h)','(i)','(j)','(k)','(l)'};

%% === 3) SCENARIOS & TYPE‑GROUPS ============================================
scenarioList = [1, 5, 10];          % 세 개의 시나리오(행)

typeGroup_dt     = {'A','D','E','F'};
legendLabels_dt  = {'dt=0.1','dt=0.2','dt=1','dt=2'};

typeGroup_dur    = {'A','G','H'};
legendLabels_dur = {'Dur=1000','Dur=500','Dur=250'};

typeGroup_N      = {'A','B','C'};
legendLabels_N   = {'N=201','N=101','N=21'};

subplotsMarkerLegend = {'(b)','(c)','(d)','(f)','(g)','(h)','(j)','(k)','(l)'};

%% === 4) LOOP OVER NOISE LEVELS =============================================
noiseLevels = {'1per','2per','4per','5per'};

for nIdx = 1:numel(noiseLevels)
    noiseTag = noiseLevels{nIdx};
    dataFile = ['AS1_' noiseTag '_new.mat'];

    % -------- 데이터 로드 (변수 이름 자동 추출) -----------------------------
    matData = load(fullfile(dataFolder, dataFile));
    varName = fieldnames(matData);
    AS_data = matData.(varName{1});     % 구조체 배열

    % -------- Figure 생성 ---------------------------------------------------
    figure('Name',['CompareAll_' noiseTag],'Color','w','Units','centimeters',...
           'Position',[figPosX_cm figPosY_cm figWidth_cm figHeight_cm]);
    tiledlayout(3,4,'TileSpacing',tileSpacingChoice,'Padding',tilePaddingChoice);

    labelIdx = 1;                       % subplot 라벨 인덱스 초기화

    %% === 5) ROW LOOP (시나리오) ===========================================
    for iRow = 1:numel(scenarioList)
        sn = scenarioList(iRow);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % (A) Column #1 : Waveforms (dual‑y)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ax1 = nexttile;  hold(ax1,'on'); box(ax1,'on');
        ax1.FontSize = axisFontSize;  ax1.XColor = 'k';  ax1.YColor = 'k';

        tPlot = AS_data(sn).t;     % time
        iPlot = AS_data(sn).I;     % current
        vPlot = AS_data(sn).V;     % voltage

        yyaxis left
        h1 = plot(tPlot, iPlot, 'Color', p_colors(1,:), ...
                  'LineWidth',1,'DisplayName','Current');
        ylabel('Current (A)','FontSize',axisFontSize);
        ylim([-4 4]);

        yyaxis right
        h2 = plot(tPlot, vPlot, 'Color', p_colors(3,:), ...
                  'LineWidth',1,'DisplayName','Voltage');
        ylabel('Voltage (V)','FontSize',axisFontSize);

        xlabel('Time (s)','FontSize',axisFontSize);

        lgd = legend([h1,h2],'FontSize',legendFontSize,...
                     'Orientation','horizontal','Box','off');
        lgd.ItemTokenSize = legendTokenManualList{labelIdx};
        set(lgd,'Location','none','Units','normalized','Position',legendPosList{labelIdx});

        try   % MATLAB R2020a+ only
            lgd.BoxFace.ColorType = 'truecoloralpha';
            lgd.BoxFace.ColorData = uint8(255*[1;1;1;legendAlpha]);
        catch,  warning('Legend alpha not supported in this MATLAB version.');
        end

        % annotation
        text(annotPos_a(1), annotPos_a(2), subplotLabels{labelIdx},...
             'Units','normalized','FontSize',annotationFontSize,...
             'FontWeight','bold');
        labelIdx = labelIdx + 1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % (B) Column #2 : dt effect
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ax2 = nexttile;  hold(ax2,'on'); box(ax2,'on');
        ax2.FontSize = axisFontSize;  ax2.XColor = 'k'; ax2.YColor = 'k';

        thisLabel = subplotLabels{labelIdx};
        markerInLegendOnly = ismember(thisLabel, subplotsMarkerLegend);

        % (1) true curve
        plot(theta_true, gamma_true, 'k-', 'LineWidth',1, 'HandleVisibility','off');

        % (2) 선택 데이터
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

            % fill CI
            fill([theta_est; flipud(theta_est)], ...
                 [gamma_lower; flipud(gamma_upper)], ...
                 p_colors(cidx,:), 'FaceAlpha',fillAlpha,...
                 'EdgeColor','none','HandleVisibility','off');

            % mean curve
            plot(theta_est, gamma_avg, 'LineWidth',lineWidthValue,...
                 'Color',p_colors(cidx,:), 'HandleVisibility','off');

            % legend (첫 등장 시)
            if ~addedType(cidx)
                if markerInLegendOnly
                    plot(NaN,NaN,'LineWidth',lineWidthValue,'Color',p_colors(cidx,:),...
                         'Marker','s','MarkerFaceColor',p_colors(cidx,:),...
                         'DisplayName',legendLabels_dt{cidx});
                else
                    plot(NaN,NaN,'LineWidth',lineWidthValue,'Color',p_colors(cidx,:),...
                         'DisplayName',legendLabels_dt{cidx});
                end
                addedType(cidx) = true;
            end
        end
        % true (legend)
        plot(NaN,NaN,'k-','LineWidth',1,'DisplayName','True');

        xlabel('$\\theta = \\ln(\\tau\\,[\\mathrm{s}])$','Interpreter','latex',...
               'FontSize',axisFontSize);
        ylabel('$\\gamma~(\\Omega)$','Interpreter','latex',...
               'FontSize',axisFontSize);

        lgd2 = legend('Box','off','FontSize',legendFontSize);
        lgd2.ItemTokenSize = legendTokenManualList{labelIdx};
        set(lgd2,'Location','none','Units','normalized','Position',legendPosList{labelIdx});
        try
            lgd2.BoxFace.ColorType = 'truecoloralpha';
            lgd2.BoxFace.ColorData = uint8(255*[1;1;1;legendAlpha]);
        catch,  warning('Legend alpha not supported.');  end

        text(annotPos_b(1), annotPos_b(2), thisLabel,...
             'Units','normalized','FontSize',annotationFontSize,'FontWeight','bold');
        labelIdx = labelIdx + 1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % (C) Column #3 : dur effect
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ax3 = nexttile;  hold(ax3,'on'); box(ax3,'on');
        ax3.FontSize = axisFontSize;  ax3.XColor = 'k'; ax3.YColor = 'k';

        thisLabel = subplotLabels{labelIdx};
        markerInLegendOnly = ismember(thisLabel, subplotsMarkerLegend);

        % true curve
        plot(theta_true, gamma_true, 'k-', 'LineWidth',1,'HandleVisibility','off');

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
                 p_colors(cidx,:), 'FaceAlpha',fillAlpha,...
                 'EdgeColor','none','HandleVisibility','off');
            plot(theta_est, gamma_avg, 'LineWidth',lineWidthValue,...
                 'Color',p_colors(cidx,:), 'HandleVisibility','off');

            if ~addedType(cidx)
                if markerInLegendOnly
                    plot(NaN,NaN,'LineWidth',lineWidthValue,'Color',p_colors(cidx,:),...
                         'Marker','s','MarkerFaceColor',p_colors(cidx,:),...
                         'DisplayName',legendLabels_dur{cidx});
                else
                    plot(NaN,NaN,'LineWidth',lineWidthValue,'Color',p_colors(cidx,:),...
                         'DisplayName',legendLabels_dur{cidx});
                end
                addedType(cidx) = true;
            end
        end

        plot(NaN,NaN,'k-','LineWidth',1,'DisplayName','True');

        xlabel('$\\theta = \\ln(\\tau\\,[\\mathrm{s}])$','Interpreter','latex',...
               'FontSize',axisFontSize);
        ylabel('$\\gamma~(\\Omega)$','Interpreter','latex',...
               'FontSize',axisFontSize);

        lgd3 = legend('Box','off','FontSize',legendFontSize);
        lgd3.ItemTokenSize = legendTokenManualList{labelIdx};
        set(lgd3,'Location','none','Units','normalized','Position',legendPosList{labelIdx});
        try
            lgd3.BoxFace.ColorType = 'truecoloralpha';
            lgd3.BoxFace.ColorData = uint8(255*[1;1;1;legendAlpha]);
        catch,  warning('Legend alpha not supported.');  end

        text(annotPos_c(1), annotPos_c(2), thisLabel,...
             'Units','normalized','FontSize',annotationFontSize,'FontWeight','bold');
        labelIdx = labelIdx + 1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % (D) Column #4 : N effect
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ax4 = nexttile;  hold(ax4,'on'); box(ax4,'on');
        ax4.FontSize = axisFontSize;  ax4.XColor = 'k'; ax4.YColor = 'k';

        thisLabel = subplotLabels{labelIdx};
        markerInLegendOnly = ismember(thisLabel, subplotsMarkerLegend);

        % true curve
        plot(theta_true, gamma_true, 'k-', 'LineWidth',1,'HandleVisibility','off');

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
                 p_colors(cidx,:), 'FaceAlpha',fillAlpha,...
                 'EdgeColor','none','HandleVisibility','off');
            plot(theta_est, gamma_avg, 'LineWidth',lineWidthValue,...
                 'Color',p_colors(cidx,:), 'HandleVisibility','off');

            if ~addedType(cidx)
                if markerInLegendOnly
                    plot(NaN,NaN,'LineWidth',lineWidthValue,'Color',p_colors(cidx,:),...
                         'Marker','s','MarkerFaceColor',p_colors(cidx,:),...
                         'DisplayName',legendLabels_N{cidx});
                else
                    plot(NaN,NaN,'LineWidth',lineWidthValue,'Color',p_colors(cidx,:),...
                         'DisplayName',legendLabels_N{cidx});
                end
                addedType(cidx) = true;
            end
        end

        plot(NaN,NaN,'k-','LineWidth',1,'DisplayName','True');

        xlabel('$\\theta = \\ln(\\tau\\,[\\mathrm{s}])$','Interpreter','latex',...
               'FontSize',axisFontSize);
        ylabel('$\\gamma~(\\Omega)$','Interpreter','latex',...
               'FontSize',axisFontSize);

        lgd4 = legend('Box','off','FontSize',legendFontSize);
        lgd4.ItemTokenSize = legendTokenManualList{labelIdx};
        set(lgd4,'Location','none','Units','normalized','Position',legendPosList{labelIdx});
        try
            lgd4.BoxFace.ColorType = 'truecoloralpha';
            lgd4.BoxFace.ColorData = uint8(255*[1;1;1;legendAlpha]);
        catch,  warning('Legend alpha not supported.');  end

        text(annotPos_d(1), annotPos_d(2), thisLabel,...
             'Units','normalized','FontSize',annotationFontSize,'FontWeight','bold');
        labelIdx = labelIdx + 1;

    end  % ----- 시나리오 행 루프 끝 -----------------------------------------

    %% === 6) SAVE FIGURE (PNG + FIG) =======================================
    outName = ['CompareAll_3x4_' noiseTag];
    exportgraphics(gcf, [outName '.png'], 'Resolution',300);
    savefig(gcf, [outName '.fig']);
    % close(gcf);   % ← 주석 처리: Figure 창을 닫지 않고 남겨둠

end   % ----- 노이즈 레벨 루프 끝 --------------------------------------------


